# Remove formulations from a snapshot

Remove one or more formulations from a Snapshot by name.

## Usage

``` r
remove_formulation(snapshot, formulation_name)
```

## Arguments

- snapshot:

  A Snapshot object

- formulation_name:

  Character vector of formulation names to remove

## Value

The updated Snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Remove a single formulation
snapshot <- remove_formulation(snapshot, "Tablet")

# Remove multiple formulations
snapshot <- remove_formulation(
  snapshot,
  c("Tablet", "Oral solution")
)
} # }
```
