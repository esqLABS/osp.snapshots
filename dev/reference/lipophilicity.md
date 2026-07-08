# Lipophilicity value object

Build a lipophilicity value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)'s
`lipophilicity` argument (or the writable `Compound$lipophilicity`
field). Produces one default `Lipophilicity` alternative with parameter
`"Lipophilicity"`.

## Usage

``` r
lipophilicity(value, unit = "Log Units", name = "User defined")
```

## Arguments

- value:

  Numeric scalar. Lipophilicity value.

- unit:

  Character. Unit for the lipophilicity parameter, validated against
  dimension `"Log Units"`. Defaults to `"Log Units"`.

- name:

  Character. `Name` of the created alternative. Defaults to
  `"User defined"`.

## Value

A `lipophilicity_spec` object to pass to
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md).

## See also

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/intestinal_permeability.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)

## Examples

``` r
lipophilicity(2.5)
#> $value
#> [1] 2.5
#> 
#> $unit
#> [1] "Log Units"
#> 
#> $name
#> [1] "User defined"
#> 
#> attr(,"class")
#> [1] "lipophilicity_spec" "osp_value_spec"    
create_compound(name = "Drug X", lipophilicity = lipophilicity(2.5))
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Lipophilicity:
#>   • 2.5 Log Units [Unknown]
```
