# Limitations and Caveats

This repository is a small legacy Delphi tool. Some constraints are part of its current operating model, not accidental omissions.

## Build and platform constraints

- The authoritative build environment is Windows with Delphi 7.
- The current repo does not provide a native Linux or macOS build path.
- On non-Windows hosts, the practical runtime path is Wine plus an already-built Windows executable.

## Binary asset boundaries

- `.dfm` files in this repo are binary form assets.
- `.res` files in this repo are binary resource assets.
- These files should not be treated like text-form forms/resources, and they are harder to diff and review than plain text sources.

## Validation limits

- There is no automated test suite in the current repo surface.
- Serializer-sensitive changes require explicit manual load/save validation.
- Static review is the only broadly available validation path on Linux unless Wine and a previously built executable are available.

## Tooling limits in the workspace

- `.vscode/tasks.json`, `.vscode/launch.json`, `.vscode/settings.json`, and `.vscode/extensions.json` are aligned to SSFEdit.
- They remain convenience-layer metadata, not the primary source of truth for build, CLI, or runtime behavior.
- On non-Windows hosts, launch flows still depend on Wine and an already-built Windows executable.

## Repository-history limits

- The current `main` branch has no commit history in this checkout.
- Git archaeology is therefore not a trustworthy source of intent here.
- The Pascal sources and the repository docs are the primary evidence surfaces.

## File-handling caveats

- `.gitignore` excludes `.exe`, `.cfg`, `.dfm`, and `.res` even though files of those types are already present in the repo surface.
- If you intentionally modify tracked artifacts of those types, stage and summarize them deliberately.

## Format safety caveats

- SSF layout is fixed to 40 entries.
- SSF slot arrays are 1-indexed in the code.
- `$FFFFFFFF` is the unset SSF sentinel.
- TLK `StrRef` values are position-based, so deleting or reordering existing entries is unsafe.

## Related documents

- `BUILD.md` for the supported build/runtime story
- `CONTRIBUTING.md` for contributor workflow
- `CONVENTIONS.md` for editing invariants
- `docs/file-formats.md` for serializer-level details
- `docs/manual-validation.md` for practical verification guidance
