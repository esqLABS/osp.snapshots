# Intestinal permeability value object

Build an intestinal-permeability value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)'s
`intestinal_permeability` argument (or the writable
`Compound$intestinal_permeability` field). Produces one default
`IntestinalPermeability` alternative with parameter
`"Specific intestinal permeability (transcellular)"`.

## Usage

``` r
intestinal_permeability(
  value,
  unit = "cm/min",
  name = "User defined",
  default = FALSE
)
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

- default:

  Logical. Whether this alternative is the group's default when it
  appears in a list of alternatives passed to the matching
  [`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)
  argument or `Compound` field. Defaults to `FALSE`. Ignored for a
  single (non-list) value object, which is always the default. When a
  list has no element marked `default = TRUE`, the first element is the
  default (unchanged behaviour); marking two or more elements
  `default = TRUE` in the same list is an error.

## Value

An `intestinal_permeability_spec` object to pass to
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md).

## See also

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/reference/height.md),
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/reference/weight.md)

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
#> $default
#> [1] FALSE
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

# Several alternatives, the second marked as the default
create_compound(
  name = "Drug X",
  intestinal_permeability = list(
    intestinal_permeability(1.14e-05, name = "Caco-2"),
    intestinal_permeability(2e-05, name = "PAMPA", default = TRUE)
  )
)
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Intestinal Permeability:
#>   • Caco-2: 1.14e-05 cm/min [Unknown]
#>   • PAMPA (Default): 2e-05 cm/min [Unknown]
```
