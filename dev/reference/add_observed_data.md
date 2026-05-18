# Add observed data to a snapshot

Add an \`ospsuite::DataSet\` (observed data) to a \[Snapshot\].

## Usage

``` r
add_observed_data(snapshot, observed_data)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- observed_data:

  A \`DataSet\` object, typically created with
  \[create_observed_data()\] or \[loadDataSetFromSnapshot()\].

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
dataset <- create_observed_data(
  name = "Study A",
  time = c(0, 1, 2),
  values = c(0, 5, 8),
  value_dimension = "Concentration (mass)"
)
snapshot <- load_snapshot("Midazolam") |>
  add_observed_data(dataset)
} # }
```
