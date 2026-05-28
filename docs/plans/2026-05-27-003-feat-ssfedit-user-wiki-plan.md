---
title: feat: add end-user wiki submodule for SSFEdit
type: feat
status: active
date: 2026-05-27
---

## Summary

This plan adds a top-level `wiki` git submodule that points at the canonical GitHub wiki for `OpenKotOR/SSFEdit` and fills that wiki with plain-language end-user documentation. The goal is to give non-technical users a clear manual for what SSFEdit does, how to complete the main editing tasks, and what the app cannot safely do, without pushing them into contributor-facing repo docs.

---

## Problem Frame

The repository already has strong contributor and maintenance documentation, but it does not expose a distinct end-user manual surface. That leaves non-technical users to infer the app's workflow from developer docs or from the Delphi UI itself, which is a poor fit for explaining TLK selection, the fixed 40-slot model, save behavior, and the tool's scope/limitations.

---

## Assumptions

*This plan was authored without synchronous user confirmation. The items below are agent inferences that should be reviewed during implementation.*

- The desired documentation tier is a user-facing wiki, not another developer-focused `docs/` expansion.
- The top-level submodule path must be exactly `wiki` and should point to the canonical repository wiki remote for `OpenKotOR/SSFEdit`.
- It is acceptable to keep the wiki text-only for now rather than introducing screenshots or other binary assets that could drift quickly or violate the no-UI/resource constraint.
- Existing repo docs remain the authoritative source material for developer and maintenance concerns; the wiki should translate them for users rather than replacing them.

---

## Requirements

- R1. Add a top-level git submodule at `wiki` that points to the repository's own GitHub wiki.
- R2. Populate the wiki with a clear landing page and navigation structure aimed at non-technical users.
- R3. Document the main user workflows in plain language: preparing the TLK file, opening an existing SSF, creating a new SSF, editing slot values, appending TLK entries, and saving changes.
- R4. Document the app's scope and limitations without overpromising unsupported behavior.
- R5. Keep the end-user wiki distinct from the in-repo contributor/reference docs while still making the wiki easy to find from the main repo.
- R6. Avoid committing UI/designer/resource files as part of this slice.

---

## Scope Boundaries

- No Delphi source or runtime behavior changes are part of this slice.
- No `.dfm`, `.res`, screenshot, or other binary asset work is part of this slice.
- No attempt will be made to turn the in-repo developer docs into end-user docs; the new wiki is a separate documentation surface.
- No attempt will be made to document unsupported native Linux/macOS build flows.

---

## Context & Research

### Relevant Code and Patterns

- `README.md` already explains the product at a high level and should become the main discoverability surface for the wiki.
- `docs/workflows.md` maps the real user-visible flows and is the best structured source for user-task coverage.
- `docs/limitations.md` already captures platform, tooling, and format constraints that should be translated into end-user language.
- `docs/file-formats.md` is useful as a correctness reference for SSF/TLK terminology, but it should not be copied verbatim into the wiki.
- `USSFEdit.dpr` anchors the tracked startup and CLI behavior, while `docs/workflows.md` is the best tracked source for TLK selection, slot editing, add-entry behavior, and save flow in the current repo surface.
- Direct git observation confirms the wiki remote is reachable at `https://github.com/OpenKotOR/SSFEdit.wiki.git`.

### Institutional Learnings

- No applicable `docs/solutions/` or other institutional learnings were found for a user-facing wiki or a wiki submodule in this repo.
- The main risk called out by repo research is drift between the new wiki and the existing repo docs, so ownership boundaries must be explicit.

### External References

- Current official GitHub docs for wiki repository behavior could not be fetched because the Context7 query hit a monthly quota limit.
- Planning therefore relies on repo-local evidence plus direct git observation of the wiki remote instead of current official GitHub documentation.

---

## Key Technical Decisions

