# Individual class for OSP snapshot individuals

An R6 class that represents an individual in an OSP snapshot. This class
provides methods to access different properties of an individual and
display a summary of its information.

## Active bindings

- `data`:

  The raw data of the individual (read-only)

- `name`:

  The name of the individual

- `seed`:

  The simulation seed for the individual

- `origin_data`:

  The \[OriginData\] object holding species, population, gender,
  physiological parameters, and calculation methods.

- `species`:

  The species of the individual

- `population`:

  The population of the individual

- `gender`:

  The gender of the individual

- `age`:

  The age value of the individual

- `age_unit`:

  The age unit of the individual

- `weight`:

  The weight value of the individual

- `weight_unit`:

  The weight unit of the individual

- `height`:

  The height value of the individual

- `height_unit`:

  The height unit of the individual

- `gestational_age`:

  The gestational age value of the individual

- `gestational_age_unit`:

  The gestational age unit of the individual

- `disease_state`:

  The disease state of the individual

- `disease_state_parameters`:

  The disease state parameters of the individual

- `parameters`:

  The list of parameter objects with a custom print method

- `calculation_methods`:

  The calculation methods of the individual, returned as a character
  vector for backwards compatibility. Use
  \`\$origin_data\$calculation_methods\` to access the
  \[CalculationMethodCache\] directly.

- `expression_profiles`:

  The expression profiles of the individual (read-only)

## Methods

### Public methods

- [`Individual$new()`](#method-Individual-initialize)

- [`Individual$print()`](#method-Individual-print)

- [`Individual$to_df()`](#method-Individual-to_df)

- [`Individual$clone()`](#method-Individual-clone)

------------------------------------------------------------------------

### `Individual$new()`

Create a new Individual object

#### Usage

    Individual$new(data)

#### Arguments

- `data`:

  Raw individual data from a snapshot

#### Returns

A new Individual object

------------------------------------------------------------------------

### `Individual$print()`

Print a summary of the individual including its properties and
parameters.

#### Usage

    Individual$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Individual object for method chaining

------------------------------------------------------------------------

### `Individual$to_df()`

Convert individual data to tibbles

#### Usage

    Individual$to_df(type = "all")

#### Arguments

- `type`:

  Character. Type of data to convert: "all" (default), "individuals",
  "individuals_parameters", or "individuals_expressions"

#### Returns

A list of tibbles containing the requested data

------------------------------------------------------------------------

### `Individual$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Individual$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
