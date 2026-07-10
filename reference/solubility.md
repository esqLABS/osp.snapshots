# Solubility value object

Build a solubility value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)'s
`solubility` argument (or the writable `Compound$solubility` field).
Expresses either the scalar form (a single solubility value at a
reference pH, optionally with a solubility gain per charge) or the
mutually exclusive table form (a pH/value table).

The scalar-form arguments (`value`, `reference_pH`, `gain_per_charge`)
and `table` are mutually exclusive: supplying `table` together with any
of them is an error. Unlike the previous
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md)
behaviour, where `reference_pH` / `gain_per_charge` were silently
ignored on the table path, this helper rejects the combination so the
intent is unambiguous.

## Usage

``` r
solubility(
  value = NULL,
  unit = "mg/l",
  reference_pH = NULL,
  gain_per_charge = NULL,
  table = NULL,
  name = "User defined",
  default = FALSE
)
```

## Arguments

- value:

  Numeric scalar. Solubility-at-reference-pH value for the scalar form.
  Leave `NULL` for the table form.

- unit:

  Character. Unit for the solubility value (scalar form) and for the
  table Y values, validated against dimension `"Concentration (mass)"`.
  Defaults to `"mg/l"`.

- reference_pH:

  Numeric scalar. Reference pH added to the scalar `Solubility`
  alternative. Scalar form only.

- gain_per_charge:

  Numeric scalar. Optional `Solubility gain per charge` parameter added
  to the scalar `Solubility` alternative. Scalar form only.

- table:

  Two-column data frame giving table-based solubility: the first column
  is pH and the second is the solubility value. When supplied, the table
  form is built and the scalar-form arguments must be left unset.

- name:

  Character. `Name` of the created alternative (scalar or table).
  Defaults to `"User defined"`.

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

A `solubility_spec` object to pass to
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
[`lipophilicity()`](https://esqlabs.github.io/osp.snapshots/reference/lipophilicity.md),
[`permeability()`](https://esqlabs.github.io/osp.snapshots/reference/permeability.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/reference/weight.md)

## Examples

``` r
# Scalar form with reference pH and gain per charge
solubility(9999, reference_pH = 7, gain_per_charge = 1000)
#> $value
#> [1] 9999
#> 
#> $unit
#> [1] "mg/l"
#> 
#> $reference_pH
#> [1] 7
#> 
#> $gain_per_charge
#> [1] 1000
#> 
#> $table
#> NULL
#> 
#> $name
#> [1] "User defined"
#> 
#> $form
#> [1] "scalar"
#> 
#> $default
#> [1] FALSE
#> 
#> attr(,"class")
#> [1] "solubility_spec" "osp_value_spec" 

# Table form (first column pH, second column value)
solubility(table = data.frame(pH = c(3, 6, 6.8), value = c(5000, 3000, 90)))
#> $value
#> NULL
#> 
#> $unit
#> [1] "mg/l"
#> 
#> $reference_pH
#> NULL
#> 
#> $gain_per_charge
#> NULL
#> 
#> $table
#>    pH value
#> 1 3.0  5000
#> 2 6.0  3000
#> 3 6.8    90
#> 
#> $name
#> [1] "User defined"
#> 
#> $form
#> [1] "table"
#> 
#> $default
#> [1] FALSE
#> 
#> attr(,"class")
#> [1] "solubility_spec" "osp_value_spec" 

# Several alternatives, the second marked as the default
create_compound(
  name = "Drug X",
  solubility = list(
    solubility(9999, name = "Aqueous"),
    solubility(200, name = "FaSSIF", default = TRUE)
  )
)
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Solubility:
#>   • Aqueous: 9999 mg/l [Unknown]
#>   • FaSSIF (Default): 200 mg/l [Unknown]
```
