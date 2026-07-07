# Create compound properties for a simulation

Build a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/reference/CompoundProperties.md)
entry, used inside a
[Simulation](https://esqlabs.github.io/osp.snapshots/reference/Simulation.md)
to configure a
[Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md)
building block: which calculation methods to apply, which alternatives,
processes, and protocol to use.

## Usage

``` r
create_compound_properties(
  name,
  calculation_methods = NULL,
  alternatives = NULL,
  processes = NULL,
  protocol = NULL
)
```

## Arguments

- name:

  Character. Name of the compound building block (required).

- calculation_methods:

  Character vector. Calculation method names that override the
  compound's defaults for this simulation.

- alternatives:

  List of
  [CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/reference/CompoundGroupSelection.md)
  objects or raw lists.

- processes:

  List of
  [CompoundProcessSelection](https://esqlabs.github.io/osp.snapshots/reference/CompoundProcessSelection.md)
  objects or raw lists.

- protocol:

  A
  [ProtocolSelection](https://esqlabs.github.io/osp.snapshots/reference/ProtocolSelection.md)
  object or raw list.

## Value

A
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/reference/CompoundProperties.md)
object.

## Examples

``` r
create_compound_properties(
  name = "Rifampicin",
  calculation_methods = c(
    "Cellular partition coefficient method - Rodgers and Rowland"
  ),
  processes = list(
    create_compound_process_selection(systemic_process_type = "Hepatic")
  ),
  protocol = create_protocol_selection(
    name = "Rifampicin Protocol",
    formulations = list(
      create_formulation_selection(name = "Oral solution", key = "Formulation")
    )
  )
)
#> <CompoundProperties>
#>   Public:
#>     alternatives: active binding
#>     calculation_methods: active binding
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     name: active binding
#>     processes: active binding
#>     protocol: active binding
#>   Private:
#>     .alternatives: list
#>     .data: list
#>     .processes: list
#>     .protocol: ProtocolSelection, R6
#>     deep_clone: function (name, value) 
```
