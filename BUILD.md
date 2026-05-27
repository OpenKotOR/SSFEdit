# Build and Runtime Notes

## Source of truth

The canonical project entrypoint is `USSFEdit.dpr`. The project metadata in `USSFEdit.dof` identifies the tool as SSFEdit version `0.3.3a`.

## Supported build environment

- Primary build target: Windows
- Expected compiler generation: Delphi 7 / `dcc32.exe`
- UI framework: classic VCL forms
- Current repo surface does not provide a working cross-platform build configuration

## Build from source on Windows

From a Delphi 7 command prompt in the repository root:

```bat
dcc32.exe USSFEdit.dpr
```

You can also open `USSFEdit.dpr` directly in the Delphi IDE and build from there.

Notes:

- Some developer worktrees may contain both `SSFEdit.exe` and `USSFEdit.exe` as ignored local build outputs. Treat those as convenience artifacts when present, not the source of truth.
- `USSFEdit.cfg` and `USSFEdit.dof` contain compiler and version settings used by the project.

## Run an existing build on Linux or macOS

If Wine is installed and a local Windows executable is available, it can be launched manually:

```bash
wine ./USSFEdit.exe
```

or:

```bash
wine ./SSFEdit.exe
```

The application optionally accepts a single CLI argument. If the first argument exists on disk and ends with `.ssf` case-insensitively, the main form attempts to autoload it on startup.

## Runtime prerequisites

- A valid `.ssf` file for editing, or use the app's new-file flow.
- A valid `dialog.tlk` file. The application prompts for it before loading or creating SSF data.

## Validation limits in the current repo

- There is no automated test suite.
- The `.vscode/tasks.json` and `.vscode/launch.json` files are aligned to SSFEdit, but Windows Delphi 7 build behavior and the Pascal entrypoint remain the authoritative references.
- `.gitignore` excludes `.exe`, `.cfg`, `.dfm`, and `.res`, even though files of those types may already exist in a local worktree. If you intentionally update tracked artifacts or rely on local ignored ones, stage and summarize them deliberately.

See `docs/manual-validation.md` for the workflow-specific checks to run after source or serializer changes.

## Suggested manual validation after code changes

1. Build `USSFEdit.dpr` on a Windows host with Delphi 7.
2. Launch the app with a representative `.ssf` file.
3. Load the relevant `dialog.tlk`.
4. Modify an existing slot.
5. If TLK-writing code changed, add a new TLK entry and confirm the new `StrRef` is assigned to the selected slot.
6. Save and reopen the output file to confirm round-trip behavior.
