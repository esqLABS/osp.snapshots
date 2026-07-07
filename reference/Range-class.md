# Range class for physiological parameters

An R6 class that represents a range of values with a minimum, maximum
and unit. Used for age, weight, height, and BMI ranges in populations.
Either `min` or `max` can be `NULL` to represent ranges with only an
upper or lower bound.

Use
[`range()`](https://esqlabs.github.io/osp.snapshots/reference/range.md)
as the user-facing constructor; `Range$new()` is the equivalent direct
call on the R6 generator.

## Active bindings

- `min`:

  The minimum value of the range

- `max`:

  The maximum value of the range

- `unit`:

  The unit of the range

## Methods

### Public methods

- [`Range$new()`](#method-Range-initialize)

- [`Range$print()`](#method-Range-print)

- [`Range$clone()`](#method-Range-clone)

------------------------------------------------------------------------

### `Range$new()`

Create a new Range object

#### Usage

    Range$new(min, max, unit)

#### Arguments

- `min`:

  Numeric or NULL. Minimum value, can be NULL for ranges with only an
  upper bound

- `max`:

  Numeric or NULL. Maximum value, can be NULL for ranges with only a
  lower bound

- `unit`:

  Character. Unit for the range

#### Returns

A new Range object

------------------------------------------------------------------------

### `Range$print()`

Print a summary of the range

#### Usage

    Range$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Range object for method chaining

------------------------------------------------------------------------

### `Range$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Range$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
