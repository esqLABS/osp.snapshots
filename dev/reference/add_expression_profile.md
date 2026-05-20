# Add one or more expression profiles to a snapshot

Add one or more
[ExpressionProfile](https://esqlabs.github.io/osp.snapshots/dev/reference/ExpressionProfile.md)
objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md).

## Usage

``` r
add_expression_profile(snapshot, expression_profile)
```

## Arguments

- snapshot:

  A Snapshot object

- expression_profile:

  An ExpressionProfile object, or a list of such objects.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Create a new expression profile
profile_data <- list(
  Type = "Enzyme",
  Species = "Human",
  Molecule = "CYP3A4",
  Category = "Healthy",
  Parameters = list()
)
profile <- ExpressionProfile$new(profile_data)

# Add a single expression profile
snapshot <- add_expression_profile(snapshot, profile)

# Add several at once
snapshot <- add_expression_profile(snapshot, list(profile, profile))
} # }
```
