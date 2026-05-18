# Add an observer set to a snapshot

Add an \`ObserverSet\` building block to a \`Snapshot\`. The exported
function is the canonical, pipeable surface for the mutation; it
validates the snapshot before delegating to the underlying R6 method.

## Usage

``` r
add_observer_set(snapshot, observer_set)
```

## Arguments

- snapshot:

  A \`Snapshot\` object.

- observer_set:

  An \`ObserverSet\` object.

## Value

The updated \`Snapshot\` object, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam")

observer_set <- ObserverSet$new(list(
  Name = "BrainPlasmaConcentration",
  Observers = list()
))

snapshot |> add_observer_set(observer_set)
} # }
```
