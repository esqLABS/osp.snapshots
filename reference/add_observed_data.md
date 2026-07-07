# Add one or more observed-data entries to a snapshot

Add one or more
[`ospsuite::DataSet`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/DataSet.html)
(observed data) objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md).

## Usage

``` r
add_observed_data(snapshot, observed_data)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
  object.

- observed_data:

  A `DataSet` object, typically created with
  [`create_observed_data()`](https://esqlabs.github.io/osp.snapshots/reference/create_observed_data.md)
  or
  [`loadDataSetFromSnapshot()`](https://esqlabs.github.io/osp.snapshots/reference/loadDataSetFromSnapshot.md),
  or a list of such objects.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
dataset <- create_observed_data(
  name = "Study A",
  time = c(0, 1, 2),
  values = c(0, 5, 8),
  value_dimension = "Concentration (mass)"
)
snapshot <- load_snapshot("Midazolam") |>
  add_observed_data(dataset)

snapshot <- load_snapshot("Midazolam") |>
  add_observed_data(list(dataset, dataset))
} # }
```
