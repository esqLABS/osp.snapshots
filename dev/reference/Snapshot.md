# Snapshot class for OSP snapshots

An R6 class that represents an OSP snapshot file. This class provides
methods to access different components of the snapshot and visualize its
structure.

## Supported snapshot versions

`Snapshot` only accepts PK-Sim v11+ snapshots, i.e. integer `Version`
values of `79` or greater (see `osp.snapshots:::SUPPORTED_VERSION_MIN`).
Earlier snapshots use different conventions (notably `Applications|...`
instead of `Events|...` in parameter paths) and are not modelled by this
package; `Snapshot$new()` aborts on them rather than silently rewriting
fields. Hand-rolled list input must supply `Version` for the same
reason.

## Active bindings

- `data`:

  The aggregated data of the snapshot from all components

- `pksim_version`:

  The human-readable PKSIM version corresponding to the snapshot version

- `path`:

  The path to the snapshot file relative to the working directory

- `compounds`:

  List of Compound objects in the snapshot

- `expression_profiles`:

  List of ExpressionProfile objects in the snapshot

- `individuals`:

  List of Individual objects in the snapshot

- `formulations`:

  List of Formulation objects in the snapshot

- `populations`:

  List of Population objects in the snapshot

- `events`:

  List of Event objects in the snapshot

- `observer_sets`:

  List of ObserverSet objects in the snapshot

- `protocols`:

  List of Protocol objects in the snapshot

- `observed_data`:

  List of DataSet objects (observed data) in the snapshot

- `simulations`:

  List of Simulation objects in the snapshot

## Methods

### Public methods

