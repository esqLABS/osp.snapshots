# Add a compound to a snapshot

Add a \[Compound\] object to a \[Snapshot\].

## Usage

``` r
add_compound(snapshot, compound)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- compound:

  A \[Compound\] object created with \[create_compound()\].

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  add_compound(create_compound(name = "Drug X"))
} # }
```
