# Create a molecule list for an observer

Build a `MoleculeList` for an
[Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md),
selecting which molecules the observer applies to. This is a small
builder that returns the raw named list for
[`create_observer()`](https://esqlabs.github.io/osp.snapshots/reference/create_observer.md)
or `observer$molecule_list`.

## Usage

``` r
create_molecule_list(for_all = NULL, include = NULL, exclude = NULL)
```

## Arguments

- for_all:

  Logical (length 1). When `TRUE`, the observer applies to all
  molecules. Omitted when `NULL`.

- include:

  Character vector of molecule names to include. Always serialises as a
  JSON array, even for a single name. Omitted when `NULL`.

- exclude:

  Character vector of molecule names to exclude. Always serialises as a
  JSON array, even for a single name. Omitted when `NULL`.

## Value

A named list with `ForAll`, `MoleculeNamesToInclude`, and
`MoleculeNamesToExclude` for the arguments supplied (an empty named list
when all are `NULL`).

## Examples

``` r
create_molecule_list(for_all = FALSE, include = "Drug")
#> $ForAll
#> [1] FALSE
#> 
#> $MoleculeNamesToInclude
#> $MoleculeNamesToInclude[[1]]
#> [1] "Drug"
#> 
#> 

# Multiple names and an exclusion
create_molecule_list(include = c("Drug", "Metabolite"), exclude = "Water")
#> $MoleculeNamesToInclude
#> $MoleculeNamesToInclude[[1]]
#> [1] "Drug"
#> 
#> $MoleculeNamesToInclude[[2]]
#> [1] "Metabolite"
#> 
#> 
#> $MoleculeNamesToExclude
#> $MoleculeNamesToExclude[[1]]
#> [1] "Water"
#> 
#> 
```