- [`Snapshot$new()`](#method-Snapshot-initialize)

- [`Snapshot$print()`](#method-Snapshot-print)

- [`Snapshot$export()`](#method-Snapshot-export)

- [`Snapshot$add_individual()`](#method-Snapshot-add_individual)

- [`Snapshot$remove_individual()`](#method-Snapshot-remove_individual)

- [`Snapshot$add_formulation()`](#method-Snapshot-add_formulation)

- [`Snapshot$remove_formulation()`](#method-Snapshot-remove_formulation)

- [`Snapshot$remove_population()`](#method-Snapshot-remove_population)

- [`Snapshot$add_expression_profile()`](#method-Snapshot-add_expression_profile)

- [`Snapshot$remove_expression_profile()`](#method-Snapshot-remove_expression_profile)

- [`Snapshot$add_observer_set()`](#method-Snapshot-add_observer_set)

- [`Snapshot$remove_observer_set()`](#method-Snapshot-remove_observer_set)

- [`Snapshot$add_observed_data()`](#method-Snapshot-add_observed_data)

- [`Snapshot$remove_observed_data()`](#method-Snapshot-remove_observed_data)

- [`Snapshot$add_compound()`](#method-Snapshot-add_compound)

- [`Snapshot$remove_compound()`](#method-Snapshot-remove_compound)

- [`Snapshot$add_population()`](#method-Snapshot-add_population)

- [`Snapshot$add_protocol()`](#method-Snapshot-add_protocol)

- [`Snapshot$remove_protocol()`](#method-Snapshot-remove_protocol)

- [`Snapshot$add_event()`](#method-Snapshot-add_event)

- [`Snapshot$remove_event()`](#method-Snapshot-remove_event)

- [`Snapshot$add_simulation()`](#method-Snapshot-add_simulation)

- [`Snapshot$remove_simulation()`](#method-Snapshot-remove_simulation)

- [`Snapshot$clone()`](#method-Snapshot-clone)

------------------------------------------------------------------------

### `Snapshot$new()`

Create a new Snapshot object from a JSON file or a list

#### Usage

    Snapshot$new(input)

#### Arguments

- `input`:

  Path to the snapshot JSON file, URL, template name, or a list
  containing snapshot data. The parsed data must contain an integer
  `Version` field of `79` (v11.2) or greater; older or missing versions
  abort.

#### Returns

A new Snapshot object

------------------------------------------------------------------------

### `Snapshot$print()`

Print a summary of the snapshot

#### Usage

    Snapshot$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the snapshot object

------------------------------------------------------------------------

### `Snapshot$export()`

Export the snapshot to a JSON file

#### Usage

    Snapshot$export(path)

#### Arguments

- `path`:

  Path to save the JSON file

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Snapshot$add_individual()`

Add one or more Individual objects to the snapshot. References to
expression profiles not yet in the snapshot trigger one informational
warning per individual; the add proceeds either way.

#### Usage

    Snapshot$add_individual(individual)

#### Arguments

- `individual`:

  An Individual object created with create_individual(), or a list of
  such objects.

#### Returns

Invisibly returns the object

#### Examples

    # Create a new individual
    ind <- create_individual(name = "New Patient", age = 35, weight = 70)

    # Add the individual to a snapshot
    snapshot$add_individual(ind)

    # Add several at once
    patients <- list(
      create_individual("Patient_A", age = 25),
      create_individual("Patient_B", age = 45)
    )
    snapshot$add_individual(patients)

------------------------------------------------------------------------

### `Snapshot$remove_individual()`

Remove an individual from the snapshot by name

#### Usage

    Snapshot$remove_individual(individual_name)

#### Arguments

- `individual_name`:

  Character vector of individual name(s) to remove

#### Returns

Invisibly returns the object

#### Examples

    # Remove an individual from the snapshot
    snapshot$remove_individual("Subject_001")

------------------------------------------------------------------------

### `Snapshot$add_formulation()`

Add one or more Formulation objects to the snapshot.

#### Usage

    Snapshot$add_formulation(formulation)

#### Arguments

- `formulation`:

  A Formulation object created with create_formulation(), or a list of
  such objects.

#### Returns

Invisibly returns the object

#### Examples

    # Create a new formulation
    form <- create_formulation(name = "Tablet", type = "Weibull")

    # Add the formulation to a snapshot
    snapshot$add_formulation(form)

    # Add several at once
    forms <- list(
      create_formulation("Tablet", type = "Weibull"),
      create_formulation("Oral solution", type = "First Order")
    )
    snapshot$add_formulation(forms)

------------------------------------------------------------------------

### `Snapshot$remove_formulation()`

Remove a formulation from the snapshot by name

#### Usage

    Snapshot$remove_formulation(formulation_name)

#### Arguments

- `formulation_name`:

  Character vector of formulation name(s) to remove

#### Returns

Invisibly returns the object

#### Examples

    # Remove a formulation from the snapshot
    snapshot$remove_formulation("Tablet")

------------------------------------------------------------------------

### `Snapshot$remove_population()`

Remove a population from the snapshot by name

#### Usage

    Snapshot$remove_population(population_name)

#### Arguments

- `population_name`:

  Character vector of population name(s) to remove

#### Returns

Invisibly returns the object

#### Examples

    # Remove a population from the snapshot
    snapshot$remove_population("pop_1")

------------------------------------------------------------------------

### `Snapshot$add_expression_profile()`

Add one or more ExpressionProfile objects to the snapshot.

#### Usage

    Snapshot$add_expression_profile(expression_profile)

#### Arguments

- `expression_profile`:

  An ExpressionProfile object, or a list of such objects.

#### Returns

Invisibly returns the object

#### Examples

    # Create a new expression profile
    profile_data <- list(
      Type = "Enzyme",
      Species = "Human",
      Molecule = "CYP3A4",
      Category = "Healthy",
      Parameters = list()
    )
    profile <- ExpressionProfile$new(profile_data)

    # Add the expression profile to a snapshot
    snapshot$add_expression_profile(profile)

    # Add several at once
    snapshot$add_expression_profile(list(profile, profile))

------------------------------------------------------------------------

### `Snapshot$remove_expression_profile()`

Remove expression profiles from the snapshot by ID

#### Usage

    Snapshot$remove_expression_profile(profile_id)

#### Arguments

- `profile_id`:

  Character vector of expression profile IDs to remove

#### Returns

Invisibly returns the object

#### Examples

    # Remove an expression profile from the snapshot
    snapshot$remove_expression_profile("CYP3A4_Human_Healthy")

------------------------------------------------------------------------

### `Snapshot$add_observer_set()`

#### Usage

    Snapshot$add_observer_set(observer_set)

------------------------------------------------------------------------

### `Snapshot$remove_observer_set()`

#### Usage

    Snapshot$remove_observer_set(observer_set_name)

------------------------------------------------------------------------

### `Snapshot$add_observed_data()`

Add one or more DataSet objects (observed data) to the snapshot.

#### Usage

    Snapshot$add_observed_data(observed_data)

#### Arguments

- `observed_data`:

  A DataSet object created from snapshot observed data, or a list of
  such objects.

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Snapshot$remove_observed_data()`

Remove observed data from the snapshot by name

#### Usage

    Snapshot$remove_observed_data(observed_data_name)

#### Arguments

- `observed_data_name`:

  Character vector of observed data names to remove

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Snapshot$add_compound()`

#### Usage

    Snapshot$add_compound(compound)

------------------------------------------------------------------------

### `Snapshot$remove_compound()`

#### Usage

    Snapshot$remove_compound(compound_name)

------------------------------------------------------------------------

### `Snapshot$add_population()`

#### Usage

    Snapshot$add_population(population)

------------------------------------------------------------------------

### `Snapshot$add_protocol()`

#### Usage

    Snapshot$add_protocol(protocol)

------------------------------------------------------------------------

### `Snapshot$remove_protocol()`

#### Usage

    Snapshot$remove_protocol(protocol_name)

------------------------------------------------------------------------

### `Snapshot$add_event()`

#### Usage

    Snapshot$add_event(event)

------------------------------------------------------------------------

### `Snapshot$remove_event()`

#### Usage

    Snapshot$remove_event(event_name)

------------------------------------------------------------------------

### `Snapshot$add_simulation()`

Build a simulation from named arguments and attach it, or attach a
pre-built simulation.

The build mode is the entry point: with the snapshot in hand it resolves
compound references and derives defaults (calculation methods,
formulation key, alternatives) before attaching. Supply `name` plus
exactly one of `individual` / `population` to build; each inline
`compounds` entry is either a config list
(`list(name =, protocol =, formulation =, processes =, ...)`) or a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
escape-hatch object. Alternatively supply a pre-built
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
(or a list of them) through `simulation`. References to building blocks
not yet in the snapshot trigger one informational warning per
simulation; the add proceeds either way.

#### Usage

    Snapshot$add_simulation(
      simulation = NULL,
      name = NULL,
      model = "4Comp",
      individual = NULL,
      population = NULL,
      compounds = NULL,
      events = NULL,
      observer_sets = NULL,
      observed_data_names = NULL,
      solver = NULL,
      output_schema = NULL,
      output_selections = NULL,
      output_mappings = NULL,
      parameters = NULL,
      advanced_parameters = NULL,
      description = NULL,
      allow_aging = NULL
    )

#### Arguments

- `simulation`:

  A pre-built
  [Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
  object, or a list of such objects. Leave `NULL` to build a simulation
  from the named arguments instead.

- `name`:

  Character. Simulation name (required in build mode).

- `model`:

  Character. PK-Sim model name (defaults to `"4Comp"`).

- `individual`:

  Character. Name of the individual building block. Mutually exclusive
  with `population`.

- `population`:

  Character. Name of the population building block. Mutually exclusive
  with `individual`.

- `compounds`:

  List of inline compound-config lists
  (`list(name =, protocol =, formulation =, processes =, calculation_methods =, alternatives =)`)
  and/or
  [CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
  objects (the escape hatch).

- `events`:

  List of
  [EventSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/EventSelection.md)
  objects or raw lists.

- `observer_sets`:

  List of
  [ObserverSetSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ObserverSetSelection.md)
  objects or raw lists.

- `observed_data_names`:

  Character vector of observed-data names.

- `solver`:

  A
  [SolverSettings](https://esqlabs.github.io/osp.snapshots/dev/reference/SolverSettings.md)
  object or raw list. Defaults to PK-Sim defaults.

- `output_schema`:

  An
  [OutputSchema](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputSchema.md)
  object or raw list. Defaults to an empty schema.

- `output_selections`:

  Character vector of output quantity paths.

- `output_mappings`:

  List of
  [OutputMapping](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputMapping.md)
  objects or raw lists.

- `parameters`:

  List of
  [LocalizedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/LocalizedParameter.md)
  objects (created with `create_parameter(path = ..., ...)`) or raw
  parameter lists.

- `advanced_parameters`:

  List of
  [AdvancedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/AdvancedParameter.md)
  objects or raw lists (population simulations only).

- `description`:

  Character. Free-text description of the simulation.

- `allow_aging`:

  Logical. Whether the simulation allows aging.

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Snapshot$remove_simulation()`

Remove a simulation from the snapshot by name

#### Usage

    Snapshot$remove_simulation(simulation_name)

#### Arguments

- `simulation_name`:

  Character vector of simulation name(s) to remove

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Snapshot$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Snapshot$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r

## ------------------------------------------------
## Method `Snapshot$add_individual()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Create a new individual
ind <- create_individual(name = "New Patient", age = 35, weight = 70)

# Add the individual to a snapshot
snapshot$add_individual(ind)

# Add several at once
patients <- list(
  create_individual("Patient_A", age = 25),
  create_individual("Patient_B", age = 45)
)
snapshot$add_individual(patients)
} # }

## ------------------------------------------------
## Method `Snapshot$remove_individual()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove an individual from the snapshot
snapshot$remove_individual("Subject_001")
} # }

## ------------------------------------------------
## Method `Snapshot$add_formulation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Create a new formulation
form <- create_formulation(name = "Tablet", type = "Weibull")

# Add the formulation to a snapshot
snapshot$add_formulation(form)

# Add several at once
forms <- list(
  create_formulation("Tablet", type = "Weibull"),
  create_formulation("Oral solution", type = "First Order")
)
snapshot$add_formulation(forms)
} # }

## ------------------------------------------------
## Method `Snapshot$remove_formulation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove a formulation from the snapshot
snapshot$remove_formulation("Tablet")
} # }

## ------------------------------------------------
## Method `Snapshot$remove_population()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove a population from the snapshot
snapshot$remove_population("pop_1")
} # }

## ------------------------------------------------
## Method `Snapshot$add_expression_profile()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Create a new expression profile
profile_data <- list(
  Type = "Enzyme",
  Species = "Human",
  Molecule = "CYP3A4",
  Category = "Healthy",
  Parameters = list()
)
profile <- ExpressionProfile$new(profile_data)

# Add the expression profile to a snapshot
snapshot$add_expression_profile(profile)

# Add several at once
snapshot$add_expression_profile(list(profile, profile))
} # }

## ------------------------------------------------
## Method `Snapshot$remove_expression_profile()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
# Remove an expression profile from the snapshot
snapshot$remove_expression_profile("CYP3A4_Human_Healthy")
} # }
```
