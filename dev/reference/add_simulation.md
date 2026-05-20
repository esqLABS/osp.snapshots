# Add one or more simulations to a snapshot

Add one or more
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md).
References to missing building blocks (individual, population,
compounds, events, observer sets, observed data, protocols,
formulations) trigger one informational warning per simulation; the add
proceeds either way.

## Usage

``` r
add_simulation(snapshot, simulation)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- simulation:

  A
  [Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
  object created with
  [`create_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_simulation.md),
  or a list of such objects.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
sim <- create_simulation(name = "Sim 1", individual = "Adult")
snapshot <- load_snapshot("Midazolam") |>
  add_simulation(sim)
} # }
```
