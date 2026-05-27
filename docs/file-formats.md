# File Formats

This document summarizes the SSF and TLK structures that SSFEdit currently reads and writes. It is intentionally scoped to what the repository code establishes today.

## SSF v1.1

SSFEdit treats an SSF file as a fixed-width binary record with a short header followed by exactly 40 `DWORD` entries.

### On-disk layout

- Bytes `0..3`: file type magic `'SSF '`
- Bytes `4..7`: version `'V1.1'`
- Bytes `8..11`: `DWORD` start offset, written as `12`
- Bytes `12..171`: 40 consecutive `DWORD` slot values

### Slot semantics

- Each slot stores a `StrRef` into `dialog.tlk`.
- The application uses a 1-indexed in-memory slot array.
- `$FFFFFFFF` means the slot is unset.
- The UI renders an unset slot as `-1` in the `StrRef` column and `None` in the sound/text columns.

### Slot order

The slot order is hardcoded and must stay aligned between the main form and the reusable SSF helper:

1. Battlecry 1
2. Battlecry 2
3. Battlecry 3
4. Battlecry 4
5. Battlecry 5
6. Battlecry 6
7. Selected 1
8. Selected 2
9. Selected 3
10. Attack 1
11. Attack 2
12. Attack 3
13. Pain 1
14. Pain 2
15. Low health
16. Death
17. Critical hit
18. Target immune
19. Place mine
20. Disarm mine
21. Stealth on
22. Search
23. Pick lock start
24. Pick lock fail
25. Pick lock done
26. Leave party
27. Rejoin party
28. Poisoned
29. Unknown(29)
30. Unknown(30)
31. Unknown(31)
32. Unknown(32)
33. Unknown(33)
34. Unknown(34)
35. Unknown(35)
36. Unknown(36)
37. Unknown(37)
38. Unknown(38)
39. Unknown(39)
40. Unknown(40)

### TLK ownership in the repo

- `USSFFile.pas` contains the reusable `TSSFFile` reader/writer.
- `SSFEdit.pas` also performs direct SSF stream IO in the main form instead of delegating to `TSSFFile`.

Any SSF format change would have to account for both code paths.

## TLK v3.0

SSFEdit treats `dialog.tlk` as a binary table with a short header, a fixed-width string-data table, and a variable-length string-entry table.

### Header fields used by the repo

- Bytes `0..3`: file type magic `'TLK '`
- Bytes `4..7`: version `'V3.0'`
- Next `DWORD`: `LanguageId`
- Next `DWORD`: `StringCount`
- Next `DWORD`: `StringEntriesOffset`

If the magic or version does not match, the TLK loader raises an exception.

### Per-entry data held in memory

Each TLK entry is represented by `TTLKString` and carries:

- `strflags`: bitfield flags
- `strsound`: fixed 16-byte `TResRef`
- `sndvolume`: `DWORD`
- `sndpitch`: `DWORD`
- `stroffset`: `DWORD`
- `strsize`: `DWORD`
- `sndlength`: `Single`
- `strref`: position-based index assigned by load order or append order
- `strtext`: string payload
- `iscustom`: whether the entry was created by this program rather than loaded from disk

### Flag constants

- `TEXT_PRESENT = $0001`
- `SND_PRESENT = $0002`
- `SNDLENGTH_PRESENT = $0004`

When SSFEdit appends a brand-new TLK entry from the modal form, it sets all three flags.

### String and sound handling

- `strsound` is stored as a fixed 16-character buffer and null-padded when the user enters a shorter resref.
- TLK text shown in the main grid is normalized for display by removing carriage returns and replacing line feeds with spaces.
- TLK text written for new entries removes carriage returns before save because the memo control returns CR/LF line breaks.

### Repository ownership

- `UTLKFile.pas` owns TLK v3.0 load/save behavior.
- TLK entries are stored in a linked list (`TStringDataList`) rather than an array.
- `SSFEdit.pas` uses `GetTlkString` to resolve an SSF slot's `StrRef` by iterating that linked list.

## App-specific safety rules

These rules are format-adjacent and matter when changing the serializer code or documenting contributor expectations:

- TLK `StrRef` identity is position-based. Appending is safe; deleting or reordering existing entries is not.
- `TTLKFileHandler.AddEntry` appends new entries at the end of the list and assigns the next `StringCount` as the new `StrRef`.
- `TStringDataList.Delete` is explicitly marked as dangerous because removing a non-terminal entry would shift later indices.
- The SSF layout is fixed to 40 slots. The UI, the reusable SSF class, and the direct SSF stream logic all depend on that width.

## Related documents

- `ARCHITECTURE.md` for unit ownership and runtime flow
- `CONVENTIONS.md` for repo editing invariants
- `docs/manual-validation.md` for the validation steps to use after serializer-sensitive changes
