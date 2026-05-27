# SSFEdit

SSFEdit is a Delphi 7 VCL desktop utility for inspecting and editing KotOR/TSL soundset definition files (`.ssf`). Each `.ssf` entry points to a `StrRef` in `dialog.tlk`, and the application resolves that reference to both the spoken sound resource name and the display text shown in the grid.

The source of truth in this repository is the Pascal code, not the current VS Code tasks. The repo contains committed Windows executables and binary form/resource artifacts, but the canonical source entrypoint is `USSFEdit.dpr`.

## What the app does

- Opens an existing `.ssf` file or starts a new blank one.
- Prompts for a `dialog.tlk` file before SSF editing begins.
- Displays the fixed set of 40 soundset slots used by the game.
- Lets the user replace a slot's `StrRef` directly.
- Lets the user append a brand-new TLK entry and assign that new `StrRef` to the selected slot.
- Saves modified TLK data first, then writes the updated SSF file.

## Repo map

- `USSFEdit.dpr`: application startup and optional CLI autoload of a `.ssf` path.
- `SSFEdit.pas`: main window and user workflow.
- `USSFFile.pas`: SSF v1.1 serializer/deserializer.
- `UTLKFile.pas`: TLK v3.0 serializer/deserializer.
- `UEntryForm.pas`: modal dialog for adding a TLK entry.
- `UST_Common.pas`, `StoffeUtils.pas`: legacy helper utilities.

## Documentation index

- [BUILD.md](BUILD.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [CONVENTIONS.md](CONVENTIONS.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [AGENTS.md](AGENTS.md)
- [docs/file-formats.md](docs/file-formats.md)
- [docs/manual-validation.md](docs/manual-validation.md)
- [docs/workflows.md](docs/workflows.md)
- [docs/limitations.md](docs/limitations.md)

## Current repo state

- The repo surface is small and self-contained. There is no automated test suite and no existing project documentation besides the Delphi project metadata.
- The checked-in `.vscode` tasks and launch configs currently target a different Delphi project named `TSLPatcher`; treat them as workspace drift until they are rewritten for SSFEdit.
- `.gitignore` currently excludes several artifact types that are nevertheless present in the working tree, including `.exe`, `.cfg`, `.dfm`, and `.res`. Be explicit when intentionally changing those files.

For deeper operational detail, use the topic docs under `docs/` rather than expanding the root files as ad hoc catch-alls.

## Quick start

### Windows

1. Open `USSFEdit.dpr` in Delphi 7.
2. Build the project.
3. Launch the resulting executable, optionally with a `.ssf` path as the first argument.

### Linux or macOS

There is no native build path in the current repo. If Wine is available, you can run an existing Windows build from the workspace root, for example:

```bash
wine ./USSFEdit.exe
```

or:

```bash
wine ./SSFEdit.exe
```

At runtime the app will still prompt for `dialog.tlk` before it can load or create SSF content.
