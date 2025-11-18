# Add a formulation to a snapshot

Add a Formulation object to a Snapshot. This is a convenience function
that calls the add_formulation method of the Snapshot class.

## Usage

``` r
add_formulation(snapshot, formulation)
```

## Arguments

- snapshot:

  A Snapshot object

- formulation:

  A Formulation object created with create_formulation()

## Value

The updated Snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Create a new formulation
form <- create_formulation(name = "Tablet", type = "Weibull")

# Add the formulation to the snapshot
snapshot <- add_formulation(snapshot, form)
} # }
```
