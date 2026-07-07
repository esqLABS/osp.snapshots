# Create an output interval for a simulation output schema

Build an
[OutputInterval](https://esqlabs.github.io/osp.snapshots/reference/OutputInterval.md)
entry, used inside an
[OutputSchema](https://esqlabs.github.io/osp.snapshots/reference/OutputSchema.md)
to record one time window of output reporting (start time, end time,
resolution). All three time parameters are required; PK-Sim's default
units (`"h"` for times and `"pts/h"` for resolution) are used.

## Usage

``` r
create_output_interval(name = NULL, start_time, end_time, resolution)
```

## Arguments

- name:

  Character. Optional interval name.

- start_time:

  Numeric. Interval start time, in hours (required).

- end_time:

  Numeric. Interval end time, in hours (required).

- resolution:

  Numeric. Reporting resolution, in points per hour (required).

## Value

An
[OutputInterval](https://esqlabs.github.io/osp.snapshots/reference/OutputInterval.md)
object.

## Examples

``` r
create_output_interval(start_time = 0, end_time = 24, resolution = 20)
#> <OutputInterval>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     name: active binding
#>     parameters: active binding
#>   Private:
#>     .data: list
#>     .parameters: parameter_collection, list
#>     deep_clone: function (name, value) 
```
