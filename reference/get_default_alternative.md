# Get the default alternative of a compound property

Returns the name of the default alternative in a compound
physicochemical-property group, for example the `Solubility`,
`Lipophilicity`, or `FractionUnbound` field of a
[Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md).
The default is the alternative whose `IsDefault` flag is `TRUE` (an
absent flag is treated as `TRUE`, per the snapshot schema); when no
alternative sets it, the `"User defined"` alternative is used, and a
group with no resolvable default returns `NULL`.

## Usage

``` r
get_default_alternative(alternatives)
```

## Arguments

- alternatives:

  A compound physicochemical-property group, such as
  `compound$solubility`, `compound$lipophilicity`, or any list of named
  alternatives each carrying an optional `IsDefault` flag.

## Value

The default alternative's name as a character string, or `NULL` when the
group has no resolvable default.

## Examples

``` r
compound <- create_compound(
  name = "Drug X",
  solubility = list(
    solubility(9999, name = "Aqueous"),
    solubility(200, name = "FaSSIF", default = TRUE)
  )
)
get_default_alternative(compound$solubility)
#> [1] "FaSSIF"
```
