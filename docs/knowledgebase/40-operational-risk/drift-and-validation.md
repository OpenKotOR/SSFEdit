# Drift and Validation Register

## Current Drift Surfaces

### Documentation Freshness

- [REPO] Some root docs previously described the repo as lacking project documentation or meaningful history, even though focused docs now exist and reachable history is shallow rather than empty.
- [REPO] Historical plan docs still describe stale `.vscode` problems as active current issues.
- [SYNTH] Treat maintained source and current docs as higher priority than older plan/problem statements when they conflict.

### Artifact Ambiguity

- [REPO] `.gitignore` excludes `.exe`, `.cfg`, `.dfm`, and `.res`, but files of those types may still appear in local worktrees.
- [SYNTH] The main failure mode is mistaking local ignored artifacts for committed repo truth.
- [SYNTH] Recovery path: check `git ls-files` for tracked artifacts and `git status --ignored` for local-only ones before describing the repo surface.

### Source vs Runtime Parity

- [REPO] Windows Delphi 7 remains the authoritative build path.
- [REPO] Linux and macOS offer only static review unless Wine can run an already-built Windows executable.
- [OPEN] Current source-to-binary parity is not fully verified from this environment.

## Verification Paths

- [REPO] Documentation-only changes: `git diff --check` plus source-backed claim review.
- [REPO] `.vscode` metadata changes: JSON validation, `git diff --check`, and cross-checks against `USSFEdit.dpr` plus root docs.
- [REPO] Pascal source changes: Windows Delphi 7 build plus manual workflow checks from `docs/manual-validation.md`.

## What To Prefer During Recovery

- [SYNTH] Prefer the smallest decisive verification command for each drift surface instead of broad repo retesting.
- [SYNTH] Prefer current repo state, current source, and maintained docs over local folklore and stale plan text.
- [SYNTH] Avoid idealized narratives that hide the current lack of automated regression coverage.
