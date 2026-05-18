# Remove observed data from a snapshot

Remove one or more observed-data entries from a \[Snapshot\] by name.

## Usage

``` r
remove_observed_data(snapshot, observed_data_name)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- observed_data_name:

  Character vector of observed-data names to remove.

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_observed_data("Study A")
} # }
```
