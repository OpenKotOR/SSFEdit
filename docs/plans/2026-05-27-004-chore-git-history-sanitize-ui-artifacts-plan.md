---
title: chore: commit non-UI changes and sanitize UI artifact history
type: chore
status: active
date: 2026-05-27
---

## Summary

Commit all current branch work except resource/designer/form/UI artifacts, add ignore coverage for those artifacts, and verify commit graph history to ensure those artifacts are not present. If present in branch history, rewrite and force-push; otherwise continue normal branch investigation.

## Requirements

- R1. Detect and classify changed files as allowed vs excluded UI/resource/designer/form artifacts.
- R2. Add `.gitignore` entries that prevent excluded artifacts from being staged in future.
- R3. Commit only non-excluded files with a clear commit message.
- R4. Inspect branch commit graph/history for excluded artifacts.
- R5. If excluded artifacts appear in branch history, remove them via history rewrite and force-push.
- R6. If excluded artifacts are absent, proceed with normal push/investigation flow.

## Exclusion Policy

- Exclude any file path matching resource/designer/form/UI intent.
- Explicitly include Delphi source/docs/config and other non-UI artifacts requested by the user.

## Execution Steps

1. Snapshot working tree with `git status --short` and enumerate staged/unstaged files.
2. Identify exclusion candidates by path/name pattern (`*.dfm`, `*.res`, form/designer/ui naming, resource directories).
3. Update `.gitignore` with narrowly-scoped rules for those excluded artifacts.
4. Stage only allowed files and commit.
5. Audit history for excluded artifacts in current branch relative to `origin/main`.
6. If hits are found, rewrite branch history to purge those paths, then force-push with lease.
7. If no hits are found, push normally and report branch status.

## Validation

- `git status --short` confirms excluded files are not staged.
- `git log --name-only --oneline origin/main..HEAD` (or equivalent) confirms no excluded artifacts in branch history.
- Push outcome confirms branch is synchronized with remote strategy used.

## Risks

- Broad ignore patterns can hide wanted files; keep patterns explicit.
- History rewrite can disrupt collaborators; use `--force-with-lease` and report commit changes.
