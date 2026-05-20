# Create a formulation selection for a simulation compound

Build a
[FormulationSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/FormulationSelection.md)
entry, used inside a
[ProtocolSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ProtocolSelection.md)
to bind a formulation building block to one of the protocol's
application slots.

## Usage

``` r
create_formulation_selection(name, key)
```

## Arguments

- name:

  Character. Name of the formulation building block (required).

- key:

  Character. Formulation key identifying which application in the
  protocol uses this formulation (required).

## Value

A
[FormulationSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/FormulationSelection.md)
object.

## Examples

``` r
create_formulation_selection(name = "Oral solution", key = "Formulation")
#> <FormulationSelection>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     key: active binding
#>     name: active binding
#>   Private:
#>     .data: list
```
