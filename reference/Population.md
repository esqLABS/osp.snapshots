# Population class for OSP snapshot populations

An R6 class that represents a population in an OSP snapshot. This class
provides methods to access different properties of a population and
display a summary of its information.

## Active bindings

- `data`:

  The raw data of the population (read-only)

- `name`:

  The name of the population

- `source_population`:

  The source population name (read-only)

- `individual_name`:

  The individual name (read-only)

- `seed`:

  The seed used for population generation

- `number_of_individuals`:

  The number of individuals in the population

- `proportion_of_females`:

  The percentage of females in the population

- `age_range`:

  The age range for the population

- `weight_range`:

  The weight range for the population

- `height_range`:

  The height range for the population

- `bmi_range`:

  The BMI range for the population

- `egfr_range`:

  The eGFR range for the population (if available)

- `advanced_parameters`:

  Advanced parameters for the population

## Methods

### Public methods

- [`Population$new()`](#method-Population-new)

- [`Population$print()`](#method-Population-print)

- [`Population$to_df()`](#method-Population-to_df)

- [`Population$clone()`](#method-Population-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Population object

#### Usage

    Population$new(data)

#### Arguments

- `data`:

  Raw population data from a snapshot

#### Returns

A new Population object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the population including its properties and settings.

#### Usage

    Population$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Population object for method chaining

------------------------------------------------------------------------

### Method `to_df()`

Convert the population to a list of data frames for easier analysis

#### Usage

    Population$to_df()

#### Returns

A list containing data frames with population information:

- characteristics: Population characteristics including basic
  information and physiological parameters

- parameters: Advanced parameters information

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Population$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
