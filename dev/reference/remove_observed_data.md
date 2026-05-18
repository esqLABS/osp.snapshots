# Remove observed data from a snapshot

Remove one or more observed-data entries from a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
by name.

## Usage

``` r
remove_observed_data(snapshot, observed_data_name)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- observed_data_name:

  Character vector of observed-data names to remove.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_observed_data("Study A")
} # }
```
