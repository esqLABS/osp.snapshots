# Solubility value object

Build a solubility value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)'s
`solubility` argument (or the writable `Compound$solubility` field).
Expresses either the scalar form (a single solubility value at a
reference pH, optionally with a solubility gain per charge) or the
mutually exclusive table form (a pH/value table).

The scalar-form arguments (`value`, `reference_pH`, `gain_per_charge`)
and `table` are mutually exclusive: supplying `table` together with any
of them is an error. Unlike the previous
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)
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
  name = "User defined"
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

## Value

A `solubility_spec` object to pass to
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
[`permeability()`](https://esqlabs.github.io/osp.snapshots/dev/reference/permeability.md),
[`time()`](https://esqlabs.github.io/osp.snapshots/dev/reference/time.md),
[`values()`](https://esqlabs.github.io/osp.snapshots/dev/reference/values.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)

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
#> attr(,"class")
#> [1] "solubility_spec" "osp_value_spec" 
```
