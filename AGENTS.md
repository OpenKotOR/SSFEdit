# SSFEdit Agent Guide

This repository contains a Delphi 7 VCL desktop editor for KotOR/TSL `.ssf` soundset files and the related `dialog.tlk` data they reference.

Start here:

- [README.md](README.md) for project overview and repo map.
- [BUILD.md](BUILD.md) for build and runtime constraints.
- [ARCHITECTURE.md](ARCHITECTURE.md) for unit responsibilities and data flow.
- [CONVENTIONS.md](CONVENTIONS.md) for file-format and editing invariants.
- [CONTRIBUTING.md](CONTRIBUTING.md) for change and validation workflow.
- `docs/file-formats.md` for the deeper SSF/TLK reference.
- `docs/manual-validation.md` for workflow-specific validation steps.
- `docs/workflows.md` for user-flow to unit-ownership mapping.
- `docs/limitations.md` for legacy and tooling caveats.

High-value anchors:

- `USSFEdit.dpr`: executable entrypoint and the only CLI handling.
- `SSFEdit.pas`: main form, grid UI, file-open/new/save flow, TLK lookup, and add-entry workflow.
- `USSFFile.pas`: reusable SSF v1.1 reader/writer.
- `UTLKFile.pas`: reusable TLK v3.0 reader/writer and linked-list storage.
- `UEntryForm.pas`: modal for creating a new TLK entry.
- `UST_Common.pas` and `StoffeUtils.pas`: shared helpers used by the legacy code.

Working rules for agents:

- Preserve Delphi 7 compatibility. Avoid newer Delphi, Free Pascal, Lazarus-only, generic, or Unicode-only language features unless the user explicitly asks for a port.
- Treat the SSF layout as fixed-width: 40 entries, 1-indexed arrays, and `$FFFFFFFF` as the unset sentinel.
- Keep the hardcoded label order aligned across UI and file handling code.
- Treat TLK string indices as position-based. Appending is safe; deleting or reordering existing entries is not.
- `.dfm` and `.res` files in this repo are binary assets, not text-form forms/resources.
- `.vscode/tasks.json`, `.vscode/launch.json`, and the file nesting patterns currently describe `TSLPatcher`, not `SSFEdit`. They are not authoritative documentation for this repo.

Validation expectations:

- For documentation-only edits, run `git diff --check`.
- For Pascal source edits, prefer a Delphi 7 build on Windows. Linux can only do static validation unless Wine is used to run an already-built executable.
- There is no automated test suite in the current repo surface; if serializer logic changes, validate the relevant load/save path explicitly.
