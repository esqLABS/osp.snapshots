# Intestinal permeability value object

Build an intestinal-permeability value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)'s
`intestinal_permeability` argument (or the writable
`Compound$intestinal_permeability` field). Produces one default
`IntestinalPermeability` alternative with parameter
`"Specific intestinal permeability (transcellular)"`.

## Usage

``` r
intestinal_permeability(value, unit = "cm/min", name = "User defined")
```

## Arguments

- value:

  Numeric scalar. Intestinal-permeability value.

- unit:

  Character. Unit for the parameter, validated against dimension
  `"Velocity"`. Defaults to `"cm/min"`.

- name:

  Character. `Name` of the created alternative. Defaults to
  `"User defined"`.

## Value

An `intestinal_permeability_spec` object to pass to
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md).

## See also

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)

## Examples

``` r
intestinal_permeability(1.14e-05)
#> $value
#> [1] 1.14e-05
#> 
#> $unit
#> [1] "cm/min"
#> 
#> $name
#> [1] "User defined"
#> 
#> attr(,"class")
#> [1] "intestinal_permeability_spec" "osp_value_spec"              
create_compound(
  name = "Drug X",
  intestinal_permeability = intestinal_permeability(1.14e-05)
)
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Intestinal Permeability:
#>   • 1.14e-05 cm/min [Unknown]
```
