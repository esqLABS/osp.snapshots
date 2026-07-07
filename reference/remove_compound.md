# Remove compounds from a snapshot

Remove one or more compounds from a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
by name.

## Usage

``` r
remove_compound(snapshot, compound_name)
```

## Arguments

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
  object.

- compound_name:

  Character vector of compound names to remove.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  remove_compound("Midazolam")
} # }
```
