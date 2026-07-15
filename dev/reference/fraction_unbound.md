# Fraction unbound value object

Build a fraction-unbound value object for
[`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md)'s
`fraction_unbound` argument (or the writable `Compound$fraction_unbound`
field). Produces one default `FractionUnbound` alternative with
parameter `"Fraction unbound (plasma, reference value)"`. Fraction
unbound stores a bare value with no unit, so this helper takes no `unit`
argument.

Fraction unbound is the one species-dependent single-parameter group, so
the emitted alternative carries a `Species` field (see `species`), which
PK-Sim requires to load the snapshot.

## Usage

``` r
fraction_unbound(
  value,
  name = "User defined",
  default = FALSE,
  species = "Human"
)
```

## Arguments

- value:

  Numeric scalar. Fraction-unbound value.

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

- species:

  Character. PK-Sim species emitted as the alternative's `Species`
  field. Defaults to `"Human"` and is validated against
  [`ospsuite::Species`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/Species.html).
  Fraction unbound is species-dependent, and PK-Sim rejects a snapshot
  whose fraction-unbound alternative has no resolvable species, so this
  is emitted on every fraction-unbound alternative. A user hand-building
  a raw alternative list (the `Compound$fraction_unbound` escape hatch)
  is responsible for its own `Species`.

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
#> $default
#> [1] FALSE
#> 
#> $species
#> [1] "Human"
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

# Several alternatives, the second marked as the default
create_compound(
  name = "Drug X",
  fraction_unbound = list(
    fraction_unbound(0.1, name = "Plasma"),
    fraction_unbound(0.2, name = "Microsomal", default = TRUE)
  )
)
#> 
#> ── Compound: Drug X ────────────────────────────────────────────────────────────
#> 
#> ── Basic Properties ──
#> 
#> ── Physicochemical Properties ──
#> 
#> • Fraction Unbound:
#>   • Plasma: 0.1 [Unknown]
#>   • Microsomal (Default): 0.2 [Unknown]
```
