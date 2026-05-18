# Add a compound to a snapshot

Add a
[Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
object to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md).

## Usage

``` r
add_compound(snapshot, compound)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- compound:

  A
  [Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
  object created with
  [`create_compound()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_compound.md).

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  add_compound(create_compound(name = "Drug X"))
} # }
```
