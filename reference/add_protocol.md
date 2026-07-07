# Add one or more protocols to a snapshot

Add one or more
[Protocol](https://esqlabs.github.io/osp.snapshots/reference/Protocol.md)
objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md).

## Usage

``` r
add_protocol(snapshot, protocol)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
  object.

- protocol:

  A
  [Protocol](https://esqlabs.github.io/osp.snapshots/reference/Protocol.md)
  object created with
  [`create_protocol()`](https://esqlabs.github.io/osp.snapshots/reference/create_protocol.md),
  or a list of such objects.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
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

snapshot <- load_snapshot("Midazolam") |>
  add_protocol(list(prot, prot))
} # }
```
