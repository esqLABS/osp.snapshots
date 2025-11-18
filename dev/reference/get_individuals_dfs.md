# Get all individuals in a snapshot as data frames

This function extracts all individuals from a snapshot and converts them
to data frames for easier analysis and visualization.

## Usage

``` r
get_individuals_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A list containing three data frames:

- individuals: Basic information about each individual

- individuals_parameters: All parameters for all individuals

- individuals_expressions: Expression profiles for all individuals

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all individual data as data frames
dfs <- get_individuals_dfs(snapshot)

# Access specific data frames
individuals_df <- dfs$individuals
individuals_parameters_df <- dfs$individuals_parameters
individuals_expressions_df <- dfs$individuals_expressions
} # }
```
