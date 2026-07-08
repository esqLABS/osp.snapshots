# Weight value object

Build a weight value object for
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)'s
`weight` argument (or the writable `Individual$weight` /
`OriginData$weight` field). Fills the `OriginData` `Weight`
characteristic (`list(Value =, Unit =)`).

## Usage

``` r
weight(value, unit = "kg")
```

## Arguments

- value:

  Numeric scalar. Weight value.

- unit:

  Character. Unit for weight, validated against dimension `"Mass"`.
  Defaults to `"kg"`.

## Value

A `weight_spec` object to pass to
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md).

## See also

[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md)

## Examples

``` r
weight(70)
#> $value
#> [1] 70
#> 
#> $unit
#> [1] "kg"
#> 
#> attr(,"class")
#> [1] "weight_spec"    "osp_value_spec"
create_individual(name = "Subject", weight = weight(70))
#> 
#> ── Individual: Subject ─────────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Weight: 70 kg
```
