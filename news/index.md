# Changelog

## osp.snapshots (development version)

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
  [`osp_models()`](https://esqlabs.github.io/osp.snapshots/reference/osp_models.md)
  function to browse and discover available OSP building block templates
  from the OSPSuite Community repository.

- Fixed bug in dataframe generation functions that caused errors when
  combining empty or NULL building block data using
  [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html).

## osp.snapshots 0.2.0

- New
  [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/load_snapshot.md)
  function to import PKSIM project snapshots from JSON files, URLs, or
  predefined templates.

- New
  [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/export_snapshot.md)
  function to save modified snapshots back to JSON files for import into
  PKSIM.

- Complete R6 class implementations for all major PKSIM building blocks:
  `Individual`, `Compound`, `Formulation`, `Population`, `Protocol`,
  `Event`, `ExpressionProfile`, and `Parameter`.

- New data frame conversion functions for all building block types:
  [`get_individuals_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_individuals_dfs.md),
  [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_compounds_dfs.md),
  [`get_formulations_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_formulations_dfs.md),
  [`get_populations_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_populations_dfs.md),
  [`get_protocols_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_protocols_dfs.md),
  [`get_events_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_events_dfs.md),
  [`get_expression_profiles_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_expression_profiles_dfs.md),
  and
  [`get_observed_data_dfs()`](https://esqlabs.github.io/osp.snapshots/reference/get_observed_data_dfs.md).

- New creation functions:
  [`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md),
  [`create_formulation()`](https://esqlabs.github.io/osp.snapshots/reference/create_formulation.md),
  and
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/reference/create_parameter.md)
  for building new building blocks.

- New management functions:
  [`add_individual()`](https://esqlabs.github.io/osp.snapshots/reference/add_individual.md),
  [`add_formulation()`](https://esqlabs.github.io/osp.snapshots/reference/add_formulation.md),
  [`add_expression_profile()`](https://esqlabs.github.io/osp.snapshots/reference/add_expression_profile.md),
  [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/reference/remove_individual.md),
  [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/reference/remove_formulation.md),
  [`remove_population()`](https://esqlabs.github.io/osp.snapshots/reference/remove_population.md),
  and
  [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/reference/remove_expression_profile.md).

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
