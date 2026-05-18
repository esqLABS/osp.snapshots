# Get all populations in a snapshot as data frames

Thin wrapper around \[as_tibbles()\] with \`kind = "populations"\`.
Prefer \[as_tibbles()\] in new code.

## Usage

``` r
get_populations_dfs(snapshot)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

## Value

A list with \`populations\` and \`populations_parameters\` tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
dfs <- get_populations_dfs(snapshot)
} # }
```
