# Error series value object

Build an error-series value object for
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)'s
`error` argument. Carries the error y-values, an optional unit, and an
auxiliary type.

The unit is not validated here: the error dimension is the values-series
dimension, which this helper does not see.
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)
validates the error unit against the values dimension when a unit is
present, and defaults the error unit to the values unit when `unit` is
`NULL`.

## Usage

``` r
error(value, unit = NULL, type = "ArithmeticStdDev")
```

## Arguments

- value:

  Numeric vector. Error y-values, same length as the values series.

- unit:

  Character. Optional unit for the error. Defaults (in the factory) to
  the values-series unit when `NULL`.

- type:

  Character. Auxiliary type for the error, typically one of
  `"ArithmeticStdDev"`, `"GeometricStdDev"`, or `"ArithmeticStdErr"`.
  Defaults to `"ArithmeticStdDev"`.

## Value

An `error_spec` object to pass to
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md).

## See also

[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observed_data.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)

## Examples

``` r
error(c(0, 1.2, 1.5, 1.1, 0.6))
#> $value
#> [1] 0.0 1.2 1.5 1.1 0.6
#> 
#> $unit
#> NULL
#> 
#> $type
#> [1] "ArithmeticStdDev"
#> 
#> attr(,"class")
#> [1] "error_spec"     "osp_value_spec"
```
