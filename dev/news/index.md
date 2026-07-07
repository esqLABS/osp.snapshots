# Changelog

## osp.snapshots (development version)

- [`create_descriptor_condition()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_descriptor_condition.md)
  builds a container criterion (`Tag`, and an open-string `Type` such as
  `"InContainer"` or `"MatchTag"`) for an observer’s container criteria
  (#119).
- [`create_formula_reference()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formula_reference.md)
  builds a formula reference (`Alias`, `Path`, optional `Dimension`) for
  an observer’s formula (#119).
- [`create_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation.md)
  accepts an arbitrary `FormulationType` string and a raw `parameters`
  form (a list of
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  objects or `list(Name=, Value=, ...)` dicts), so you can author
  unknown formulation types and set arbitrary parameters by name,
  per-parameter `ValueOrigin`, and a custom `TableFormula` on any type;
  the curated alias form is unchanged and `Formulation$formulation_type`
  now accepts any non-empty string (#120).
- [`create_molecule_list()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_molecule_list.md)
  builds an observer’s molecule list from `for_all`, `include`, and
  `exclude` (#119).
- [`create_observer()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer.md)
  builds a single observer for an observer set, with arguments for name,
  type, dimension, formula, formula references, container criteria, and
  molecule list (#119).
- `Observer` now exposes a lossless writable `container_criteria` field
  (preserving each criterion’s `Type`), a writable `formula_references`
  field, and a writable `molecule_list` field, and validates `type`
  against `Amount`/`Container` on assignment (#119).
- [`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md)
  gains `description`, `gestational_age_range`,
  `disease_state_parameters`, and `individual` arguments, the last
  composing a base individual from
  [`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)
  to fully configure the population’s base individual (#118).
- [`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md)
  now validates `application_type` against the canonical PK-Sim
  application types and errors early on an invalid value, matching
  [`create_schema_item()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema_item.md)
  (#121).
- `Population` objects gain read/write `description`,
  `gestational_age_range`, and `disease_state_parameters` bindings and a
  read-only `individual` binding exposing the base individual (#118).
- `Population$egfr_range` now persists into the population settings, so
  an eGFR range set on a population survives export (#118).

## osp.snapshots 1.0.0

### Breaking changes

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
- [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
  returns a list with two tibbles, `properties` and `processes`, instead
  of a single combined tibble. Update callers from
  `df <- get_compounds_dfs(snap)` to
  `dfs <- get_compounds_dfs(snap); df <- dfs$properties`, or switch to
  the new long-form `dfs$processes` (#40).
- [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
  now requires PK-Sim v11.2 snapshots or newer (`Version >= 79`).
  Re-export older projects from PK-Sim v11.2+ before loading (#52).

### New features

- [`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
  attaches one or more `Simulation` objects to a `Snapshot`. Unresolved
  references to other building blocks (individual, population,
  compounds, events, observer sets, observed data, protocols,
  formulations) trigger one informational warning per simulation; the
  add proceeds either way (#94).
- `add_*()` mutators now accept either a single building block or a list
  of building blocks, mirroring `remove_*()` which has accepted a
  character vector of names since \#66. Success messages on both sides
  now uniformly report `Added N kind(s)` / `Removed N kind(s)` (#92).
- `as_tibbles(snapshot, kind)` converts any building-block collection to
  a tibble through one entry point, returning either a bare tibble
  (`"protocols"`, `"observed_data"`) or a named list of related tibbles
  (every other kind). The eight existing `get_*_dfs()` functions remain
  available as thin wrappers (#36).
- `compound$calculation_methods` and
  `individual$origin_data$calculation_methods` return a
  `CalculationMethods` object you can inspect (`$names`, `$length`) and
  mutate (`$add()`, `$remove()`) (#30).
- `compound$processes` returns a named list of `Process` objects, each
  exposing `internal_name`, `data_source`, `molecule`, `metabolite`,
  `species`, `parameters`, and a derived `category` (#40).
- [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  builds a compound from named arguments, with validation on
  `molecular_weight_unit` against
  `ospsuite::ospUnits$"Molecular weight"` (#27, \#48). It also sets the
  physicochemical properties directly: `lipophilicity`,
  `fraction_unbound`, `solubility` (with `reference_pH`,
  `solubility_gain_per_charge`, and `solubility_table`),
  `intestinal_permeability`, `permeability`, and `pKa`, and attaches
  `processes`; the matching `Compound` fields (`$lipophilicity`,
  `$fraction_unbound`, `$solubility`, `$intestinal_permeability`,
  `$permeability`, `$pka_types`, `$processes`) are writable so a loaded
  compound can be mutated. Attach with
  [`add_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_compound.md),
  remove by name with
  [`remove_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_compound.md)
  (#39, \#115).
- [`create_compound_group_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_group_selection.md),
  [`create_compound_process_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_process_selection.md),
  [`create_compound_properties()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_properties.md),
  [`create_event_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event_selection.md),
  [`create_formulation_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation_selection.md),
  [`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md),
  [`create_output_interval()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_interval.md),
  [`create_output_mapping()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_mapping.md),
  [`create_output_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_schema.md),
  [`create_protocol_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol_selection.md),
  [`create_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_simulation.md),
  and
  [`create_solver_settings()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_solver_settings.md)
  build a `Simulation` and its supporting structures from named
  arguments (#94).
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
- [`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)
  gains `expression_profiles`, `description`, and `parameters` arguments
  to attach expression-profile references, a description, and localized
  parameter overrides at creation time; the
  `Individual$expression_profiles` binding is now writable and a new
  read/write `Individual$description` binding is available (#117).
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
- [`create_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_snapshot.md)
  creates an empty snapshot carrying the current supported PK-Sim
  version, optionally named and described, as a snapshot-level
  counterpart to
  [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
  and
  [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  (#112).
- `individual$origin_data` returns an `OriginData` object holding the
  demographic starting point of the individual (species, population,
  gender, age, weight, height, gestational age, calculation methods,
  optional disease state) (#30).
- `ObserverSet` objects are now fully supported end to end (load,
  mutate, convert, export). Each exposes its observers as a named list
  of `Observer` objects with `name`, `type`, `dimension`, `formula` (the
  full `ExplicitFormula` list), `formula_expression`,
  `formula_dimension`, `formula_references`, and `container_tags`.
  [`get_observer_sets_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_observer_sets_dfs.md)
  returns two tibbles (`observer_sets` for set-level rows, `observers`
  joinable back via `observer_set_id` / `observer_set_name`); the
  `observers` tibble carries `formula_expression`, `formula_dimension`,
  and `formula_references` columns alongside `name`, `type`,
  `dimension`, and `container_tags` (#38, \#42, \#76, \#79).
- `protocol$schemas` returns a named list of `Schema` objects, each
  exposing `$items` as a list of `SchemaItem` objects (application type,
  formulation key, target organ and compartment, parameters) (#29).
- [`remove_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_simulation.md)
  removes one or more simulations from a `Snapshot` by name (#94).
- `Simulation` is now a first-class building block wrapping the
  simulation slice of a snapshot with R6 accessors for solver settings,
  output schemas, compound configurations, event and observer-set
  selections, observed-data references, output mappings, and
  `LocalizedParameter` overrides. Four post-run fields (`Interactions`,
  `AlteredBuildingBlocks`, `IndividualAnalyses`, `PopulationAnalyses`)
  are preserved byte-equivalent through `$data`, and construction
  enforces an XOR on `$individual` and `$population` so that exactly one
  subject is configured (#94).
- Parameters that live in a parameter tree (under an `Individual`,
  `ExpressionProfile`, or `Simulation`) are now `LocalizedParameter`
  objects, identified by a pipe-separated path. Pre-v11
  `Applications|...` segments are migrated to `Events|...` on load.
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  routes to `LocalizedParameter` when called with a `path` argument
  (#31).

### Minor improvements and fixes

- `as_tibbles(snapshot, "protocols")` (and the legacy
  [`get_protocols_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_protocols_dfs.md)
  wrapper) now returns the same 13 columns whether the snapshot has any
  protocols or not. Previously the empty-state path returned an
  18-column tibble that disagreed with the populated path, breaking
  [`bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
  across mixed snapshots (#56).
- [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  output can now be printed when `is_small_molecule` is left unset.
  Previously printing such a compound aborted with “missing value where
  TRUE/FALSE needed”; the type line is now omitted instead (#115).
- [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  now serializes `DataSet` objects attached at runtime via
  [`add_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_observed_data.md),
  so a snapshot built from
  [`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
  and
  [`add_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_observed_data.md)
  round-trips through
  [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  and
  [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md).
  Entries that were already present in the loaded snapshot are still
  replayed from the original JSON slice, which means post-load mutations
  to a `DataSet` (e.g. changing `xUnit` on an entry in
  `snapshot$observed_data`) are not reflected on export (#35, \#96).
- [`loadDataSetFromSnapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/loadDataSetFromSnapshot.md)
  now preserves the observed-data time unit (`BaseGrid$Unit`) on the
  resulting `DataSet$xUnit` for every ospsuite Time unit, including
  `"day(s)"`, `"week(s)"`, `"month(s)"`, `"year(s)"`, and `"ks"`.
  Previously only `"h"`, `"min"`, and `"s"` survived and any other unit
  silently reverted to `"h"`, misplacing time points (for example a 24x
  error for `day(s)`); this also affected
  `create_observed_data(time_unit = ...)` (#104).
- [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_expression_profile.md),
  [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_formulation.md),
  [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_individual.md),
  [`remove_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observed_data.md),
  and
  [`remove_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_population.md)
  now report the actual number of entries removed instead of the length
  of the input vector, so the success message reads correctly when a
  requested name is not present in the snapshot (#66).
- Building-block collections now share a `snapshot_collection` S3 class
  with a single generic [`print()`](https://rdrr.io/r/base/print.html)
  method. The existing per-kind classes (`compound_collection`,
  `individual_collection`, …) are preserved as marker classes (#34).
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
- The eight category-keyed compound accessors
  (`$protein_binding_partners`, `$metabolizing_enzymes`,
  `$hepatic_clearance`, `$transporter_proteins`, `$renal_clearance`,
  `$biliary_clearance`, `$inhibition`, `$induction`) are
  soft-deprecated. Use `compound$processes` (filter by
  `process$category`) or the long-form `processes` tibble returned by
  [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
  (#40).

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
