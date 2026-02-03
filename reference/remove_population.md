# Remove populations from a snapshot

Remove one or more populations from a Snapshot by name.

## Usage

``` r
remove_population(snapshot, population_name)
```

## Arguments

- snapshot:

  A Snapshot object

- population_name:

  Character vector of population names to remove

## Value

The updated Snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Remove a single population
snapshot <- remove_population(snapshot, "pop_1")

# Remove multiple populations
snapshot <- remove_population(
  snapshot,
  c("pop_1", "pop_2")
)
} # }
```
