# Get all individuals in a snapshot as data frames

Thin wrapper around \[as_tibbles()\] with \`kind = "individuals"\`.
Prefer \[as_tibbles()\] in new code.

## Usage

``` r
get_individuals_dfs(snapshot)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

## Value

A list with \`individuals\`, \`individuals_parameters\`, and
\`individuals_expressions\` tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
dfs <- get_individuals_dfs(snapshot)
} # }
```
