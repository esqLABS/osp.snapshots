# Height value object

Build a height value object for
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)'s
`height` argument (or the writable `Individual$height` /
`OriginData$height` field). Fills the `OriginData` `Height`
characteristic (`list(Value =, Unit =)`).

## Usage

``` r
height(value, unit = "cm")
```

## Arguments

- value:

  Numeric scalar. Height value.

- unit:

  Character. Unit for height, validated against dimension `"Length"`.
  Defaults to `"cm"`.

## Value

A `height_spec` object to pass to
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md).

## See also

[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)

## Examples

``` r
height(175)
#> $value
#> [1] 175
#> 
#> $unit
#> [1] "cm"
#> 
#> attr(,"class")
#> [1] "height_spec"    "osp_value_spec"
create_individual(name = "Subject", height = height(175))
#> 
#> ── Individual: Subject ─────────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Height: 175 cm
```
