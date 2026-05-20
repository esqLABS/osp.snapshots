# Create a compound process selection

Build a
[CompoundProcessSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProcessSelection.md)
entry, used inside a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
to record which compound processes are selected for the simulation.

All arguments are optional and serialized only when supplied. PK-Sim
resolves the right process placeholder from whichever combination of
fields is set.

## Usage

``` r
create_compound_process_selection(
  name = NULL,
  molecule_name = NULL,
  metabolite_name = NULL,
  compound_name = NULL,
  systemic_process_type = NULL
)
```

## Arguments

- name:

  Character. Process name.

- molecule_name:

  Character. Molecule involved in the process.

- metabolite_name:

  Character. Metabolite produced by the process.

- compound_name:

  Character. Other compound involved in the process.

- systemic_process_type:

  Character. Systemic process type (e.g. `"Hepatic"`, `"Renal"`,
  `"Biliary"`).

## Value

A
[CompoundProcessSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProcessSelection.md)
object.

## Examples

``` r
create_compound_process_selection(
  name = "P-gp-Collett 2004",
  molecule_name = "P-gp"
)
#> <CompoundProcessSelection>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     compound_name: active binding
#>     data: active binding
#>     initialize: function (data) 
#>     metabolite_name: active binding
#>     molecule_name: active binding
#>     name: active binding
#>     systemic_process_type: active binding
#>   Private:
#>     .data: list

create_compound_process_selection(systemic_process_type = "Hepatic")
#> <CompoundProcessSelection>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     compound_name: active binding
#>     data: active binding
#>     initialize: function (data) 
#>     metabolite_name: active binding
#>     molecule_name: active binding
#>     name: active binding
#>     systemic_process_type: active binding
#>   Private:
#>     .data: list
```
