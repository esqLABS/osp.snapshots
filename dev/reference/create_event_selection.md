# Create an event selection for a simulation

Build an
[EventSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/EventSelection.md)
entry that references an
[Event](https://esqlabs.github.io/osp.snapshots/dev/reference/Event.md)
building block by name and supplies a numeric start time (in hours) for
the event inside the simulation.

## Usage

``` r
create_event_selection(name, start_time)
```

## Arguments

- name:

  Character. Name of the event building block (required).

- start_time:

  Numeric. Start time, in hours, when the event fires in the simulation
  (required).

## Value

An
[EventSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/EventSelection.md)
object.

## Examples

``` r
create_event_selection(name = "GB emptying", start_time = 12)
#> <EventSelection>
#>   Public:
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     initialize: function (data) 
#>     name: active binding
#>     start_time: active binding
#>   Private:
#>     .data: list
#>     .start_time: Parameter, R6
#>     deep_clone: function (name, value) 
```
