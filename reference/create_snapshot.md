# Create an empty snapshot

Create an in-memory
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
from scratch, carrying the current supported PK-Sim version and no
building blocks. This is the snapshot-level constructor that pairs with
[`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/load_snapshot.md)
and
[`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/export_snapshot.md):
rather than loading an existing project, it starts an empty one you can
then populate.

The result touches no files and has no path. Mutate it with the
`add_*()` verbs (for example
[`add_compound()`](https://esqlabs.github.io/osp.snapshots/reference/add_compound.md))
and serialize it with
[`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/export_snapshot.md).

## Usage

``` r
create_snapshot(name = NULL, description = NULL)
```

## Arguments

- name:

  Character. Optional snapshot name. When supplied, it is written to the
  snapshot's `Name`; when `NULL`, no `Name` is set. An empty string `""`
  is written verbatim rather than treated as absent.

- description:

  Character. Optional snapshot description. Follows the same
  `NULL`-versus-supplied and empty-string semantics as `name`.

## Value

A
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
object.

## See also

[`load_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/load_snapshot.md),
[`export_snapshot()`](https://esqlabs.github.io/osp.snapshots/reference/export_snapshot.md)

## Examples

``` r
# An empty snapshot
snapshot <- create_snapshot()
#> ℹ Creating snapshot from list data
#> ✔ Snapshot loaded successfully

# A named and described snapshot
snapshot <- create_snapshot(name = "My Project", description = "Notes")
#> ℹ Creating snapshot from list data
#> ✔ Snapshot loaded successfully

# Populate it with a building block
snapshot <- add_compound(create_snapshot(), create_compound(name = "Drug X"))
#> ℹ Creating snapshot from list data
#> ✔ Snapshot loaded successfully
#> ✔ Added 1 compound(s)
```
