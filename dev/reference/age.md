# Age value object

Build an age value object for
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)'s
`age` argument (or the writable `Individual$age` / `OriginData$age`
field). Fills the `OriginData` `Age` characteristic
(`list(Value =, Unit =)`).

## Usage

``` r
age(value, unit = "year(s)")
```

## Arguments

- value:

  Numeric scalar. Age value.

- unit:

  Character. Unit for age, validated against dimension `"Age in years"`.
  Defaults to `"year(s)"`.

## Value

An `age_spec` object to pass to
[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md).

## See also

[`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md)

Other value-object helpers:
[`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md),
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
age(30)
#> $value
#> [1] 30
#> 
#> $unit
#> [1] "year(s)"
#> 
#> attr(,"class")
#> [1] "age_spec"       "osp_value_spec"
create_individual(name = "Subject", age = age(30))
#> 
#> ── Individual: Subject ─────────────────────────────────────────────────────────
#> 
#> ── Characteristics ──
#> 
#> • Age: 30 year(s)
```
