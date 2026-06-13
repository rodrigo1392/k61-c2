# AGENTS.md

## Purpose

Configure and compile zmk firmware for the Keyball61 bluetooth keyboard.

## Rules:

- Make minimal changes.
- Do not modify unrelated files.
- Preserve existing keymaps and overlays.
- Explain risky firmware changes before applying them.
- Use github actions to compile firmware and build svg.
- Do not compile anything locally.
- Do not install tools without approval.
- Do not review the generated SVG image.
- Do not review commits.
- Check git status before editing.
- Keep diffs small and reviewable.

Current user instructions:

- Do not review the generated SVG image.
- Do not review commits.

Build workflow:

- Development host: WSL2
- Build remotely.
- Build host: github actions
- Artifact: UF2 firmware

Success criteria:
- Requested change implemented.
- Clean build.
- Small, understandable diff.

Stack:
- Language: C, Devicetree, Kconfig
- Framework: ZMK Firmware
- Build system: West
- RTOS: Zephyr

Important files:
- config/*.keymap
- config/*.conf
- config/*.overlay
- build.yaml

Firmware behavior quick path:

- Always read `config/keyball61.keymap` before changing key behavior. It defines
  layer numbers, layer order, behaviors, macros, and key bindings.
- Read `config/boards/shields/keyball61/keyball61_right.overlay` when changing
  trackball behavior or layer numbers. It references layer numbers for
  `automouse-layer`, `scroll-layers`, `snipe-layers`, and `trackball_lock`.
- Read `config/boards/shields/keyball61/keyball61_right.conf` when changing
  PMW3610, mouse, studio, power, sleep, or polling behavior.
- Read `config/keyball61.conf` when changing shared ZMK, Bluetooth, split,
  display, behavior queue, or power behavior.
- Read `build.yaml` when changing which firmware artifacts GitHub Actions
  builds.
- Usually do not read `vault/`, generated SVG files, or historical docs unless
  the user asks for history or a previous firmware artifact.

Firmware behavior edit checklist:

- Keep layer `#define` values consistent with the order of layer nodes inside
  `config/keyball61.keymap`.
- When renumbering `MOUSE`, `SCROLL`, `SNIPE`, `TRACKBLESS`, or `BLOCKED`,
  update matching numeric references in
  `config/boards/shields/keyball61/keyball61_right.overlay`.
- After edits, check every layer still has 61 bindings.
- Do not compile locally; use GitHub Actions for build validation.

## Script Style

If Python or Bash scripts are modified:

Follow the canonical scripting guides defined in the user's personal standards. Apply the full scripting guide only to standalone CLI scripts. For helper scripts and automation fragments, apply the principles but not necessarily the full CLI structure.

## Documentation

Repository-specific knowledge:

* AGENTS.md
* docs/adr/

## ADR Policy

Create one ADRs only for major changes, not for small adjustments. Explain:

* keyboard behavior changes: layers, key assignment, logic changes, combinations
* scripts that control flow of compiling and flashing

## Before Finishing

Summarize:

1. What changed.
2. Why it changed.
3. How it was validated.
4. Documentation created or modified.
5. Run ~/.local/bin/codex-done-sound when finished.
