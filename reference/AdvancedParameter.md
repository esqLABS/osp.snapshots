# AdvancedParameter class for Population advanced parameters

An R6 class that represents an advanced parameter in a population.

## Active bindings

- `data`:

  The raw data of the parameter (read-only)

- `name`:

  The name of the parameter

- `seed`:

  The seed used for parameter generation

- `distribution_type`:

  The distribution type of the parameter

- `parameters`:

  The parameters of the distribution

## Methods

### Public methods

- [`AdvancedParameter$new()`](#method-AdvancedParameter-new)

- [`AdvancedParameter$print()`](#method-AdvancedParameter-print)

- [`AdvancedParameter$clone()`](#method-AdvancedParameter-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new AdvancedParameter object

#### Usage

    AdvancedParameter$new(data)

#### Arguments

- `data`:

  Raw parameter data from a population

#### Returns

A new AdvancedParameter object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print a summary of the advanced parameter

#### Usage

    AdvancedParameter$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the AdvancedParameter object for method chaining

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    AdvancedParameter$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
