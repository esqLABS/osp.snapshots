# Population class for OSP snapshot populations

An R6 class that represents a population in an OSP snapshot. This class
provides methods to access different properties of a population and
display a summary of its information.

## Active bindings

- `data`:

  The raw data of the population (read-only)

- `name`:

  The name of the population. Writable: must be a non-empty scalar
  string.

- `description`:

  A free-text description of the population

- `source_population`:

  The source population name (read-only)

- `individual_name`:

  The individual name (read-only)

- `individual`:

  The base individual the population samples from, returned as an
  [Individual](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md)
  object built from the base individual in the population settings, or
  `NULL` when none is set (read-only). Author it at construction time
  via the `individual` argument of
  [`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md).

- `seed`:

  The seed used for population generation

- `number_of_individuals`:

  The number of individuals in the population. Writable: must be a
  single positive whole number.

- `proportion_of_females`:

  The percentage of females in the population

- `age_range`:

  The age range for the population. Writable: the `Range`'s `unit` must
  be a valid unit for dimension `"Age in years"`.

- `weight_range`:

  The weight range for the population. Writable: the `Range`'s `unit`
  must be a valid unit for dimension `"Mass"`.

- `height_range`:

  The height range for the population. Writable: the `Range`'s `unit`
  must be a valid unit for dimension `"Length"`.

- `bmi_range`:

  The BMI range for the population. Writable: when the `"BMI"` dimension
  resolves in the installed `ospsuite`, the `Range`'s `unit` must be a
  valid unit for it; otherwise the unit is left unvalidated (a
  documented, opportunistic limitation).

- `gestational_age_range`:

  The gestational age range used for population generation. Writable:
  the `Range`'s `unit` must be a valid unit for dimension `"Time"`.

- `egfr_range`:

  The eGFR range for the population (if available). Convenience over the
  case-insensitive `"egfr"` entry of `disease_state_parameters`; writes
  persist into the population settings so they survive export.

- `disease_state_parameters`:

  The population disease-state parameters as a named list mapping each
  parameter name to a
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object. Assign a named list of `Range` objects to replace them, or
  `NULL` to clear them. This population-level name-to-`Range` map is
  distinct from the base individual's own `disease_state_parameters`,
  which carries scalar parameter values.

- `advanced_parameters`:

  Advanced parameters for the population

## Methods

### Public methods

- [`Population$new()`](#method-Population-initialize)

- [`Population$print()`](#method-Population-print)

- [`Population$to_df()`](#method-Population-to_df)

- [`Population$clone()`](#method-Population-clone)

------------------------------------------------------------------------

### `Population$new()`

Create a new Population object

#### Usage

    Population$new(data)

#### Arguments

- `data`:

  Raw population data from a snapshot

#### Returns

A new Population object

------------------------------------------------------------------------

### `Population$print()`

Print a summary of the population including its properties and settings.

#### Usage

    Population$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Population object for method chaining

------------------------------------------------------------------------

### `Population$to_df()`

Convert the population to a list of data frames for easier analysis

#### Usage

    Population$to_df()

#### Returns

A list containing data frames with population information:

- characteristics: Population characteristics including basic
  information and physiological parameters

- parameters: Advanced parameters information

------------------------------------------------------------------------

### `Population$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Population$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
