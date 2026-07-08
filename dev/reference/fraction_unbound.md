# Fraction unbound value object

Build a fraction-unbound value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)'s
`fraction_unbound` argument (or the writable `Compound$fraction_unbound`
field). Produces one default `FractionUnbound` alternative with
parameter `"Fraction unbound (plasma, reference value)"`. Fraction
unbound stores a bare value with no unit, so this helper takes no `unit`
argument.

## Usage

``` r
fraction_unbound(value, name = "User defined")
```

## Arguments

- value:

  Numeric scalar. Fraction-unbound value.

- name:

  Character. `Name` of the created alternative. Defaults to
  `"User defined"`.

## Value

A `fraction_unbound_spec` object to pass to
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md).

## See also

[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)

Other value-object helpers:
[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`error()`](https://esqlabs.github.io/osp.snapshots/dev/reference/error.md),
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
fraction_unbound(0.1)
#> $value
#> [1] 0.1
#> 
#> $name
#> [1] "User defined"
#> 
#> attr(,"class")
#> [1] "fraction_unbound_spec" "osp_value_spec"       
create_compound(name = "Drug X", fraction_unbound = fraction_unbound(0.1))
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Fraction Unbound:
#>   • 0.1 [Unknown]
```
