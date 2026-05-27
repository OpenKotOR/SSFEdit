# Workflows

This document maps the main user-facing actions in SSFEdit to the units that own them. Use it when deciding where a change belongs before modifying code.

## Startup and optional CLI open

### Startup behavior

- The app starts the main form and the modal entry form.
- If the first CLI argument is an existing `.ssf` path, the app attempts to load it immediately.

### Startup ownership

- `USSFEdit.dpr` initializes the application, creates both forms, and handles the optional first CLI argument.
- `SSFEdit.pas` provides `LoadFile`, which executes the actual load flow.

## TLK selection before editing

### TLK selection behavior

- The app asks for `dialog.tlk` before it can load an SSF file or create a new one.
- If no TLK file is selected, the operation aborts with a warning.

### TLK selection ownership

- `SSFEdit.pas` manages the TLK-open dialog, the `l_tlkloaded` state flag, and the abort paths for missing TLK input.
- `UTLKFile.pas` owns the TLK file parsing once a path is chosen.

## Open an existing SSF file

### Existing-file open behavior

- The app opens a soundset file, validates its format, reads all 40 slot values, and displays their resolved TLK sound/text metadata in the grid.

### Existing-file open ownership

- `SSFEdit.pas`
  - `Button1Click` drives the interactive open-file flow.
  - `LoadFile` drives the startup autoload flow.
  - `RefreshGrid` and `GetTlkString` populate the visible grid content.
- `UTLKFile.pas` provides TLK resolution data.
- `USSFFile.pas` contains a reusable SSF reader, but the main form currently performs its own SSF stream reads instead of delegating to it.

## Create a new SSF file

### New-file behavior

- The app initializes a blank 40-slot soundset after a TLK file has been selected.
- Every slot starts unset.

### New-file ownership

- `SSFEdit.pas`
  - `btnNewClick` owns the new-file flow.
  - `RefreshGrid` rebuilds the blank grid state.

## Edit an existing slot value

### Slot-edit behavior

- Selecting a row enables editing controls.
- Updating the `StrRef` and clicking modify rewrites the in-memory slot value and refreshes the display.

### Slot-edit ownership

- `SSFEdit.pas`
  - `gridSndClick` updates the selected-row UI.
  - `btnModifyClick` applies the edited `StrRef` to `l_entries`.
  - `edStrRefKeyPress` restricts input to numeric-compatible edit operations.

## Append a new TLK entry

### TLK append behavior

- The user opens a modal dialog, enters text and a sound resref, and saves.
- The app appends a new TLK entry and assigns its new `StrRef` to the currently selected SSF slot.

### TLK append ownership

- `UEntryForm.pas` owns the modal input form.
- `SSFEdit.pas`
  - `btnAddTlkClick` owns the append workflow.
  - It converts the entered resref into a fixed 16-byte buffer, sets TLK flags, normalizes text, appends the entry, and updates the selected slot.
- `UTLKFile.pas`
  - `AddEntry` appends the new TLK record and increments `StringCount`.

## Save modified data

### Save behavior

- If TLK data was modified, the app prompts to save the TLK file first.
- The app then prompts to save the SSF file.

### Save ownership

- `SSFEdit.pas`
  - `btnSaveClick` owns the save flow and save prompts.
  - The main form writes SSF bytes directly.
- `UTLKFile.pas`
  - `SaveTlkFile` writes the full TLK structure.
- `UST_Common.pas` and local message-box helpers support prompts and writable-file behavior.

## Where to change what

- Change `USSFEdit.dpr` when the startup, CLI, or form creation behavior changes.
- Change `SSFEdit.pas` when the main UI flow, grid behavior, or save/open orchestration changes.
- Change `USSFFile.pas` when the reusable SSF serializer changes.
- Change `UTLKFile.pas` when TLK parsing, writing, or append semantics change.
- Change `UEntryForm.pas` when the add-entry modal itself changes.
- Change `UST_Common.pas` or `StoffeUtils.pas` only when a shared helper behavior actually belongs there.

## Related documents

- `ARCHITECTURE.md` for the unit map and runtime flow
- `docs/file-formats.md` for SSF and TLK structure details
- `docs/manual-validation.md` for the checks to run after workflow changes
