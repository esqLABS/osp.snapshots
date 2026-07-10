# Gestational age value object

Build a gestational-age value object for
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md)'s
`gestational_age` argument (or the writable `Individual$gestational_age`
/ `OriginData$gestational_age` field). Fills the `OriginData`
`GestationalAge` characteristic (`list(Value =, Unit =)`).

## Usage

``` r
gestational_age(value, unit = "week(s)")
```

## Arguments

- value:

  Numeric scalar. Gestational-age value.

- unit:

  Character. Unit for gestational age, validated against dimension
  `"Time"`. Defaults to `"week(s)"`.

## Value

A `gestational_age_spec` object to pass to
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md).

## See also

[`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/reference/fraction_unbound.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/reference/height.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/reference/intestinal_permeability.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/reference/weight.md)

## Examples

``` r
gestational_age(38)
#> $value
#> [1] 38
#> 
#> $unit
#> [1] "week(s)"
#> 
#> attr(,"class")
#> [1] "gestational_age_spec" "osp_value_spec"      
create_individual(name = "Preterm", gestational_age = gestational_age(30))
#> 
#> ── Individual: Preterm ─────────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Gestational Age: 30 week(s)
```
