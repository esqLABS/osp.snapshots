# Remove protocols from a snapshot

Remove one or more protocols from a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
by name.

## Usage

``` r
remove_protocol(snapshot, protocol_name)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- protocol_name:

  Character vector of protocol names to remove.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_protocol("IV bolus 1mg")
} # }
```
