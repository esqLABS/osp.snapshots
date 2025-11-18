# Get all populations in a snapshot as data frames

This function extracts all populations from a snapshot and converts them
to data frames for easier analysis and visualization.

## Usage

``` r
get_populations_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A list containing two data frames:

- populations: Basic information about each population including ranges

- populations_parameters: All parameters for all populations

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all population data as data frames
dfs <- get_populations_dfs(snapshot)

# Access specific data frames
populations_df <- dfs$populations
populations_parameters_df <- dfs$populations_parameters
} # }
```
