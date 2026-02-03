# Get all expression profiles in a snapshot as data frames

This function extracts all expression profiles from a snapshot and
converts them to data frames for easier analysis and visualization.

## Usage

``` r
get_expression_profiles_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A list containing two data frames:

- expression_profiles: Basic information about each expression profile

- expression_profiles_parameters: All parameters for all expression
  profiles

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all expression profile data as data frames
dfs <- get_expression_profiles_dfs(snapshot)

# Access specific data frames
expression_profiles_df <- dfs$expression_profiles
expression_profiles_parameters_df <- dfs$expression_profiles_parameters
} # }
```
