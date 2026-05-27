# Runtime Authority Map

## Current Runtime Owners

- [REPO] `USSFEdit.dpr` initializes the VCL application, creates both forms, and handles the only CLI surface: an optional existing `.ssf` path.
- [REPO] `SSFEdit.pas` owns TLK selection, SSF load/new flows, grid refresh, direct `StrRef` edits, TLK append, and save orchestration.
- [REPO] `UTLKFile.pas` owns TLK parsing, full-file rewrite, and append-at-end entry creation.
- [REPO] `USSFFile.pas` owns a reusable SSF serializer, but the main form still performs direct SSF stream IO instead of delegating to it.

## Authority Order

- [REPO] The maintained root docs and Pascal source are the primary authority surfaces.
- [REPO] `.vscode/tasks.json`, `.vscode/launch.json`, `.vscode/settings.json`, and `.vscode/extensions.json` are SSFEdit-specific convenience metadata.
- [SYNTH] When runtime or launch claims differ, check `USSFEdit.dpr`, `SSFEdit.pas`, and the root docs before trusting editor wrappers or historical plan text.

## Source vs Runtime Parity Notes

- [REPO] The app must have a TLK file before opening or creating SSF content.
- [REPO] The save flow writes modified TLK data first, then the SSF file.
- [REPO] The runtime contract is duplicated for SSF handling because both `SSFEdit.pas` and `USSFFile.pas` know the SSF layout.
- [OPEN] Current source-to-binary parity is not fully proven from this Linux environment, because the authoritative build path is still Windows Delphi 7.

## Failure and Fallback Behavior

- [REPO] Missing TLK input aborts open/new workflows instead of allowing partial editing.
- [REPO] Linux and macOS are fallback review environments unless Wine can run an already-built Windows executable.
- [SYNTH] The highest-risk maintenance path is changing SSF behavior in only one of the two SSF code paths.

## Verification Path

- [REPO] Use `docs/manual-validation.md` for workflow checks after source edits.
- [REPO] Use `BUILD.md` for the authoritative build and runtime split.
- [SYNTH] Treat serializer changes as a two-surface verification problem: reusable serializer units plus main-form orchestration.
