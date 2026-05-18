# Changelog

## osp.snapshots (development version)

### Breaking changes

- `Compound$calculation_methods` now returns a `CalculationMethodCache`
  R6 object instead of a plain list with class
  `compound_calculation_methods`. The old list-shape accessors
  (`compound$calculation_methods$partition_coef`,
  `compound$calculation_methods$permeability`) no longer work; use the
  new R6 surface (`$methods`, `$add()`, `$remove()`, `$length`) on
  `CalculationMethodCache` instead (#30).

### New features

- [`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
  is the new unified entry point for converting any building-block
  collection in a snapshot to a tibble (or list of tibbles), dispatched
  on a `kind` argument. The eight existing `get_*_dfs()` functions
  remain available as thin wrappers (#36).
- New `CalculationMethodCache` R6 class wrapping the array of
  calculation method names stored on a `Compound` and inside an
  `Individual`’s `OriginData`. `Compound$calculation_methods` and
  `Individual$origin_data$calculation_methods` now return this class
  (#30).
- New `LocalizedParameter` R6 class for path-bearing parameters used in
  Individual, ExpressionProfile, and Simulation parameter trees.
  Inherits from `Parameter` and migrates legacy `Applications` path
  segments to `Events` for v11+ snapshots.
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  now routes to `LocalizedParameter` when called with a `path` argument
  (#31).
- New `OriginData` R6 class wrapping the demographic starting point of
  an `Individual` (species, population, gender, age, weight, height,
  gestational age, calculation methods, optional disease state).
  Available via `Individual$origin_data` (#30).
- [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  builds a Compound building block from named arguments, wrapping
  `Compound$new()` with validation of common fields (#27).
  `molecular_weight_unit` is now validated against
  `ospsuite::ospUnits$"Molecular weight"` when `molecular_weight` is
  supplied (#48).
- [`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md)
  builds an Event building block from named arguments and a template
  name, wrapping `Event$new()` (#27).
- [`create_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_expression_profile.md)
  builds an ExpressionProfile building block from named arguments,
  requiring molecule, species, category, and type (#27).
- [`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
  builds an
  [`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
  from named arguments for time, values, units, and optional error
  series (#27). `value_dimension` is now required (previously defaulted
  silently to `"Concentration (mass)"`); `time_unit` and `value_unit`
  are validated against the corresponding dimension (#48).
- [`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md)
  builds a Population building block from named arguments and `Range`
  objects for age, weight, height, and BMI bounds (#27).
  `number_of_individuals` must be a positive integer;
  `proportion_of_females` must be a length-1 number (#48).
- [`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md)
  builds a Simple or Advanced Protocol building block from named
  arguments, wrapping `Protocol$new()` (#27). Passing `schemas` now
  errors if any Simple Protocol field (`application_type`,
  `dosing_interval`, `target_organ`, `target_compartment`, `parameters`)
  is also supplied (#48).

### Minor improvements

- Building-block collections now share a `snapshot_collection` S3 class
  with a single generic [`print()`](https://rdrr.io/r/base/print.html)
  method, replacing the eight per-kind methods. The existing per-kind
  classes (`compound_collection`, `individual_collection`, etc.) are
  preserved as marker classes (#34).

### Bug fixes

- Fixed `Snapshot$data` so observed data removed via
  `remove_observed_data()` is also dropped from the exported snapshot.
  Previously the export reused the full original `ObservedData` list
  whenever the lazy cache had been touched, re-introducing the removed
  entries on round-trip.

- Fixed snapshot export/import so single-element JSON arrays remain
  arrays, allowing exported snapshots to load in PK-Sim (#23).

## osp.snapshots 0.2.2

### New features

- Extract Molecular Weight from Snapshot and include it in datasets
  (#18).

- Add support for importing y error values and related metadata from
  snapshot observed data.

### Bug fixes

- Fixed yValues units not being captured correctly from snapshot
  observed data.

- Fixed Snapshot failing to load when observed data contains unitless
  dimensions (#19).

## osp.snapshots 0.2.1

### Minor improvements and bug fixes

- New
  [`osp_models()`](https://esqlabs.github.io/osp.snapshots/dev/reference/osp_models.md)
  function to browse and discover available OSP building block templates
  from the OSPSuite Community repository.

- Fixed bug in dataframe generation functions that caused errors when
  combining empty or NULL building block data using
  [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html).

## osp.snapshots 0.2.0

- New
  [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
  function to import PKSIM project snapshots from JSON files, URLs, or
  predefined templates.

- New
  [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  function to save modified snapshots back to JSON files for import into
  PKSIM.

- Complete R6 class implementations for all major PKSIM building blocks:
  `Individual`, `Compound`, `Formulation`, `Population`, `Protocol`,
  `Event`, `ExpressionProfile`, and `Parameter`.

- New data frame conversion functions for all building block types:
  [`get_individuals_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_individuals_dfs.md),
  [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md),
  [`get_formulations_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_formulations_dfs.md),
  [`get_populations_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_populations_dfs.md),
  [`get_protocols_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_protocols_dfs.md),
  [`get_events_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_events_dfs.md),
  [`get_expression_profiles_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_expression_profiles_dfs.md),
  and
  [`get_observed_data_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_observed_data_dfs.md).

- New creation functions:
  [`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md),
  [`create_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation.md),
  and
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  for building new building blocks.

- New management functions:
  [`add_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_individual.md),
  [`add_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_formulation.md),
  [`add_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_expression_profile.md),
  [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_individual.md),
  [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_formulation.md),
  [`remove_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_population.md),
  and
  [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_expression_profile.md).

- Full integration with
  [`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
  objects for observed data.

- Comprehensive input validation for species, populations, genders, and
  units.

- Time conversion utilities between OSPSuite and R `lubridate` formats.

- Structured print methods for all building block classes.

## osp.snapshots 0.1.0

- Prototype release of the `osp.snapshots` package for managing PKSIM
  project snapshots in R.
