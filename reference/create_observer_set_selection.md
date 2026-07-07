# Create an observer-set selection for a simulation

Build an
[ObserverSetSelection](https://esqlabs.github.io/osp.snapshots/reference/ObserverSetSelection.md)
entry that references an
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md)
building block by name inside a
[Simulation](https://esqlabs.github.io/osp.snapshots/reference/Simulation.md).

## Usage

``` r
create_observer_set_selection(name)
```

## Arguments

- name:

  Character. Name of the observer-set building block (required).

## Value

An
[ObserverSetSelection](https://esqlabs.github.io/osp.snapshots/reference/ObserverSetSelection.md)
object.

## Examples

``` r
create_observer_set_selection(name = "BrainPlasmaConcentration")
#> <ObserverSetSelection>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     name: active binding
#>   Private:
#>     .data: list
```
