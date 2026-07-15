### create_event()

Only 23 of the 113 crawled snapshots carried an `Events` section, and the events observed are feeding/meal definitions (the application factory itself is dominated by protocols, not events). Four distinct event parameters appear in the corpus, and only one clears the D5 breadth bar:

| argument | pksim_parameter | default_unit | dimension | occurrences | n_models | evidence |
|---|---|---|---|---|---|---|
| `meal_energy_content` | `Meal energy content` | `kcal` | Energy | 14 | 11 | D5(a): on 11 distinct models (>= 5 models), the only event parameter clearing the breadth bar. Maps to the engine constant `Meal energy content`; `kcal` validated against dimension `Energy`. |

The other three event parameters are below the >= 5-models bar and are recorded in the raw tally for traceability but not promoted: `Meal fraction solid` (3 occurrences, 3 models, dimensionless), `Gallbladder emptying lag time` (2 occurrences, 1 model, `min`, dimension Time), and `Meal volume` (1 occurrence, 1 model, `l`, dimension Volume). A follow-up may still choose to promote `meal_fraction_solid`, `meal_volume`, and a `gallbladder_emptying_lag_time` alongside `meal_energy_content` to make a coherent meal-definition signature, since they are the canonical companions of the same feeding event even though sparse in this corpus (D5(b) rationale for a coherent family); their units (`min` -> Time, `l` -> Volume) validate, but on frequency alone only `Meal energy content` qualifies.
