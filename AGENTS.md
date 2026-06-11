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
- Check git status before editing.
- Keep diffs small and reviewable.

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
5. Play ~/projects/magic-doorbell.wav when finished.
