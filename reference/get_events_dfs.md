# Get all events in a snapshot as data frames

This function extracts all events from a snapshot and converts them to
data frames for easier analysis and visualization.

## Usage

``` r
get_events_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A list containing two data frames:

- events: Basic information about each event

- events_parameters: All parameters for all events

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all event data as data frames
dfs <- get_events_dfs(snapshot)

# Access specific data frames
events_df <- dfs$events
events_parameters_df <- dfs$events_parameters
} # }
```
