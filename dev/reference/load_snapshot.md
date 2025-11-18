# Load a snapshot from various sources

Conveniently load an OSP snapshot from a local file, URL, or predefined
template name.

## Usage

``` r
load_snapshot(source)
```

## Arguments

- source:

  Character string. Can be: - Path to a local file (.json) - URL to a
  remote snapshot file - Name of a template from the
  OSPSuite.BuildingBlockTemplates repository

## Value

A Snapshot object

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
