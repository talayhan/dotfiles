#!/usr/bin/env bash
#
# Verify a completed install: every link in the composed manifest for the given
# platform must exist in $HOME, be a symlink, and point at a real file in the
# repo.
#
#   ./tests/verify_install.sh <platform>
#
# Exits non-zero and prints every failure, rather than stopping at the first.

set -u

PLATFORM="${1:?usage: verify_install.sh <platform>}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

failures=0
checked=0
skipped=0

fail() { echo -e "${RED}[FAIL]${NC} ${1}"; failures=$((failures + 1)); }
pass() { echo -e "${GREEN}[ ok ]${NC} ${1}"; }
skip() { echo -e "${YELLOW}[skip]${NC} ${1}"; skipped=$((skipped + 1)); }

# Pull "destination<TAB>source" pairs out of the composed manifest. The manifest
# is generated, so the shape is known: link entries are two-space indented
# "~/dest: source" lines, and extended entries put the source on a "path:" line.
#
# Deliberately no `mapfile` here: macOS still ships bash 3.2.
entries=()
while IFS= read -r line; do
    entries+=("${line}")
done < <(
    "${REPO}/install" -n -p "${PLATFORM}" | awk '
        /^- link:/            { in_link = 1; next }
        /^- / && !/^- link:/  { in_link = 0 }
        !in_link              { next }
        /^      path: /       { sub(/^      path: /, ""); print pending "\t" $0; pending = ""; next }
        /^    [^ #].*:[ ]*$/  { line = $0; sub(/^    /, "", line); sub(/:[ ]*$/, "", line); pending = line; next }
        /^    [^ #].*: .+/    {
            line = $0; sub(/^    /, "", line)
            idx = index(line, ": ")
            print substr(line, 1, idx - 1) "\t" substr(line, idx + 2)
        }
    '
)

if [ "${#entries[@]}" -eq 0 ]; then
    echo "No link entries parsed from the manifest for '${PLATFORM}'." >&2
    exit 1
fi

echo "Verifying ${#entries[@]} link entries for platform '${PLATFORM}'"
echo

for entry in "${entries[@]}"; do
    dest="${entry%%$'\t'*}"
    src="${entry##*$'\t'}"

    expanded_dest="${dest/#\~/${HOME}}"
    expected_src="${REPO}/${src}"

    # Entries guarded by an `if:` in the manifest (currently the private
    # pconfigs submodule) are legitimately absent when the source is not there.
    if [ ! -e "${expected_src}" ]; then
        skip "${dest} -> ${src} (source not present)"
        continue
    fi

    checked=$((checked + 1))

    if [ ! -L "${expanded_dest}" ]; then
        if [ -e "${expanded_dest}" ]; then
            fail "${dest} exists but is not a symlink"
        else
            fail "${dest} was not created"
        fi
        continue
    fi

    actual="$(readlink "${expanded_dest}")"
    # dotbot canonicalizes, so compare resolved paths.
    if [ "$(cd "$(dirname "${actual}")" 2>/dev/null && pwd -P)/$(basename "${actual}")" \
         != "$(cd "$(dirname "${expected_src}")" && pwd -P)/$(basename "${expected_src}")" ]; then
        fail "${dest} points at '${actual}', expected '${expected_src}'"
        continue
    fi

    if [ ! -e "${expanded_dest}" ]; then
        fail "${dest} is a broken symlink"
        continue
    fi

    pass "${dest} -> ${src}"
done

echo
echo "checked: ${checked}   skipped: ${skipped}   failed: ${failures}"

# macOS must never receive the X11 layer.
if [ "${PLATFORM}" = "macos" ]; then
    for x11 in "${HOME}/.Xresources" "${HOME}/.gtkrc-2.0" "${HOME}/.fonts" "${HOME}/.i3"; do
        if [ -L "${x11}" ]; then
            fail "X11 entry ${x11} was linked on macOS"
        fi
    done
    if [ ! -L "${HOME}/Library/Fonts" ]; then
        fail '$HOME/Library/Fonts was not linked on macOS'
    fi
fi

exit $(( failures > 0 ? 1 : 0 ))
