# Add an event to a snapshot

Add an \[Event\] object to a \[Snapshot\].

## Usage

``` r
add_event(snapshot, event)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- event:

  An \[Event\] object created with \[create_event()\].

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
evt <- create_event(
  name = "Breakfast",
  template = "Meal: Standard (Human)"
)
snapshot <- load_snapshot("Midazolam") |>
  add_event(evt)
} # }
```
