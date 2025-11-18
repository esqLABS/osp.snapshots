# Add an expression profile to a snapshot

Add an ExpressionProfile object to a Snapshot. This is a convenience
function that calls the add_expression_profile method of the Snapshot
class.

## Usage

``` r
add_expression_profile(snapshot, expression_profile)
```

## Arguments

- snapshot:

  A Snapshot object

- expression_profile:

  An ExpressionProfile object

## Value

The updated Snapshot object

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

# Add the expression profile to the snapshot
snapshot <- add_expression_profile(snapshot, profile)
} # }
```
