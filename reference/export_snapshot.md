# Export a snapshot to a JSON file

Export a Snapshot object to a JSON file. This is a convenient wrapper
around the \`\$export()\` method of the Snapshot class.

## Usage

``` r
export_snapshot(snapshot, path)
```

## Arguments

- snapshot:

  A Snapshot object

- path:

  Character string. Path where to save the JSON file

## Value

Invisibly returns the snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("path/to/snapshot.json")

# Export to a new file
export_snapshot(snapshot, "path/to/exported_snapshot.json")
} # }
```
