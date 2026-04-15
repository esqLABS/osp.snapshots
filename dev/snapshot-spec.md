# PKSim Snapshot-to-Project Specification

This document specifies how PKSim JSON snapshot files are converted into
PKSim domain objects. Each section describes a snapshot type, its
properties, and how each property maps into the domain model during the
JSON-to-Project conversion driven by `PKSim.CLI snap -p`.

------------------------------------------------------------------------

## Project

The top-level snapshot object. All other snapshots are nested arrays
within it.

| Property                                 | Type                                                    | Required | Domain Mapping                                                                                                                                                                                  |
|------------------------------------------|---------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Version`                                | `int`                                                   | Yes      | Sets `PKSimProject.Creation.InternalVersion`. Used to create a `SnapshotContext` that controls version-specific mapping behavior throughout the entire conversion. Current version: `80` (v12). |
| `Name`                                   | `string`                                                | No       | `PKSimProject.Name` (also overridden by the input filename).                                                                                                                                    |
| `Description`                            | `string`                                                | No       | `PKSimProject.Description`.                                                                                                                                                                     |
| `ExpressionProfiles`                     | [ExpressionProfile](#expressionprofile)\[\]             | No       | Mapped first and added to the project before any other building blocks, because Individuals reference them by name.                                                                             |
| `Individuals`                            | [Individual](#individual)\[\]                           | No       | Mapped via `IndividualMapper`, added to project as building blocks.                                                                                                                             |
| `Populations`                            | [Population](#population)\[\]                           | No       | Mapped via `PopulationMapper`, added to project as building blocks.                                                                                                                             |
| `Compounds`                              | [Compound](#compound)\[\]                               | No       | Mapped via `CompoundMapper`, added to project as building blocks.                                                                                                                               |
| `Formulations`                           | [Formulation](#formulation)\[\]                         | No       | Mapped via `FormulationMapper`, added to project as building blocks.                                                                                                                            |
| `Protocols`                              | [Protocol](#protocol)\[\]                               | No       | Mapped via `ProtocolMapper`, added to project as building blocks.                                                                                                                               |
| `ObserverSets`                           | [ObserverSet](#observerset)\[\]                         | No       | Mapped via `ObserverSetMapper`, added to project as building blocks.                                                                                                                            |
| `Events`                                 | [Event](#event)\[\]                                     | No       | Mapped via `EventMapper`, added to project as building blocks.                                                                                                                                  |
| `Simulations`                            | [Simulation](#simulation)\[\]                           | No       | Mapped sequentially via `SimulationMapper`. Each simulation references building blocks by name from the project.                                                                                |
| `ObservedData`                           | [DataRepository](#datarepository-observed-data)\[\]     | No       | Mapped via `DataRepositoryMapper`, added to project as observed data.                                                                                                                           |
| `ParameterIdentifications`               | [ParameterIdentification](#parameteridentification)\[\] | No       | Mapped via `ParameterIdentificationMapper`. References simulations by name.                                                                                                                     |
| `SimulationComparisons`                  | [SimulationComparison](#simulationcomparison)\[\]       | No       | Mapped via `SimulationComparisonMapper`. References simulations by name.                                                                                                                        |
| `ObservedDataClassifications`            | [Classification](#classification)\[\]                   | No       | Folder hierarchy for observed data. Applied after all data is loaded.                                                                                                                           |
| `SimulationClassifications`              | [Classification](#classification)\[\]                   | No       | Folder hierarchy for simulations.                                                                                                                                                               |
| `SimulationComparisonClassifications`    | [Classification](#classification)\[\]                   | No       | Folder hierarchy for simulation comparisons.                                                                                                                                                    |
| `ParameterIdentificationClassifications` | [Classification](#classification)\[\]                   | No       | Folder hierarchy for parameter identifications.                                                                                                                                                 |

**Loading order**: ExpressionProfiles -\> (Individuals, Compounds,
Events, Formulations, Protocols, Populations, ObserverSets) -\>
ObservedData -\> Simulations -\> SimulationComparisons -\>
ParameterIdentifications -\> Classifications.

**Duplicate detection**: If two building blocks of the same type share a
name, the second is skipped and an error is logged.

------------------------------------------------------------------------

## Compound

Created via `ICompoundFactory.Create()`.

| Property                      | Type                                                         | Required | Domain Mapping                                                                                                                                                                                          |
|-------------------------------|--------------------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`                        | `string`                                                     | No       | `Compound.Name`                                                                                                                                                                                         |
| `Description`                 | `string`                                                     | No       | `Compound.Description`                                                                                                                                                                                  |
| `IsSmallMolecule`             | `bool?`                                                      | No       | `Compound.IsSmallMolecule`. Defaults to `true`.                                                                                                                                                         |
| `PlasmaProteinBindingPartner` | [PlasmaProteinBindingPartner](#plasmaproteinbindingpartner)? | No       | `Compound.PlasmaProteinBindingPartner`. Defaults to `Unknown`.                                                                                                                                          |
| `CalculationMethods`          | [CalculationMethodCache](#calculationmethodcache)            | No       | Updates `Compound.CalculationMethodCache`. Each string name is looked up in the calculation method repository and added.                                                                                |
| `Lipophilicity`               | [Alternative](#alternative)\[\]                              | No       | Mapped to the `COMPOUND_LIPOPHILICITY` alternative group. Existing non-calculated alternatives are removed and replaced.                                                                                |
| `FractionUnbound`             | [Alternative](#alternative)\[\]                              | No       | Mapped to the `COMPOUND_FRACTION_UNBOUND` alternative group.                                                                                                                                            |
| `Solubility`                  | [Alternative](#alternative)\[\]                              | No       | Mapped to the `COMPOUND_SOLUBILITY` alternative group. Has special handling for table-based solubility formulas.                                                                                        |
| `IntestinalPermeability`      | [Alternative](#alternative)\[\]                              | No       | Mapped to the `COMPOUND_INTESTINAL_PERMEABILITY` alternative group.                                                                                                                                     |
| `Permeability`                | [Alternative](#alternative)\[\]                              | No       | Mapped to the `COMPOUND_PERMEABILITY` alternative group.                                                                                                                                                |
| `PkaTypes`                    | [PkaType](#pkatype)\[\]                                      | No       | Each entry sets the compound type parameter (`ParameterCompoundType(index)`) and pKa value parameter (`ParameterPKa(index)`) on the compound. Value origins are synchronized across all pKa parameters. |
| `Processes`                   | [CompoundProcess](#compoundprocess)\[\]                      | No       | Each process is mapped via `CompoundProcessMapper` and added to the compound via `Compound.AddProcess()`.                                                                                               |
| `Parameters`                  | [Parameter](#parameter)\[\]                                  | No       | User-overridden parameters mapped via `ParameterMapper` onto the compound’s parameter container.                                                                                                        |

------------------------------------------------------------------------

## Individual

Created via `IIndividualFactory.CreateAndOptimizeFor(originData, seed)`.

| Property             | Type                                          | Required | Domain Mapping                                                                                                                                                                                                                  |
|----------------------|-----------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`               | `string`                                      | No       | `Individual.Name`                                                                                                                                                                                                               |
| `Description`        | `string`                                      | No       | `Individual.Description`                                                                                                                                                                                                        |
| `Seed`               | `int?`                                        | No       | Passed to the factory as the random seed for individual creation.                                                                                                                                                               |
| `OriginData`         | [OriginData](#origindata)                     | No       | Mapped via `OriginDataMapper` first. The resulting domain `OriginData` is passed to the factory to create the individual.                                                                                                       |
| `ExpressionProfiles` | `string[]`                                    | No       | Array of [ExpressionProfile](#expressionprofile) names. Each name is resolved from the project’s building blocks and added to the individual via `IMoleculeExpressionTask.AddExpressionProfile()`. Only used in v11+ snapshots. |
| `Molecules`          | [ExpressionProfile](#expressionprofile)\[\]   | No       | **Legacy (v10 and below)**. Embedded expression profile snapshots. Converted to standalone `ExpressionProfile` building blocks during loading and added to the project. The individual then references them by name.            |
| `Parameters`         | [LocalizedParameter](#localizedparameter)\[\] | No       | Mapped via `ParameterMapper.MapLocalizedParameters()` onto the individual’s parameter tree.                                                                                                                                     |

------------------------------------------------------------------------

## Population

Created via
`IRandomPopulationFactory.CreateFor(settings, cancellationToken, seed)`.

| Property             | Type                                        | Required | Domain Mapping                                                                                                         |
|----------------------|---------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------|
| `Name`               | `string`                                    | No       | `Population.Name`                                                                                                      |
| `Description`        | `string`                                    | No       | `Population.Description`                                                                                               |
| `Seed`               | `int?`                                      | No       | Passed to the factory as the random seed for population generation.                                                    |
| `Settings`           | [PopulationSettings](#populationsettings)   | Yes      | Mapped via `RandomPopulationSettingsMapper`. Defines the number of individuals and parameter ranges.                   |
| `AdvancedParameters` | [AdvancedParameter](#advancedparameter)\[\] | No       | Applied after population creation via `AdvancedParameterMapper`. These override the default variability distributions. |

The factory is called with `addMoleculeParametersVariability: false` to
prevent default variability (since it will come from the snapshot’s
advanced parameters instead).

------------------------------------------------------------------------

## ExpressionProfile

Created via `IExpressionProfileFactory.Create(type, species, molecule)`.

| Property                            | Type                                                                     | Required | Domain Mapping                                                                                                                                                                        |
|-------------------------------------|--------------------------------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Type`                              | [QuantityType](#quantitytype)                                            | Yes      | Molecule type (Enzyme, Transporter, or other protein type). Passed to the factory.                                                                                                    |
| `Species`                           | `string`                                                                 | Yes      | Species name. Resolved to a `Species` object and passed to the factory.                                                                                                               |
| `Molecule`                          | `string`                                                                 | Yes      | Molecule name. Passed to the factory.                                                                                                                                                 |
| `Category`                          | `string`                                                                 | Yes      | `ExpressionProfile.Category`. The expression profile name is a composite: `Molecule|Species|Category`.                                                                                |
| `Description`                       | `string`                                                                 | No       | `ExpressionProfile.Description`                                                                                                                                                       |
| `Localization`                      | [Localization](#localization)?                                           | No       | For proteins: sets expression localization via `IMoleculeExpressionTask.SetExpressionLocalizationFor()`. Used in v10+ snapshots.                                                      |
| `MembraneLocation`                  | [MembraneLocation](#membranelocation)?                                   | No       | **Legacy (v9 and below)**. Combined with `TissueLocation` and `IntracellularVascularEndoLocation` and converted to a [Localization](#localization) value via `LocalizationConverter`. |
| `TissueLocation`                    | [TissueLocation](#tissuelocation)?                                       | No       | **Legacy (v9 and below)**. See `MembraneLocation`.                                                                                                                                    |
| `IntracellularVascularEndoLocation` | [IntracellularVascularEndoLocation](#intracellularvascularendolocation)? | No       | **Legacy (v9 and below)**. See `MembraneLocation`.                                                                                                                                    |
| `TransportType`                     | [TransportType](#transporttype)?                                         | No       | For transporters: sets transporter type via `IMoleculeExpressionTask.SetTransporterTypeFor()`.                                                                                        |
| `Ontogeny`                          | [Ontogeny](#ontogeny)                                                    | No       | Mapped via `OntogenyMapper`. Sets ontogeny data for the molecule.                                                                                                                     |
| `Expression`                        | [ExpressionContainer](#expressioncontainer)\[\]                          | No       | Array of expression containers mapped via `ExpressionContainerMapper`. Each entry defines relative expression values per organ/compartment.                                           |
| `Parameters`                        | [LocalizedParameter](#localizedparameter)\[\]                            | No       | Mapped onto the expression profile’s individual parameters.                                                                                                                           |
| `Disease`                           | [DiseaseState](#diseasestate)                                            | No       | Mapped via `DiseaseStateMapper`. Applied to the expression profile’s origin data.                                                                                                     |

**Version behavior**: In v9 or earlier, after mapping, relative
expressions are normalized and default molecule parameters are loaded.

------------------------------------------------------------------------

## Simulation

Created via
`ISimulationFactory.CreateFrom(simulationSubject, compounds, modelProperties)`,
then `ISimulationModelCreator.CreateModelFor(simulation)`.

| Property                | Type                                                    | Required | Domain Mapping                                                                                                                                                                                                   |
|-------------------------|---------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`                  | `string`                                                | No       | `Simulation.Name`                                                                                                                                                                                                |
| `Description`           | `string`                                                | No       | `Simulation.Description`                                                                                                                                                                                         |
| `Model`                 | `string`                                                | Yes      | Model name (e.g. `"4Comp"`). Passed to `IModelPropertiesTask.DefaultFor()` to build `ModelProperties`, which is then passed to the simulation factory.                                                           |
| `AllowAging`            | `bool?`                                                 | No       | `Simulation.AllowAging`. Defaults to `false`.                                                                                                                                                                    |
| `Individual`            | `string`                                                | No       | Name of the Individual building block. Resolved from the project by name. Used as the simulation subject for individual simulations.                                                                             |
| `Population`            | `string`                                                | No       | Name of the Population building block. Resolved from the project by name. Used as the simulation subject for population simulations. Presence of this field determines that a `PopulationSimulation` is created. |
| `Compounds`             | [CompoundProperties](#compoundproperties)\[\]           | No       | Each entry configures one compound in the simulation. The compound is resolved by `Name` from the project.                                                                                                       |
| `Events`                | [EventSelection](#eventselection)\[\]                   | No       | Mapped via `EventMappingMapper`. Each event is resolved by name from the project and added to the simulation’s `EventProperties`.                                                                                |
| `ObserverSets`          | [ObserverSetSelection](#observersetselection)\[\]       | No       | Mapped via `ObserverSetMappingMapper`. Each observer set is resolved by name.                                                                                                                                    |
| `ObservedData`          | `string[]`                                              | No       | Array of observed data names. Each is resolved from `project.AllObservedData` by name and added to the simulation’s `UsedObservedData`.                                                                          |
| `Solver`                | [SolverSettings](#solversettings)                       | No       | Mapped via `SolverSettingsMapper`.                                                                                                                                                                               |
| `OutputSchema`          | [OutputSchema](#outputschema)                           | No       | Mapped via `OutputSchemaMapper`.                                                                                                                                                                                 |
| `OutputSelections`      | [OutputSelections](#outputselections)                   | No       | Mapped via `OutputSelectionsMapper`. Each string path is resolved against the simulation’s quantity tree.                                                                                                        |
| `OutputMappings`        | [OutputMapping](#outputmapping)\[\]                     | No       | Mapped via `OutputMappingMapper`. Each mapping links a simulation output path to observed data.                                                                                                                  |
| `Parameters`            | [LocalizedParameter](#localizedparameter)\[\]           | No       | Overridden simulation parameters. Mapped via `ParameterMapper.MapLocalizedParameters()` onto the simulation model root. After mapping, changes are synced back to the simulation’s used building blocks.         |
| `AdvancedParameters`    | [AdvancedParameter](#advancedparameter)\[\]             | No       | Only for population simulations. Mapped via `AdvancedParameterMapper`.                                                                                                                                           |
| `Interactions`          | [CompoundProcessSelection](#compoundproperties)\[\]     | No       | Interaction selections. Each process is resolved by name from the compound. Unselected interactions create `NoInteractionProcess` placeholders.                                                                  |
| `AlteredBuildingBlocks` | [AlteredBuildingBlock](#alteredbuildingblock)\[\]       | No       | Marks which building blocks have been modified within this simulation. Sets `UsedBuildingBlock.Altered = true`.                                                                                                  |
| `IndividualAnalyses`    | [CurveChart](#curvechart)\[\]                           | No       | Chart analyses for individual simulations. Mapped via `SimulationTimeProfileChartMapper`.                                                                                                                        |
| `PopulationAnalyses`    | [PopulationAnalysisChart](#populationanalysischart)\[\] | No       | Chart analyses for population simulations. Mapped via `PopulationAnalysisChartMapper`.                                                                                                                           |
| `HasResults`            | `bool`                                                  | No       | If `true` and the context’s `RunSimulations` is `true`, the simulation is executed via `ISimulationRunner.RunSimulation()` after mapping.                                                                        |

------------------------------------------------------------------------

## Protocol

Created via `IProtocolFactory.Create(mode, applicationType)`. Protocol
type is determined by the snapshot: if `ApplicationType` is present, a
`SimpleProtocol` is created; otherwise an `AdvancedProtocol` is created
from `Schemas`.

### Simple Protocol

| Property            | Type                                  | Required | Domain Mapping                                                                             |
|---------------------|---------------------------------------|----------|--------------------------------------------------------------------------------------------|
| `Name`              | `string`                              | No       | `SimpleProtocol.Name`                                                                      |
| `ApplicationType`   | `string`                              | No       | Resolved via `ApplicationTypes.ByName()`. Determines the application type (e.g. IV, Oral). |
| `DosingInterval`    | [DosingIntervalId](#dosingintervalid) | No       | Resolved via `DosingIntervals.ById()`.                                                     |
| `TargetOrgan`       | `string`                              | No       | `SimpleProtocol.TargetOrgan`                                                               |
| `TargetCompartment` | `string`                              | No       | `SimpleProtocol.TargetCompartment`                                                         |
| `Parameters`        | [Parameter](#parameter)\[\]           | No       | Mapped onto the protocol’s parameters (dose, end time, etc.).                              |

### Advanced Protocol

| Property   | Type                                    | Required | Domain Mapping                                                                                   |
|------------|-----------------------------------------|----------|--------------------------------------------------------------------------------------------------|
| `Name`     | `string`                                | No       | `AdvancedProtocol.Name`                                                                          |
| `TimeUnit` | `string`                                | No       | Resolved via `IDimensionRepository.Time.UnitOrDefault()`. Sets the protocol’s time display unit. |
| `Schemas`  | [Schema](#schema-advanced-protocol)\[\] | No       | Mapped via `SchemaMapper`. All existing schemas are removed, then mapped schemas are added.      |

------------------------------------------------------------------------

## Formulation

Created by cloning a template:
`IFormulationRepository.FormulationBy(formulationType)` then
`ICloner.Clone(template)`.

| Property          | Type                        | Required | Domain Mapping                                                                                                          |
|-------------------|-----------------------------|----------|-------------------------------------------------------------------------------------------------------------------------|
| `Name`            | `string`                    | No       | `Formulation.Name`                                                                                                      |
| `FormulationType` | `string`                    | Yes      | Key used to look up the template formulation from the repository. The template is cloned to create the domain instance. |
| `Parameters`      | [Parameter](#parameter)\[\] | No       | Mapped onto the cloned formulation’s parameters. After mapping, `UpdateParticleParametersVisibility()` is called.       |

------------------------------------------------------------------------

## Event

Created via `IEventFactory.Create(templateName)`.

| Property     | Type                        | Required | Domain Mapping                                                                     |
|--------------|-----------------------------|----------|------------------------------------------------------------------------------------|
| `Name`       | `string`                    | No       | `PKSimEvent.Name`                                                                  |
| `Template`   | `string`                    | Yes      | Event template name passed to the factory. Determines which event type is created. |
| `Parameters` | [Parameter](#parameter)\[\] | No       | Mapped onto the event’s parameters.                                                |

------------------------------------------------------------------------

## ObserverSet

Created via `IObserverSetFactory.Create()`.

| Property    | Type                      | Required | Domain Mapping                                                     |
|-------------|---------------------------|----------|--------------------------------------------------------------------|
| `Name`      | `string`                  | No       | `ObserverSet.Name`                                                 |
| `Observers` | [Observer](#observer)\[\] | No       | Each observer is mapped via `ObserverMapper` and added to the set. |

------------------------------------------------------------------------

## Supporting Types

### OriginData

Created directly as `new OriginData { Species = ... }`.

| Property                 | Type                                              | Required | Domain Mapping                                                                                                           |
|--------------------------|---------------------------------------------------|----------|--------------------------------------------------------------------------------------------------------------------------|
| `Species`                | `string`                                          | Yes      | Resolved via `ISpeciesRepository.FindByName()`. Throws if not found.                                                     |
| `Population`             | `string`                                          | No       | Resolved from the species’ available populations. Uses the species default if not specified. Throws if not found.        |
| `Gender`                 | `string`                                          | No       | Resolved from the population’s available genders. Uses the first gender if not specified. Throws if not found.           |
| `Age`                    | [Parameter](#parameter)                           | No       | Set only if the population `IsAgeDependent`. Value converted from display unit to base unit.                             |
| `GestationalAge`         | [Parameter](#parameter)                           | No       | Set only if the population `IsAgeDependent`.                                                                             |
| `Weight`                 | [Parameter](#parameter)                           | No       | Value compared with mean weight (from `IIndividualModelTask.MeanWeightFor()`). Converted from display unit to base unit. |
| `Height`                 | [Parameter](#parameter)                           | No       | Set only if the population `IsHeightDependent`. Compared with mean height.                                               |
| `CalculationMethods`     | [CalculationMethodCache](#calculationmethodcache) | No       | Each method name resolved from the calculation method repository and added to the cache.                                 |
| `ValueOrigin`            | [ValueOrigin](#valueorigin)                       | No       | Updates the origin data’s value origin.                                                                                  |
| `Disease`                | [DiseaseState](#diseasestate)                     | No       | Mapped via `DiseaseStateMapper`.                                                                                         |
| `DiseaseState`           | `string`                                          | No       | **Legacy format**. Old-style disease state name, converted to the new `Disease` format.                                  |
| `DiseaseStateParameters` | [Parameter](#parameter)\[\]                       | No       | **Legacy format**. Parameters associated with the old-style disease state.                                               |

### CompoundProperties

Not created – retrieves the existing `CompoundProperties` from the
simulation via `simulation.CompoundPropertiesFor(name)`.

| Property             | Type                                                      | Required | Domain Mapping                                                                                                                                                                                          |
|----------------------|-----------------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`               | `string`                                                  | Yes      | Compound name. Used to look up the compound from the project and the corresponding `CompoundProperties` from the simulation.                                                                            |
| `CalculationMethods` | [CalculationMethodCache](#calculationmethodcache)         | No       | Updates the compound properties’ calculation method cache.                                                                                                                                              |
| `Alternatives`       | [CompoundGroupSelection](#compoundgroupselection)\[\]     | No       | Each entry sets the `AlternativeName` on the matching `CompoundGroupSelection` in the compound properties. The group is resolved by name.                                                               |
| `Processes`          | [CompoundProcessSelection](#compoundprocessselection)\[\] | No       | Each process is resolved by name from the compound. Missing or deselected processes create placeholder objects (`NotSelectedSystemicProcess`, `NoInteractionProcess`, etc.) depending on molecule type. |
| `Protocol`           | [ProtocolSelection](#protocolselection)                   | No       | Protocol resolved by name from the project. Formulation mappings resolved by formulation name and mapped to template IDs.                                                                               |

### CompoundProcess

Created by cloning a template:
`ICompoundProcessRepository.ProcessByName(internalName)` then
`ICloner.Clone(template)`.

| Property       | Type                        | Required | Domain Mapping                                                                                                                             |
|----------------|-----------------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`         | `string`                    | No       | Not used during import (name is calculated programmatically via `process.RefreshName()`).                                                  |
| `InternalName` | `string`                    | Yes      | Key used to look up the process template from the compound process repository. The template is cloned.                                     |
| `DataSource`   | `string`                    | Yes      | `CompoundProcess.DataSource`. Set directly on the cloned process.                                                                          |
| `Description`  | `string`                    | No       | `CompoundProcess.Description`. Only set if non-empty.                                                                                      |
| `Molecule`     | `string`                    | No       | For partial processes: `PartialProcess.MoleculeName`.                                                                                      |
| `Metabolite`   | `string`                    | No       | For enzymatic processes: `EnzymaticProcess.MetaboliteName`.                                                                                |
| `Species`      | `string`                    | No       | For species-dependent processes: resolved via `ISpeciesRepository.FindByName()` and set via `ICompoundProcessTask.SetSpeciesForProcess()`. |
| `Parameters`   | [Parameter](#parameter)\[\] | No       | Mapped onto the cloned process’s parameters.                                                                                               |

### Alternative

Created via `IParameterAlternativeFactory.CreateAlternativeFor(group)`.

| Property     | Type                        | Required | Domain Mapping                                                                                                                                                                    |
|--------------|-----------------------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`       | `string`                    | No       | `ParameterAlternative.Name`                                                                                                                                                       |
| `IsDefault`  | `bool?`                     | No       | `ParameterAlternative.IsDefault`. Defaults to `true`.                                                                                                                             |
| `Species`    | `string`                    | No       | For species-specific alternatives (`ParameterAlternativeWithSpecies`): resolved via `ISpeciesRepository.FindByName()`. Throws `SnapshotOutdatedException` if not found.           |
| `Parameters` | [Parameter](#parameter)\[\] | No       | Mapped onto the alternative’s parameters. For solubility alternatives with table formulas, `ICompoundAlternativeTask.PrepareSolubilityAlternativeForTableSolubility()` is called. |

Note: Calculated alternatives are never exported and are not expected in
the snapshot.

### PkaType

Not a standalone mapped object. Each entry directly modifies compound
parameters.

| Property      | Type                          | Required | Domain Mapping                                                                                     |
|---------------|-------------------------------|----------|----------------------------------------------------------------------------------------------------|
| `Type`        | [CompoundType](#compoundtype) | Yes      | Sets `ParameterCompoundType(index)` parameter value on the compound.                               |
| `Pka`         | `double`                      | Yes      | Sets `ParameterPKa(index)` parameter value on the compound.                                        |
| `ValueOrigin` | [ValueOrigin](#valueorigin)   | No       | Applied to both the compound type and pKa parameters. All pKa value origins are then synchronized. |

### Parameter

Not created – updates an existing `IParameter` found in the domain
model’s parameter tree.

| Property       | Type                          | Required | Domain Mapping                                                                                                                                                       |
|----------------|-------------------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`         | `string`                      | No       | Used to find the parameter by name within its container.                                                                                                             |
| `Value`        | `double?`                     | No       | Converted from display unit to base unit via `parameter.ConvertToBaseUnit()`. Only applied if it differs from the current value. Sets `parameter.IsDefault = false`. |
| `Unit`         | `string`                      | No       | Resolved via `parameter.Dimension.UnitOrDefault()`. Sets `parameter.DisplayUnit`. A warning is logged if the unit is not found in the dimension.                     |
| `ValueOrigin`  | [ValueOrigin](#valueorigin)   | No       | Updates the parameter’s value origin.                                                                                                                                |
| `TableFormula` | [TableFormula](#tableformula) | No       | If present, mapped via `TableFormulaMapper` and set as the parameter’s formula. Must be mapped before the value is set.                                              |

### LocalizedParameter

Extends `Parameter` with a path for simulation-level parameter
overrides.

| Property                                   | Type     | Required | Domain Mapping                                                                                                                                                                                            |
|--------------------------------------------|----------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Path`                                     | `string` | Yes      | Full container path used to locate the parameter in the simulation’s parameter tree. All children are cached for performance. In v11 or earlier, `"Applications"` in the path is converted to `"Events"`. |
| *(all [Parameter](#parameter) properties)* |          |          | Same as Parameter above.                                                                                                                                                                                  |

### ValueOrigin

Not created as a new object. Updates an existing `ValueOrigin` via
`valueOrigin.UpdateAllFrom()`.

| Property      | Type                                                                   | Required | Domain Mapping                                                                  |
|---------------|------------------------------------------------------------------------|----------|---------------------------------------------------------------------------------|
| `Id`          | `int?`                                                                 | No       | `ValueOrigin.Id`                                                                |
| `Source`      | [ValueOriginSourceId](#valueoriginsourceid)?                           | No       | Resolved via `ValueOriginSources.ById()`. Defaults to `Undefined`.              |
| `Method`      | [ValueOriginDeterminationMethodId](#valueorigindeterminationmethodid)? | No       | Resolved via `ValueOriginDeterminationMethods.ById()`. Defaults to `Undefined`. |
| `Description` | `string`                                                               | No       | `ValueOrigin.Description`                                                       |

### CalculationMethodCache

An array of calculation method name strings. Not created – updates an
existing cache.

| Property        | Type     | Required | Domain Mapping                                                                                                                                                                                                        |
|-----------------|----------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *(each string)* | `string` | No       | Each name is resolved via `ICalculationMethodRepository.FindByName()`. The matching `CalculationMethod` replaces any existing method of the same category in the cache. A warning is logged if the name is not found. |

### SolverSettings

Created via `ISolverSettingsFactory.CreateDefault()`.

| Property      | Type      | Required | Domain Mapping                                      |
|---------------|-----------|----------|-----------------------------------------------------|
| `AbsTol`      | `double?` | No       | `SolverSettings.AbsTol`. Uses default if null.      |
| `RelTol`      | `double?` | No       | `SolverSettings.RelTol`. Uses default if null.      |
| `UseJacobian` | `bool?`   | No       | `SolverSettings.UseJacobian`. Uses default if null. |
| `H0`          | `double?` | No       | `SolverSettings.H0`. Uses default if null.          |
| `HMin`        | `double?` | No       | `SolverSettings.HMin`. Uses default if null.        |
| `HMax`        | `double?` | No       | `SolverSettings.HMax`. Uses default if null.        |
| `MxStep`      | `int?`    | No       | `SolverSettings.MxStep`. Uses default if null.      |

All properties use sparse serialization: absent/null values fall back to
factory defaults.

### OutputSchema

Created via `IOutputSchemaFactory.CreateEmpty()`.

| Property                         | Type                                  | Required | Domain Mapping                                                                                                                                        |
|----------------------------------|---------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| *(collection of OutputInterval)* | [OutputInterval](#outputinterval)\[\] | No       | Each interval is mapped via `OutputIntervalMapper` and added to the schema. Interval names are forced unique via `IContainerTask.CreateUniqueName()`. |

### OutputInterval

Extends `ParameterContainerSnapshotBase`.

| Property     | Type                        | Required | Domain Mapping                                                            |
|--------------|-----------------------------|----------|---------------------------------------------------------------------------|
| `Name`       | `string`                    | No       | `OutputInterval.Name`                                                     |
| `Parameters` | [Parameter](#parameter)\[\] | No       | Mapped onto the interval’s parameters (start time, end time, resolution). |

### OutputSelections

An array of output path strings.

| Property        | Type     | Required | Domain Mapping                                                                                                                                                                                                                               |
|-----------------|----------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| *(each string)* | `string` | No       | Each path is resolved against the simulation’s quantity tree via `IEntitiesInContainerRetriever.QuantitiesFrom(simulation)`. If found, a `QuantitySelection(path, quantityType)` is created and added. Missing paths are logged as warnings. |

### OutputMapping

| Property       | Type                  | Required | Domain Mapping                                            |
|----------------|-----------------------|----------|-----------------------------------------------------------|
| `Path`         | `string`              | No       | Simulation output quantity path.                          |
| `ObservedData` | `string`              | No       | Observed data repository name. Resolved from the project. |
| `Scaling`      | [Scalings](#scalings) | No       | Scaling type for the mapping.                             |
| `Weight`       | `float?`              | No       | Weight for the mapping.                                   |
| `Weights`      | `float[]`             | No       | Per-point weights.                                        |

### ProtocolSelection

| Property       | Type                                              | Required | Domain Mapping                                                      |
|----------------|---------------------------------------------------|----------|---------------------------------------------------------------------|
| `Name`         | `string`                                          | Yes      | Protocol name. Resolved from the project’s building blocks by name. |
| `Formulations` | [FormulationSelection](#formulationselection)\[\] | No       | Each entry maps a formulation key to a formulation building block.  |

### FormulationSelection

| Property | Type     | Required | Domain Mapping                                                                                                  |
|----------|----------|----------|-----------------------------------------------------------------------------------------------------------------|
| `Name`   | `string` | Yes      | Formulation name. Resolved from the project’s building blocks by name. The formulation’s template ID is stored. |
| `Key`    | `string` | Yes      | Formulation key identifying which application in the protocol uses this formulation.                            |

### Schema (Advanced Protocol)

| Property      | Type                          | Required | Domain Mapping                                                                      |
|---------------|-------------------------------|----------|-------------------------------------------------------------------------------------|
| `Name`        | `string`                      | No       | `Schema.Name`                                                                       |
| `Parameters`  | [Parameter](#parameter)\[\]   | No       | Schema-level parameters (number of repetitions, time between repetitions, etc.).    |
| `SchemaItems` | [SchemaItem](#schemaitem)\[\] | No       | Mapped via `SchemaItemMapper`. Each item defines one application within the schema. |

### SchemaItem

| Property            | Type                        | Required | Domain Mapping                                                         |
|---------------------|-----------------------------|----------|------------------------------------------------------------------------|
| `Name`              | `string`                    | No       | `SchemaItem.Name`                                                      |
| `ApplicationType`   | `string`                    | Yes      | Resolved via `ApplicationTypes.ByName()`.                              |
| `FormulationKey`    | `string`                    | No       | `SchemaItem.FormulationKey`. Links to a formulation in the simulation. |
| `TargetOrgan`       | `string`                    | No       | `SchemaItem.TargetOrgan`                                               |
| `TargetCompartment` | `string`                    | No       | `SchemaItem.TargetCompartment`                                         |
| `Parameters`        | [Parameter](#parameter)\[\] | No       | Schema item parameters (dose, start time, etc.).                       |

### PopulationSettings

| Property                 | Type                                  | Required | Domain Mapping                                                         |
|--------------------------|---------------------------------------|----------|------------------------------------------------------------------------|
| `NumberOfIndividuals`    | `int`                                 | Yes      | Number of individuals to generate in the population.                   |
| `ProportionOfFemales`    | `int?`                                | No       | Percentage of females in the population.                               |
| `Individual`             | [Individual](#individual)             | Yes      | The base individual for the population. Mapped via `IndividualMapper`. |
| `Age`                    | [ParameterRange](#parameterrange)     | No       | Age range constraint for population generation.                        |
| `Weight`                 | [ParameterRange](#parameterrange)     | No       | Weight range constraint.                                               |
| `Height`                 | [ParameterRange](#parameterrange)     | No       | Height range constraint.                                               |
| `GestationalAge`         | [ParameterRange](#parameterrange)     | No       | Gestational age range constraint.                                      |
| `BMI`                    | [ParameterRange](#parameterrange)     | No       | BMI range constraint.                                                  |
| `DiseaseStateParameters` | [ParameterRange](#parameterrange)\[\] | No       | Disease-state-specific parameter ranges.                               |

### ParameterRange

| Property | Type      | Required | Domain Mapping                                              |
|----------|-----------|----------|-------------------------------------------------------------|
| `Name`   | `string`  | No       | Parameter name (used for dynamic/disease-state parameters). |
| `Min`    | `double?` | No       | Minimum value for the range.                                |
| `Max`    | `double?` | No       | Maximum value for the range.                                |
| `Unit`   | `string`  | No       | Display unit for the range values.                          |

### AdvancedParameter

Extends `ParameterContainerSnapshotBase`.

| Property           | Type                                  | Required | Domain Mapping                                                     |
|--------------------|---------------------------------------|----------|--------------------------------------------------------------------|
| `Name`             | `string`                              | No       | Parameter name used to locate the advanced parameter.              |
| `Seed`             | `int`                                 | No       | Random seed for the distribution.                                  |
| `DistributionType` | [DistributionType](#distributiontype) | No       | Distribution type (Normal, LogNormal, Uniform, etc.).              |
| `Parameters`       | [Parameter](#parameter)\[\]           | No       | Distribution parameters (mean, deviation, minimum, maximum, etc.). |

### EventSelection

| Property    | Type                    | Required | Domain Mapping                                                   |
|-------------|-------------------------|----------|------------------------------------------------------------------|
| `Name`      | `string`                | No       | Event building block name. Resolved from the project by name.    |
| `StartTime` | [Parameter](#parameter) | Yes      | Start time parameter for when the event fires in the simulation. |

### ObserverSetSelection

| Property | Type     | Required | Domain Mapping                                                       |
|----------|----------|----------|----------------------------------------------------------------------|
| `Name`   | `string` | No       | Observer set building block name. Resolved from the project by name. |

### AlteredBuildingBlock

| Property | Type                                              | Required | Domain Mapping                                                                                                            |
|----------|---------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------|
| `Name`   | `string`                                          | No       | Building block name.                                                                                                      |
| `Type`   | [PKSimBuildingBlockType](#pksimbuildingblocktype) | No       | Building block type. The matching `UsedBuildingBlock` in the simulation is found and its `Altered` flag is set to `true`. |

### TableFormula

Created via `IFormulaFactory.CreateTableFormula()`.

| Property           | Type                | Required | Domain Mapping                                                                                                                                       |
|--------------------|---------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`             | `string`            | No       | `TableFormula.Name`                                                                                                                                  |
| `XDimension`       | `string`            | No       | Resolved via `IDimensionRepository.DimensionByName()`. Sets X-axis dimension.                                                                        |
| `XUnit`            | `string`            | No       | Resolved from the X dimension. Sets `TableFormula.XDisplayUnit`.                                                                                     |
| `XName`            | `string`            | No       | `TableFormula.XName`. Display name for X-axis.                                                                                                       |
| `YDimension`       | `string`            | No       | Resolved via `IDimensionRepository.DimensionByName()`. Sets Y-axis dimension.                                                                        |
| `YUnit`            | `string`            | No       | Resolved from the Y dimension. Sets `TableFormula.YDisplayUnit`.                                                                                     |
| `YName`            | `string`            | No       | `TableFormula.YName`. Display name for Y-axis.                                                                                                       |
| `UseDerivedValues` | `bool`              | No       | `TableFormula.UseDerivedValues`.                                                                                                                     |
| `Points`           | [Point](#point)\[\] | No       | Each point’s X and Y values are converted from display units to base units via `XBaseValueFor()` and `YBaseValueFor()`, then added via `AddPoint()`. |

### Point

| Property        | Type     | Required | Domain Mapping                                                         |
|-----------------|----------|----------|------------------------------------------------------------------------|
| `X`             | `double` | Yes      | X value in display units. Converted to base units.                     |
| `Y`             | `double` | Yes      | Y value in display units. Converted to base units.                     |
| `RestartSolver` | `bool`   | No       | `ValuePoint.RestartSolver`. Whether the solver restarts at this point. |

### Observer

Created via `IObjectBaseFactory.Create<AmountObserverBuilder>()` or
`Create<ContainerObserverBuilder>()` based on the `Type` property.

| Property            | Type                                            | Required | Domain Mapping                                                                                                                              |
|---------------------|-------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`              | `string`                                        | No       | `Observer.Name`                                                                                                                             |
| `Type`              | `string`                                        | No       | `"Amount"` creates an `AmountObserverBuilder`; `"Container"` creates a `ContainerObserverBuilder`. Returns null with error if unrecognized. |
| `Dimension`         | `string`                                        | No       | Resolved via `IDimensionRepository.DimensionByName()`. Sets `Observer.Dimension`.                                                           |
| `ContainerCriteria` | [DescriptorCondition](#descriptorcondition)\[\] | No       | Each mapped via `DescriptorConditionMapper`, wrapped in a `DescriptorCriteria` container.                                                   |
| `Formula`           | [ExplicitFormula](#explicitformula)             | No       | Mapped via `ExplicitFormulaMapper`. Sets the observer’s calculation formula.                                                                |
| `MoleculeList`      | [MoleculeList](#moleculelist)                   | No       | Mapped via `MoleculeListMapper`, then applied via `observer.MoleculeList.Update()`.                                                         |

### DiseaseState

| Property     | Type                        | Required | Domain Mapping                                                                     |
|--------------|-----------------------------|----------|------------------------------------------------------------------------------------|
| `Name`       | `string`                    | No       | Disease state name. Resolved from the available disease states for the population. |
| `Parameters` | [Parameter](#parameter)\[\] | No       | Disease-state-specific parameters.                                                 |

### Ontogeny

| Property | Type                                     | Required | Domain Mapping                                                                                                                                                |
|----------|------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`   | `string`                                 | No       | Ontogeny name. If it matches a known database ontogeny, that ontogeny is used. Otherwise treated as user-defined.                                             |
| `Table`  | [DistributedTableFormula](#tableformula) | No       | Custom ontogeny table data. Mapped via `DistributedTableFormulaMapper`. Extends [TableFormula](#tableformula) with `Percentile` and `DistributionMetaData[]`. |

### ExpressionContainer

Extends `Parameter`.

| Property             | Type                                           | Required | Domain Mapping                                                                   |
|----------------------|------------------------------------------------|----------|----------------------------------------------------------------------------------|
| `Name`               | `string`                                       | No       | Container/organ name. Used to locate the expression container in the individual. |
| `Value`              | `double?`                                      | No       | Relative expression value.                                                       |
| `CompartmentName`    | `string`                                       | No       | Compartment within the organ.                                                    |
| `TransportDirection` | [TransportDirectionId](#transportdirectionid)? | No       | For transporters: the transport direction in this container.                     |
| `MembraneLocation`   | [MembraneLocation](#membranelocation)?         | No       | **Legacy (v9)**. Per-container membrane location.                                |

### ExplicitFormula

Created via `IObjectBaseFactory.Create<ExplicitFormula>()`.

| Property     | Type                                        | Required | Domain Mapping                                                                                                |
|--------------|---------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------|
| `Name`       | `string`                                    | No       | `ExplicitFormula.Name`                                                                                        |
| `Formula`    | `string`                                    | No       | `ExplicitFormula.FormulaString`. The mathematical expression as a string.                                     |
| `Dimension`  | `string`                                    | No       | Resolved via `IDimensionRepository.DimensionByName()`. Sets the formula’s output dimension.                   |
| `References` | [FormulaUsablePath](#formulausablepath)\[\] | No       | Each mapped and added to the formula via `AddObjectPath()`. Defines the variables used in the formula string. |

### FormulaUsablePath

| Property    | Type     | Required | Domain Mapping                                                   |
|-------------|----------|----------|------------------------------------------------------------------|
| `Alias`     | `string` | No       | The variable alias used in the formula string (e.g. `"Volume"`). |
| `Path`      | `string` | No       | The object path to the referenced quantity in the model tree.    |
| `Dimension` | `string` | No       | The dimension of the referenced quantity.                        |

### DescriptorCondition

| Property | Type     | Required | Domain Mapping                                                               |
|----------|----------|----------|------------------------------------------------------------------------------|
| `Tag`    | `string` | No       | The tag value to match against container descriptors.                        |
| `Type`   | `string` | No       | The condition type (e.g. `"InContainer"`, `"NotInContainer"`, `"InParent"`). |

### MoleculeList

| Property                 | Type       | Required | Domain Mapping                                                                                    |
|--------------------------|------------|----------|---------------------------------------------------------------------------------------------------|
| `ForAll`                 | `bool`     | No       | If `true`, the observer applies to all molecules. If `false`, the include/exclude lists are used. |
| `MoleculeNamesToInclude` | `string[]` | No       | Molecules the observer explicitly applies to.                                                     |
| `MoleculeNamesToExclude` | `string[]` | No       | Molecules explicitly excluded from the observer.                                                  |

### DistributedTableFormula

Created via `IFormulaFactory.CreateDistributedTableFormula()`. Extends
[TableFormula](#tableformula).

| Property                                         | Type                                              | Required | Domain Mapping                                                                   |
|--------------------------------------------------|---------------------------------------------------|----------|----------------------------------------------------------------------------------|
| *(all [TableFormula](#tableformula) properties)* |                                                   |          | Mapped via `TableFormulaMapper.UpdateModelProperties()`.                         |
| `Percentile`                                     | `double`                                          | No       | `DistributedTableFormula.Percentile`. The percentile value for the distribution. |
| `DistributionMetaData`                           | [DistributionMetaData](#distributionmetadata)\[\] | No       | Each entry added via `AddDistributionMetaData()`.                                |

### DistributionMetaData

| Property       | Type                                  | Required | Domain Mapping                                                             |
|----------------|---------------------------------------|----------|----------------------------------------------------------------------------|
| `Mean`         | `double`                              | No       | `DistributionMetaData.Mean`. Mean value of the distribution at this point. |
| `Deviation`    | `double`                              | No       | `DistributionMetaData.Deviation`. Standard deviation.                      |
| `Distribution` | [DistributionType](#distributiontype) | No       | `DistributionMetaData.Distribution`. The distribution type at this point.  |

### CompoundProcessSelection

| Property              | Type     | Required | Domain Mapping                                                                                                  |
|-----------------------|----------|----------|-----------------------------------------------------------------------------------------------------------------|
| `Name`                | `string` | No       | Process name. Resolved from the compound’s processes.                                                           |
| `MoleculeName`        | `string` | No       | Name of the molecule involved in the process (for partial processes).                                           |
| `MetaboliteName`      | `string` | No       | Name of the metabolite produced (for enzymatic processes).                                                      |
| `CompoundName`        | `string` | No       | Compound name (for interaction processes involving multiple compounds).                                         |
| `SystemicProcessType` | `string` | No       | Type of systemic process (e.g. `"Hepatic"`, `"Renal"`, `"Biliary"`). Used when no specific process is selected. |

### CompoundGroupSelection

| Property          | Type     | Required | Domain Mapping                                                                                          |
|-------------------|----------|----------|---------------------------------------------------------------------------------------------------------|
| `GroupName`       | `string` | No       | Alternative group name (e.g. `"Lipophilicity"`, `"Solubility"`). Resolved from the compound properties. |
| `AlternativeName` | `string` | No       | Selected alternative name within the group.                                                             |

------------------------------------------------------------------------

## Analysis Types

### DataRepository (Observed Data)

Created directly as `new DataRepository()`.

| Property             | Type                                      | Required | Domain Mapping                                                                             |
|----------------------|-------------------------------------------|----------|--------------------------------------------------------------------------------------------|
| `Name`               | `string`                                  | No       | `DataRepository.Name`                                                                      |
| `Description`        | `string`                                  | No       | `DataRepository.Description`                                                               |
| `BaseGrid`           | [DataColumn](#datacolumn)                 | No       | The time/independent variable column. Mapped via `DataColumnMapper` and added first.       |
| `Columns`            | [DataColumn](#datacolumn)\[\]             | No       | Dependent data columns. Each mapped via `DataColumnMapper` and added to the repository.    |
| `ExtendedProperties` | [ExtendedProperty](#extendedproperty)\[\] | No       | Metadata properties. Each mapped via `ExtendedPropertyMapper` and added to the repository. |

### DataColumn

Created as `BaseGrid` or `DataColumn` depending on the `DataInfo.Origin`
value. If `Origin == BaseGrid`, creates a `BaseGrid`; otherwise creates
a `DataColumn` linked to the repository’s base grid.

| Property         | Type                          | Required | Domain Mapping                                                                                                                           |
|------------------|-------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`           | `string`                      | No       | Constructor parameter for the column.                                                                                                    |
| `Dimension`      | `string`                      | No       | Resolved via `IDimensionRepository.DimensionByName()`. Passed to the constructor.                                                        |
| `Unit`           | `string`                      | No       | Resolved from the dimension via `UnitOrDefault()`. Sets `DataColumn.DisplayUnit`. Values are converted from display units to base units. |
| `Values`         | `float[]`                     | No       | Column data values in display units. Converted to base units via `ConvertToBaseValues()` during mapping.                                 |
| `QuantityInfo`   | [QuantityInfo](#quantityinfo) | No       | Mapped via `QuantityInfoMapper`. Sets quantity type and path.                                                                            |
| `DataInfo`       | [DataInfo](#datainfo)         | No       | Mapped via `DataInfoMapper`. Determines column type (base grid vs data) and sets metadata.                                               |
| `RelatedColumns` | [DataColumn](#datacolumn)\[\] | No       | Recursively mapped. Each added via `AddRelatedColumn()` (e.g., error columns).                                                           |

### DataInfo

| Property              | Type                                      | Required | Domain Mapping                                                                    |
|-----------------------|-------------------------------------------|----------|-----------------------------------------------------------------------------------|
| `Origin`              | [ColumnOrigins](#columnorigins)?          | No       | `DataInfo.Origin`. Determines the column type during DataColumn creation.         |
| `AuxiliaryType`       | [AuxiliaryType](#auxiliarytype)           | No       | `DataInfo.AuxiliaryType`. Classifies auxiliary columns (e.g. standard deviation). |
| `Category`            | `string`                                  | No       | `DataInfo.Category`. Grouping category for the data.                              |
| `MolWeight`           | `double?`                                 | No       | `DataInfo.MolWeight`. Molecular weight for unit conversions.                      |
| `LLOQ`                | `float?`                                  | No       | `DataInfo.LLOQ`. Lower limit of quantification.                                   |
| `ComparisonThreshold` | `float?`                                  | No       | `DataInfo.ComparisonThreshold`.                                                   |
| `ExtendedProperties`  | [ExtendedProperty](#extendedproperty)\[\] | No       | Additional metadata properties.                                                   |

### QuantityInfo

| Property     | Type                           | Required | Domain Mapping                                                       |
|--------------|--------------------------------|----------|----------------------------------------------------------------------|
| `Path`       | `string`                       | No       | `QuantityInfo.Path`. The path identifying the quantity in the model. |
| `Type`       | [QuantityType](#quantitytype)? | No       | `QuantityInfo.Type`. The type of quantity.                           |
| `OrderIndex` | `int?`                         | No       | `QuantityInfo.OrderIndex`. Display ordering hint.                    |

### ExtendedProperty

Created as `ExtendedProperty<T>` where T is determined by the `Type`
property or inferred from the value.

| Property       | Type                                           | Required | Domain Mapping                                                                                                               |
|----------------|------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------|
| `Name`         | `string`                                       | No       | `ExtendedProperty.Name`                                                                                                      |
| `FullName`     | `string`                                       | No       | `ExtendedProperty.FullName`. Full display name.                                                                              |
| `Description`  | `string`                                       | No       | `ExtendedProperty.Description`                                                                                               |
| `Value`        | `object`                                       | No       | Parsed to the appropriate type (string, int, double, or bool) and set as `ExtendedProperty.Value`. Returns null if absent.   |
| `Type`         | [ExtendedPropertyType](#extendedpropertytype)? | No       | Determines the .NET type for value parsing. If absent, type is inferred: tries double, then bool, then falls back to string. |
| `ListOfValues` | `object[]`                                     | No       | Each value parsed with the same type conversion, added via `AddToListOfValues()`. Defines allowed values.                    |
| `ReadOnly`     | `bool?`                                        | No       | `ExtendedProperty.ReadOnly`.                                                                                                 |

### ParameterIdentification

Created via `IObjectBaseFactory.Create<ParameterIdentification>()`.

| Property                   | Type                                                                          | Required | Domain Mapping                                                                                                                                         |
|----------------------------|-------------------------------------------------------------------------------|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`                     | `string`                                                                      | No       | `ParameterIdentification.Name`                                                                                                                         |
| `Description`              | `string`                                                                      | No       | `ParameterIdentification.Description`                                                                                                                  |
| `Simulations`              | `string[]`                                                                    | No       | Array of simulation names. Each resolved from the project via `FindByName()`. Added via `AddSimulation()`. Missing simulations are logged as warnings. |
| `Configuration`            | [ParameterIdentificationConfiguration](#parameteridentificationconfiguration) | No       | Mapped via `ParameterIdentificationConfigurationMapper`. Updates the existing configuration on the domain object.                                      |
| `OutputMappings`           | [OutputMapping](#outputmapping)\[\]                                           | No       | Each mapped and added via `AddOutputMapping()`.                                                                                                        |
| `IdentificationParameters` | [IdentificationParameter](#identificationparameter)\[\]                       | No       | Each mapped and added via `AddIdentificationParameter()`.                                                                                              |
| `Analyses`                 | [ParameterIdentificationAnalysis](#parameteridentificationanalysis)\[\]       | No       | Each mapped and added via `AddAnalysis()`.                                                                                                             |

### SimulationComparison

Type is polymorphic: if `IndividualComparison` is present, creates
`IndividualSimulationComparison`; otherwise creates
`PopulationSimulationComparison`.

| Property                | Type                                                    | Required | Domain Mapping                                                                                                         |
|-------------------------|---------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------|
| `Name`                  | `string`                                                | No       | `SimulationComparison.Name`                                                                                            |
| `Simulations`           | `string[]`                                              | No       | Simulation names. Each resolved from the project by name and added via `AddSimulation()`.                              |
| `IndividualComparison`  | [CurveChart](#curvechart)                               | No       | If present, creates an `IndividualSimulationComparison` and maps the chart via `IndividualSimulationComparisonMapper`. |
| `PopulationComparisons` | [PopulationAnalysisChart](#populationanalysischart)\[\] | No       | For population comparisons. Each chart mapped and added via `AddAnalysis()`.                                           |
| `ReferenceGroupingItem` | [GroupingItem](#groupingitem)                           | No       | For population comparisons: `PopulationSimulationComparison.ReferenceGroupingItem`.                                    |
| `ReferenceSimulation`   | `string`                                                | No       | For population comparisons: resolved from project by name.                                                             |

### Classification

Created directly as `new Classification()`.

| Property          | Type                                  | Required | Domain Mapping                                                                |
|-------------------|---------------------------------------|----------|-------------------------------------------------------------------------------|
| `Name`            | `string`                              | No       | `Classification.Name`. Represents a folder in the project tree.               |
| `Classifications` | [Classification](#classification)\[\] | No       | Nested child classifications (sub-folders).                                   |
| `Classifiables`   | `string[]`                            | No       | Names of items (simulations, observed data, etc.) that belong in this folder. |

The classification type (ObservedData, Simulation, etc.) is determined
by which project array the classification appears in, not by a property
on the snapshot.

### ParameterIdentificationConfiguration

Not created – updates the existing `Configuration` on the
`ParameterIdentification` domain object.

| Property            | Type                                                              | Required | Domain Mapping                                                                |
|---------------------|-------------------------------------------------------------------|----------|-------------------------------------------------------------------------------|
| `LLOQMode`          | `string`                                                          | No       | Resolved via `LLOQModes.ByName()`. Sets `Configuration.LLOQMode`.             |
| `RemoveLLOQMode`    | `string`                                                          | No       | Resolved via `RemoveLLOQModes.ByName()`. Sets `Configuration.RemoveLLOQMode`. |
| `CalculateJacobian` | `bool`                                                            | No       | `Configuration.CalculateJacobian`.                                            |
| `Algorithm`         | [OptimizationAlgorithm](#optimizationalgorithm)                   | No       | Mapped via dedicated mapper. Sets `Configuration.AlgorithmProperties`.        |
| `RunMode`           | [ParameterIdentificationRunMode](#parameteridentificationrunmode) | No       | Mapped via dedicated mapper. Sets `Configuration.RunMode`.                    |

### OptimizationAlgorithm

| Property     | Type                                      | Required | Domain Mapping                                                                |
|--------------|-------------------------------------------|----------|-------------------------------------------------------------------------------|
| `Name`       | `string`                                  | No       | Algorithm name. Used to identify the optimization algorithm.                  |
| `Properties` | [ExtendedProperty](#extendedproperty)\[\] | No       | Algorithm-specific configuration properties (e.g. tolerance, max iterations). |

### ParameterIdentificationRunMode

| Property              | Type                                              | Required | Domain Mapping                                                                                   |
|-----------------------|---------------------------------------------------|----------|--------------------------------------------------------------------------------------------------|
| `NumberOfRuns`        | `int?`                                            | No       | Number of optimization runs for multi-start mode.                                                |
| `AllTheSameSelection` | [CalculationMethodCache](#calculationmethodcache) | No       | Calculation methods applied uniformly across all runs.                                           |
| `CalculationMethods`  | `Dictionary<string, CalculationMethodCache>`      | No       | Per-category calculation method selections for categorial optimization. Keys are category names. |

### IdentificationParameter

Created via
`IIdentificationParameterFactory.CreateFor(parameterSelections, parameterIdentification)`.

| Property           | Type                        | Required | Domain Mapping                                                                                                                                                                                                        |
|--------------------|-----------------------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`             | `string`                    | No       | `IdentificationParameter.Name`                                                                                                                                                                                        |
| `LinkedParameters` | `string[]`                  | No       | Array of full parameter paths (format: `SimulationName|Container|...|ParameterName`). Each resolved to a `ParameterSelection` by parsing the simulation name and looking it up in the project. Passed to the factory. |
| `Scaling`          | [Scalings](#scalings)       | No       | `IdentificationParameter.Scaling`.                                                                                                                                                                                    |
| `UseAsFactor`      | `bool?`                     | No       | `IdentificationParameter.UseAsFactor`. If true, parameter range is updated via `IIdentificationParameterTask`.                                                                                                        |
| `IsFixed`          | `bool?`                     | No       | `IdentificationParameter.IsFixed`. Whether this parameter is fixed during identification.                                                                                                                             |
| `Parameters`       | [Parameter](#parameter)\[\] | No       | Identification parameter bounds (min, max, start value).                                                                                                                                                              |

### ParameterIdentificationAnalysis

| Property           | Type                                                | Required | Domain Mapping                                                      |
|--------------------|-----------------------------------------------------|----------|---------------------------------------------------------------------|
| `Name`             | `string`                                            | No       | `ParameterIdentificationAnalysis.Name`                              |
| `Type`             | `string`                                            | Yes      | Analysis type name. Determines the concrete analysis class created. |
| `Chart`            | [CurveChart](#curvechart)                           | No       | For chart-based analyses. Mapped via `CurveChartMapper`.            |
| `DataRepositories` | [DataRepository](#datarepository-observed-data)\[\] | No       | Data repositories specific to this analysis (e.g. residual data).   |

### GroupingItem

A domain model object used directly in JSON (not a snapshot class).

| Property | Type                | Required | Domain Mapping                 |
|----------|---------------------|----------|--------------------------------|
| `Label`  | `string`            | No       | Display label for this group.  |
| `Color`  | `Color`             | No       | Color assigned to this group.  |
| `Symbol` | [Symbols](#symbols) | No       | Symbol assigned to this group. |

------------------------------------------------------------------------

## Chart Types

### CurveChart

Created via a chart factory function (typically
`new SimulationTimeProfileChart()` or
`new IndividualSimulationComparison()`). The chart object is created
first, then chart-level properties are updated in-place via
`ChartMapper`.

| Property            | Type                                                  | Required | Domain Mapping                                                                                                |
|---------------------|-------------------------------------------------------|----------|---------------------------------------------------------------------------------------------------------------|
| `Name`              | `string`                                              | No       | `CurveChart.Name`                                                                                             |
| `Description`       | `string`                                              | No       | `CurveChart.Description`                                                                                      |
| `Title`             | `string`                                              | No       | `CurveChart.Title`                                                                                            |
| `OriginText`        | `string`                                              | No       | `CurveChart.OriginText`                                                                                       |
| `IncludeOriginData` | `bool?`                                               | No       | `CurveChart.IncludeOriginData`                                                                                |
| `PreviewSettings`   | `bool?`                                               | No       | `CurveChart.PreviewSettings`                                                                                  |
| `FontAndSize`       | [ChartFontAndSizeSettings](#chartfontandsizesettings) | No       | Updated via `chart.FontAndSize.UpdatePropertiesFrom()`.                                                       |
| `Settings`          | [ChartSettings](#chartsettings)                       | No       | Updated via `chart.ChartSettings.UpdatePropertiesFrom()`.                                                     |
| `Axes`              | [Axis](#axis)\[\]                                     | No       | Each mapped via `AxisMapper` and added to the chart.                                                          |
| `Curves`            | [Curve](#curve)\[\]                                   | No       | Each mapped via `CurveMapper` and added to the chart. Curves that reference missing data columns are skipped. |

### Axis

Created as `new Axis(snapshot.Type)`.

| Property           | Type                        | Required | Domain Mapping                                                                                     |
|--------------------|-----------------------------|----------|----------------------------------------------------------------------------------------------------|
| `Type`             | [AxisTypes](#axistypes)     | No       | Constructor parameter. Determines which axis this is (X, Y, Y2, Y3).                               |
| `Dimension`        | `string`                    | No       | Resolved via `IDimensionRepository.DimensionByName()`, then optimized via `OptimalDimensionFor()`. |
| `Unit`             | `string`                    | No       | `Axis.UnitName`.                                                                                   |
| `Caption`          | `string`                    | No       | `Axis.Caption`. Display label for the axis.                                                        |
| `GridLines`        | `bool`                      | No       | `Axis.GridLines`. Whether grid lines are shown.                                                    |
| `Visible`          | `bool`                      | No       | `Axis.Visible`. Whether the axis is visible.                                                       |
| `Min`              | `float?`                    | No       | `Axis.Min`. Minimum axis value.                                                                    |
| `Max`              | `float?`                    | No       | `Axis.Max`. Maximum axis value.                                                                    |
| `DefaultColor`     | `Color`                     | No       | `Axis.DefaultColor`. Default color for curves on this axis.                                        |
| `DefaultLineStyle` | [LineStyles](#linestyles)   | No       | `Axis.DefaultLineStyle`. Default line style for curves on this axis.                               |
| `Scaling`          | [Scalings](#scalings)       | No       | `Axis.Scaling`. Linear or logarithmic scale.                                                       |
| `NumberMode`       | [NumberModes](#numbermodes) | No       | `Axis.NumberMode`. How numbers are formatted on the axis.                                          |

### Curve

Created as `new Curve()`.

| Property       | Type                          | Required | Domain Mapping                                                                                                                                                                     |
|----------------|-------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`         | `string`                      | No       | `Curve.Name`                                                                                                                                                                       |
| `X`            | `string`                      | No       | Path to the X data column. Resolved by searching all data repositories in the analysis context. If not specified, defaults to the Y column’s base grid. Returns null if not found. |
| `Y`            | `string`                      | No       | Path to the Y data column. Resolved by searching all data repositories in the analysis context. Returns null with warning if not found.                                            |
| `CurveOptions` | [CurveOptions](#curveoptions) | No       | Mapped via `CurveOptionsMapper`, then applied via `curve.CurveOptions.UpdateFrom()`.                                                                                               |

### CurveOptions

| Property            | Type                                       | Required | Domain Mapping                                                           |
|---------------------|--------------------------------------------|----------|--------------------------------------------------------------------------|
| `yAxisType`         | [AxisTypes](#axistypes)?                   | No       | `CurveOptions.yAxisType`. Which Y axis this curve is plotted on.         |
| `Visible`           | `bool?`                                    | No       | `CurveOptions.Visible`. Whether the curve is displayed.                  |
| `VisibleInLegend`   | `bool?`                                    | No       | `CurveOptions.VisibleInLegend`. Whether the curve appears in the legend. |
| `ShouldShowLLOQ`    | `bool?`                                    | No       | `CurveOptions.ShouldShowLLOQ`. Whether to show the LLOQ line.            |
| `InterpolationMode` | [InterpolationModes](#interpolationmodes)? | No       | `CurveOptions.InterpolationMode`. How data points are connected.         |
| `Color`             | `Color?`                                   | No       | `CurveOptions.Color`. Curve color.                                       |
| `LegendIndex`       | `int?`                                     | No       | `CurveOptions.LegendIndex`. Position in the legend.                      |
| `LineThickness`     | `int?`                                     | No       | `CurveOptions.LineThickness`. Line width in pixels.                      |
| `LineStyle`         | [LineStyles](#linestyles)?                 | No       | `CurveOptions.LineStyle`.                                                |
| `Symbol`            | [Symbols](#symbols)?                       | No       | `CurveOptions.Symbol`. Data point marker shape.                          |

### ChartFontAndSizeSettings

A domain model object used directly in JSON. Updated via
`UpdatePropertiesFrom()`.

| Property      | Type         | Required | Domain Mapping                                                                                  |
|---------------|--------------|----------|-------------------------------------------------------------------------------------------------|
| `ChartWidth`  | `int?`       | No       | `ChartFontAndSizeSettings.ChartWidth`. Export width in pixels (200-2000).                       |
| `ChartHeight` | `int?`       | No       | `ChartFontAndSizeSettings.ChartHeight`. Export height in pixels (200-2000).                     |
| `Fonts`       | `ChartFonts` | No       | `ChartFontAndSizeSettings.Fonts`. Font settings for chart elements (title, axes, legend, etc.). |

### ChartSettings

A domain model object used directly in JSON. Updated via
`UpdatePropertiesFrom()`.

| Property             | Type                                | Required | Domain Mapping                                                                          |
|----------------------|-------------------------------------|----------|-----------------------------------------------------------------------------------------|
| `SideMarginsEnabled` | `bool`                              | No       | `ChartSettings.SideMarginsEnabled`. Whether side margins are shown. Defaults to `true`. |
| `LegendPosition`     | [LegendPositions](#legendpositions) | No       | `ChartSettings.LegendPosition`. Where the legend is placed. Defaults to `RightInside`.  |
| `BackColor`          | `Color`                             | No       | `ChartSettings.BackColor`. Chart background color. Defaults to `Transparent`.           |
| `DiagramBackColor`   | `Color`                             | No       | `ChartSettings.DiagramBackColor`. Plot area background color. Defaults to `White`.      |

### PopulationAnalysisChart

Created via `IPopulationAnalysisChartFactory.Create(type)`.

| Property                 | Type                                              | Required | Domain Mapping                                                                       |
|--------------------------|---------------------------------------------------|----------|--------------------------------------------------------------------------------------|
| `Name`                   | `string`                                          | No       | `PopulationAnalysisChart.Name`                                                       |
| `Type`                   | [PopulationAnalysisType](#populationanalysistype) | No       | Determines the concrete chart type created by the factory.                           |
| `XAxisSettings`          | [AxisSettings](#axissettings)                     | No       | `PopulationAnalysisChart.PrimaryXAxisSettings`.                                      |
| `YAxisSettings`          | [AxisSettings](#axissettings)                     | No       | `PopulationAnalysisChart.PrimaryYAxisSettings`.                                      |
| `SecondaryYAxisSettings` | [AxisSettings](#axissettings)\[\]                 | No       | Each added via `AddSecondaryAxis()`.                                                 |
| `Analysis`               | [PopulationAnalysis](#populationanalysis)         | No       | Mapped via `PopulationAnalysisMapper`. Updates the chart’s `BasePopulationAnalysis`. |
| `ObservedDataCollection` | [ObservedDataCollection](#observeddatacollection) | No       | Mapped and applied via `UpdateFrom()` on the chart’s existing collection.            |
| *(chart properties)*     |                                                   |          | Title, FontAndSize, Settings, etc. — same as [CurveChart](#curvechart) base.         |

### AxisSettings

A domain model object used directly in JSON.

| Property    | Type      | Required | Domain Mapping                                                      |
|-------------|-----------|----------|---------------------------------------------------------------------|
| `Min`       | `double?` | No       | `AxisSettings.Min`. Minimum axis value.                             |
| `Max`       | `double?` | No       | `AxisSettings.Max`. Maximum axis value.                             |
| `AutoRange` | `bool`    | No       | `AxisSettings.AutoRange`. Whether the axis auto-scales to fit data. |

### PopulationAnalysis

Not created – updates the existing `BasePopulationAnalysis` on the chart
via context.

| Property       | Type                                                    | Required | Domain Mapping                                                                                                           |
|----------------|---------------------------------------------------------|----------|--------------------------------------------------------------------------------------------------------------------------|
| `Fields`       | [PopulationAnalysisField](#populationanalysisfield)\[\] | No       | Each mapped via `PopulationAnalysisFieldMapper` and added to the analysis.                                               |
| `Statistics`   | [StatisticalAggregation](#statisticalaggregation)\[\]   | No       | For `PopulationStatisticalAnalysis`: each statistic is matched by ID, marked as selected, and its line style is updated. |
| `ShowOutliers` | `bool?`                                                 | No       | For `PopulationBoxWhiskerAnalysis`: `analysis.ShowOutliers`.                                                             |

After fields are added, their pivot positions (`Area` and `Index`) are
applied for `PopulationPivotAnalysis` types.

### PopulationAnalysisField

Created as one of several field types depending on which snapshot
properties are present: `PopulationAnalysisOutputField` (default),
`PopulationAnalysisParameterField`,
`PopulationAnalysisPKParameterField`,
`PopulationAnalysisCovariateField`, or
`PopulationAnalysisGroupingField`.

| Property             | Type                                      | Required | Domain Mapping                                                                                                                            |
|----------------------|-------------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `Name`               | `string`                                  | No       | `PopulationAnalysisField.Name`                                                                                                            |
| `Dimension`          | `string`                                  | No       | Resolved via `IDimensionRepository.DimensionByName()`. Sets the field’s dimension for numeric fields.                                     |
| `Unit`               | `string`                                  | No       | Resolved from the dimension. Sets `DisplayUnit`.                                                                                          |
| `Scaling`            | [Scalings](#scalings)?                    | No       | `PopulationAnalysisField.Scaling`.                                                                                                        |
| `Color`              | `Color?`                                  | No       | For output fields: `PopulationAnalysisOutputField.Color`.                                                                                 |
| `QuantityPath`       | `string`                                  | No       | For output and PK parameter fields: path to the simulation quantity.                                                                      |
| `QuantityType`       | [QuantityType](#quantitytype)?            | No       | For PK parameter fields: `PopulationAnalysisPKParameterField.QuantityType`.                                                               |
| `ParameterPath`      | `string`                                  | No       | For parameter fields: `PopulationAnalysisParameterField.ParameterPath`. Presence of this property triggers creation of a parameter field. |
| `PKParameter`        | `string`                                  | No       | For PK parameter fields: `PopulationAnalysisPKParameterField.PKParameter`. Presence triggers PK parameter field creation.                 |
| `Covariate`          | `string`                                  | No       | For covariate fields: `PopulationAnalysisCovariateField.Covariate`. Presence triggers covariate field creation.                           |
| `GroupingItems`      | [GroupingItem](#groupingitem)\[\]         | No       | For covariate fields: each item added via `AddGroupingItem()`.                                                                            |
| `GroupingDefinition` | [GroupingDefinition](#groupingdefinition) | No       | For grouping fields: mapped via `GroupingDefinitionMapper`. Presence triggers grouping field creation.                                    |
| `Area`               | [PivotArea](#pivotarea)?                  | No       | Pivot area position (used after field is added to analysis).                                                                              |
| `Index`              | `int?`                                    | No       | Position index within the pivot area.                                                                                                     |

### GroupingDefinition

Created as one of: `ValueMappingGroupingDefinition` (if `Mapping`
present), `FixedLimitsGroupingDefinition` (if `Limits` present), or
`NumberOfBinsGroupingDefinition` (default).

| Property        | Type                                                     | Required | Domain Mapping                                                                                                                                 |
|-----------------|----------------------------------------------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `FieldName`     | `string`                                                 | Yes      | Constructor parameter. The name of the field this grouping applies to.                                                                         |
| `Mapping`       | `Dictionary<string, GroupingItem>`                       | No       | For value-mapping groupings: each key-value pair added via `AddValueLabel()`. Presence triggers value-mapping creation.                        |
| `Limits`        | `double[]`                                               | No       | For fixed-limits groupings: converted from display to base units, sorted, then set via `SetLimits()`. Presence triggers fixed-limits creation. |
| `Dimension`     | `string`                                                 | No       | For interval groupings (fixed-limits and number-of-bins): resolved via dimension repository.                                                   |
| `Unit`          | `string`                                                 | No       | For interval groupings: resolved from the dimension. Sets display unit.                                                                        |
| `Items`         | [GroupingItem](#groupingitem)\[\]                        | No       | For interval groupings: added via `AddItems()`.                                                                                                |
| `NumberOfBins`  | `int?`                                                   | No       | For number-of-bins groupings: `NumberOfBinsGroupingDefinition.NumberOfBins`.                                                                   |
| `StartColor`    | `Color?`                                                 | No       | For number-of-bins groupings: start of the color gradient.                                                                                     |
| `EndColor`      | `Color?`                                                 | No       | For number-of-bins groupings: end of the color gradient.                                                                                       |
| `NamingPattern` | `string`                                                 | No       | For number-of-bins groupings: pattern for generating bin labels.                                                                               |
| `Strategy`      | [LabelGenerationStrategyId](#labelgenerationstrategyid)? | No       | For number-of-bins groupings: resolved via `LabelGenerationStrategies.ById()`.                                                                 |

### StatisticalAggregation

| Property    | Type                      | Required | Domain Mapping                                                                                                                  |
|-------------|---------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------|
| `Id`        | `string`                  | Yes      | Statistic identifier. Matched against the analysis’s predefined statistics by ID. The matching statistic is marked as selected. |
| `LineStyle` | [LineStyles](#linestyles) | No       | `StatisticalAggregation.LineStyle`. The line style used when rendering this statistic.                                          |

### ObservedDataCollection

| Property        | Type                                                      | Required | Domain Mapping                                                                                |
|-----------------|-----------------------------------------------------------|----------|-----------------------------------------------------------------------------------------------|
| `ObservedData`  | `string[]`                                                | No       | Array of observed data repository names. Each resolved from the project.                      |
| `ApplyGrouping` | `bool`                                                    | No       | `ObservedDataCollection.ApplyGrouping`. Whether grouping is applied to observed data display. |
| `CurveOptions`  | [ObservedDataCurveOptions](#observeddatacurveoptions)\[\] | No       | Per-dataset display options.                                                                  |

### ObservedDataCurveOptions

| Property       | Type                          | Required | Domain Mapping                                |
|----------------|-------------------------------|----------|-----------------------------------------------|
| `Caption`      | `string`                      | No       | Display caption for this observed data curve. |
| `Path`         | `string`                      | No       | Path identifying the observed data column.    |
| `CurveOptions` | [CurveOptions](#curveoptions) | No       | Display options for this observed data curve. |

------------------------------------------------------------------------

## Version Compatibility Summary

| Version | Int | Key Changes                                                                                                                                                                   |
|---------|-----|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| v7.3.0+ | 74+ | Minimum version for snapshot support.                                                                                                                                         |
| v9      | 77  | ExpressionProfile uses `MembraneLocation`/`TissueLocation`/`IntracellularVascularEndoLocation` (converted to `Localization`). Expression values are normalized after loading. |
| v10     | 78  | Individual uses `Molecules[]` (embedded expression profiles).                                                                                                                 |
| v11     | 79  | Individual switches to `ExpressionProfiles[]` (string references). `LocalizedParameter` paths convert `"Applications"` to `"Events"`.                                         |
| v12     | 80  | Current version.                                                                                                                                                              |

------------------------------------------------------------------------

## Sparse Serialization

All nullable properties use **sparse serialization**: if a property
equals its default value, it is serialized as `null` and omitted from
the JSON output. During import, null values are replaced with defaults.
This keeps snapshot files compact – only non-default values appear in
the JSON.

------------------------------------------------------------------------

## Enums

All enums are serialized as their string name in JSON (via
`StringEnumGenerationProvider`). Flags enums that combine multiple
values are serialized as comma-separated strings.

### CompoundType

Used in [PkaType](#pkatype) to classify ionization behavior.

| Value     | Description                           |
|-----------|---------------------------------------|
| `Neutral` | Uncharged compound, no ionization.    |
| `Acid`    | Donates a proton at physiological pH. |
| `Base`    | Accepts a proton at physiological pH. |

### PlasmaProteinBindingPartner

Used in [Compound](#compound) to specify the primary binding protein in
plasma.

| Value          | Description                                         |
|----------------|-----------------------------------------------------|
| `Unknown`      | Binding partner not specified (default).            |
| `Albumin`      | Binds primarily to albumin.                         |
| `Glycoprotein` | Binds primarily to alpha-1-acid glycoprotein (AGP). |

### QuantityType

Flags enum. Used in [ExpressionProfile](#expressionprofile) to define
the molecule type.

| Value          | Description                                   |
|----------------|-----------------------------------------------|
| `Undefined`    | No type assigned.                             |
| `Drug`         | Parent drug molecule.                         |
| `Metabolite`   | Metabolic product of a drug.                  |
| `Enzyme`       | Metabolizing enzyme.                          |
| `Transporter`  | Membrane transporter protein.                 |
| `Complex`      | Drug-protein complex.                         |
| `OtherProtein` | Protein that is not an enzyme or transporter. |
| `Observer`     | Calculated observer quantity.                 |
| `Parameter`    | Model parameter.                              |
| `BaseGrid`     | Independent variable (time axis).             |

Composite values: `Protein` = OtherProtein, Enzyme, Transporter.
`Molecule` = Drug, Metabolite, Protein, Complex.

### Localization

Flags enum. Used in [ExpressionProfile](#expressionprofile) to specify
where a protein is expressed in tissue.

| Value                     | Description                                                     |
|---------------------------|-----------------------------------------------------------------|
| `None`                    | No localization.                                                |
| `Intracellular`           | Inside the cell cytoplasm.                                      |
| `Interstitial`            | In the interstitial space surrounding cells.                    |
| `BloodCellsMembrane`      | On the membrane of blood cells (e.g. red blood cells).          |
| `BloodCellsIntracellular` | Inside blood cells.                                             |
| `VascEndosome`            | In endosomes of vascular endothelial cells.                     |
| `VascMembranePlasmaSide`  | On the plasma-facing side of the vascular endothelium membrane. |
| `VascMembraneTissueSide`  | On the tissue-facing side of the vascular endothelium membrane. |

Composite values: `InTissue` = Intracellular, Interstitial.
`InBloodCells` = BloodCellsMembrane, BloodCellsIntracellular.
`InVascularEndothelium` = VascEndosome, VascMembranePlasmaSide,
VascMembraneTissueSide.

### MembraneLocation

**Legacy (v9 and below)**. Used in
[ExpressionProfile](#expressionprofile) and
[ExpressionContainer](#expressioncontainer). Converted to
[Localization](#localization) during import.

| Value               | Description                               |
|---------------------|-------------------------------------------|
| `Apical`            | Apical (luminal) side of polarized cells. |
| `Basolateral`       | Basolateral side of polarized cells.      |
| `BloodBrainBarrier` | Blood-brain barrier membrane.             |
| `Tissue`            | General tissue membrane.                  |

### TissueLocation

**Legacy (v9 and below)**. Used in
[ExpressionProfile](#expressionprofile). Converted to
[Localization](#localization) during import.

| Value                   | Description                            |
|-------------------------|----------------------------------------|
| `ExtracellularMembrane` | On the extracellular membrane surface. |
| `Intracellular`         | Inside the cell.                       |
| `Interstitial`          | In the interstitial space.             |

### IntracellularVascularEndoLocation

**Legacy (v9 and below)**. Used in
[ExpressionProfile](#expressionprofile). Converted to
[Localization](#localization) during import.

| Value          | Description                                        |
|----------------|----------------------------------------------------|
| `Endosomal`    | In vascular endothelial endosomes.                 |
| `Interstitial` | In the interstitial space of vascular endothelium. |

### TransportType

Flags enum. Used in [ExpressionProfile](#expressionprofile) to classify
the transporter mechanism.

| Value           | Description                               |
|-----------------|-------------------------------------------|
| `Efflux`        | Pumps substrate out of the cell.          |
| `Influx`        | Pumps substrate into the cell.            |
| `PgpLike`       | P-glycoprotein-like bidirectional efflux. |
| `BiDirectional` | Transports in both directions.            |
| `Secretion`     | Passive secretion.                        |
| `Elimination`   | Passive elimination.                      |
| `Diffusion`     | Passive diffusion across membranes.       |
| `Convection`    | Passive convective transport.             |

Composite values: `Active` = Influx, Efflux, PgpLike, BiDirectional.
`Passive` = Secretion, Elimination, Diffusion, Convection.

### TransportDirectionId

Used in [ExpressionContainer](#expressioncontainer) to specify the
direction of transport in a specific organ/compartment.

| Value                                    | Description                                               |
|------------------------------------------|-----------------------------------------------------------|
| `None`                                   | No transport.                                             |
| `InfluxPlasmaToInterstitial`             | Influx from plasma to interstitial space.                 |
| `EffluxInterstitialToPlasma`             | Efflux from interstitial space to plasma.                 |
| `BiDirectionalPlasmaInterstitial`        | Bidirectional between plasma and interstitial.            |
| `InfluxPlasmaToBloodCells`               | Influx from plasma into blood cells.                      |
| `EffluxBloodCellsToPlasma`               | Efflux from blood cells to plasma.                        |
| `BiDirectionalBloodCellsPlasma`          | Bidirectional between blood cells and plasma.             |
| `InfluxInterstitialToIntracellular`      | Influx from interstitial to intracellular space.          |
| `EffluxIntracellularToInterstitial`      | Efflux from intracellular to interstitial space.          |
| `BiDirectionalInterstitialIntracellular` | Bidirectional between interstitial and intracellular.     |
| `PgpIntracellularToInterstitial`         | P-gp-like efflux from intracellular to interstitial.      |
| `InfluxLumenToMucosaIntracellular`       | Influx from gut lumen into mucosa intracellular.          |
| `EffluxMucosaIntracellularToLumen`       | Efflux from mucosa intracellular to gut lumen.            |
| `BiDirectionalLumenMucosaIntracellular`  | Bidirectional between lumen and mucosa intracellular.     |
| `PgpMucosaIntracellularToLumen`          | P-gp-like efflux from mucosa intracellular to lumen.      |
| `ExcretionKidney`                        | Renal excretion (kidney).                                 |
| `ExcretionLiver`                         | Hepatic excretion (liver/bile).                           |
| `InfluxBrainInterstitialToTissue`        | Influx from brain interstitial to brain tissue.           |
| `EffluxBrainTissueToInterstitial`        | Efflux from brain tissue to brain interstitial.           |
| `BiDirectionalBrainInterstitialTissue`   | Bidirectional between brain interstitial and tissue.      |
| `PgpBrainTissueToInterstitial`           | P-gp-like efflux from brain tissue to interstitial.       |
| `InfluxBrainPlasmaToInterstitial`        | Influx from brain plasma to brain interstitial (BBB).     |
| `EffluxBrainInterstitialToPlasma`        | Efflux from brain interstitial to brain plasma (BBB).     |
| `BiDirectionalBrainPlasmaInterstitial`   | Bidirectional across blood-brain barrier.                 |
| `PgpBrainInterstitialToPlasma`           | P-gp-like efflux from brain interstitial to plasma (BBB). |

### DosingIntervalId

Used in [Protocol (Simple)](#simple-protocol) to define the dosing
schedule.

| Value        | Description                    |
|--------------|--------------------------------|
| `Single`     | Single dose administration.    |
| `DI_6_6_6_6` | Every 6 hours (4 times daily). |
| `DI_6_6_12`  | 6h, 6h, then 12h intervals.    |
| `DI_8_8_8`   | Every 8 hours (3 times daily). |
| `DI_12_12`   | Every 12 hours (twice daily).  |
| `DI_24`      | Every 24 hours (once daily).   |

### DistributionType

Used in [AdvancedParameter](#advancedparameter) to define the
statistical distribution for population variability.

| Value       | Description                               |
|-------------|-------------------------------------------|
| `Normal`    | Normal (Gaussian) distribution.           |
| `LogNormal` | Log-normal distribution.                  |
| `Uniform`   | Uniform distribution between min and max. |
| `Discrete`  | Discrete distribution with fixed values.  |
| `Unknown`   | Distribution type not specified.          |

### Scalings

Used in [OutputMapping](#outputmapping), [Simulation](#simulation) axes,
and [PopulationAnalysisField](#populationanalysischart) for axis
scaling.

| Value    | Description        |
|----------|--------------------|
| `Linear` | Linear scale.      |
| `Log`    | Logarithmic scale. |

### PKSimBuildingBlockType

Flags enum. Used in [AlteredBuildingBlock](#alteredbuildingblock) to
identify the type of a building block.

| Value               | Description             |
|---------------------|-------------------------|
| `Simulation`        | A simulation.           |
| `Compound`          | A compound (drug).      |
| `Formulation`       | A formulation.          |
| `Protocol`          | A dosing protocol.      |
| `Individual`        | An individual organism. |
| `Population`        | A population.           |
| `Event`             | A simulation event.     |
| `ObserverSet`       | A set of observers.     |
| `ExpressionProfile` | An expression profile.  |

Composite values: `SimulationSubject` = Individual, Population.
`Template` = all non-Simulation types.

### ValueOriginSourceId

Used in [ValueOrigin](#valueorigin) to identify where a parameter value
came from.

| Value                     | Description                                             |
|---------------------------|---------------------------------------------------------|
| `Undefined`               | Not specified (default).                                |
| `Unknown`                 | Source is unknown.                                      |
| `Database`                | Value from the PKSim database.                          |
| `Internet`                | Value sourced from an internet resource.                |
| `Publication`             | Value from a scientific publication.                    |
| `ParameterIdentification` | Value determined by parameter identification (fitting). |
| `Other`                   | Other source not listed above.                          |

### ValueOriginDeterminationMethodId

Used in [ValueOrigin](#valueorigin) to describe how a parameter value
was determined.

| Value                     | Description                                             |
|---------------------------|---------------------------------------------------------|
| `Undefined`               | Not specified (default).                                |
| `Unknown`                 | Determination method unknown.                           |
| `Assumption`              | Value based on an assumption.                           |
| `ManualFit`               | Value determined by manual fitting.                     |
| `ParameterIdentification` | Value determined by automated parameter identification. |
| `InVitro`                 | Value measured in vitro.                                |
| `InVivo`                  | Value measured in vivo.                                 |
| `Other`                   | Other method not listed above.                          |

### ColumnOrigins

Used in [DataColumn](#datacolumn) (via `DataInfo`) to classify the
origin of a data column.

| Value                  | Description                                               |
|------------------------|-----------------------------------------------------------|
| `Undefined`            | Origin not specified.                                     |
| `BaseGrid`             | Independent variable column (e.g. time).                  |
| `Calculation`          | Result of a simulation calculation.                       |
| `Observation`          | Experimentally observed data.                             |
| `ObservationAuxiliary` | Auxiliary data related to observations (e.g. error bars). |
| `CalculationAuxiliary` | Auxiliary data related to calculations.                   |
| `DeviationLine`        | Deviation line for comparison.                            |

### AuxiliaryType

Used in [DataColumn](#datacolumn) (via `DataInfo`) to classify auxiliary
column types.

| Value               | Description                    |
|---------------------|--------------------------------|
| `Undefined`         | Not an auxiliary column.       |
| `ArithmeticStdDev`  | Arithmetic standard deviation. |
| `GeometricStdDev`   | Geometric standard deviation.  |
| `ArithmeticMeanPop` | Arithmetic mean of population. |
| `GeometricMeanPop`  | Geometric mean of population.  |

### PopulationAnalysisType

Used in [PopulationAnalysisChart](#populationanalysischart) to determine
the chart type.

| Value         | Description                         |
|---------------|-------------------------------------|
| `TimeProfile` | Time-profile analysis chart.        |
| `BoxWhisker`  | Box-and-whisker plot.               |
| `Scatter`     | Scatter plot.                       |
| `Range`       | Range plot (e.g. percentile bands). |

### AxisTypes

Used in [CurveChart](#curvechart) axes and curve options to assign
curves to axes.

| Value | Description              |
|-------|--------------------------|
| `X`   | X-axis (typically time). |
| `Y`   | Primary Y-axis.          |
| `Y2`  | Secondary Y-axis.        |
| `Y3`  | Tertiary Y-axis.         |

### LineStyles

Used in [CurveChart](#curvechart) curve options and axes to define line
rendering.

| Value     | Description                |
|-----------|----------------------------|
| `None`    | No line drawn.             |
| `Solid`   | Solid continuous line.     |
| `Dash`    | Dashed line.               |
| `Dot`     | Dotted line.               |
| `DashDot` | Alternating dash-dot line. |

### Symbols

Used in [CurveChart](#curvechart) curve options to define data point
markers.

| Value              | Description                 |
|--------------------|-----------------------------|
| `None`             | No symbol drawn.            |
| `Circle`           | Circle marker.              |
| `Diamond`          | Diamond marker.             |
| `Triangle`         | Upward-pointing triangle.   |
| `Square`           | Square marker.              |
| `InvertedTriangle` | Downward-pointing triangle. |
| `Plus`             | Plus sign (+) marker.       |
| `Cross`            | Cross (x) marker.           |
| `Star`             | Star marker.                |
| `Pentagon`         | Pentagon marker.            |
| `Hexagon`          | Hexagon marker.             |
| `ThinCross`        | Thin cross marker.          |

### InterpolationModes

Used in [CurveChart](#curvechart) curve options to define how points are
connected.

| Value     | Description                            |
|-----------|----------------------------------------|
| `xLinear` | Linear interpolation along the X-axis. |
| `yLinear` | Linear interpolation along the Y-axis. |

### NumberModes

Used in [CurveChart](#curvechart) axes to control number display format.

| Value        | Description                         |
|--------------|-------------------------------------|
| `Normal`     | Standard decimal notation.          |
| `Scientific` | Scientific notation (e.g. 1.5E+03). |
| `Relative`   | Relative/normalized values.         |

### PivotArea

Flags enum. Used in [PopulationAnalysisChart](#populationanalysischart)
fields to control where a field appears in the analysis pivot layout.

| Value        | Description                         |
|--------------|-------------------------------------|
| `DataArea`   | Field provides the data values.     |
| `FilterArea` | Field is used as a filter.          |
| `RowArea`    | Field defines the rows (grouping).  |
| `ColorArea`  | Field controls the color grouping.  |
| `SymbolArea` | Field controls the symbol grouping. |

Composite values: `ColumnArea` = ColorArea, SymbolArea. `All` =
DataArea, FilterArea, ColumnArea, RowArea.

### LegendPositions

Used in [ChartSettings](#chartsettings) to control legend placement.

| Value          | Description                                                     |
|----------------|-----------------------------------------------------------------|
| `None`         | No legend displayed.                                            |
| `Right`        | Legend placed to the right of the chart, outside the plot area. |
| `RightInside`  | Legend placed inside the plot area, top-right (default).        |
| `Bottom`       | Legend placed below the chart, outside the plot area.           |
| `BottomInside` | Legend placed inside the plot area, bottom.                     |

### ExtendedPropertyType

Used in [ExtendedProperty](#extendedproperty) to explicitly specify the
.NET type for value parsing.

| Value     | Description                  |
|-----------|------------------------------|
| `String`  | Value is a string.           |
| `Integer` | Value is parsed as `int`.    |
| `Double`  | Value is parsed as `double`. |
| `Boolean` | Value is parsed as `bool`.   |

### LabelGenerationStrategyId

Used in [GroupingDefinition](#groupingdefinition) to control how bin
labels are generated for number-of-bins groupings.

| Value     | Description                                                     |
|-----------|-----------------------------------------------------------------|
| `Numeric` | Labels generated as numeric values (e.g. `1`, `2`, `3`).        |
| `Alpha`   | Labels generated as alphabetic characters (e.g. `A`, `B`, `C`). |
| `Roman`   | Labels generated as Roman numerals (e.g. `I`, `II`, `III`).     |
