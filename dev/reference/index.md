# Package index

## Import and export

Load snapshots and export modifications

- [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
  : Load a snapshot from various sources
- [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  : Export a snapshot to a JSON file
- [`create_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_snapshot.md)
  : Create an empty snapshot
- [`osp_models()`](https://esqlabs.github.io/osp.snapshots/dev/reference/osp_models.md)
  : Browse available OSPSuite building block templates

## Building blocks

R6 classes wrapping the PK-Sim building blocks and the root snapshot

- [`Snapshot`](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  : Snapshot class for OSP snapshots
- [`Compound`](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
  : Compound class for OSP snapshot compounds
- [`Event`](https://esqlabs.github.io/osp.snapshots/dev/reference/Event.md)
  : Event class for OSP snapshot events
- [`ExpressionProfile`](https://esqlabs.github.io/osp.snapshots/dev/reference/ExpressionProfile.md)
  : ExpressionProfile class for OSP snapshot expression profiles
- [`Formulation`](https://esqlabs.github.io/osp.snapshots/dev/reference/Formulation.md)
  : Formulation class for OSP snapshot formulations
- [`Individual`](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md)
  : Individual class for OSP snapshot individuals
- [`ObserverSet`](https://esqlabs.github.io/osp.snapshots/dev/reference/ObserverSet.md)
  : ObserverSet class for OSP snapshot observer sets
- [`Population`](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
  : Population class for OSP snapshot populations
- [`Protocol`](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
  : Protocol class for OSP snapshot protocols
- [`Simulation`](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
  : Simulation class for OSP snapshot simulations

## Leaf and sub-structure types

Reusable R6 leaf classes and sub-structures held inside building blocks

- [`AdvancedParameter`](https://esqlabs.github.io/osp.snapshots/dev/reference/AdvancedParameter.md)
  : AdvancedParameter class for Population advanced parameters
- [`CalculationMethods`](https://esqlabs.github.io/osp.snapshots/dev/reference/CalculationMethods.md)
  : CalculationMethods class for OSP snapshots
- [`CompoundProcessSelection`](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProcessSelection.md)
  : CompoundProcessSelection class for compound process selections
- [`EventSelection`](https://esqlabs.github.io/osp.snapshots/dev/reference/EventSelection.md)
  : EventSelection class for Simulation event references
- [`FormulationSelection`](https://esqlabs.github.io/osp.snapshots/dev/reference/FormulationSelection.md)
  : FormulationSelection class for Simulation compound formulations
- [`LocalizedParameter`](https://esqlabs.github.io/osp.snapshots/dev/reference/LocalizedParameter.md)
  : LocalizedParameter class for path-bearing OSP snapshot parameters
- [`Observer`](https://esqlabs.github.io/osp.snapshots/dev/reference/Observer.md)
  : Observer class for OSP snapshot observer sets
- [`ObserverSetSelection`](https://esqlabs.github.io/osp.snapshots/dev/reference/ObserverSetSelection.md)
  : ObserverSetSelection class for Simulation observer-set references
- [`OriginData`](https://esqlabs.github.io/osp.snapshots/dev/reference/OriginData.md)
  : OriginData class for OSP snapshot individuals
- [`OutputInterval`](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputInterval.md)
  : OutputInterval class for Simulation output schemas
- [`OutputMapping`](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputMapping.md)
  : OutputMapping class for simulation output-to-observed-data mappings
- [`OutputSchema`](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputSchema.md)
  : OutputSchema class for Simulation output schedules
- [`Parameter`](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  : Parameter class for OSP snapshot parameters
- [`Process`](https://esqlabs.github.io/osp.snapshots/dev/reference/Process.md)
  : Process class for OSP snapshot compound processes
- [`ProtocolSelection`](https://esqlabs.github.io/osp.snapshots/dev/reference/ProtocolSelection.md)
  : ProtocolSelection class for Simulation compound protocol assignments
- [`Schema`](https://esqlabs.github.io/osp.snapshots/dev/reference/Schema.md)
  : Schema class for OSP advanced protocols
- [`SchemaItem`](https://esqlabs.github.io/osp.snapshots/dev/reference/SchemaItem.md)
  : SchemaItem class for OSP advanced protocols
- [`SolverSettings`](https://esqlabs.github.io/osp.snapshots/dev/reference/SolverSettings.md)
  : SolverSettings class for simulation solver configuration
- [`range()`](https://esqlabs.github.io/osp.snapshots/dev/reference/range.md)
  : Create a range object for physiological parameters
- [`Range-class`](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  [`Range`](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  : Range class for physiological parameters

## Factories

Construct building blocks and leaves from named arguments

- [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  : Create a new compound
- [`create_compound_process_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound_process_selection.md)
  : Create a compound process selection
- [`create_descriptor_condition()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_descriptor_condition.md)
  : Create a container criterion for an observer
- [`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md)
  : Create a new event
- [`create_event_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event_selection.md)
  : Create an event selection for a simulation
- [`create_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_expression_profile.md)
  : Create a new expression profile
- [`create_formula_reference()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formula_reference.md)
  : Create a formula reference for an observer
- [`create_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation.md)
  : Create a new formulation
- [`create_formulation_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation_selection.md)
  : Create a formulation selection for a simulation compound
- [`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)
  : Create a new individual
- [`create_molecule_list()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_molecule_list.md)
  : Create a molecule list for an observer
- [`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
  : Create a new observed data set
- [`create_observer()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer.md)
  : Create a new observer
- [`create_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set.md)
  : Create a new observer set
- [`create_observer_set_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer_set_selection.md)
  : Create an observer-set selection for a simulation
- [`create_output_interval()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_interval.md)
  : Create an output interval for a simulation output schema
- [`create_output_mapping()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_mapping.md)
  : Create an output-to-observed-data mapping for a simulation
- [`create_output_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_output_schema.md)
  : Create an output schema for a simulation
- [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  : Create a new parameter
- [`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md)
  : Create a new population
- [`create_process()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_process.md)
  : Create a new compound process
- [`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md)
  : Create a new protocol
- [`create_protocol_selection()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol_selection.md)
  : Create a protocol selection for a simulation compound
- [`create_schema()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema.md)
  : Create a new schema
- [`create_schema_item()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_schema_item.md)
  : Create a new schema item
- [`create_solver_settings()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_solver_settings.md)
  : Create a solver settings object for a simulation

## Value-object helpers

Bundle a value, unit, and field-specific extras for the create\_\*
factory arguments

- [`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md)
  : Lipophilicity value object
- [`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md)
  : Fraction unbound value object
- [`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md)
  : Solubility value object
- [`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md)
  : Intestinal permeability value object
- [`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md)
  : Permeability value object
- [`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md)
  : Age value object
- [`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)
  : Weight value object
- [`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md)
  : Height value object
- [`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md)
  : Gestational age value object
- [`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md)
  : Time series value object
- [`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md)
  : Measurement values series value object
- [`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md)
  : Error series value object

## Mutators

Add and remove building blocks on a snapshot

- [`add_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_compound.md)
  : Add one or more compounds to a snapshot
- [`add_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_event.md)
  : Add one or more events to a snapshot
- [`add_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_expression_profile.md)
  : Add one or more expression profiles to a snapshot
- [`add_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_formulation.md)
  : Add one or more formulations to a snapshot
- [`add_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_individual.md)
  : Add one or more individuals to a snapshot
- [`add_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_observed_data.md)
  : Add one or more observed-data entries to a snapshot
- [`add_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_observer_set.md)
  : Add one or more observer sets to a snapshot
- [`add_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_population.md)
  : Add one or more populations to a snapshot
- [`add_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_protocol.md)
  : Add one or more protocols to a snapshot
- [`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)
  : Build a simulation from a snapshot and attach it
- [`remove_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_compound.md)
  : Remove compounds from a snapshot
- [`remove_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_event.md)
  : Remove events from a snapshot
- [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_expression_profile.md)
  : Remove expression profiles from a snapshot
- [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_formulation.md)
  : Remove formulations from a snapshot
- [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_individual.md)
  : Remove individuals from a snapshot
- [`remove_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observed_data.md)
  : Remove observed data from a snapshot
- [`remove_observer_set()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_observer_set.md)
  : Remove observer sets from a snapshot
- [`remove_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_population.md)
  : Remove populations from a snapshot
- [`remove_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_protocol.md)
  : Remove protocols from a snapshot
- [`remove_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_simulation.md)
  : Remove simulations from a snapshot

## Tibble exporters

Convert building blocks to tibbles for analysis

- [`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
  : Convert a snapshot collection to a tibble or list of tibbles
- [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
  : Get all compounds in a snapshot as data frames
- [`get_events_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_events_dfs.md)
  : Get all events in a snapshot as data frames
- [`get_expression_profiles_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_expression_profiles_dfs.md)
  : Get all expression profiles in a snapshot as data frames
- [`get_formulations_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_formulations_dfs.md)
  : Get all formulations in a snapshot as data frames
- [`get_individuals_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_individuals_dfs.md)
  : Get all individuals in a snapshot as data frames
- [`get_observed_data_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_observed_data_dfs.md)
  : Get all observed data in a snapshot as a tibble
- [`get_observer_sets_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_observer_sets_dfs.md)
  : Get all observer sets in a snapshot as data frames
- [`get_populations_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_populations_dfs.md)
  : Get all populations in a snapshot as data frames
- [`get_protocols_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_protocols_dfs.md)
  : Get all protocols in a snapshot as a single consolidated data frame

## Observed data

Bridge between PK-Sim observed data and ospsuite

- [`loadDataSetFromSnapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/loadDataSetFromSnapshot.md)
  : Load DataSet from OSP snapshot observed data

## Validators and utilities

Helpers for validation and data conversion

- [`validate_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_snapshot.md)
  : Validate that an object is a Snapshot
- [`validate_species()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_species.md)
  : Validate that a species is valid
- [`validate_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_population.md)
  : Validate that a population is valid
- [`validate_gender()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_gender.md)
  : Validate that a gender is valid
- [`validate_unit()`](https://esqlabs.github.io/osp.snapshots/dev/reference/validate_unit.md)
  : Validate that a unit is valid for a given dimension
- [`convert_ospsuite_time_unit_to_lubridate()`](https://esqlabs.github.io/osp.snapshots/dev/reference/convert_ospsuite_time_unit_to_lubridate.md)
  : Convert ospsuite time units to lubridate-compatible units
- [`convert_ospsuite_time_to_duration()`](https://esqlabs.github.io/osp.snapshots/dev/reference/convert_ospsuite_time_to_duration.md)
  : Convert time value and unit to lubridate duration

## Print methods

Formatted display methods for building block collections

- [`print(`*`<biliary_clearance>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.biliary_clearance.md)
  : Print method for biliary clearance processes
- [`print(`*`<compound_additional_parameters>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.compound_additional_parameters.md)
  : Print method for compound additional parameters
- [`print(`*`<compound_processes>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.compound_processes.md)
  : S3 print method for compound processes
- [`print(`*`<hepatic_clearance>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.hepatic_clearance.md)
  : Print method for hepatic clearance processes
- [`print(`*`<induction>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.induction.md)
  : Print method for induction processes
- [`print(`*`<inhibition>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.inhibition.md)
  : Print method for inhibition processes
- [`print(`*`<metabolizing_enzymes>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.metabolizing_enzymes.md)
  : Print method for metabolizing enzymes
- [`print(`*`<parameter_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.parameter_collection.md)
  : Print method for parameter collections
- [`print(`*`<physicochemical_property>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.physicochemical_property.md)
  : S3 print method for physicochemical properties
- [`print(`*`<protein_binding_partners>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.protein_binding_partners.md)
  : Print method for protein binding partners
- [`print(`*`<renal_clearance>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.renal_clearance.md)
  : Print method for renal clearance processes
- [`print(`*`<snapshot_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.snapshot_collection.md)
  : Generic print method for snapshot collections
- [`print(`*`<transporter_proteins>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.transporter_proteins.md)
  : Print method for transporter proteins
