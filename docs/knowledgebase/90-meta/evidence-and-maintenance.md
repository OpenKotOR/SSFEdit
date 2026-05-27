# Evidence and Maintenance Rules

## Knowledgebase Role

- [REPO] This knowledgebase is a companion layer over the existing root docs and source, not a replacement authority path.
- [SYNTH] Keep companion docs thin: summarize durable conclusions, point to the owning root doc or source file, and avoid re-explaining full workflows that already have a maintained home.

## Evidence Priority

- [REPO] Source and maintained repo docs outrank local editor metadata and historical plan problem statements.
- [OFFICIAL] As of 2026-05-27, current official Embarcadero and Wine evidence was partially inaccessible from this environment.
- [SYNTH] When official docs are blocked, preserve repo-local truth and mark the external evidence gap explicitly instead of filling it with speculation.

## Observation Boundaries

- [OPEN] No live desktop UI observation was captured in this pass.
- [OPEN] Reachable git history is shallow enough that git archaeology is weak evidence for intent.
- [OPEN] Current worktree artifacts may not match the current committed branch, especially for ignored executables and binary assets.

## Stale-Guidance Handling

- [REPO] Historical plan docs can contain resolved problem statements that no longer describe current repo truth.
- [SYNTH] Treat plan problem framing as historical unless current source or maintained docs still confirm it.
- [SYNTH] Prefer rewriting a stale root-doc claim or recording it in the operational-risk layer over silently carrying it forward.

## Update Triggers

- [SYNTH] Update the intent and execution layers when build, validation, or authority paths change.
- [SYNTH] Update the runtime and domain layers when startup flow, serializer ownership, or format invariants change.
- [SYNTH] Update the risk and meta layers whenever local-artifact handling, history depth assumptions, or external evidence access meaningfully change.
