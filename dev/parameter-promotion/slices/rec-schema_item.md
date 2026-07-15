### create_schema_item()

85 of the 113 crawled snapshots carried Advanced protocols with schema items. Per FR-007 this factory counts only the deepest level, `Protocols[].Schemas[].SchemaItems[].Parameters`. The crawl found four distinct schema-item parameters, all clearing the D5 breadth bar. This is where the dose family lives in Advanced protocols, mirroring `create_protocol()` for the Simple case.

| argument | pksim_parameter | default_unit | dimension | occurrences | n_models | evidence |
|---|---|---|---|---|---|---|
| `dose` | `InputDose` | `mg` | Mass | 928 | 85 | D5(a)+(b): on all 85 schema-item-bearing models (100% breadth) and the core dosing constant. Resolves to the dose family by unit dimension (rule below); observed units `mg` and `mg/kg` in this corpus on the single JSON parameter `InputDose`. |
| `start_time` | `Start time` | `h` | Time | 925 | 84 | D5(a): on 84 of 85 models. Maps to the engine constant `Start time`; observed `h`/`min`/`s`/`day(s)` all Time, canonical default `h`. |
| `volume_of_water_per_body_weight` | `Volume of water/body weight` | `ml/kg` | Volume per body weight | 835 | 81 | D5(a): 81 of 85 models. Maps to the engine constant `Volume of water/body weight`; single observed unit `ml/kg` (dimension Volume per body weight). |
| `infusion_time` | `Infusion time` | `h` | Time | 78 | 24 | D5(a): 24 models (>= 5). Maps to the engine constant `Infusion time`; observed `h`/`min`/`s` all Time, canonical default `h`. |

**Dose family and unit-to-family resolution rule (FR-009, FR-011, AC-4).** As on Simple protocols, PK-Sim stores the applied dose on a schema item as a single JSON parameter named `InputDose`, and its unit dimension selects the canonical engine dose-family member. A follow-up implementing `dose` here resolves the family identically to `create_protocol()`:

- a mass unit (`mg`, dimension `Mass`) -> `Dose` / `InputDose`;
- a body-weight-normalised unit (`mg/kg`, dimension `Dose per body weight`) -> `DosePerBodyWeight`;
- a body-surface-area-normalised unit (`mg/m²`, dimension `Dose per body surface area`) -> `DosePerBodySurfaceArea`.

All three dimensions and their default units validated against `validate_unit()`. In this corpus only `mg` and `mg/kg` were observed on schema items (`mg/m²` appeared on Simple protocols), but the same dimension-driven rule covers `mg/m²` -> `DosePerBodySurfaceArea` and an amount-based `mol` -> `Dose` (dimension `Amount`) as D5(b) canonical-constant family members. The repetition parameters (`NumberOfRepetitions`, `TimeBetweenRepetitions`) live one level up on the schema and are covered by `create_schema()`.
