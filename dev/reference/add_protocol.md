# Add a protocol to a snapshot

Add a \[Protocol\] object to a \[Snapshot\].

## Usage

``` r
add_protocol(snapshot, protocol)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- protocol:

  A \[Protocol\] object created with \[create_protocol()\].

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
prot <- create_protocol(
  name = "Single oral dose",
  application_type = "Oral",
  dosing_interval = "Single"
)
snapshot <- load_snapshot("Midazolam") |>
  add_protocol(prot)
} # }
```
