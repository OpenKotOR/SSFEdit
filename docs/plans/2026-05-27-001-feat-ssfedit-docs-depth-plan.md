---
title: feat: deepen SSFEdit repository documentation
type: feat
status: active
date: 2026-05-27
---

## Summary

This plan extends the initial root-level documentation pass with the next layer of repo guidance: file-format reference material, manual validation procedures, contributor workflows, and explicit legacy/tooling limitations. The goal is to make future documentation and code changes safer by moving the repo from high-level orientation docs to code-grounded operational documentation.

---

## Problem Frame

The repository now has core overview documents at the root, but the remaining high-value knowledge is still implicit in the Pascal sources. Because the repo has no automated test suite, no commit history on `main`, binary Delphi form/resource assets, and stale `.vscode` metadata for a different project, contributors still lack a durable source for detailed format rules, safe validation flows, and workflow boundaries.

---

## Assumptions

*This plan was authored without synchronous user confirmation. The items below are agent inferences that fill gaps in the input and should be reviewed before implementation proceeds.*

- The user wants a follow-up documentation pass rather than code changes to the Pascal application itself.
- The new documentation should live in `docs/` and complement, not replace, the root documentation files already written.
- The current pass should stay grounded in repository evidence only and should not invent unsupported claims about KotOR/TSL behavior beyond what the code and project metadata establish.

---

## Requirements

- R1. Add detailed documentation for SSF/TLK format boundaries and editing invariants that are currently only evident from the Pascal sources.
- R2. Add a contributor-facing manual validation guide for documentation-led and serializer-adjacent changes in a repo without automated tests.
- R3. Add a workflow-oriented document that explains where common user and contributor actions live in the codebase.
- R4. Add an explicit limitations/caveats document that captures Delphi 7 constraints, binary asset boundaries, and stale workspace-tooling caveats.
- R5. Keep the new docs consistent with the existing root docs and avoid duplicating content that is already adequately covered there.

---

## Scope Boundaries

- No Pascal code changes are planned in this documentation pass.
- No attempt will be made to repair `.vscode/tasks.json`, `.vscode/launch.json`, or file-nesting configuration during this slice.
- No sample asset pack or test fixtures will be created unless the repo already contains suitable examples to reference.

### Deferred to Follow-Up Work

- Correct the stale `.vscode` task and launch surfaces in a separate workflow focused on editor tooling.
- Add sample SSF/TLK fixtures only after confirming what can be safely committed and redistributed.

---

## Context & Research

### Relevant Code and Patterns

- `USSFEdit.dpr` is the application entrypoint and only CLI surface.
- `SSFEdit.pas` owns the main user workflow: TLK selection, SSF load/new/save, slot editing, and add-entry flow.
- `USSFFile.pas` defines the reusable SSF v1.1 reader/writer and the fixed 40-slot label/value model.
- `UTLKFile.pas` defines the TLK v3.0 reader/writer, linked-list storage, append semantics, and string/sound metadata handling.
- `UEntryForm.pas` isolates the modal workflow for adding a TLK entry.
- `UST_Common.pas` and `StoffeUtils.pas` hold legacy helper behavior that should be documented only where it affects contributor workflow or serializer safety.

### Institutional Learnings

- `AGENTS.md` already defines the current top-level guidance and should remain the routing document for future agents.
- `AGENTS.md` explicitly warns that `.vscode/tasks.json`, `.vscode/launch.json`, and file nesting patterns currently document `TSLPatcher`, not `SSFEdit`.
- Current root docs already cover overview, build/runtime constraints, architecture, conventions, contributing workflow, and agent guidance, so this plan should add the next layer rather than rewriting those files wholesale.

### External References

- None. This pass should stay repo-grounded.

---

## Key Technical Decisions

- Add the new material under `docs/` rather than expanding the root files into larger monolithic documents. This keeps the root docs as navigation and summary surfaces while deeper reference material lives in topic-specific docs.
- Keep the new docs implementation-adjacent and evidence-based: every detailed claim should trace back to current repo files or already-established root docs.
- Treat the current root docs as the public entrypoints and cross-link from them into the new `docs/` files when deeper detail is added.

---

## Open Questions

### Resolved During Planning

- Should this slice rewrite the root docs or extend them? Resolved: extend them with deeper `docs/` references and keep the root docs concise.
- Should this pass attempt to fix the stale VS Code tooling? Resolved: no; document the caveat only.

### Deferred to Implementation

- Whether all four new docs should be linked from `README.md` only, or also from the root topical docs where relevant.
- Whether one combined workflows/validation document reads better than two narrower files once the drafting pass starts.

---

## Output Structure

    docs/
      file-formats.md
      manual-validation.md
      workflows.md
      limitations.md
      plans/
        2026-05-27-001-feat-ssfedit-docs-depth-plan.md

---

## Implementation Units

### U1. Add file-format reference documentation

**Goal:** Capture the SSF v1.1 and TLK v3.0 structures, sentinel values, index semantics, and UI-to-format relationships in a dedicated reference doc.

**Requirements:** R1, R5

**Dependencies:** None

**Files:**

- Create: `docs/file-formats.md`
- Modify: `README.md`
- Modify: `ARCHITECTURE.md`
- Modify: `CONVENTIONS.md`

**Approach:**

- Extract the stable binary and indexing rules from `USSFFile.pas`, `UTLKFile.pas`, and `SSFEdit.pas`.
- Keep this file descriptive rather than reverse-engineering every byte offset beyond what the code clearly establishes.
- Cross-link back to root docs where the file-format doc becomes the deeper reference.