- Use a real git submodule at `wiki/` rather than generating end-user docs under `docs/`, so the wiki can remain the canonical user manual surface.
- Keep the wiki page set task-oriented and plain-language, with one clear page per user concern instead of a single long technical document.
- Keep contributor/reference material in the main repo and add only discoverability plus maintenance guidance there.
- Prefer text-only content for this first pass so the history stays lightweight and the documentation is less likely to drift than screenshot-heavy pages.

---

## Open Questions

### Resolved During Planning

- Should the wiki live inside the main repo docs tree? Resolved: no; use a top-level `wiki` submodule that points to the repository's own wiki remote.
- Should the wiki reuse contributor-facing wording verbatim? Resolved: no; translate the existing docs into plain user tasks and outcomes.

### Deferred to Implementation

- Whether the target wiki already contains pages that should be preserved or revised in place. Implementation should inspect the current wiki contents before overwriting anything.
- Whether the wiki navigation should use only `Home.md` links or also a `_Sidebar.md`. Implementation should choose the structure that best matches the current wiki repo contents.

---

## Output Structure

    .gitmodules
    wiki/
      Home.md
      _Sidebar.md
      Getting-Started.md
      Opening-and-Creating-Soundsets.md
      Editing-Soundset-Slots.md
      Adding-New-TLK-Entries.md
      Saving-and-Checking-Your-Changes.md
      Scope-and-Limitations.md
      Troubleshooting.md
    README.md
    CONTRIBUTING.md
    AGENTS.md

---

## Implementation Units

### U1. Attach the canonical wiki as a top-level submodule

**Goal:** Add the `wiki` git submodule and ensure it tracks the canonical GitHub wiki remote for this repository.

**Requirements:** R1, R6

**Dependencies:** None

**Files:**

- Create or modify: `.gitmodules`
- Create: `wiki`

**Approach:**

- Add the top-level submodule path `wiki` using the canonical wiki remote.
- Inspect the initial wiki checkout before writing pages so any existing wiki content is handled deliberately rather than overwritten blindly.
- Keep the main repo history limited to submodule metadata plus documentation updates.

**Patterns to follow:**

- Follow the repo's existing preference for explicit, deliberate staging of non-generated files only.

**Test scenarios:**

- Happy path: `.gitmodules` contains a `wiki` entry pointing at the canonical `OpenKotOR/SSFEdit.wiki.git` remote.
- Happy path: the top-level `wiki/` path is present as a git submodule rather than copied files.
- Error path: no UI/designer/resource files are introduced into the main repo as part of the submodule setup.

**Verification:**

- `git submodule status`
- Manual inspection of `.gitmodules`

---

### U2. Author the end-user wiki page set

**Goal:** Populate the wiki with a plain-language manual that explains what SSFEdit does, the main workflows, and the current limitations.

**Requirements:** R2, R3, R4

**Dependencies:** U1

**Files:**

- Create or modify: `wiki/Home.md`
- Create or modify: `wiki/_Sidebar.md`
- Create: `wiki/Getting-Started.md`
- Create: `wiki/Opening-and-Creating-Soundsets.md`
- Create: `wiki/Editing-Soundset-Slots.md`
- Create: `wiki/Adding-New-TLK-Entries.md`
- Create: `wiki/Saving-and-Checking-Your-Changes.md`
- Create: `wiki/Scope-and-Limitations.md`
- Create: `wiki/Troubleshooting.md`

**Approach:**

- Use `README.md`, `docs/workflows.md`, `docs/limitations.md`, `docs/file-formats.md`, `USSFEdit.dpr`, `USSFFile.pas`, and `UTLKFile.pas` as the accuracy set.
- Translate technical concepts into user outcomes and step-by-step tasks without hiding important constraints like the TLK requirement, fixed slot count, and save ordering.
- Keep each page narrowly focused so users can navigate to one task at a time.

**Patterns to follow:**

- Mirror the existing repo docs' factual accuracy while intentionally using simpler wording and less contributor-centric structure.

