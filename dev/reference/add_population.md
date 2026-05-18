# Add a population to a snapshot

Add a
[Population](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
object to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md).

## Usage

``` r
add_population(snapshot, population)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- population:

  A
  [Population](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
  object created with
  [`create_population()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_population.md).

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
pop <- create_population(name = "Adults", number_of_individuals = 100)
snapshot <- load_snapshot("Midazolam") |>
  add_population(pop)
} # }
```
