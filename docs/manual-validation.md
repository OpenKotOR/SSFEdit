# Manual Validation

SSFEdit has no automated test suite in the current repo surface. When behavior changes, validation is a manual process anchored to the actual executable workflow and the binary files it reads and writes.

## Validation tiers

### Documentation-only changes

- Run `git diff --check`.
- Re-read any updated links and file references to confirm they still point at the right repo paths.
- If a doc makes behavior claims, verify those claims against the Pascal source rather than repeating assumptions.

### Source changes without serializer impact

Preferred path:

1. Build `USSFEdit.dpr` on a Windows host with Delphi 7.
2. Launch the app.
3. Exercise the directly affected workflow.
4. Confirm the UI still opens and the relevant dialogs/messages behave as expected.

Fallback on Linux or macOS:

- Static source review only, unless Wine is available and a previously built executable can be run.
- Treat the `.vscode` tasks and launch configurations as SSFEdit-specific helpers, but not as substitutes for direct source inspection or a real Windows Delphi 7 build.

### Serializer-sensitive changes

Use this tier when `USSFFile.pas`, `UTLKFile.pas`, or the direct SSF stream logic in `SSFEdit.pas` changes.

1. Build `USSFEdit.dpr` on Windows with Delphi 7.
2. Launch the app with a representative `.ssf` file, or use the new-file flow.
3. Load a representative `dialog.tlk` when prompted.
4. Confirm existing slot values render as expected in the grid.
5. Modify at least one existing slot `StrRef` and confirm the display refreshes.
6. If TLK write behavior changed, append a new TLK entry and confirm the selected slot receives the newly assigned `StrRef`.
7. Save the result.
8. Reopen the saved output and confirm the edited slot values and any appended TLK entry still resolve correctly.

## Suggested scenario coverage

### SSF load/save path

- Open a valid `.ssf` file and confirm the 40-slot grid populates.
- Save changes and reopen the output to confirm round-trip persistence.
- Confirm unset entries still appear as `-1` and `None`.

### TLK lookup path

- Load a valid `dialog.tlk` and confirm sound/text metadata resolves for populated slots.
- Check at least one slot whose TLK text contains line breaks to confirm the grid display remains normalized.

### TLK append path

- Add a new entry through the modal form.
- Confirm the app assigns the next TLK index to the selected slot.
- Save and reopen to confirm the appended TLK entry remains addressable by `StrRef`.

### New-file path

- Start a blank SSF file.
- Confirm all 40 slots initialize to the unset sentinel behavior.
- Save the new file and reopen it.

## What cannot be validated well in this repo today

- Native Linux or macOS builds
- Automated regression coverage
- Trustworthy editor tasks or launch configs for SSFEdit from the current `.vscode` folder

## Related documents

- `BUILD.md` for environment constraints
- `CONTRIBUTING.md` for contributor workflow
- `docs/file-formats.md` for serializer-adjacent invariants
- `docs/workflows.md` for the user-visible flows these checks exercise
