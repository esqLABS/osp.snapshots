# Time series value object

Build a time-series value object for
[`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md)'s
`time` argument. Carries the time grid x-values and their unit.

## Usage

``` r
time(value, unit = "h")
```

## Arguments

- value:

  Numeric vector. Time grid x-values.

- unit:

  Character. Unit for `value`, validated against dimension `"Time"`.
  Defaults to `"h"`.

## Value

A `time_spec` object to pass to
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
[`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/reference/weight.md)

## Examples

``` r
time(c(0, 1, 2, 4, 8))
#> $value
#> [1] 0 1 2 4 8
#> 
#> $unit
#> [1] "h"
#> 
#> attr(,"class")
#> [1] "time_spec"      "osp_value_spec"
```
