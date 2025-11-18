# Package index

## Import and Export

Load snapshots and export modifications

- [`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/load_snapshot.md)
  : Load a snapshot from various sources
- [`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/export_snapshot.md)
  : Export a snapshot to a JSON file
- [`osp_models()`](https://esqlabs.github.io/osp.snapshots/dev/reference/osp_models.md)
  : Browse available OSPSuite building block templates

## Core Classes

Main classes for working with snapshots and building blocks

- [`Snapshot`](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  : Snapshot class for OSP snapshots
- [`Individual`](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md)
  : Individual class for OSP snapshot individuals
- [`Compound`](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
  : Compound class for OSP snapshot compounds
- [`Formulation`](https://esqlabs.github.io/osp.snapshots/dev/reference/Formulation.md)
  : Formulation class for OSP snapshot formulations
- [`Population`](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
  : Population class for OSP snapshot populations
- [`Protocol`](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
  : Protocol class for OSP snapshot protocols
- [`Event`](https://esqlabs.github.io/osp.snapshots/dev/reference/Event.md)
  : Event class for OSP snapshot events
- [`ExpressionProfile`](https://esqlabs.github.io/osp.snapshots/dev/reference/ExpressionProfile.md)
  : ExpressionProfile class for OSP snapshot expression profiles
- [`Parameter`](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  : Parameter class for OSP snapshot parameters
- [`AdvancedParameter`](https://esqlabs.github.io/osp.snapshots/dev/reference/AdvancedParameter.md)
  : AdvancedParameter class for Population advanced parameters
- [`range()`](https://esqlabs.github.io/osp.snapshots/dev/reference/Range.md)
  : Create a range object for physiological parameters

## Create Building Blocks

Functions to create new building blocks from scratch

- [`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)
  : Create a new individual
- [`create_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_formulation.md)
  : Create a new formulation
- [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_parameter.md)
  : Create a new parameter

## Manage Building Blocks

Add and remove building blocks from snapshots

- [`add_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_individual.md)
  : Add an individual to a snapshot
- [`add_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_formulation.md)
  : Add a formulation to a snapshot
- [`add_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_expression_profile.md)
  : Add an expression profile to a snapshot
- [`remove_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_individual.md)
  : Remove individuals from a snapshot
- [`remove_formulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_formulation.md)
  : Remove formulations from a snapshot
- [`remove_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_population.md)
  : Remove populations from a snapshot
- [`remove_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/remove_expression_profile.md)
  : Remove expression profiles from a snapshot

## Data Frame Conversion

Convert building blocks to data frames for analysis

- [`get_individuals_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_individuals_dfs.md)
  : Get all individuals in a snapshot as data frames
- [`get_compounds_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_compounds_dfs.md)
  : Get all compounds in a snapshot as data frames
- [`get_formulations_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_formulations_dfs.md)
  : Get all formulations in a snapshot as data frames
- [`get_populations_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_populations_dfs.md)
  : Get all populations in a snapshot as data frames
- [`get_protocols_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_protocols_dfs.md)
  : Get all protocols in a snapshot as a single consolidated data frame
- [`get_events_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_events_dfs.md)
  : Get all events in a snapshot as data frames
- [`get_expression_profiles_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_expression_profiles_dfs.md)
  : Get all expression profiles in a snapshot as data frames
- [`get_observed_data_dfs()`](https://esqlabs.github.io/osp.snapshots/dev/reference/get_observed_data_dfs.md)
  : Get all observed data in a snapshot as data frames

## Observed Data

Work with clinical and experimental data

- [`loadDataSetFromSnapshot()`](https://esqlabs.github.io/osp.snapshots/dev/reference/loadDataSetFromSnapshot.md)
  : Load DataSet from OSP snapshot observed data

## Validation and Utilities

Helper functions for validation and data conversion

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

## Print Methods

Formatted display methods for building block collections

- [`print(`*`<biliary_clearance>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.biliary_clearance.md)
  : Print method for biliary clearance processes
- [`print(`*`<compound_additional_parameters>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.compound_additional_parameters.md)
  : Print method for compound additional parameters
- [`print(`*`<compound_calculation_methods>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.compound_calculation_methods.md)
  : Print method for compound calculation methods
- [`print(`*`<compound_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.compound_collection.md)
  : S3 print method for compound collections
- [`print(`*`<compound_processes>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.compound_processes.md)
  : S3 print method for compound processes
- [`print(`*`<event_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.event_collection.md)
  : S3 print method for event collections
- [`print(`*`<expression_profile_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.expression_profile_collection.md)
  : S3 print method for expression profile collections
- [`print(`*`<formulation_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.formulation_collection.md)
  : S3 print method for formulation collections
- [`print(`*`<hepatic_clearance>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.hepatic_clearance.md)
  : Print method for hepatic clearance processes
- [`print(`*`<individual_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.individual_collection.md)
  : S3 print method for individual collections
- [`print(`*`<induction>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.induction.md)
  : Print method for induction processes
- [`print(`*`<inhibition>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.inhibition.md)
  : Print method for inhibition processes
- [`print(`*`<metabolizing_enzymes>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.metabolizing_enzymes.md)
  : Print method for metabolizing enzymes
- [`print(`*`<observed_data_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.observed_data_collection.md)
  : Print method for observed data collection
- [`print(`*`<parameter_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.parameter_collection.md)
  : Print method for parameter collections
- [`print(`*`<physicochemical_property>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.physicochemical_property.md)
  : S3 print method for physicochemical properties
- [`print(`*`<population_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.population_collection.md)
  : S3 print method for population collections
- [`print(`*`<protein_binding_partners>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.protein_binding_partners.md)
  : Print method for protein binding partners
- [`print(`*`<protocol_collection>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.protocol_collection.md)
  : S3 print method for protocol collections
- [`print(`*`<renal_clearance>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.renal_clearance.md)
  : Print method for renal clearance processes
- [`print(`*`<transporter_proteins>`*`)`](https://esqlabs.github.io/osp.snapshots/dev/reference/print.transporter_proteins.md)
  : Print method for transporter proteins
