@RTK.md

# Talayhan's agent instructions

These are common instructions for Talayhan's agents across all scenarios.

## General Guidelines

* Never use the em dash "—". Use plain dash "-" instead
* When writing commit messages, NEVER auto-add your agent name as co-author
* Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
* When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
* When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
* When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end use
  This makes sure you find the real problem so your fix will actually solve it.
* When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along
* Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.

## HTML Generation & UI Spec

- **Aesthetic**: Apple minimalist (Linear/Vercel/Notion). Maximize whitespace/alignment; avoid decorative effects.
- **Fonts**: `-apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", sans-serif`. Weight/size defines hierarchy.
- **Palette**: Accent `#147EFF` (Apple Blue). Text: `#1D1D1F` (Primary), `#6E6E73` (Secondary). BG: `#FFFFFF`, `#F5F5F7`, `#FAFAFA`.
- **Status Cues**: Success `#34C759`, Error `#FF3B30`. **CRITICAL**: Never use purple. No rainbow/saturated palettes.
- **Layout & FX**: 8px spacing system. Cards: 20px radius, no shadows, subtle borders. No heavy gradients or glassmorphism.
- **Motion**: Subtle hover/transitions (`150–300ms`, `ease`/`ease-in-out`). No flashing/distracting motion.
- **HTML/UX Constraints**: Mobile-first responsive. Semantic, accessible markup with contrast verification. **NO EMOJIS**.
- **Architecture Docs**: Add Sequence, UML, and Component diagrams (showing components/actors) whenever applicable. Use mermaid format always.
- **Enterprise Callouts**: White BG, 18px radius, thin dashed accent border, airy padding, no shadow. 
  - *Layout*: Left icon (filled accent circle, white glyph) | thin vertical divider | Right content.
  - *Text*: Accent uppercase 14px eyebrow, 30px bold title, 18px gray body. 
  - *Hover*: Solid border, subtle accent tint BG (`#F8FAFF`), 200ms ease. Swap accent color for success/warning variants.
- **Workflows**: Use Gerrit style for code diffs. Upon generating/saving an HTML page, immediately trigger the tool to open it in Safari without prompting.
- **Code Snippets in HTML**: Render all code in real `<pre><code>` blocks - never `<div>`s (they collapse newlines/indentation).
  - *No wrapping*: `white-space: pre` with horizontal scroll on overflow (Gerrit style). Never wrap lines.
  - *Syntax highlighting*: Always apply it. Use highlight.js (GitHub theme) with the correct `language-*` class per snippet.
  - *Gerrit-style panels*: Each block gets a header bar showing file + line (e.g. `path/to/file.go · go · L2265`) and a colored left border - red for buggy/current code, green for the suggested fix. Preserve source indentation exactly.
  - *Inline refs*: Style inline code identifiers (e.g. `currentUser.IsActive`) as monospace chips.
