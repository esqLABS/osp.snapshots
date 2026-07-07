# Get all formulations in a snapshot as data frames

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
with `kind = "formulations"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_formulations_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A list with `formulations` and `formulations_parameters` tibbles. Table
parameter points have `is_table_point = TRUE` and carry `x_value`,
`y_value`, and `table_name`.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
dfs <- get_formulations_dfs(snapshot)
} # }
```