**Test scenarios:**

- Happy path: the landing page explains what the tool is for and where to start.
- Happy path: workflow pages cover TLK selection, opening/creating SSFs, editing slot values, adding TLK entries, and saving.
- Edge case: the limitations page clearly states platform/build constraints and the fixed nature of SSF/TLK handling.
- Error path: troubleshooting explains likely user-visible blockers such as missing `dialog.tlk`, unsupported build expectations on non-Windows hosts, and save-order confusion.

**Verification:**

- Manual content review for plain-language readability and consistency
- `git diff --check`

---

### U3. Wire wiki discoverability and maintenance guidance into the main repo

**Goal:** Make the wiki easy to find and document how contributors should treat the submodule-backed user manual.

**Requirements:** R5, R6

**Dependencies:** U1, U2

**Files:**

- Modify: `README.md`
- Modify: `CONTRIBUTING.md`
- Modify: `AGENTS.md`

**Approach:**

- Add a clear wiki link from `README.md` so non-technical readers can find the manual quickly.
- Update contributor guidance so maintainers know the wiki is a submodule-backed documentation surface with separate content ownership from the main repo docs.
- Update `AGENTS.md` so future agent work recognizes the wiki as the end-user doc surface and avoids mixing it with contributor documentation.

**Patterns to follow:**

- Keep the main repo docs concise and role-specific; do not duplicate full wiki content there.

**Test scenarios:**

- Happy path: `README.md` points readers to the wiki as the user manual surface.
- Happy path: `CONTRIBUTING.md` and `AGENTS.md` explain the wiki/submodule split clearly enough for future maintenance.
- Edge case: the main repo docs still preserve their contributor/reference focus instead of turning into user manuals.

**Verification:**

- Manual doc cross-check for role clarity
- `git diff --check`

---

## System-Wide Impact

- **Interaction graph:** This work adds a new documentation surface that sits alongside the existing developer docs and GitHub repo UI.
- **Error propagation:** The main failure mode is documentation drift between the wiki and the repo docs; discoverability and ownership wording are the mitigations.
- **State lifecycle risks:** The wiki becomes a second git history via submodule, so contributor workflows must account for separate checkout and update state.
- **API surface parity:** Not applicable at runtime, but the wiki's workflow descriptions must stay aligned with the tracked behavior evidence in `USSFEdit.dpr`, `docs/workflows.md`, and the serializer-related repo docs.
- **Unchanged invariants:** The app remains a Delphi 7 VCL editor with fixed 40-slot SSF handling and TLK position-based `StrRef` behavior.

---

## Risks & Dependencies

| Risk | Mitigation |
| ---- | ---------- |
| The wiki duplicates or contradicts repo docs | Keep the split explicit: user manual in `wiki/`, contributor/reference docs in the main repo |
| Submodule setup adds contributor friction | Document discoverability and maintenance expectations in `README.md`, `CONTRIBUTING.md`, and `AGENTS.md` |
| User docs overpromise unsupported capabilities | Anchor every workflow and limitation to the tracked repo docs plus the entrypoint and serializer files that remain in source control |
| Existing wiki content could be overwritten carelessly | Inspect the current wiki checkout before authoring or replacing pages |

---

## Documentation / Operational Notes

- This is documentation and git metadata work only; no browser or application-runtime validation is expected beyond static checks in the current Linux environment.
- If screenshots are desired later, they should be considered as a separate slice with explicit approval because they raise drift and asset-management concerns.

---

## Sources & References

- Related docs: `README.md`
- Related docs: `CONTRIBUTING.md`
- Related docs: `AGENTS.md`
- Related docs: `docs/workflows.md`
- Related docs: `docs/limitations.md`
- Related docs: `docs/file-formats.md`
- Related code: `USSFEdit.dpr`
- Related code: `USSFFile.pas`
- Related code: `UTLKFile.pas`
