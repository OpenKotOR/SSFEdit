# Conventions and Invariants

## Language and platform expectations

- Write for Delphi 7-era Object Pascal and classic VCL.
- Prefer existing language patterns used in the repo: manual stream IO, Pascal classes, explicit `try/finally`, and direct dialog handling.
- Do not assume Unicode strings, generics, advanced RTTI, or later Delphi helper APIs are available.

## Naming and structure

- Most units use a `U` prefix (`USSFFile`, `UTLKFile`, `UEntryForm`, `UST_Common`), while the main form unit is `SSFEdit.pas`.
- Primary form class names follow Delphi VCL conventions (`TForm1`, `TEntryForm`).
- The project is small enough that behavior is often localized to a single unit; follow the owning unit instead of introducing cross-cutting abstractions by default.

## File-format rules that must stay true

See `docs/file-formats.md` for the code-grounded reference behind these rules.

- SSF editing assumes a fixed 40-slot soundset layout.
- Slot arrays are 1-indexed, not 0-indexed.
- `$FFFFFFFF` is the unset SSF value; the UI renders it as `-1`.
- TLK `StrRef` values are position-based. Appending is safe; deleting or reindexing existing entries changes the meaning of every following entry.
- TLK sound resource references use a fixed 16-byte `TResRef` buffer with null padding.

## UI and workflow conventions

- The grid is the central editing surface and is rebuilt from current in-memory state by `RefreshGrid`.
- Empty SSF entries display as `None` in the sound/text columns.
- The app strips carriage returns and line feeds when showing TLK text in the grid, but preserves text data for TLK writing.
- The new-entry workflow appends a TLK entry and immediately assigns its new `StrRef` to the currently selected SSF slot.

## Error handling conventions

- The main form favors message boxes for user-facing errors.
- Reusable file handlers raise exceptions (`ESSFError`, `EHell`) rather than showing UI directly.
- Existing code uses `try/finally` for stream cleanup and targeted `except` blocks for user-facing alerts.

## Repository-specific pitfalls

- `.dfm` and `.res` are binary files in this repo. Treat them as deliberate assets, not text files.
- `.gitignore` excludes `.exe`, `.cfg`, `.dfm`, and `.res`, even though files of those types already exist in the working tree. Be careful not to assume that a modified tracked artifact will be obvious during staging.
- `.vscode/settings.json` contains file nesting patterns for `TSLPatcher`, not for SSFEdit.
- The source tree currently has no in-repo commit history, so avoid inferring undocumented conventions from git blame or logs.
