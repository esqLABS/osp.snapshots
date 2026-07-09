# Permeability value object

Build a permeability value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)'s
`permeability` argument (or the writable `Compound$permeability` field).
Produces one default `Permeability` alternative with parameter
`"Permeability"`.

## Usage

``` r
permeability(value, unit = "cm/min", name = "User defined", default = FALSE)
```

## Arguments

- value:

  Numeric scalar. Permeability value.

- unit:

  Character. Unit for the parameter, validated against dimension
  `"Velocity"`. Defaults to `"cm/min"`.

- name:

  Character. `Name` of the created alternative. Defaults to
  `"User defined"`.

- default:

  Logical. Whether this alternative is the group's default when it
  appears in a list of alternatives passed to the matching
  [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
  argument or `Compound` field. Defaults to `FALSE`. Ignored for a
  single (non-list) value object, which is always the default. When a
  list has no element marked `default = TRUE`, the first element is the
  default (unchanged behaviour); marking two or more elements
  `default = TRUE` in the same list is an error.

## Value

A `permeability_spec` object to pass to
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
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/dev/reference/lipophilicity.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/dev/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)

## Examples

``` r
permeability(0.0069)
#> $value
#> [1] 0.0069
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
#> [1] "permeability_spec" "osp_value_spec"   
create_compound(name = "Drug X", permeability = permeability(0.0069))
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Permeability:
#>   • 0.0069 cm/min [Unknown]

# Several alternatives, the second marked as the default
create_compound(
  name = "Drug X",
  permeability = list(
    permeability(0.0069, name = "Measured"),
    permeability(0.008, name = "Predicted", default = TRUE)
  )
)
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Permeability:
#>   • Measured: 0.0069 cm/min [Unknown]
#>   • Predicted (Default): 0.008 cm/min [Unknown]
```
