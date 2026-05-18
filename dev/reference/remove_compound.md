# Remove compounds from a snapshot

Remove one or more compounds from a \[Snapshot\] by name.

## Usage

``` r
remove_compound(snapshot, compound_name)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- compound_name:

  Character vector of compound names to remove.

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_compound("Midazolam")
} # }
```
