# Create a formula reference for an observer

Build a single `FormulaUsablePath` entry for the `References` of an
observer's `ExplicitFormula`. A formula reference binds an alias used in
the formula expression to a model path. This is a small builder that
returns the raw named list; assemble several of them into a list for
[`create_observer()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_observer.md)
or `observer$formula_references`.

## Usage

``` r
create_formula_reference(alias, path, dimension = NULL)
```

## Arguments

- alias:

  Character. The alias used in the formula expression (required).

- path:

  Character. The model path the alias resolves to (required).

- dimension:

  Character. The dimension of the referenced quantity. Omitted when
  `NULL`.

## Value

A named list with `Alias`, `Path`, and, when supplied, `Dimension`.

## Examples

``` r
create_formula_reference(
  "Conc_Br",
  "Organism|Brain|Plasma|Drug|Concentration"
)
#> $Alias
#> [1] "Conc_Br"
#> 
#> $Path
#> [1] "Organism|Brain|Plasma|Drug|Concentration"
#> 

# With an explicit dimension
create_formula_reference(
  "Conc_Br",
  "Organism|Brain|Plasma|Drug|Concentration",
  "Concentration (molar)"
)
#> $Alias
#> [1] "Conc_Br"
#> 
#> $Path
#> [1] "Organism|Brain|Plasma|Drug|Concentration"
#> 
#> $Dimension
#> [1] "Concentration (molar)"
#> 
```
