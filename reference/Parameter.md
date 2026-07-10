# Parameter class for OSP snapshot parameters

An R6 class that represents a parameter in an OSP snapshot. This class
provides methods to access different properties of a parameter and
display a summary of its information.

## Active bindings

- `data`:

  The raw data of the parameter (read-only).

- `path`:

  The path of the parameter

- `name`:

  The name of the parameter (same as path)

- `value`:

  The value of the parameter

- `unit`:

  The unit of the parameter (if any). Writable: a non-`NULL` value must
  be a single non-empty character string, or `NULL` to clear. A bare
  `Parameter` carries no dimension, so a dimension-aware
  [`validate_unit()`](https://esqlabs.github.io/osp.snapshots/reference/validate_unit.md)
  check is not universally applicable here; only the shape is enforced.

- `value_origin`:

  The origin information for the parameter value

- `table_formula`:

  The table formula data for table parameters

## Methods

### Public methods

- [`Parameter$new()`](#method-Parameter-initialize)

- [`Parameter$print()`](#method-Parameter-print)

- [`Parameter$to_df()`](#method-Parameter-to_df)

- [`Parameter$clone()`](#method-Parameter-clone)

------------------------------------------------------------------------

### `Parameter$new()`

Create a new Parameter object

#### Usage

    Parameter$new(data)

#### Arguments

- `data`:

  Raw parameter data from a snapshot

#### Returns

A new Parameter object

------------------------------------------------------------------------

### `Parameter$print()`

Print a summary of the parameter

#### Usage

    Parameter$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the object

------------------------------------------------------------------------

### `Parameter$to_df()`

Convert parameter data to a tibble row

#### Usage

    Parameter$to_df()

#### Returns

A tibble with one row containing the parameter data

------------------------------------------------------------------------

### `Parameter$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Parameter$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
