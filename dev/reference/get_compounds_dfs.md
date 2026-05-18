# Get all compounds in a snapshot as data frames

Thin wrapper around \[as_tibbles()\] with \`kind = "compounds"\`. Prefer
\[as_tibbles()\] in new code.

## Usage

``` r
get_compounds_dfs(snapshot)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

## Value

A tibble with one row per compound parameter; see \[as_tibbles()\] for
the column contract.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
compounds_df <- get_compounds_dfs(snapshot)
} # }
```
