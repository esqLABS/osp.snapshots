# Remove observer sets from a snapshot

Remove one or more `ObserverSet` building blocks from a `Snapshot` by
name. Names not present in the snapshot trigger a warning rather than an
error so callers can run idempotent cleanup pipelines.

## Usage

``` r
remove_observer_set(snapshot, observer_set_name)
```

## Arguments

- snapshot:

  A `Snapshot` object.

- observer_set_name:

  Character vector of observer set names to remove.

## Value

The updated `Snapshot` object, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam")

snapshot |> remove_observer_set("BrainPlasmaConcentration")

snapshot |>
  remove_observer_set(c("BrainPlasmaConcentration", "LiverObservers"))
} # }
```
