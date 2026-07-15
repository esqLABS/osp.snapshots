# Load a snapshot from various sources

Conveniently load an OSP snapshot from a local file, URL, or predefined
template name.

## Usage

``` r
load_snapshot(source, upgrade = FALSE)
```

## Arguments

- source:

  Character string. Can be:

  - Path to a local file (.json)

  - URL to a remote snapshot file

  - Name of a template from the OSPSuite.BuildingBlockTemplates
    repository

- upgrade:

  Logical, default `FALSE`. When `TRUE`, a below-floor snapshot
  (`Version 74-78`) is migrated up to the version the installed PK-Sim
  core emits via a round trip through `ospsuite` (slow, several minutes,
  and requires a compatible installed core). When `FALSE`, such a
  snapshot reports how to migrate and does not load. In-band snapshots
  (`Version 79-81`) are never migrated regardless of this argument.

## Value

A Snapshot object

## Details

Available templates can be listed with
[`osp_models()`](https://esqlabs.github.io/osp.snapshots/dev/reference/osp_models.md).

## Examples

``` r
if (FALSE) { # \dontrun{
# Load from local file
snapshot <- load_snapshot("path/to/local/snapshot.json")

# Load from URL
snapshot <- load_snapshot("https://example.com/snapshot.json")

# Load a predefined template by name
snapshot <- load_snapshot("Midazolam")
} # }
```
