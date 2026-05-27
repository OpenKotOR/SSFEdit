# Future Portability Register

All items below are Tier 3 adjacent research. They are not current repo truth or an implicit migration plan.

## Newer RAD Studio Path

- [OFFICIAL] As of 2026-05-27, current RAD Studio guidance treats modern `string`, `Char`, and pointer-oriented string APIs as Unicode-centric rather than Delphi 7-style ANSI defaults.
- [SYNTH] If the repo ever needs a supported Windows toolchain without changing product shape, a newer RAD Studio VCL path is the lowest conceptual-change option.
- [SYNTH] Adoption threshold: a reproducible SSF/TLK fixture corpus, explicit Unicode migration review, and willingness to keep the app Windows-first.
- [SYNTH] Risk of premature adoption: maintenance work turns into a Unicode migration project before serializer behavior is well covered.

## Lazarus and LCL Path

- [OFFICIAL] As of 2026-05-27, Lazarus guidance for Delphi users describes LCL as similar to VCL but not fully compatible, with converters available for Delphi projects, units, and forms.
- [SYNTH] If native Linux or macOS builds ever become a real goal, the likely path is serializer-first portability and only then a one-form LCL experiment.
- [SYNTH] Adoption threshold: explicit cross-platform requirement, tolerance for DFM-to-LFM churn, and separation of file-format logic from VCL-bound UI code.
- [SYNTH] Risk of premature adoption: the repo's current one-form convenience becomes UI-conversion noise and platform-compat debugging.

## Automation Ladder

- [SYNTH] The next credible automation step is not a full cross-platform build; it is a small SSF/TLK corpus plus round-trip validation around file-format logic and optional Wine smoke runs.
- [SYNTH] Adoption threshold: stable sample inputs and a maintainer need for repeatable serializer confidence.
- [SYNTH] Risk of premature adoption: GUI-only smoke coverage can create false confidence if the serializer surfaces are still duplicated and under-isolated.

## Observation Boundary

- [OPEN] Official Embarcadero and Wine pages were partially blocked by 403 or challenge responses in this pass, so current external evidence is thinner than repo evidence.
