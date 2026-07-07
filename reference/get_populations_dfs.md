# Get all populations in a snapshot as data frames

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
with `kind = "populations"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_populations_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A list with `populations` and `populations_parameters` tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
dfs <- get_populations_dfs(snapshot)
} # }
```