**Patterns to follow:**

- Follow the concise, evidence-driven style already established in `README.md`, `ARCHITECTURE.md`, and `CONVENTIONS.md`.

**Test scenarios:**

- Test expectation: none -- documentation-only unit grounded in existing source inspection.

**Verification:**

- A reader can identify SSF header/version expectations, the fixed 40-slot model, the unset sentinel, and TLK append-only safety without reading the Pascal units first.

---

### U2. Add manual validation guidance

**Goal:** Create a repo-specific manual validation guide for documentation-driven reasoning and serializer-adjacent changes.

**Requirements:** R2, R5

**Dependencies:** U1

**Files:**

- Create: `docs/manual-validation.md`
- Modify: `BUILD.md`
- Modify: `CONTRIBUTING.md`

**Approach:**

- Translate the current build/runtime constraints into explicit validation paths: Windows + Delphi 7 authoritative build, Linux static-only validation, Wine-based execution of existing binaries when available.
- Include scenario-based validation guidance for open/edit/save, new-file creation, TLK entry append, and round-trip verification.
- Keep command examples lightweight and avoid presenting unverified automation as if it already exists.

**Patterns to follow:**

- Mirror the structure and caution level in `BUILD.md` and `CONTRIBUTING.md`.

**Test scenarios:**

- Test expectation: none -- documentation-only unit defining manual verification procedures.

**Verification:**

- A contributor can tell which checks are possible on Linux versus Windows, and what manual steps are expected after serializer-sensitive changes.

---

### U3. Add contributor workflow mapping

**Goal:** Document the common user and contributor workflows and map each one to the owning unit in the codebase.

**Requirements:** R3, R5

**Dependencies:** U1

**Files:**

- Create: `docs/workflows.md`
- Modify: `README.md`
- Modify: `ARCHITECTURE.md`

**Approach:**

- Describe the main flows already supported by the app: launch with optional CLI file, prompt for TLK, open SSF, create new SSF, modify slot `StrRef`, append TLK entry, and save.
- For each workflow, identify the primary unit and any supporting units involved.
- Use this file to reduce future architecture drift when deciding whether a change belongs in the main form, serializer units, or helper code.

**Patterns to follow:**

- Use the repo-map and responsibility language already present in `README.md` and `ARCHITECTURE.md`.

**Test scenarios:**

- Test expectation: none -- documentation-only unit explaining code ownership and user workflow boundaries.

**Verification:**

- A contributor can trace each major user-facing workflow to the owning unit without manually reconstructing the call path from source files.

---

### U4. Add explicit limitations and tooling caveats

**Goal:** Document the repo's legacy constraints and caveats that might otherwise be mistaken for omissions or bugs.

**Requirements:** R4, R5

**Dependencies:** None

**Files:**

- Create: `docs/limitations.md`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `CONTRIBUTING.md`

**Approach:**

- Consolidate the Delphi 7 constraint, binary `.dfm` / `.res` asset handling, lack of automated tests, no-commit-history state, and stale TSLPatcher `.vscode` metadata into one durable caveat document.
- Keep the content specific to repo behavior and contributor expectations rather than generic legacy-software commentary.
- Update the navigation surfaces so this doc is discoverable from the main entrypoints.

**Patterns to follow:**

- Reuse the repo-specific caveat language already established in `AGENTS.md`, `README.md`, and `CONTRIBUTING.md`.

**Test scenarios:**

- Test expectation: none -- documentation-only unit consolidating repo constraints and warnings.

**Verification:**

- A contributor can quickly identify which environment/tooling constraints are intentional repo realities and which surfaces are not authoritative.

---

## System-Wide Impact

- **Interaction graph:** This work affects every documentation entrypoint because the root docs will begin routing readers into deeper `docs/` references.
- **Error propagation:** The main risk is documentation drift or contradiction, not runtime behavior.
- **State lifecycle risks:** None at runtime; the relevant risk is stale guidance that could mislead future code changes.
- **API surface parity:** The CLI/load/save behavior described in the new docs must stay aligned with `USSFEdit.dpr` and `SSFEdit.pas`.
- **Integration coverage:** Cross-link integrity between root docs and new `docs/` files matters more than standalone document quality.
- **Unchanged invariants:** This plan documents existing behavior only; it does not alter SSF/TLK parsing, UI behavior, or build tooling.

---

## Risks & Dependencies

| Risk | Mitigation |
| ---- | ---------- |
| Over-documenting unsupported implementation details | Keep claims anchored to current Pascal source and project metadata only |
| Duplicating or contradicting the root docs | Treat root docs as summary/navigation layers and use cross-links instead of restating full sections |
| Treating stale `.vscode` configuration as product truth | Preserve the warning that these files currently describe `TSLPatcher`, not `SSFEdit` |

---

## Documentation / Operational Notes

- After this pass, `README.md` should route readers to both the root summaries and the deeper `docs/` references.
- If future work corrects the stale workspace tooling, `docs/limitations.md` and `AGENTS.md` will need a coordinated update.

---

## Sources & References

- Related code: `USSFEdit.dpr`
- Related code: `SSFEdit.pas`
- Related code: `USSFFile.pas`
- Related code: `UTLKFile.pas`
- Related code: `UEntryForm.pas`
- Related docs: `README.md`
- Related docs: `BUILD.md`
- Related docs: `ARCHITECTURE.md`
- Related docs: `CONVENTIONS.md`
- Related docs: `CONTRIBUTING.md`
- Related docs: `AGENTS.md`
