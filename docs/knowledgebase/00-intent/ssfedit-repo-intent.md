# SSFEdit Repo Intent

## Durable Scope

- [REPO] SSFEdit is a Delphi 7 VCL desktop editor for KotOR/TSL `.ssf` soundset files whose slot values resolve through `dialog.tlk`.
- [REPO] `USSFEdit.dpr` is the canonical source entrypoint, and `SSFEdit.pas` owns the main runtime workflow.
- [SYNTH] Treat this repo as a small Windows-first maintenance surface for a legacy desktop utility, not as a greenfield cross-platform application or general-purpose content pipeline.

## Quality Bar

- [REPO] The repo has no automated test suite; docs-only changes rely on `git diff --check`, while Pascal changes rely on Windows Delphi 7 builds plus manual workflow checks.
- [REPO] SSF/TLK correctness depends on fixed-width SSF layout, append-only-safe TLK mutation, and save flows that preserve TLK-before-SSF ordering when TLK data changed.
- [SYNTH] A change is only done when it preserves file-format compatibility, keeps the hardcoded slot order aligned, and uses the narrowest available validation path that can still falsify the claim being made.

## Prefer Now

- [SYNTH] Prefer Pascal source and maintained root docs over editor metadata, stale plans, or local artifacts when claims conflict.
- [SYNTH] Prefer small, local changes that stay inside the current main-form-plus-serializer architecture unless a refactor is explicitly requested.
- [SYNTH] Prefer append-only TLK growth and explicit manual validation for serializer-sensitive edits.

## Defer

- [SYNTH] Defer native Linux or macOS build expectations until there is an explicit portability effort.
- [SYNTH] Defer automation-heavy runbooks until the repo has a reproducible SSF/TLK fixture corpus or another trustworthy regression surface.
- [SYNTH] Defer deeper product-UX claims until a live runtime observation pass exists.

## Avoid

- [SYNTH] Avoid treating `.vscode` metadata as the canonical build or runtime contract.
- [SYNTH] Avoid TLK deletion or reordering, because `StrRef` identity is position-based.
- [SYNTH] Avoid assuming ignored executables or binary assets in a local worktree are committed repo truth.

## Companion Layers

- `../10-architecture-runtime/runtime-authority-map.md`
- `../20-domain-theory/ssf-tlk-editing-model.md`
- `../20-domain-theory/future-portability-register.md`
- `../30-product-ux/workflow-observation-boundary.md`
- `../40-operational-risk/drift-and-validation.md`
- `../50-execution/current-runbook-authority.md`
- `../90-meta/evidence-and-maintenance.md`

## Caveat Boundary

- [OPEN] This pass did not directly observe a live desktop session, so workflow claims remain source-backed rather than UI-observed.
- [OPEN] Current official vendor documentation for Embarcadero and Wine was partially inaccessible from this environment, so external evidence is thinner than repo evidence here.
- [OPEN] Reachable git history is shallow enough that source and maintained docs remain more trustworthy than git archaeology for intent reconstruction.
