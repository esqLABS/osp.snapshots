# Remove events from a snapshot

Remove one or more events from a \[Snapshot\] by name.

## Usage

``` r
remove_event(snapshot, event_name)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- event_name:

  Character vector of event names to remove.

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_event("Breakfast")
} # }
```
