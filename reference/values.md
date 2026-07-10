# Measurement values series value object

Build a measurement-values value object for
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md)'s
`values` argument. Carries the measurement y-values, their dimension,
and an optional unit.

The `dimension` is required and has no default; it gates unit validation
and is written to the data-set column. When `unit` is supplied it is
validated against `dimension` via
[`validate_unit()`](https://esqlabs.github.io/osp.snapshots/reference/validate_unit.md).

## Usage

``` r
values(value, unit = NULL, dimension)
```

## Arguments

- value:

  Numeric vector. Measurement y-values.

- unit:

  Character. Optional unit for `value`. When supplied, validated against
  `dimension`.

- dimension:

  Character. Dimension for `value` (for example
  `"Concentration (mass)"`). Required: pass one of the names of
  [`ospsuite::ospDimensions`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/ospDimensions.html).

## Value

A `values_spec` object to pass to
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md).

## See also

[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/reference/height.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/reference/intestinal_permeability.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/reference/weight.md)

## Examples

``` r
values(c(0, 12, 18, 11, 5), unit = "mg/l", dimension = "Concentration (mass)")
#> $value
#> [1]  0 12 18 11  5
#> 
#> $unit
#> [1] "mg/l"
#> 
#> $dimension
#> [1] "Concentration (mass)"
#> 
#> attr(,"class")
#> [1] "values_spec"    "osp_value_spec"
```
