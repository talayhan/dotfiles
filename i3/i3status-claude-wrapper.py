#!/usr/bin/env python3
"""Wraps i3status, injecting a Claude Code usage block as the first block
in the i3bar JSON stream. Point the i3 `bar { status_command ... }` at
this script instead of calling i3status directly.

Primary source: ~/.cache/claude-ratelimit.json, written by
~/.claude/ratelimit-tap.sh (sits in front of the real statusLine command)
every time Claude Code renders its terminal status line. Gives real
session (5h) / weekly (7d) rate-limit usage percentages and reset times,
straight from the Anthropic account API.

Fallback (no cache yet, e.g. no Claude Code session run since login):
local cost/burn-rate estimate from `ccusage`.
"""
import json
import os
import shutil
import subprocess
import sys
import time

CCUSAGE = shutil.which("ccusage") or os.path.expanduser("~/.local/bin/ccusage")
RATELIMIT_CACHE = os.path.expanduser("~/.cache/claude-ratelimit.json")


def format_duration(seconds):
    seconds = int(seconds)
    if seconds <= 0:
        return "now"
    days, rem = divmod(seconds, 86400)
    hours, rem = divmod(rem, 3600)
    minutes, _ = divmod(rem, 60)
    if days:
        return f"{days}d{hours}h"
    if hours:
        return f"{hours}h{minutes}m"
    return f"{minutes}m"


def rate_limit_block():
    with open(RATELIMIT_CACHE) as f:
        data = json.load(f)
    now = time.time()
    parts = []
    for label, key in (("5h", "five_hour"), ("7d", "seven_day")):
        window = data.get(key) or {}
        pct = window.get("used_percentage")
        if pct is None:
            continue
        resets_at = window.get("resets_at") or now
        parts.append(f"{label} {round(pct)}% (↻{format_duration(resets_at - now)})")
    if not parts:
        return None
    return {"name": "claude_usage", "full_text": "CC " + " | ".join(parts)}


def cost_estimate_block():
    try:
        out = subprocess.run(
            [CCUSAGE, "blocks", "--active", "--json"],
            capture_output=True, text=True, timeout=3,
        )
        data = json.loads(out.stdout)
        blocks = data.get("blocks", [])
        if not blocks:
            return {"name": "claude_usage", "full_text": "CC: idle"}
        b = blocks[0]
        cost = b.get("costUSD", 0.0)
        rate = b.get("burnRate", {}).get("costPerHour", 0.0)
        return {
            "name": "claude_usage",
            "full_text": f"CC: ${cost:.2f} (${rate:.2f}/hr)",
        }
    except Exception:
        return {"name": "claude_usage", "full_text": "CC: n/a"}


def claude_usage_block():
    try:
        block = rate_limit_block()
        if block is not None:
            return block
    except Exception:
        pass
    return cost_estimate_block()


def main():
    proc = subprocess.Popen(
        ["i3status"], stdout=subprocess.PIPE, text=True, bufsize=1,
    )

    # Pass through the two i3bar protocol header lines unchanged:
    # {"version":1}
    # [
    sys.stdout.write(proc.stdout.readline())
    sys.stdout.write(proc.stdout.readline())
    sys.stdout.flush()

    for line in proc.stdout:
        line = line.strip()
        prefix = ""
        if line.startswith(","):
            prefix, line = ",", line[1:]
        try:
            blocks = json.loads(line)
        except json.JSONDecodeError:
            continue
        blocks.insert(0, claude_usage_block())
        sys.stdout.write(f"{prefix}{json.dumps(blocks)}\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
