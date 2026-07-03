---
name: osp-snapshots
description: Use when writing R code that loads, navigates, mutates, or exports PK-Sim project snapshots with the osp.snapshots package. Covers the public API tour (loading, building-block access, the tibble layer, exporting) and the package's non-obvious contracts so an agent avoids its known gotchas.
x-osp-snapshots-version: "@VERSION@"
---

# Working with osp.snapshots

This skill teaches an AI agent to consume the public API of the osp.snapshots R package. It is a consumer's guide, not a guide to the package internals. Read it before writing R code that touches PK-Sim project snapshots.

## What the package is

osp.snapshots reads a PK-Sim project snapshot (a JSON file exported from PK-Sim) into an R6 object graph, lets you navigate and mutate it in R, and writes it back out. The one-line mental model is a load, navigate or mutate, export cycle over a single PK-Sim project JSON.

A snapshot holds building blocks. The eight building-block kinds this package models are compounds, events, expression profiles, formulations, individuals, observer sets, populations, and protocols; simulations are modeled too. Each building block carries parameters, and some fields are localized parameters (a parameter identified by a path inside the simulation tree). Observed data is a special case, covered in the gotchas.

## Loading

Use `load_snapshot(source)` to load. The `source` accepts three forms:

1. A local path to a `.json` file.
2. An `http://` or `https://` URL.
3. A template name, resolved against the building-block templates repository.

Use `osp_models(pattern = NULL)` to list the available template names; pass a `pattern` to filter them.

`Snapshot$new()` is the class-level equivalent of `load_snapshot()` when you already hold snapshot data.

```r
library(osp.snapshots)
snapshot <- load_snapshot("path/to/project.json")
```

## Navigating and mutating building blocks

Each building-block collection is reached by a plural accessor on the snapshot and indexed by name:

```r
midazolam <- snapshot$compounds[["Midazolam"]]
```

Fields are read and written through active bindings on the R6 objects:

```r
individual <- snapshot$individuals[["European"]]
individual$age <- 35
```

Mutators come as a function plus a method pair and chain with the base pipe. The `add_*()` and `remove_*()` family covers every building-block kind: `add_compound()` / `remove_compound()`, `add_event()` / `remove_event()`, `add_expression_profile()` / `remove_expression_profile()`, `add_formulation()` / `remove_formulation()`, `add_individual()` / `remove_individual()`, `add_observed_data()` / `remove_observed_data()`, `add_observer_set()` / `remove_observer_set()`, `add_population()` / `remove_population()`, `add_protocol()` / `remove_protocol()`, and `add_simulation()` / `remove_simulation()`.

Build a new building block from named arguments with the `create_*()` factory family: `create_compound()`, `create_event()`, `create_expression_profile()`, `create_formulation()`, `create_individual()`, `create_observed_data()`, `create_observer_set()`, `create_population()`, `create_process()`, `create_protocol()`, and `create_simulation()`, plus the supporting factories for their inner structures (for example `create_output_schema()`, `create_output_mapping()`, `create_solver_settings()`).

`create_parameter()` builds a parameter. With a `path` argument it yields a `LocalizedParameter` (a parameter keyed by its path in the simulation tree); without `path` it yields a plain `Parameter` keyed by name.

## The tibble layer

Every collection converts to a tibble for analysis. The `get_*_dfs()` family gives one function per kind: `get_compounds_dfs()`, `get_individuals_dfs()`, `get_formulations_dfs()`, `get_populations_dfs()`, `get_events_dfs()`, `get_expression_profiles_dfs()`, `get_protocols_dfs()`, `get_observer_sets_dfs()`, and `get_observed_data_dfs()`. The single dispatched entry point is `as_tibbles(snapshot, kind)`, where `kind` selects the collection.

Two facts matter when you use this layer:

1. `get_compounds_dfs()` returns a list with a `properties` tibble and a `processes` tibble, not a single tibble. Reach the pieces with `dfs$properties` and `dfs$processes`.
2. The tibble layer is read-only. Each `get_*_dfs()` and `as_tibbles()` call builds fresh tibbles from the current snapshot state. Mutating a returned tibble does not feed back into the snapshot. To change the snapshot, mutate through the R6 API (active bindings or the `add_*()` / `remove_*()` family).

## Exporting

Use `export_snapshot(snapshot, path)` to write the snapshot back to JSON. It wraps `snapshot$export(path)`.

```r
export_snapshot(snapshot, "path/to/modified.json")
```

## Gotchas

These are the highest-value part of this skill.

### Round-trip fidelity

Any snapshot section the package does not model is preserved verbatim from load through export. That includes `Classifications`, `ParameterIdentifications`, `SimulationComparisons`, and the four post-run `Simulation` fields (`Interactions`, `AlteredBuildingBlocks`, `IndividualAnalyses`, `PopulationAnalyses`). Mutate through the R6 API and never hand-edit the exported JSON to fix a passthrough section; the package round-trips those sections for you, and editing the JSON by hand risks corrupting them.

### Observed data export carve-out

Observed data loads into `ospsuite::DataSet` objects. Because a `DataSet` does not round-trip back to the snapshot list shape, two things are true and easy to miss:

1. Post-load mutations to a loaded `DataSet` are silently lost on export.
2. A runtime-added `DataSet` that has no backing JSON slice is dropped on export. `add_observed_data()` warns once at addition time to flag this.

Guidance: do not rely on modifying observed data through the loaded `DataSet` and expecting the change to survive export. If you need the change persisted, prepare the observed data before load or through the supported channels. Use `loadDataSetFromSnapshot()` to read a `DataSet` out of a snapshot.

### PK-Sim v11.2 and newer only

`load_snapshot()` accepts only PK-Sim v11.2 snapshots or newer (`Version >= 79`). Older projects fail to load; re-export them from PK-Sim v11.2+ first. Relatedly, localized-parameter paths use the `Events|...` form in v11+; the pre-v11 `Applications|...` form is migrated on load, so you will see `Events|...` on loaded snapshots.

## End-to-end example

```r
library(osp.snapshots)

snapshot <- load_snapshot("path/to/project.json")

# Inspect a collection as tibbles.
compound_dfs <- get_compounds_dfs(snapshot)
compound_dfs$properties

# Mutate through the R6 API.
snapshot$individuals[["European"]]$age <- 35
new_event <- create_event(name = "Meal", template = "Meal")
snapshot |> add_event(new_event)

# Write the result back to JSON.
export_snapshot(snapshot, "path/to/modified.json")
```
