---
title: fix: align VS Code workspace config with SSFEdit
type: fix
status: active
date: 2026-05-27
---

## Summary

This plan replaces the placeholder `.vscode` task, launch, and workspace settings with SSFEdit-specific configuration. The goal is to make editor automation, launch flows, and file organization match the actual Delphi 7 project in this repository instead of the unrelated TSLPatcher surface currently checked in.

---

## Problem Frame

The current `.vscode` folder was copied from a different Delphi project. It validates the wrong files, launches the wrong executable, exposes irrelevant CLI override inputs, and nests files under nonexistent units. That makes the workspace actively misleading for contributors and agents.

---

## Assumptions

*This plan was authored without synchronous user confirmation. The items below are agent inferences that should be reviewed before implementation proceeds.*

- The desired outcome is a repo-specific `.vscode` surface for SSFEdit, not a generic Delphi template.
- It is acceptable to add a missing `.vscode/extensions.json` recommendation file if it improves workspace specificity.
- The workspace should preserve the documented Windows-build / Linux-Wine-run split already established in the repo docs.

---

## Requirements

- R1. Replace `TSLPatcher`-specific task labels, validations, defaults, and launch surfaces with SSFEdit-specific ones.
- R2. Ensure the `.vscode` run/build flows reflect the actual `USSFEdit.dpr` entrypoint and the executable/CLI behavior defined in the repo.
- R3. Update file nesting and other workspace settings so they match the real repo files.
- R4. Keep the editor configuration consistent with the repo docs and avoid inventing unsupported runtime behaviors.
- R5. Make the `.vscode` surface comprehensive enough that contributors are not left with placeholder inputs or unrelated project names.

---

## Scope Boundaries

- No Delphi source behavior changes are part of this slice.
- No attempt will be made to create a native Linux build path for SSFEdit.
- No attempt will be made to fix the repo’s missing git remote or PR workflow.

---

## Context & Research

### Relevant Code and Patterns

- `USSFEdit.dpr` is the canonical project entrypoint and the only CLI surface.
- The executable accepts at most one meaningful CLI argument: an existing `.ssf` file path.
- `USSFEdit.dof` identifies the project as SSFEdit version `0.3.3a` and confirms Delphi 7-era build assumptions.
- `.vscode/tasks.json`, `.vscode/launch.json`, and `.vscode/settings.json` currently target `TSLPatcher`, `UMainForm.pas`, and `UNamespaceForm.pas`, none of which exist in this repo.
- The actual high-value repo files for tooling purposes are `USSFEdit.dpr`, `SSFEdit.pas`, `UEntryForm.pas`, `USSFFile.pas`, `UTLKFile.pas`, `UST_Common.pas`, and the generated/binary siblings.

### Institutional Learnings

- `AGENTS.md` explicitly warns that the current `.vscode` files are not authoritative because they describe `TSLPatcher`, not `SSFEdit`.
- `BUILD.md` documents the expected platform split: Delphi 7 on Windows for builds, Linux/macOS only for static validation or Wine-based execution of existing binaries.

### External References

- None. This is a repo-local workspace configuration fix.

---

## Key Technical Decisions

- Keep the `.vscode` surface narrow and repo-specific: validate actual SSFEdit files, not a generic Delphi checklist.
- Preserve the current cross-platform pattern where Windows handles authoritative build/launch and Linux/macOS proxy existing executables through Wine.
- Remove the irrelevant TSLPatcher CLI override model and replace it with the only supported runtime parameter: an optional `.ssf` file path.
- Add `.vscode/extensions.json` if needed to recommend the editor extensions that make this workspace function well.

---

## Open Questions

### Resolved During Planning

- Should the workspace continue to expose TSLPatcher-style CLI override inputs? Resolved: no; SSFEdit only meaningfully supports an optional `.ssf` path.
- Should settings continue to nest files under nonexistent units? Resolved: no; nesting should match the actual project files.

### Deferred to Implementation

- Whether `SSFEdit.exe` or `USSFEdit.exe` should be the default executable prompt value if both remain present in the repo. The implementation should choose the value that best matches the source entrypoint and document that choice clearly.

---

## Output Structure

    .vscode/
      tasks.json
      launch.json
      settings.json
      extensions.json

---

## Implementation Units

### U1. Replace task definitions with SSFEdit-specific tasks

**Goal:** Rewrite `.vscode/tasks.json` so validation, build, and run tasks reflect the real SSFEdit repo surface.

**Requirements:** R1, R2, R4, R5

**Dependencies:** None

**Files:**

- Modify: `.vscode/tasks.json`
- Test: `.vscode/tasks.json`

**Approach:**

- Replace all TSLPatcher-specific labels, file checks, executable defaults, and detail text.
- Validate the actual repo surface around `USSFEdit.dpr` and the core Pascal units.
- Keep a Windows Delphi 7 build task and a Linux/macOS Wine-based launch path for existing executables.
- Replace the irrelevant override-INI/RTF input model with an optional `.ssf` launch argument.

