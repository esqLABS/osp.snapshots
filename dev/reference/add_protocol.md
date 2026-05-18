# Add a protocol to a snapshot

Add a
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
object to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md).

## Usage

``` r
add_protocol(snapshot, protocol)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- protocol:

  A
  [Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
  object created with
  [`create_protocol()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_protocol.md).

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

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
