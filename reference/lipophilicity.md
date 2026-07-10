# Lipophilicity value object

Build a lipophilicity value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)'s
`lipophilicity` argument (or the writable `Compound$lipophilicity`
field). Produces one default `Lipophilicity` alternative with parameter
`"Lipophilicity"`.

## Usage

``` r
lipophilicity(
  value,
  unit = "Log Units",
  name = "User defined",
  default = FALSE
)
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

A `lipophilicity_spec` object to pass to
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md).

## See also

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/reference/error.md),
[`fraction_unbound()`](https://esqlabs.github.io/osp.snapshots/reference/fraction_unbound.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/reference/gestational_age.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/reference/height.md),
[`intestinal_permeability()`](https://esqlabs.github.io/osp.snapshots/reference/intestinal_permeability.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/reference/permeability.md),
[`solubility()`](https://esqlabs.github.io/osp.snapshots/reference/solubility.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/reference/weight.md)

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
#> $default
#> [1] FALSE
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

# Several alternatives, the second marked as the default
create_compound(
  name = "Drug X",
  lipophilicity = list(
    lipophilicity(2.5, name = "Measured"),
    lipophilicity(3.1, name = "Predicted", default = TRUE)
  )
)
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Lipophilicity:
#>   • Measured: 2.5 Log Units [Unknown]
#>   • Predicted (Default): 3.1 Log Units [Unknown]
```
