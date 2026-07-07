# Get all observer sets in a snapshot as data frames

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
with `kind = "observer_sets"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_observer_sets_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A list with two tibbles. `observer_sets` has one row per `ObserverSet`
with columns `observer_set_id`, `name`, `n_observers`. `observers` has
one row per `Observer` with columns `observer_set_id`,
`observer_set_name`, `name`, `type`, `dimension`, `formula_expression`,
`formula_dimension`, `formula_references`, `container_tags`; rows join
back to their parent `ObserverSet` by `observer_set_id` or
`observer_set_name`. `formula_references` flattens the underlying
`ExplicitFormula` references to `"alias=path"` pairs joined with `|`.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
observer_sets_df <- get_observer_sets_dfs(snapshot)
} # }
```
