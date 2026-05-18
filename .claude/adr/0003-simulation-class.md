# ADR-0003: Wrap Simulation as an R6 class — simple fields first, nested fields deferred

**Status:** Accepted, 2026-05-18.

**Related:** issue #32 (decides). Unblocks a chain of follow-up implementation and design issues (see Consequences).

## Context

A **Simulation** is the PK-Sim entity that combines building blocks into a runnable model. Per `snapshot-spec.md`, it has 22 fields, including simple scalars (`Name`, `Model`, `AllowAging`, `HasResults`), name references to building blocks (`Individual`, `Population`, `Events`, `ObserverSets`, `ObservedData`), and dense nested types (`Compounds: CompoundProperties[]`, `OutputSchema`, `OutputSelections`, `OutputMappings`, `Interactions`, `AlteredBuildingBlocks`, `IndividualAnalyses: CurveChart[]`, `PopulationAnalyses: PopulationAnalysisChart[]`, `Solver`).

`CONTEXT.md` is explicit that Simulation is **not** a building block: "A **Simulation**, **Observed data**, **ParameterIdentification**, **SimulationComparison**, and any **Classification** are NOT building blocks." It is a *consumer* of building blocks.

Today the package treats Simulation as opaque: `Snapshot$initialize` does not iterate over `Simulations[]`; the section passes through `private$.original_data` and round-trips byte-equivalent. Zero call sites read `snapshot$simulations` because no such surface exists. Zero tests, zero vignettes.

The package owner has stated that **adding new Simulations and mutating existing ones is one of the goals of the package**. Continued opacity blocks that goal.

## Decision

**Wrap.** Introduce a `Simulation` R6 class in a new `R/Simulation.R`. Exported. `snapshot$simulations` returns a named list with the usual disambiguation suffix rule.

**Wrapping depth (first slice).** Expose only the fields whose shapes are simple enough to model without further design work:

- Simple scalars as active bindings: `name`, `description`, `model`, `allow_aging`, `individual`, `population`, `has_results`.
- Reference-array name views as active bindings: `compound_names` (read view of `Compounds[].Name`), `event_names`, `observer_set_names`, `observed_data_names`. Setters on these mutate the corresponding raw array.

**Passthrough (first slice).** The following nested fields stay in `private$.original_data` and merge through on export, unchanged: `OutputSchema`, `OutputSelections`, `OutputMappings`, full `CompoundProperties` (everything except the `Name` lookup used by `compound_names`), `Interactions`, `AlteredBuildingBlocks`, `IndividualAnalyses: CurveChart[]`, `PopulationAnalyses: PopulationAnalysisChart[]`, `Solver`, `Parameters: LocalizedParameter[]`, `AdvancedParameters`. Each becomes its own follow-up issue with its own decision before implementation.

**No `create_simulation()` / `add_simulation()` / `remove_simulation()` in the first slice.** The factory's signature depends on which nested fields are wrapped, and locking it in now would force breaking changes every time a nested type lands. Mutation today still works by copy-and-edit on an existing Simulation (which is what users do already, since the whole section was opaque). When enough nested types are wrapped to make the factory signature stable, file a design issue for it.

**Tree placement and documentation.** Top-level R6 class in `R/Simulation.R`, sibling of `ObservedData` (which is also non-building-block). `_pkgdown.yml` gets a new **"Simulations"** section, separate from "Building blocks" and "Observed data." `architecture.md`'s class table gets a `Simulation` row. `CONTEXT.md` gains a confirming sentence that `Simulation` now has a class even though the entity remains formally non-building-block.

**Round-trip fidelity.** Preserved as the implementation constraint: load → mutate → export of a snapshot containing Simulations must produce byte-equivalent output for all fields that are not explicitly modified through the new active bindings.

## Consequences

**For users:** `snapshot$simulations[[1]]$name` and `snapshot$simulations[[1]]$compound_names <- c(...)` start working. Anything that needs to change `OutputSchema`, `OutputSelections`, etc. still requires copy-and-edit from a template Simulation, same as today.

**For follow-up issues (to be filed):**

- One implementation slice for the first-pass `Simulation` class with the surface above.
- One **design** issue per nested field whose wrapping has non-trivial domain mapping: `OutputSchema` (with `OutputInterval`), `OutputSelections`, `OutputMapping`, full `CompoundProperties` (Process interaction selections, Alternatives), `Interactions`, `AlteredBuildingBlocks`, `CurveChart`, `PopulationAnalysisChart`, `Solver`. Each gated by its own ADR before implementation.
- One design issue for `create_simulation()` signature, opened once the dense nested fields are settled (or once a concrete user request makes its scope unambiguous).

**For `architecture.md`:** lines 7, 55, and 145 currently list `Simulations` as part of the "preserved verbatim, not modelled" set. They will need updating once the first-pass class lands — done in that implementation slice, not here.
