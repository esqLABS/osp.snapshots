# Create an output schema for a simulation

Build an
[OutputSchema](https://esqlabs.github.io/osp.snapshots/reference/OutputSchema.md)
from a list of
[OutputInterval](https://esqlabs.github.io/osp.snapshots/reference/OutputInterval.md)
objects.

## Usage

``` r
create_output_schema(intervals = list())
```

## Arguments

- intervals:

  List of
  [OutputInterval](https://esqlabs.github.io/osp.snapshots/reference/OutputInterval.md)
  objects (created with
  [`create_output_interval()`](https://esqlabs.github.io/osp.snapshots/reference/create_output_interval.md))
  or raw lists. Defaults to an empty list.

## Value

An
[OutputSchema](https://esqlabs.github.io/osp.snapshots/reference/OutputSchema.md)
object.

## Examples

``` r
create_output_schema(
  intervals = list(
    create_output_interval(start_time = 0, end_time = 2, resolution = 20),
    create_output_interval(start_time = 2, end_time = 24, resolution = 20)
  )
)
#> <OutputSchema>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     intervals: active binding
#>   Private:
#>     .intervals: list
#>     deep_clone: function (name, value) 
```
