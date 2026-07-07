# Create a protocol selection for a simulation compound

Build a
[ProtocolSelection](https://esqlabs.github.io/osp.snapshots/reference/ProtocolSelection.md)
entry, used inside a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/reference/CompoundProperties.md)
to assign a
[Protocol](https://esqlabs.github.io/osp.snapshots/reference/Protocol.md)
building block to the compound and (optionally) map each application
slot to a
[Formulation](https://esqlabs.github.io/osp.snapshots/reference/Formulation.md)
via
[FormulationSelection](https://esqlabs.github.io/osp.snapshots/reference/FormulationSelection.md).

## Usage

``` r
create_protocol_selection(name, formulations = NULL)
```

## Arguments

- name:

  Character. Name of the protocol building block (required).

- formulations:

  List of
  [FormulationSelection](https://esqlabs.github.io/osp.snapshots/reference/FormulationSelection.md)
  objects (created with
  [`create_formulation_selection()`](https://esqlabs.github.io/osp.snapshots/reference/create_formulation_selection.md))
  or raw lists.

## Value

A
[ProtocolSelection](https://esqlabs.github.io/osp.snapshots/reference/ProtocolSelection.md)
object.

## Examples

``` r
create_protocol_selection(
  name = "Yu 2004 - Rifampicin - 600 mg MD OD 10 days",
  formulations = list(
    create_formulation_selection(name = "Oral solution", key = "Formulation")
  )
)
#> <ProtocolSelection>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     formulations: active binding
#>     initialize: function (data) 
#>     name: active binding
#>   Private:
#>     .data: list
#>     .formulations: list
#>     deep_clone: function (name, value) 
```
