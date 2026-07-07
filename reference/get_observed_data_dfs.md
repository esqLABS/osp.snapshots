# Get all observed data in a snapshot as a tibble

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
with `kind = "observed_data"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_observed_data_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A tibble in long format with columns `name`, `xValues`, `yValues`,
`yErrorValues`, `xDimension`, `xUnit`, `yDimension`, `yUnit`,
`yErrorType`, `yErrorUnit`, `molWeight`, `lloq`.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
observed_data_df <- get_observed_data_dfs(snapshot)
} # }
```
