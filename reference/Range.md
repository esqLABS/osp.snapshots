# Create a range object for physiological parameters

Create a new Range object with the specified min, max, and unit values.
Either min or max can be NULL to represent ranges with only an upper or
lower bound. Min and max can also be equal to represent a single value.

## Usage

``` r
range(min, max, unit)
```

## Arguments

- min:

  Numeric or NULL. Minimum value, can be NULL for ranges with only an
  upper bound

- max:

  Numeric or NULL. Maximum value, can be NULL for ranges with only a
  lower bound

- unit:

  Character. Unit for the range

## Value

A Range object

## Examples

``` r
if (FALSE) { # \dontrun{
# Create a weight range with both bounds
weight_range <- range(60, 90, "kg")

# Create a weight range with only a lower bound
weight_min_range <- range(60, NULL, "kg")

# Create a weight range with only an upper bound
weight_max_range <- range(NULL, 90, "kg")

# Create a weight range with equal min and max (representing a single value)
weight_fixed_range <- range(70, 70, "kg")

# Assign to a population
population$weight_range <- weight_range
} # }
```
