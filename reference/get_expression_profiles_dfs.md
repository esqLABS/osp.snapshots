# Get all expression profiles in a snapshot as data frames

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
with `kind = "expression_profiles"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_expression_profiles_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A list with `expression_profiles` and `expression_profiles_parameters`
tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
dfs <- get_expression_profiles_dfs(snapshot)
} # }
```
