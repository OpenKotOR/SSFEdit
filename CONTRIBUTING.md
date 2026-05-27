# Contributing

## Before you change code

1. Read [README.md](README.md) for project scope.
2. Read [BUILD.md](BUILD.md) for environment limits.
3. Read [ARCHITECTURE.md](ARCHITECTURE.md) and [CONVENTIONS.md](CONVENTIONS.md) before touching file parsers or form logic.
4. Check whether the change belongs in the main form, a reusable file handler, or a helper unit before adding new abstractions.

## Scope expectations

- Keep changes small and local unless the user explicitly asks for a refactor.
- Preserve SSF and TLK binary compatibility.
- If you change serializer behavior, document the invariant in [CONVENTIONS.md](CONVENTIONS.md) or [ARCHITECTURE.md](ARCHITECTURE.md).
- If you touch runtime/build assumptions, update [BUILD.md](BUILD.md).

## Validation workflow

### Documentation-only changes

- Run `git diff --check`.
- If the docs describe runtime or serializer behavior, verify those claims against the current Pascal source.

### Pascal source changes

Preferred path:

1. Build `USSFEdit.dpr` on Windows with Delphi 7.
2. Launch the executable.
3. Open or create an `.ssf` file.
4. Load a representative `dialog.tlk`.
5. Exercise the affected behavior.
6. Save and reopen outputs when serialization changed.

Fallback on Linux or macOS:

- Static review only, unless Wine is available and a previously built executable can be run.
- Do not rely on the current `.vscode` tasks or launch configurations for SSFEdit; they currently target `TSLPatcher`.

See `docs/manual-validation.md` for a more detailed validation matrix.

## File-handling cautions

- `.dfm` and `.res` files are binary in this repo. If you intentionally change them, mention that clearly in your summary.
- `.gitignore` excludes several artifact types that are still present in the repo surface. Confirm what is actually staged before concluding a change is complete.
- There is no automated test suite and no commit history in the current `main` branch, so validation must come from direct source inspection and manual runtime checks.
- Review `docs/limitations.md` before assuming a missing workflow or missing automation is accidental.

## Preferred contribution style

- Favor root-cause fixes over UI-only workarounds.
- Reuse the existing data model and label ordering.
- Keep error handling explicit.
- Add documentation alongside behavior changes when the repo's conventions or build story would otherwise stay implicit.
