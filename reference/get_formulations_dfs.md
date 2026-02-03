# Get all formulations in a snapshot as data frames

This function extracts all formulations from a snapshot and converts
them to data frames for easier analysis and visualization.

## Usage

``` r
get_formulations_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A list containing two data frames:

- formulations: Basic information about each formulation

- formulations_parameters: All parameters for all formulations,
  including table parameter points. Table parameter points have
  is_table_point=TRUE and include x_value, y_value, and table_name
  values.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all formulation data as data frames
dfs <- get_formulations_dfs(snapshot)

# Access specific data frames
formulations_df <- dfs$formulations
formulations_parameters_df <- dfs$formulations_parameters

# Filter to get only table points
table_points <- formulations_parameters_df[formulations_parameters_df$is_table_point, ]
} # }
```
