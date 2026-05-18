# Add an event to a snapshot

Add an
[Event](https://esqlabs.github.io/osp.snapshots/dev/reference/Event.md)
object to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md).

## Usage

``` r
add_event(snapshot, event)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- event:

  An
  [Event](https://esqlabs.github.io/osp.snapshots/dev/reference/Event.md)
  object created with
  [`create_event()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_event.md).

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

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