**Patterns to follow:**

- Reuse the current cross-platform task structure where it still makes sense, but retarget every repo-specific surface to SSFEdit.

**Test scenarios:**

- Happy path: task labels and details clearly reference SSFEdit rather than TSLPatcher.
- Happy path: repo-surface validation points at real files in this workspace.
- Edge case: Linux/macOS run tasks still fail clearly when Wine is unavailable.
- Error path: build task still reports that Delphi 7 builds require Windows when run on Linux.

**Verification:**

- A contributor reading `.vscode/tasks.json` can identify the actual SSFEdit build/run/validation surface without seeing unrelated project names or inputs.

---

### U2. Replace launch configurations with SSFEdit-specific debug/run flows

**Goal:** Rewrite `.vscode/launch.json` so launch entries target SSFEdit and its actual CLI contract.

**Requirements:** R1, R2, R4, R5

**Dependencies:** U1

**Files:**

- Modify: `.vscode/launch.json`
- Test: `.vscode/launch.json`

**Approach:**

- Rename the launch configurations and groups to SSFEdit.
- Point the executable path and prelaunch tasks at the SSFEdit task surface.
- Replace the irrelevant TSLPatcher override arguments with either a default no-argument launch or a single optional `.ssf` file argument.

**Patterns to follow:**

- Mirror the existing cross-platform `cppdbg` structure where appropriate, but only after retargeting it to SSFEdit semantics.

**Test scenarios:**

- Happy path: launch names and comments describe SSFEdit.
- Happy path: the optional-argument launch reflects the single `.ssf` argument supported by `USSFEdit.dpr`.
- Error path: non-Windows launch still uses Wine and the matching validation task.

**Verification:**

- A contributor can infer the real SSFEdit launch behavior from `.vscode/launch.json` without consulting the Pascal entrypoint first.

---

### U3. Replace workspace settings and extension recommendations

**Goal:** Rewrite `.vscode/settings.json` and add any missing recommendation file so the editor organization and suggestions match this repo.

**Requirements:** R3, R4, R5

**Dependencies:** None

**Files:**

- Modify: `.vscode/settings.json`
- Create: `.vscode/extensions.json`
- Test: `.vscode/settings.json`
- Test: `.vscode/extensions.json`

**Approach:**

- Retarget explorer file nesting to the actual `USSFEdit.dpr` and related units in this workspace.
- Preserve useful Pascal file associations and exclude patterns that already fit the repo.
- Add explicit extension recommendations that are relevant to this codebase, such as Pascal support and native debugger support for the launch configs.

**Patterns to follow:**

- Keep the existing useful exclusion and OmniPascal settings where they are already repo-appropriate.

**Test scenarios:**

- Happy path: file nesting patterns reference real files like `USSFEdit.dpr`, `SSFEdit.pas`, and `UEntryForm.pas`.
- Happy path: extension recommendations are relevant to Delphi/Pascal and the configured debugger flow.
- Edge case: no stale TSLPatcher file names remain in settings.

**Verification:**

- The `.vscode` settings surface looks intentionally authored for this repo rather than copied from another project.

---

## System-Wide Impact

- **Interaction graph:** This work affects local editor automation, task execution, debug/launch flows, and file presentation in the VS Code explorer.
- **Error propagation:** The main failure mode is misleading workspace metadata that points contributors at nonexistent files or unsupported runtime contracts.
- **State lifecycle risks:** None at runtime; this is tooling/documentation-adjacent configuration.
- **API surface parity:** The `.vscode` launch and task inputs must stay aligned with the actual CLI and build assumptions in `USSFEdit.dpr` and `BUILD.md`.
- **Unchanged invariants:** The Delphi app’s behavior, file formats, and build constraints are unchanged; only the VS Code workspace metadata is being corrected.

---

## Risks & Dependencies

| Risk | Mitigation |
| ---- | ---------- |
| Accidentally inventing unsupported CLI options | Keep launch/task inputs anchored to the actual `USSFEdit.dpr` argument handling |
| Preserving useful structure while replacing bad placeholders | Reuse only the platform-shape of the current JSON files, not their repo-specific content |
| Choosing the wrong default executable when both `.exe` names exist | Base the default on the source entrypoint and make the input prompt editable |

---

## Documentation / Operational Notes

- After implementation, `AGENTS.md` and the deeper docs should no longer need to describe `.vscode` as obviously irrelevant placeholder tooling; they can instead describe it as repo-specific with any remaining caveats called out precisely.

---

## Sources & References

- Related code: `USSFEdit.dpr`
- Related metadata: `USSFEdit.dof`
- Related config: `.vscode/tasks.json`
- Related config: `.vscode/launch.json`
- Related config: `.vscode/settings.json`
- Related docs: `AGENTS.md`
- Related docs: `BUILD.md`
