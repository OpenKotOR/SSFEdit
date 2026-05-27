# Workflow Observation Boundary

## Source-Backed Workflow Surface

- [REPO] The current workflow primitives are startup and optional CLI autoload, TLK selection, open existing SSF, create new SSF, edit a selected slot, append a new TLK entry, and save TLK before SSF.
- [REPO] `docs/workflows.md` and `SSFEdit.pas` are the authority surfaces for those flows in this pass.
- [SYNTH] Use these workflow primitives to place changes and describe user-visible impact, but not as proof of exact dialog wording or control layout.

## What Is Not Yet Observed

- [OPEN] No live desktop session was observed in this pass, so discoverability, control-state polish, and exact error-message wording remain unverified.
- [OPEN] There is no meaningful `{public}` versus `{auth}` split for this local desktop tool, so this layer currently records observation boundaries rather than public-surface behavior.
- [OPEN] Any claim that the runtime UI exactly matches the documented workflow should stay caveated until a screenshot or live executable observation pass exists.
