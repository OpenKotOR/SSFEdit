# Current Runbook Authority

## Preferred Run Paths

- [REPO] The authoritative build path is Windows plus Delphi 7, either through `dcc32.exe USSFEdit.dpr` or the Delphi IDE.
- [REPO] The authoritative runtime path on non-Windows hosts is Wine plus a locally available Windows executable.
- [REPO] The only meaningful CLI argument is an existing `.ssf` path supplied as the first argument.

## Editor Metadata Role

- [REPO] `.vscode/tasks.json`, `.vscode/launch.json`, `.vscode/settings.json`, and `.vscode/extensions.json` are aligned to SSFEdit.
- [SYNTH] Use them as convenience wrappers for editor velocity, not as the source of truth for build or runtime behavior.
- [SYNTH] When `.vscode` behavior and Pascal source diverge, prefer `USSFEdit.dpr`, `BUILD.md`, and `docs/manual-validation.md`.

## Execution Guidance

- [SYNTH] Prefer `CONTRIBUTING.md` and `docs/manual-validation.md` as the current runbooks for change execution.
- [SYNTH] Defer automation-heavy execution stories until the repo has reproducible fixtures or another trustworthy regression surface.
- [SYNTH] Avoid assuming a fresh checkout will contain runnable Windows binaries or other ignored local artifacts.
