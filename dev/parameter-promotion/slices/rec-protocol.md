### create_protocol()

98 of the 113 crawled snapshots carried Simple protocols. Per the FR-007 split, this factory counts only Simple protocols (a protocol object with an `ApplicationType` field and no `Schemas`); the crawl found 901 such Simple protocols against 625 Advanced ones, and no protocol carried both, so the split on `ApplicationType` presence is unambiguous. Five distinct parameters appear on Simple protocols, and the top four clear the D5 breadth bar. This is the family issue #157 targets first.

| argument | pksim_parameter | default_unit | dimension | occurrences | n_models | evidence |
|---|---|---|---|---|---|---|
| `dose` | `InputDose` | `mg` | Mass | 901 | 98 | D5(a)+(b): on all 98 Simple-protocol models (100% breadth) and the core dosing constant. Maps to the dose family via unit dimension (see resolution rule below): `mg` -> `Dose`/`InputDose` (Mass), `mg/kg` -> `DosePerBodyWeight` (Dose per body weight), `mg/m²` -> `DosePerBodySurfaceArea` (Dose per body surface area). All three observed in the corpus on the single JSON parameter `InputDose`. |
| `start_time` | `Start time` | `h` | Time | 900 | 98 | D5(a): on all 98 models. Maps to the engine constant `Start time`; single dimension Time (`h`). Already the pattern used by `create_event_selection(start_time)`. |
| `volume_of_water_per_body_weight` | `Volume of water/body weight` | `ml/kg` | Volume per body weight | 596 | 84 | D5(a): 84 of 98 models (majority). Maps to the engine constant `Volume of water/body weight`; single observed unit `ml/kg` (dimension Volume per body weight). |
| `infusion_time` | `Infusion time` | `h` | Time | 235 | 54 | D5(a): 54 models (>= 5). Maps to the engine constant `Infusion time`; observed `h`/`min`/`s` all Time, canonical default `h` (consistent with `create_output_interval` time defaults). |

`End time` (127 occurrences, 37 models, dimension Time) also clears the >= 5-models bar and is recorded in the raw tally; a follow-up may promote it as `end_time` alongside the four above.

**Dose family and unit-to-family resolution rule (FR-009, FR-011, AC-4).** PK-Sim stores the applied dose as a single JSON parameter named `InputDose`, whose *unit dimension* selects which canonical engine dose-family member the value belongs to. A follow-up implementing `dose` must resolve the family from the unit dimension of the supplied `dose_unit`, verbatim:

- a mass unit (`mg`, dimension `Mass`) -> `Dose` / `InputDose` (absolute dose);
- a body-weight-normalised unit (`mg/kg`, dimension `Dose per body weight`) -> `DosePerBodyWeight`;
- a body-surface-area-normalised unit (`mg/m²`, dimension `Dose per body surface area`) -> `DosePerBodySurfaceArea`.

All three dimensions and their default units validated against `validate_unit()`. The fourth canonical family member, an amount-based `Dose` in `mol`/`mmol` (dimension `Amount`), was not observed in this corpus but is part of the same family and is covered by the same dimension-driven rule (D5(b): canonical constant, low frequency). The repetition parameters `NumberOfRepetitions` and `TimeBetweenRepetitions` do not occur on Simple protocols in the corpus; they live at the schema level and are covered by `create_schema()`.
