# Changelog

## osp.snapshots (development version)

This release widens the building-block coverage of `osp.snapshots` and
consolidates the public surface. You can now build every PK-Sim building
block from named arguments through a single `create_*()` factory family
(compounds, events, expression profiles, observed data, observer sets,
populations, processes, protocols, schemas, and schema items), attach or
remove them with paired `add_*()` / `remove_*()` mutators that chain
with the base pipe, and convert any collection to a tibble through one
dispatched
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
entry point. Observer sets are supported end to end (load, mutate,
convert, export). Several previously list-shaped fields on existing
classes are now first-class R6 objects with typed accessors.

### Breaking changes

- [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
  now requires PK-Sim v11.2 snapshots or newer (`Version >= 79`).
  Re-export older projects from PK-Sim v11.2+ before loading (#52).
- [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
  returns a list with two tibbles, `properties` and `processes`, instead
  of a single combined tibble. Update callers from
  `df <- get_compounds_dfs(snap)` to
  `dfs <- get_compounds_dfs(snap); df <- dfs$properties`, or switch to
  the new long-form `dfs$processes` (#40).
- `compound$calculation_methods` returns a `CalculationMethods` R6
  object instead of a plain list with class
  `compound_calculation_methods`. Read the names with
  `compound$calculation_methods$names` and mutate with `$add(name)`,
  `$remove(name)`; `$length` reports the count (#30).
- `compound$processes` returns a flat named list of `Process` R6 objects
  (duplicate names disambiguated with `_{n}`). Filter by
  `process$category` to recover the equivalent of the deprecated
  per-category accessors (#40).
- [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  writes the identifier to `data$Name` for plain parameters (no `path`
  argument) and to `data$Path` for path-bearing parameters (with `path`
  argument). Previously every result carried `data$Path`. Pass
  `path = ...` to get a path-bearing parameter; pass `name = ...` to get
  a plain one (#52).

### New features

- `add_*()` mutators now accept either a single building block or a list
  of building blocks, mirroring `remove_*()` which has accepted a
  character vector of names since \#66. Success messages on both sides
  now uniformly report `Added N kind(s)` / `Removed N kind(s)` (#92).

You can now create every kind of building block from a `create_*()`
function and attach it with the matching `add_*()` mutator:

- [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  builds a compound from named arguments, with validation on
  `molecular_weight_unit` against
  `ospsuite::ospUnits$"Molecular weight"` (#27, \#48). Attach with
  [`add_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_compound.md),
  remove by name with
  [`remove_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_compound.md)
  (#39).
- [`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md)
  builds an event from a template name and an optional list of parameter
  overrides (#27). Attach with
  [`add_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_event.md),
  remove with
  [`remove_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_event.md)
  (#39).
- [`create_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_expression_profile.md)
  builds an expression profile, requiring molecule, species, category,
  and type (#27).
- [`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
  builds an
  [`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
  from named time, value, unit, and optional error-series arguments.
  `value_dimension` is required and gates unit validation (#27, \#48).
  Attach with
  [`add_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_observed_data.md),
  remove with
  [`remove_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observed_data.md)
  (#39).
- [`create_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set.md)
  builds an observer set from a `name` and a list of observers (#43).
  Attach with
  [`add_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_observer_set.md),
  remove with
  [`remove_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observer_set.md)
  (#38).
- [`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md)
  builds a population, taking `Range` objects for age, weight, height,
  and BMI bounds. `number_of_individuals` must be a positive integer;
  `proportion_of_females` must be a length-1 number (#27, \#48). Attach
  with
  [`add_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_population.md)
  (#39).
- [`create_process()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_process.md)
  builds a compound process; `internal_name` and `data_source` are
  validated (#40). See
  [`?create_process`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_process.md)
  for the list of supported `internal_name` values.
- [`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md)
  builds a Simple or Advanced protocol. Pass `schemas` to build an
  Advanced protocol (accepts `Schema` objects from
  [`create_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema.md)
  or raw lists); mixing Simple-only fields (`application_type`,
  `dosing_interval`, …) with `schemas` errors out (#27, \#48, \#54).
  Attach with
  [`add_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_protocol.md),
  remove with
  [`remove_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_protocol.md)
  (#39).
- [`create_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema.md)
  and
  [`create_schema_item()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema_item.md)
  build the repeatable blocks and individual applications used inside an
  Advanced protocol. `application_type` on a schema item is validated
  against the canonical PK-Sim application types (#54).

You can now convert any building-block collection to a tibble through
one entry point:

- `as_tibbles(snapshot, kind)` returns either a bare tibble
  (`"protocols"`, `"observed_data"`) or a named list of related tibbles
  (every other kind). The eight existing `get_*_dfs()` functions remain
  available as thin wrappers (#36).

Observer sets are now fully supported. Each `ObserverSet` exposes its
observers as a named list of `Observer` objects with `name`, `type`,
`dimension`, `formula`, and `container_tags`.
[`get_observer_sets_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_observer_sets_dfs.md)
returns two tibbles (`observer_sets` for set-level rows, `observers`
joinable back via `observer_set_id` / `observer_set_name`) (#38, \#42,
\#76).

Several previously list-shaped fields are now first-class R6 objects:

- `compound$calculation_methods` and
  `individual$origin_data$calculation_methods` return a
  `CalculationMethods` object you can inspect (`$names`, `$length`) and
  mutate (`$add()`, `$remove()`) (#30).
- `individual$origin_data` returns an `OriginData` object holding the
  demographic starting point of the individual (species, population,
  gender, age, weight, height, gestational age, calculation methods,
  optional disease state) (#30).
- Parameters that live in a parameter tree (under an `Individual`,
  `ExpressionProfile`, or `Simulation`) are now `LocalizedParameter`
  objects, identified by a pipe-separated path. Pre-v11
  `Applications|...` segments are migrated to `Events|...` on load.
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  routes to `LocalizedParameter` when called with a `path` argument
  (#31).
- `compound$processes` returns a named list of `Process` objects, each
  exposing `internal_name`, `data_source`, `molecule`, `metabolite`,
  `species`, `parameters`, and a derived `category` (#40).
- `protocol$schemas` returns a named list of `Schema` objects, each
  exposing `$items` as a list of `SchemaItem` objects (application type,
  formulation key, target organ and compartment, parameters) (#29).

### Deprecated

- The eight category-keyed compound accessors
  (`$protein_binding_partners`, `$metabolizing_enzymes`,
  `$hepatic_clearance`, `$transporter_proteins`, `$renal_clearance`,
  `$biliary_clearance`, `$inhibition`, `$induction`) are
  soft-deprecated. Use `compound$processes` (filter by
  `process$category`) or the long-form `processes` tibble returned by
  [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
  (#40).

### Minor improvements

- Building-block collections now share a `snapshot_collection` S3 class
  with a single generic [`print()`](https://rdrr.io/r/base/print.html)
  method. The existing per-kind classes (`compound_collection`,
  `individual_collection`, …) are preserved as marker classes (#34).
- [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  now documents that mutations to a `DataSet` after load (e.g. changing
  `xUnit` on an entry in `snapshot$observed_data`) are not preserved on
  export. The exported `ObservedData` section is replayed from the
  original snapshot JSON, filtered to entries still present after
  [`remove_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observed_data.md)
  (#35).

### Bug fixes

- `as_tibbles(snapshot, "protocols")` (and the legacy
  [`get_protocols_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_protocols_dfs.md)
  wrapper) now returns the same 13 columns whether the snapshot has any
  protocols or not. Previously the empty-state path returned an
  18-column tibble that disagreed with the populated path, breaking
  [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
  across mixed snapshots (#56).
- [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_expression_profile.md),
  [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_formulation.md),
  [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_individual.md),
  [`remove_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observed_data.md),
  and
  [`remove_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_population.md)
  now report the actual number of entries removed instead of the length
  of the input vector, so the success message reads correctly when a
  requested name is not present in the snapshot (#66).
- Observed data removed via
  [`remove_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observed_data.md)
  is now dropped from the exported snapshot. Previously the export
  reused the full original `ObservedData` list whenever the lazy cache
  had been touched, re-introducing the removed entries on round-trip.
  The same fix applies to every building-block section: clearing a
  collection via
  [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_individual.md),
  [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_formulation.md),
  [`remove_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_population.md),
  or
  [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_expression_profile.md)
  now writes an empty section on export instead of falling back to the
  original entries (#35, \#59).
- Single-element JSON arrays remain arrays on export/import, allowing
  exported snapshots to load in PK-Sim (#23).

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
