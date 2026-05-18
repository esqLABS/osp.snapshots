# Get all observer sets in a snapshot as a tibble

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
with `kind = "observer_sets"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_observer_sets_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A tibble with one row per `ObserverSet`, with columns `observer_set_id`,
`name`, `n_observers`. Richer per-observer detail is deferred until the
`Observer` leaf class lands.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
observer_sets_df <- get_observer_sets_dfs(snapshot)
} # }
```
