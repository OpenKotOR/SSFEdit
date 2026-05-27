# SSF and TLK Editing Model

## Current Invariants

- [REPO] SSF handling assumes a fixed 40-slot soundset layout.
- [REPO] SSF slot arrays are 1-indexed, not 0-indexed.
- [REPO] `$FFFFFFFF` is the unset SSF sentinel, and the UI presents that state as `-1` / `None`.
- [REPO] TLK `StrRef` identity is position-based, so appending is safe while deleting or reordering existing entries is unsafe.
- [REPO] TLK sound resource references use a fixed 16-byte `TResRef` buffer with null padding.

## Current Editing Strategy

- [REPO] Existing SSF slot values can be replaced directly by editing the selected `StrRef`.
- [REPO] Brand-new TLK content is introduced only by appending a new TLK entry and assigning the new `StrRef` to the selected SSF slot.
- [REPO] TLK text displayed in the grid is normalized for readability, but TLK writing still preserves the underlying entry semantics.

## Repo Implications

- [SYNTH] Prefer append-only TLK mutation paths and explicit slot-by-slot SSF edits.
- [SYNTH] Any serializer change must account for both the reusable SSF class and the direct SSF stream logic in the main form.
- [SYNTH] Keep the hardcoded 40-label order aligned across UI and file-format code; otherwise the editor can silently lie about which slot is being modified.

## Avoid

- [SYNTH] Avoid TLK deletion, reindexing, or in-place list reordering.
- [SYNTH] Avoid widening the SSF slot model without changing every surface that assumes exactly 40 entries.
- [SYNTH] Avoid treating the grid presentation rules as cosmetic; they are part of how unset and populated values remain distinguishable to users.
