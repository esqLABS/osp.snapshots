# Add one or more compounds to a snapshot

Add one or more
[Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md)
objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md).

## Usage

``` r
add_compound(snapshot, compound)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
  object.

- compound:

  A
  [Compound](https://esqlabs.github.io/osp.snapshots/reference/Compound.md)
  object created with
  [`create_compound()`](https://esqlabs.github.io/osp.snapshots/reference/create_compound.md),
  or a list of such objects.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  add_compound(create_compound(name = "Drug X"))

snapshot <- load_snapshot("Midazolam") |>
  add_compound(list(
    create_compound(name = "Drug X"),
    create_compound(name = "Drug Y")
  ))
} # }
```
