# Get all protocols in a snapshot as a single consolidated data frame

Thin wrapper around \[as_tibbles()\] with \`kind = "protocols"\`. Prefer
\[as_tibbles()\] in new code.

## Usage

``` r
get_protocols_dfs(snapshot)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

## Value

A tibble with one row per protocol parameter (or per schema item
parameter for advanced protocols).

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
protocols_df <- get_protocols_dfs(snapshot)
} # }
```
