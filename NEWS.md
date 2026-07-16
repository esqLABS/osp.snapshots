# osp.snapshots (development version)

- `create_population()` now requires `number_of_individuals` to be a whole number between 2 and 10000, matching the bounds PK-Sim enforces when creating a population (#170).
- `create_protocol()` gains `dose` (with `dose_unit`, default `"mg"`), `start_time` (with `start_time_unit`, default `"h"`), and `end_time` plain arguments for the Simple-Protocol dosing settings, as a validated, self-documenting alternative to hand-building the equivalent `InputDose`/`Start time`/`End time` entries in `parameters` (#157).
- `create_schema()` gains plain arguments `number_of_repetitions`, `time_between_repetitions` (with unit `time_between_repetitions_unit`, default `"h"`), and `start_time` (with unit `start_time_unit`, default `"h"`) for the schema-level repetition parameters, so callers no longer hand-write `create_parameter()` entries with PK-Sim's internal names; the `parameters` list still works for anything else, and supplying a value both ways is an error (#167).
- `create_schema_item()` gains promoted `dose` (with `dose_unit`, default `"mg"`) and `start_time` (with `start_time_unit`, default `"h"`) arguments, mirroring `create_output_interval()` and `create_event_selection()`; the dose is written as a single `InputDose` parameter whose unit selects the dose family, and supplying a promoted argument together with the matching `parameters` entry is an error (#168).
- `create_snapshot()` now authors the current PK-Sim v13 snapshot version (`Version 81`) instead of `80`, ordering the top-level `Name` before `Version` and emitting the new `CheckNegativeValues` solver field when a simulation is added (#161).
- `fraction_unbound()` gains a `species` argument (default `"Human"`, validated against `ospsuite::Species`) and now emits a `Species` field on the fraction-unbound alternative, which PK-Sim requires to load the snapshot (#156).
- `load_snapshot()` and `Snapshot$new()` gain an `upgrade` argument (default `FALSE`) that migrates a below-floor PK-Sim snapshot (`Version 74-78`) up to the installed core's version via a PK-Sim round trip; without it, such a snapshot reports how to migrate and does not load (#161).
- `load_snapshot()` now supports PK-Sim v13 snapshots (`Version 81`), reports their PK-Sim version, and rejects snapshots newer than it supports (`Version 82+`) with a clear error (#161).
- `load_snapshot()` warns, rather than fails, when a supported snapshot is newer than the installed `ospsuite` core, since it may not load or run there (#161).

# osp.snapshots 1.0.0

## Breaking changes

- `AdvancedParameter$distribution_type` is now validated against the distribution-type enum (`Normal`, `LogNormal`, `Uniform`, `Discrete`, `Unknown`).
- `compound$calculation_methods` returns a `CalculationMethods` R6 object instead of a plain list with class `compound_calculation_methods`. Read the names with `compound$calculation_methods$names` and mutate with `$add(name)`, `$remove(name)`; `$length` reports the count (#30).
- `Compound$is_small_molecule` now requires a single logical value (or `NULL`).
- `Compound$plasma_protein_binding_partner` and `create_compound()`'s `plasma_protein_binding_partner` argument are now validated against the binding-partner enum (`Unknown`, `Albumin`, `Glycoprotein`).
- `compound$processes` returns a flat named list of `Process` R6 objects (duplicate names disambiguated with `_{n}`). Filter by `process$category` to recover the equivalent of the deprecated per-category accessors (#40).
- `CompoundProperties$calculation_methods` now requires a character vector (or `NULL`).
- `create_compound()`, `create_individual()`, and `create_observed_data()` take value-object helpers (`lipophilicity()`, `fraction_unbound()`, `solubility()`, `intestinal_permeability()`, `permeability()`, `age()`, `weight()`, `height()`, `gestational_age()`, `time()`, `values()`, `error()`) for their value/unit/name fields instead of the per-field `_value`/`_unit`/`_name` scalar arguments; for example `create_compound(name = "X", lipophilicity = lipophilicity(2.5))`. The matching `Compound`/`Individual`/`OriginData` fields now require the helper as well; a bare scalar (for example `individual$age <- 30` or `compound$lipophilicity <- 2.5`) is rejected (#133, #140).
- `create_individual()` now emits the current `Disease` object (`{ Name, Parameters }`) under `OriginData$Disease` instead of the legacy `DiseaseState` / `DiseaseStateParameters` pair, matching `create_expression_profile()`; loaded legacy snapshots still read back correctly (#151).
- `create_parameter()` writes the identifier to `data$Name` for plain parameters (no `path` argument) and to `data$Path` for path-bearing parameters (with `path` argument). Previously every result carried `data$Path`. Pass `path = ...` to get a path-bearing parameter; pass `name = ...` to get a plain one (#52).
- `create_protocol()` (and the `Protocol$dosing_interval` setter) now validate `dosing_interval` against the fixed `DosingIntervalId` values (`Single`, `DI_6_6_6_6`, `DI_6_6_12`, `DI_8_8_8`, `DI_12_12`, `DI_24`) and error early on an unknown value, matching how `application_type` is validated (#151).
- `error()` now validates `type` against the schema `AuxiliaryType` values (`ArithmeticStdDev`, `GeometricStdDev`, `ArithmeticMeanPop`, `GeometricMeanPop`) and no longer accepts the off-schema `"ArithmeticStdErr"` (#151).
- `get_compounds_dfs()` returns a list with two tibbles, `properties` and `processes`, instead of a single combined tibble. Update callers from `df <- get_compounds_dfs(snap)` to `dfs <- get_compounds_dfs(snap); df <- dfs$properties`, or switch to the new long-form `dfs$processes` (#40).
- The identity-name setters across building blocks and selections (`Compound$name`, `Population$name`, `Protocol$name`, `Schema$name`, `SchemaItem$name`, `Event$name`/`$template`, `Observer$name`, `ObserverSet$name`, `Process$internal_name`/`$data_source`/`$molecule`/`$metabolite`/`$species`, `CompoundProperties$name`, `CompoundGroupSelection$group_name`/`$alternative_name`, `CompoundProcessSelection$name`/`$molecule_name`/`$metabolite_name`/`$compound_name`/`$systemic_process_type`, `FormulationSelection$name`/`$key`, `ObserverSetSelection$name`, `ProtocolSelection$name`, `EventSelection$name`, `Individual$name`) now reject empty, `NA`, or non-scalar strings.
- `load_snapshot()` now requires PK-Sim v11.2 snapshots or newer (`Version >= 79`). Re-export older projects from PK-Sim v11.2+ before loading (#52).
- `Observer$dimension` now requires a non-empty string (or `NULL`).
- `OutputMapping$path`, `$observed_data`, `$scaling`, `$weight`, `$weights`, and the matching `create_output_mapping()` arguments, are now validated (`$scaling`/`scaling` against the `Linear`/`Log` enum on both the setter and the factory).
- The parameters setters (`Protocol$parameters`, `Individual$parameters`, `Schema$parameters`, `SchemaItem$parameters`, `Formulation$parameters`, `Event$parameters`) now require a list (or `NULL`).
- `Parameter$data` and `ExpressionProfile$data` are now read-only; mutate the parameter/profile through its typed fields instead.
- `Parameter$unit` now requires a single non-empty string (or `NULL`).
- `Population$age_range`, `$weight_range`, `$height_range`, `$gestational_age_range`, and `$bmi_range` now validate the range's unit against the field's dimension.
- `Population$number_of_individuals` now requires a positive whole number (previously any positive number).
- `Protocol$application_type` and `SchemaItem$application_type` now match the canonical PK-Sim application types that `create_protocol()` and `create_schema_item()` already validated against.
- `Protocol$time_unit` and `create_protocol()`'s `time_unit` argument are now validated against the `Time` dimension.
- `Simulation$allow_aging` now requires a single logical value (or `NULL`).
- `SolverSettings` fields (`abs_tol`, `rel_tol`, `use_jacobian`, `h0`, `h_min`, `h_max`, `mx_step`) are now validated per `create_solver_settings()`'s existing rules.

## New features

- `add_simulation()` is the entry point for building a simulation: with the snapshot in hand it constructs a `Simulation` from named arguments (`name`, `individual`/`population`, `compounds`, ...), resolves the references, and derives defaults (calculation methods from the compound, the formulation key from the protocol's slot, alternatives from each group's default) before attaching. Configure each compound inline through `compounds = list(list(name =, protocol =, formulation =, processes =, calculation_methods =, alternatives =, ...))`: select a specific alternative by friendly property name and label (`alternatives = c(solubility = "FaSSIF")`, overriding the derived default for that group only) or bind a multi-slot protocol's formulations explicitly (`formulation = c(Formulation = "Oral solution", "Formulation 2" = "IV solution")`); a named `formulation` map that names a slot key the referenced protocol does not have is not an error, only an informational message, since PK-Sim itself rejects an unbound or mis-bound slot at load time. Unresolved references to other building blocks (individual, population, compounds, events, observer sets, observed data, protocols, formulations) trigger one informational warning per simulation; the add proceeds either way (#94, #135, #144).
- `add_*()` mutators now accept either a single building block or a list of building blocks, mirroring `remove_*()` which has accepted a character vector of names since #66. Success messages on both sides now uniformly report `Added N kind(s)` / `Removed N kind(s)` (#92).
- `add_individual()` warns once per individual when it references expression profiles (by composite `Molecule|Species|Category` id) that are not in the snapshot; the add proceeds either way (#135).
- `age()`, `weight()`, `height()`, `gestational_age()`, `lipophilicity()`, `fraction_unbound()`, `solubility()`, `intestinal_permeability()`, `permeability()`, `time()`, `values()`, and `error()` build small value objects that bundle a value, its unit, and any field-specific extras for the `create_*()` factory arguments; each owns its default unit and validates a supplied unit against the field's dimension. The five compound physicochemical-property helpers (`lipophilicity()`, `fraction_unbound()`, `solubility()`, `intestinal_permeability()`, `permeability()`) also take a `default` argument to mark which alternative in a list is the group's default (#133, #147).
- `as_tibbles()` converts any building-block collection to a tibble through one entry point, returning either a bare tibble (`"protocols"`, `"observed_data"`) or a named list of related tibbles (every other kind). `kind` is optional and accepts a character vector: omit it (or pass `NULL`) to get all kinds as a named list keyed by kind, or pass several kinds to get just that subset. The nine existing `get_*_dfs()` functions remain available as thin wrappers (#36, #137).
- `compound$calculation_methods` and `individual$origin_data$calculation_methods` return a `CalculationMethods` object you can inspect (`$names`, `$length`) and mutate (`$add()`, `$remove()`) (#30).
- `compound$processes` returns a named list of `Process` objects, each exposing `internal_name`, `data_source`, `molecule`, `metabolite`, `species`, `parameters`, and a derived `category` (#40).
- `create_compound()` builds a compound from named arguments, with validation on `molecular_weight_unit` against `ospsuite::ospUnits$"Molecular weight"` (#27, #48). It sets the physicochemical properties through value-object helpers: `lipophilicity()`, `fraction_unbound()`, `solubility()` (expressing reference pH, gain per charge, or a pH/value table), `intestinal_permeability()`, and `permeability()`, plus `pKa` and `processes`; each property argument also accepts a list of these objects to define several named alternatives, letting exactly one be marked the group default via its helper's `default = TRUE` argument (the first element is the default when none is marked); the matching `Compound` fields `$lipophilicity`, `$fraction_unbound`, `$solubility`, `$intestinal_permeability`, and `$permeability` are writable and require the same helper objects (single or a list for named alternatives) so a loaded compound can be mutated. `$pka_types` is writable with a list of `list(type =, value =)` entries (or a raw `PkaType` list), and `$processes` is writable with a list of `Process` objects (or raw process lists). Attach with `add_compound()`, remove by name with `remove_compound()` (#39, #115, #133, #140, #144, #147).
- `create_compound_group_selection()`, `create_compound_process_selection()`, `create_compound_properties()`, `create_event_selection()`, `create_formulation_selection()`, `create_observer_set_selection()`, `create_output_interval()`, `create_output_mapping()`, `create_output_schema()`, `create_protocol_selection()`, and `create_solver_settings()` build a `Simulation`'s supporting structures from named arguments, for use as the escape hatch to `add_simulation()` and for hand-built configurations (#94).
- `create_descriptor_condition()` builds a container criterion (`Tag`, and an open-string `Type` such as `"InContainer"` or `"MatchTag"`) for an observer's container criteria (#119).
- `create_event()` builds an event from a template name and an optional list of parameter overrides (#27). Attach with `add_event()`, remove with `remove_event()` (#39).
- `create_expression_profile()` builds an expression profile, requiring molecule, species, category, and type, and accepts `expression` (per-organ relative expression as a data frame of container rows or a raw list) and `disease` (a disease state); the `ExpressionProfile` object gains read/write `expression` and `disease` bindings so a loaded profile can be read and mutated (#27, #116).
- `create_formula_reference()` builds a formula reference (`Alias`, `Path`, optional `Dimension`) for an observer's formula (#119).
- `create_formulation()` accepts an arbitrary `FormulationType` string and a raw `parameters` form (a list of `create_parameter()` objects or `list(Name=, Value=, ...)` dicts), so you can author unknown formulation types and set arbitrary parameters by name, per-parameter `ValueOrigin`, and a custom `TableFormula` on any type; the curated alias form is unchanged and `Formulation$formulation_type` now accepts any non-empty string (#120).
- `create_individual()` sets the demographic fields through value-object helpers (`age()`, `weight()`, `height()`, `gestational_age()`), and gains `expression_profiles`, `description`, and `parameters` arguments to attach expression-profile references, a description, and localized parameter overrides at creation time; the `Individual$expression_profiles` binding is now writable and a new read/write `Individual$description` binding is available. The demographic `Individual` fields require the same helper objects (#117, #133, #140).
- `create_molecule_list()` builds an observer's molecule list from `for_all`, `include`, and `exclude` (#119).
- `create_observed_data()` builds an `ospsuite::DataSet` from the `time()`, `values()`, and optional `error()` series value-object helpers. The values dimension is required and is supplied to `values()`, where it gates unit validation (#27, #48, #133). Attach with `add_observed_data()`, remove with `remove_observed_data()` (#39).
- `create_observer()` builds a single observer for an observer set, with arguments for name, type, dimension, formula, formula references, container criteria, and molecule list. `Observer` now exposes a lossless writable `container_criteria` field (preserving each criterion's `Type`), a writable `formula_references` field, and a writable `molecule_list` field, and validates `type` against `Amount`/`Container` on assignment (#119).
- `create_observer_set()` builds an observer set from a `name` and a list of observers (#43). Attach with `add_observer_set()`, remove with `remove_observer_set()` (#38).
- `create_parameter()` gains a `source_method` argument that carries the value-origin determination method to `ValueOrigin.Method`, so it round-trips (#151).
- `create_population()` builds a population, taking `Range` objects for age, weight, height, and BMI bounds, and accepting `description`, `gestational_age_range`, `disease_state_parameters`, and an `individual` composed from `create_individual()` to fully configure the population's base individual. `number_of_individuals` must be a positive integer; `proportion_of_females` must be a length-1 number. `Population` objects gain read/write `description`, `gestational_age_range`, and `disease_state_parameters` bindings and a read-only `individual` binding exposing the base individual (#27, #48, #118). Attach with `add_population()` (#39).
- `create_process()` builds a compound process; `internal_name` and `data_source` are validated (#40). See `?create_process` for the list of supported `internal_name` values.
- `create_protocol()` builds a Simple or Advanced protocol. Pass `schemas` to build an Advanced protocol (accepts `Schema` objects from `create_schema()` or raw lists); mixing Simple-only fields (`application_type`, `dosing_interval`, ...) with `schemas` errors out (#27, #48, #54). Attach with `add_protocol()`, remove with `remove_protocol()` (#39).
- `create_schema()` and `create_schema_item()` build the repeatable blocks and individual applications used inside an Advanced protocol. `application_type` on a schema item is validated against the canonical PK-Sim application types (#54).
- `create_snapshot()` creates an empty snapshot carrying the current supported PK-Sim version, optionally named and described, as a snapshot-level counterpart to `load_snapshot()` and `export_snapshot()` (#112).
- `get_default_alternative()` returns the name of the default alternative in a compound physicochemical-property group, for example `get_default_alternative(compound$solubility)`; printing such a group also flags the default alternative with `(Default)` (#147).
- `individual$origin_data` returns an `OriginData` object holding the demographic starting point of the individual (species, population, gender, age, weight, height, gestational age, calculation methods, optional disease state) (#30).
- `ObserverSet` objects are now fully supported end to end (load, mutate, convert, export). Each exposes its observers as a named list of `Observer` objects with `name`, `type`, `dimension`, `formula` (the full `ExplicitFormula` list), `formula_expression`, `formula_dimension`, `formula_references`, and `container_tags`. `get_observer_sets_dfs()` returns two tibbles (`observer_sets` for set-level rows, `observers` joinable back via `observer_set_id` / `observer_set_name`); the `observers` tibble carries `formula_expression`, `formula_dimension`, and `formula_references` columns alongside `name`, `type`, `dimension`, and `container_tags` (#38, #42, #76, #79).
- `protocol$schemas` returns a named list of `Schema` objects, each exposing `$items` as a list of `SchemaItem` objects (application type, formulation key, target organ and compartment, parameters) (#29).
- `remove_simulation()` removes one or more simulations from a `Snapshot` by name (#94).
- `Simulation` is now a first-class building block wrapping the simulation slice of a snapshot with R6 accessors for solver settings, output schemas, compound configurations, event and observer-set selections, observed-data references, output mappings, and `LocalizedParameter` overrides. Simulations are built through `add_simulation()` and loaded from snapshots; existing simulations are mutated in place through their live bindings. Four post-run fields (`Interactions`, `AlteredBuildingBlocks`, `IndividualAnalyses`, `PopulationAnalyses`) are preserved byte-equivalent through `$data`, and construction enforces an XOR on `$individual` and `$population` so that exactly one subject is configured (#94).
- Parameters that live in a parameter tree (under an `Individual`, `ExpressionProfile`, or `Simulation`) are now `LocalizedParameter` objects, identified by a pipe-separated path. Pre-v11 `Applications|...` segments are migrated to `Events|...` on load. `create_parameter()` routes to `LocalizedParameter` when called with a `path` argument (#31).

## Minor improvements and fixes

- `as_tibbles(snapshot, "protocols")` (and the legacy `get_protocols_dfs()` wrapper) now returns the same 13 columns whether the snapshot has any protocols or not. Previously the empty-state path returned an 18-column tibble that disagreed with the populated path, breaking `bind_rows()` across mixed snapshots (#56).
- `create_compound()` output can now be printed when `is_small_molecule` is left unset. Previously printing such a compound aborted with "missing value where TRUE/FALSE needed"; the type line is now omitted instead (#115).
- `create_protocol()` now validates `application_type` against the canonical PK-Sim application types and errors early on an invalid value, matching `create_schema_item()` (#121).
- `export_snapshot()` now serializes `DataSet` objects attached at runtime via `add_observed_data()`, so a snapshot built from `create_observed_data()` and `add_observed_data()` round-trips through `export_snapshot()` and `load_snapshot()`. Entries that were already present in the loaded snapshot are still replayed from the original JSON slice, which means post-load mutations to a `DataSet` (e.g. changing `xUnit` on an entry in `snapshot$observed_data`) are not reflected on export (#35, #96).
- `loadDataSetFromSnapshot()` now preserves the observed-data time unit (`BaseGrid$Unit`) on the resulting `DataSet$xUnit` for every ospsuite Time unit, including `"day(s)"`, `"week(s)"`, `"month(s)"`, `"year(s)"`, and `"ks"`. Previously only `"h"`, `"min"`, and `"s"` survived and any other unit silently reverted to `"h"`, misplacing time points (for example a 24x error for `day(s)`); this also affected `create_observed_data(time_unit = ...)` (#104).
- `Parameter$unit` validates only shape (a single non-empty string); dimension-aware unit validation is opportunistic since a bare `Parameter` carries no dimension. `Range$unit` remains unvalidated on the class itself; unit validation happens at the `Population` range setters that consume a `Range`. `Population$bmi_range`'s unit, `Compound$plasma_protein_binding_partner`, `AdvancedParameter$distribution_type`, the `Formulation` curated unit sub-parameters, and `CompoundProcessSelection$systemic_process_type` are validated at the strongest constraint confirmable in code; each documents its own fallback (#140).
- `Population$egfr_range` now persists into the population settings, so an eGFR range set on a population survives export (#118).
- `print()` on `snapshot$simulations` no longer errors. Previously it aborted because the `simulation_collection` kind was missing its print-dispatch methods, added for every other building-block collection (#149).
- `remove_expression_profile()`, `remove_formulation()`, `remove_individual()`, `remove_observed_data()`, and `remove_population()` now report the actual number of entries removed instead of the length of the input vector, so the success message reads correctly when a requested name is not present in the snapshot (#66).
- Building-block collections now share a `snapshot_collection` S3 class with a single generic `print()` method. The existing per-kind classes (`compound_collection`, `individual_collection`, ...) are preserved as marker classes (#34).
- Observed data removed via `remove_observed_data()` is now dropped from the exported snapshot. Previously the export reused the full original `ObservedData` list whenever the lazy cache had been touched, re-introducing the removed entries on round-trip. The same fix applies to every building-block section: clearing a collection via `remove_individual()`, `remove_formulation()`, `remove_population()`, or `remove_expression_profile()` now writes an empty section on export instead of falling back to the original entries (#35, #59).
- Single-element JSON arrays remain arrays on export/import, allowing exported snapshots to load in PK-Sim (#23).
- The eight category-keyed compound accessors (`$protein_binding_partners`, `$metabolizing_enzymes`, `$hepatic_clearance`, `$transporter_proteins`, `$renal_clearance`, `$biliary_clearance`, `$inhibition`, `$induction`) are soft-deprecated. Use `compound$processes` (filter by `process$category`) or the long-form `processes` tibble returned by `get_compounds_dfs()` (#40).

# osp.snapshots 0.2.2

## New features

- Extract Molecular Weight from Snapshot and include it in datasets (#18).

- Add support for importing y error values and related metadata from snapshot
  observed data.

## Bug fixes

- Fixed yValues units not being captured correctly from snapshot observed data.

- Fixed Snapshot failing to load when observed data contains unitless dimensions
  (#19).

# osp.snapshots 0.2.1

## Minor improvements and bug fixes

- New `osp_models()` function to browse and discover available OSP building block
  templates from the OSPSuite Community repository.

- Fixed bug in dataframe generation functions that caused errors when combining
  empty or NULL building block data using `bind_rows()`.

# osp.snapshots 0.2.0

- New `load_snapshot()` function to import PKSIM project snapshots from JSON
  files, URLs, or predefined templates.

- New `export_snapshot()` function to save modified snapshots back to JSON files
  for import into PKSIM.

- Complete R6 class implementations for all major PKSIM building blocks:
  `Individual`, `Compound`, `Formulation`, `Population`, `Protocol`, `Event`,
  `ExpressionProfile`, and `Parameter`.

- New data frame conversion functions for all building block types:
  `get_individuals_dfs()`, `get_compounds_dfs()`, `get_formulations_dfs()`,
  `get_populations_dfs()`, `get_protocols_dfs()`, `get_events_dfs()`,
  `get_expression_profiles_dfs()`, and `get_observed_data_dfs()`.

- New creation functions: `create_individual()`, `create_formulation()`, and
  `create_parameter()` for building new building blocks.

- New management functions: `add_individual()`, `add_formulation()`,
  `add_expression_profile()`, `remove_individual()`, `remove_formulation()`,
  `remove_population()`, and `remove_expression_profile()`.

- Full integration with `ospsuite::DataSet` objects for observed data.

- Comprehensive input validation for species, populations, genders, and units.

- Time conversion utilities between OSPSuite and R `lubridate` formats.

- Structured print methods for all building block classes.

# osp.snapshots 0.1.0

- Prototype release of the `osp.snapshots` package for managing PKSIM project
  snapshots in R.
