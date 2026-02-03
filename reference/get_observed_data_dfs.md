# Get all observed data in a snapshot as data frames

This function extracts all observed data from a snapshot and converts
them to data frames for easier analysis and visualization.

## Usage

``` r
get_observed_data_dfs(snapshot)
```

## Arguments

- snapshot:

  A Snapshot object

## Value

A tibble containing all observed data in long format with columns:

- observed_data_name: Name of the observed data set

- time: Time values

- time_unit: Unit for time values

- column_name: Name of the measurement column

- value: Measured values

- unit: Unit for the measured values

- path: Full path of the measurement

- auxiliary_type: Type of auxiliary data (e.g., ArithmeticMean,
  ArithmeticStdDev)

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Get all observed data as data frames
observed_data_df <- get_observed_data_dfs(snapshot)
} # }
```
