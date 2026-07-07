# Create an output-to-observed-data mapping for a simulation

Build an
[OutputMapping](https://esqlabs.github.io/osp.snapshots/reference/OutputMapping.md)
entry, used inside a
[Simulation](https://esqlabs.github.io/osp.snapshots/reference/Simulation.md)
to link a simulation output quantity to an observed-data set for
downstream comparison and parameter identification.

All arguments are optional and serialized only when supplied.

## Usage

``` r
create_output_mapping(
  path = NULL,
  observed_data = NULL,
  scaling = NULL,
  weight = NULL,
  weights = NULL
)
```

## Arguments

- path:

  Character. Simulation output quantity path.

- observed_data:

  Character. Observed-data repository name.

- scaling:

  Character. Scaling used for the mapping (e.g. `"Linear"`, `"Log"`).

- weight:

  Numeric. Single weight applied to all points.

- weights:

  Numeric vector. Per-point weights.

## Value

An
[OutputMapping](https://esqlabs.github.io/osp.snapshots/reference/OutputMapping.md)
object.

## Examples

``` r
create_output_mapping(
  path = "Organism|PeripheralVenousBlood|Drug|Plasma",
  observed_data = "Study A",
  scaling = "Log",
  weight = 1
)
#> <OutputMapping>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     observed_data: active binding
#>     path: active binding
#>     scaling: active binding
#>     weight: active binding
#>     weights: active binding
#>   Private:
#>     .data: list
```
