# Remove individuals from a snapshot

Remove one or more individuals from a Snapshot by name.

## Usage

``` r
remove_individual(snapshot, individual_name)
```

## Arguments

- snapshot:

  A Snapshot object

- individual_name:

  Character vector of individual names to remove

## Value

The updated Snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Remove a single individual
snapshot <- remove_individual(snapshot, "Subject_001")

# Remove multiple individuals
snapshot <- remove_individual(
  snapshot,
  c("Subject_001", "Subject_002")
)
} # }
```
