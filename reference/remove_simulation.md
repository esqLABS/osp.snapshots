# Remove simulations from a snapshot

Remove one or more simulations from a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
by name.

## Usage

``` r
remove_simulation(snapshot, simulation_name)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
  object.

- simulation_name:

  Character vector of simulation names to remove.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_simulation("simulation1")
} # }
```
