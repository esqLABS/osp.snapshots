# Get all events in a snapshot as data frames

Thin wrapper around \[as_tibbles()\] with \`kind = "events"\`. Prefer
\[as_tibbles()\] in new code.

## Usage

``` r
get_events_dfs(snapshot)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

## Value

A list with \`events\` and \`events_parameters\` tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("path/to/snapshot.json")
dfs <- get_events_dfs(snapshot)
} # }
```
