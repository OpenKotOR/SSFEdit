# Architecture

## Overview

SSFEdit is a small desktop editor with one main form, one modal entry form, and two reusable binary file handlers. The main form owns most of the user workflow and uses TLK lookups to decorate SSF slot values with sound and text metadata.

## Units and responsibilities

### Application layer

- `USSFEdit.dpr`
  - Initializes the VCL application.
  - Creates `TForm1` from `SSFEdit.pas` and `TEntryForm` from `UEntryForm.pas`.
  - Accepts an optional first CLI argument and passes it to `Form1.LoadFile(...)` when it is an existing `.ssf` path.

- `SSFEdit.pas`
  - Defines the main form `TForm1`.
  - Maintains the 40 entry labels and current SSF slot values.
  - Loads the TLK file, reads SSF data into the grid, updates `StrRef` values, appends new TLK entries, and writes files on save.

- `UEntryForm.pas`
  - Defines the modal dialog used when appending a brand-new TLK entry.
  - Captures text plus a 16-character sound resource reference.

### File-format layer

- `USSFFile.pas`
  - Encapsulates SSF v1.1 reading and writing.
  - Treats an SSF as 40 fixed-width `DWORD` entries after the `'SSF '` / `'V1.1'` header.
  - Stores slot values in a 1-indexed array with a hardcoded label map.

- `UTLKFile.pas`
  - Encapsulates TLK v3.0 reading and writing.
  - Stores entries in a linked list (`TStringDataList`).
  - Supports appending new TLK entries and rewriting the full TLK file.

### Shared helper layer

- `UST_Common.pas`
  - User dialogs, numeric/string helpers, file writable/backup helpers, shell helpers.

- `StoffeUtils.pas`
  - Minimal legacy utility functions retained for string replacement and offset-based search.

## Runtime flow

1. `USSFEdit.dpr` starts the app and creates both forms.
2. If the first CLI argument is an existing `.ssf` path, `TForm1.LoadFile` is called during startup.
3. The main form prompts for `dialog.tlk` if one is not already loaded.
4. The app reads SSF slot values and stores them in `l_entries[1..40]`.
5. For each non-empty slot, `GetTlkString` resolves the slot's `StrRef` to TLK text and sound metadata for display in the grid.
6. The user either edits a `StrRef` directly or uses the modal entry form to append a new TLK entry and assign its new `StrRef` to the selected slot.
7. On save, the app writes modified TLK data first when needed, then writes the SSF file.

## Data model invariants

For field-level format details, see `docs/file-formats.md`.

### SSF

- Magic: `'SSF '`
- Version: `V1.1`
- Entry count: exactly 40
- Entry type: `DWORD`
- Empty slot sentinel: `$FFFFFFFF`
- UI presentation of empty slot: `-1`

### TLK

- Magic: `'TLK '`
- Version: `V3.0`
- Entry identity: position-based `StrRef`
- New entries are appended, not inserted into the middle
- Sound resource references are stored as fixed 16-character `TResRef` arrays with null padding

## Important implementation detail

The repo contains a reusable `TSSFFile` class in `USSFFile.pas`, but the main form in `SSFEdit.pas` currently performs its own SSF stream reading and writing instead of delegating to that class. Any serializer changes should account for both paths unless the code is first consolidated.

For workflow-to-unit ownership, see `docs/workflows.md`.

## Known drift and risk areas

- The window form files (`.dfm`) in this repo are binary, so UI changes are harder to diff and review than text-form forms.
- The `.vscode` workspace files now mirror the SSFEdit repo surface, but they are still convenience metadata rather than the source of truth.
- The repository currently has no commit history on `main`, so the source files themselves are the only trustworthy project history available in-repo.
