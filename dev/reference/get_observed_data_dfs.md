# Get all observed data in a snapshot as a tibble

Thin wrapper around
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
with `kind = "observed_data"`. Prefer
[`as_tibbles()`](https://esqlabs.github.io/osp.snapshots/dev/reference/as_tibbles.md)
in new code.

## Usage

``` r
get_observed_data_dfs(snapshot)
```

## Arguments

- snapshot:

  A `Snapshot` object.

## Value

A tibble in long format. The installed `ospsuite` decides the columns,
through
[`ospsuite::dataSetToTibble()`](https://www.open-systems-pharmacology.org/OSPSuite-R/reference/dataSetToDataFrame.html).
Every version returns at least `name`, `xValues`, `yValues`,
`yErrorValues`, `xDimension`, `xUnit`, `yDimension`, `yUnit`,
`yErrorType`, `yErrorUnit`, `molWeight` and `lloq`, plus one column per
meta-data field of the observed data. A snapshot with no observed data
returns the same columns with no rows.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
observed_data_df <- get_observed_data_dfs(snapshot)
} # }
```
