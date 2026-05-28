# SSFEdit Agent Guide

This repository contains a Delphi 7 VCL desktop editor for KotOR/TSL `.ssf` soundset files and the related `dialog.tlk` data they reference.

Start here:

- [README.md](README.md) for project overview and repo map.
- [wiki/Home.md](wiki/Home.md) in the top-level submodule for non-technical end-user documentation.
- [BUILD.md](BUILD.md) for build and runtime constraints.
- [ARCHITECTURE.md](ARCHITECTURE.md) for unit responsibilities and data flow.
- [CONVENTIONS.md](CONVENTIONS.md) for file-format and editing invariants.
- [CONTRIBUTING.md](CONTRIBUTING.md) for change and validation workflow.
- `docs/file-formats.md` for the deeper SSF/TLK reference.
- `docs/manual-validation.md` for workflow-specific validation steps.
- `docs/workflows.md` for user-flow to unit-ownership mapping.
- `docs/limitations.md` for legacy and tooling caveats.

High-value anchors:

- `docs/workflows.md`: main user-flow map for the legacy UI surface.
- `USSFEdit.dpr`: executable entrypoint and the only CLI handling.
- `USSFFile.pas`: reusable SSF v1.1 reader/writer.
- `UTLKFile.pas`: reusable TLK v3.0 reader/writer and linked-list storage.
- `UST_Common.pas` and `StoffeUtils.pas`: shared helpers used by the legacy code.

Working rules for agents:

- Preserve Delphi 7 compatibility. Avoid newer Delphi, Free Pascal, Lazarus-only, generic, or Unicode-only language features unless the user explicitly asks for a port.
- Treat `wiki/` as the end-user manual surface. Keep contributor/reference material in the main repo docs unless the user explicitly asks to restructure that split.
- Treat the SSF layout as fixed-width: 40 entries, 1-indexed arrays, and `$FFFFFFFF` as the unset sentinel.
- Keep the hardcoded label order aligned across UI and file handling code.
- Treat TLK string indices as position-based. Appending is safe; deleting or reordering existing entries is not.
- `.dfm` and `.res` files in this repo are binary assets, not text-form forms/resources.
- `.vscode/tasks.json`, `.vscode/launch.json`, `.vscode/settings.json`, and `.vscode/extensions.json` are now aligned to SSFEdit, but the Pascal sources and the root docs remain authoritative if tooling metadata ever drifts again.
- The tracked repo surface does not include the legacy UI form units, so user-facing workflow wording should be anchored to `docs/workflows.md`, the wiki pages, and the tracked serializer/entrypoint files.

Validation expectations:

- For documentation-only edits, run `git diff --check`.
- For wiki-submodule changes, also run `git diff --check` inside `wiki/` and verify that the main repo stages the updated submodule pointer intentionally.
- For `.vscode` metadata edits, validate changed JSON files, run `git diff --check`, and cross-check task or launch behavior claims against `USSFEdit.dpr` and the root docs.
- For Pascal source edits, prefer a Delphi 7 build on Windows. Linux can only do static validation unless Wine is used to run an already-built executable.
- There is no automated test suite in the current repo surface; if serializer logic changes, validate the relevant load/save path explicitly.
