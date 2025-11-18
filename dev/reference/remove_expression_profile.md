# Remove expression profiles from a snapshot

Remove one or more expression profiles from a Snapshot by ID
(molecule\|species\|category).

## Usage

``` r
remove_expression_profile(snapshot, profile_id)
```

## Arguments

- snapshot:

  A Snapshot object

- profile_id:

  Character vector of expression profile IDs to remove

## Value

The updated Snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Remove a single expression profile by ID
snapshot <- remove_expression_profile(snapshot, "CYP3A4|Human|Healthy")

# Remove multiple expression profiles
snapshot <- remove_expression_profile(
  snapshot,
  c("CYP3A4|Human|Healthy", "P-gp|Human|Healthy")
)
} # }
```
