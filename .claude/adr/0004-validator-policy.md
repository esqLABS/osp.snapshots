# ADR-0004: No validator-set "completion" — the question conflated two function families

**Status:** Accepted, 2026-05-18.

**Related:** issue #41 (decides, closing it as wrong framing).

## Context

Issue #41 observed that `R/utils.R` exports a partial set of `validate_*` functions and proposed either completing the set (one per building block) or pushing validation into R6 constructors and removing the exported validators.

On inspection the premise is mistaken. The five exported validators in `R/utils.R` belong to **two unrelated function families**:

1. **Domain-value validators** — `validate_unit(unit, dimension)`, `validate_species(species)`, `validate_gender(gender)`, `validate_population(population)`. These guard strings or scalars against canonical ospsuite enums or dimension catalogues (`ospsuite::Species`, `ospsuite::Gender`, `ospsuite::HumanPopulation`, `ospsuite::ospUnits`). They are *not* one-per-building-block; they are one-per-domain-vocabulary-axis. They are reused by R6 constructors and by user-facing factories (e.g. `create_individual()` checks `validate_species(species)`).

2. **Class/instance check** — `validate_snapshot(snapshot)`. An `inherits(x, "Snapshot")` guard, used only by the exported mutator wrappers.

The asymmetry the issue described ("there is `validate_population` but no `validate_individual`") is a category error: `validate_population` is a value validator over the `HumanPopulation` enum, not a class check over `Population` objects. There is no `Individual` enum to check values against, so no symmetric `validate_individual` exists. The proposal to "complete the set" would mean adding eight redundant `inherits()` checks — the mutators already do these inline.

The proposal to "push validation into R6 constructors and active bindings" describes work that **already happens** for value validators (the `Individual` constructor calls `validate_species()`, `validate_gender()`, etc.). Removing the exported value validators as a side effect of "moving them into R6" would amount to removing useful standalone helpers that `create_*` factories and downstream package consumers rely on.

## Decision

**Close issue #41 as wrong framing.** No validator gap exists; no policy change is required. The two function families are kept where they are and continue to serve different purposes.

Two **optional** follow-up issues may be filed, both cosmetic and neither blocked by anything:

- **(a) Rename and relocate the value validators for clarity.** Move from `R/utils.R` into a dedicated `R/check.R` or `R/validators.R`. Give them names that surface the value-check intent (`validate_species_name()`, `validate_unit_for_dimension()`, etc.), to remove the surface-level appearance of symmetry with `validate_snapshot()`. Backwards-compatible deprecation of the old names via `lifecycle::deprecate_warn()`.
- **(b) Reconsider `validate_snapshot()`.** Per ADR-0001, the exported function wrappers remain the public API and continue to call `validate_snapshot()`. Whether the public API benefits from this being itself an exported function is a separate, smaller question. File if there is appetite for the cleanup.

## Consequences

**For #41:** closed with a comment linking to this ADR.

**For follow-up implementation issues that previously cited #41 as a blocker:** none. #41 was not a real blocker because its premise dissolved on inspection.

**For `architecture.md`:** the "Validators" section (line 88-90) is accurate as written — it describes the value validators correctly. No change required.
