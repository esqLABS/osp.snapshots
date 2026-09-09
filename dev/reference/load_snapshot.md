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

  Logical, default `FALSE`. When `TRUE`, a snapshot older than the
  version the installed PK-Sim core writes is re-saved through that core
  to bring it up to date before loading (several minutes, and requires a
  compatible installed core). This applies to an older `Version 74-78`
  snapshot and to a supported `Version 79-81` one alike, so a v11.2 or
  v12.0 snapshot can be raised to v13. It never lowers a version and
  does nothing when the snapshot is already up to date. When `FALSE`,
  nothing is upgraded: a supported snapshot loads at its own version and
  a `74-78` snapshot reports how to upgrade it and does not load.

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
