### create_schema()

85 of the 113 crawled snapshots carried Advanced protocols with `Schemas`. Per FR-007 this factory counts only the schema-level `Protocols[].Schemas[].Parameters` (not the deeper `SchemaItems[].Parameters`, which belong to `create_schema_item()`, and not Simple-protocol `Parameters`, which belong to `create_protocol()`). The crawl found exactly three distinct schema-level parameters, and all three clear the D5 breadth bar. The schema level is where the repetition family lives.

| argument | pksim_parameter | default_unit | dimension | occurrences | n_models | evidence |
|---|---|---|---|---|---|---|
| `number_of_repetitions` | `NumberOfRepetitions` | `(none)` | (dimensionless count) | 809 | 85 | D5(a)+(b): on all 85 schema-bearing models (100% breadth) and a core repetition constant. Maps to the engine constant `NumberOfRepetitions`; a dimensionless integer count, so it carries no unit to validate. |
| `time_between_repetitions` | `TimeBetweenRepetitions` | `h` | Time | 809 | 85 | D5(a)+(b): on all 85 models and a core repetition constant. Maps to the engine constant `TimeBetweenRepetitions`; observed `h`/`min`/`day(s)` all Time, canonical default `h`. |
| `start_time` | `Start time` | `h` | Time | 805 | 85 | D5(a): on all 85 models. Maps to the engine constant `Start time`; observed `h`/`min`/`day(s)` all Time, canonical default `h`. |

**Repetition family (FR-009, AC-4).** The two repetition parameters that #157/#158 call out, `NumberOfRepetitions` and `TimeBetweenRepetitions`, are owned by this factory: they are schema-level constants describing how a dosing schema repeats. `NumberOfRepetitions` is a dimensionless integer (a count of repetitions) and so carries no unit to validate; `TimeBetweenRepetitions` is a Time value whose default unit `h` validates against dimension `Time`. Both appear on every schema-bearing model in the corpus, so they are unambiguous promotions. The dose family (`InputDose`/`Dose`/`DosePerBodyWeight`/`DosePerBodySurfaceArea`) does not live at the schema level; it lives one level deeper on the schema items and is covered by `create_schema_item()`.
