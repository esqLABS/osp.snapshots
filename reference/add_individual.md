# Add an individual to a snapshot

Add an Individual object to a Snapshot. This is a convenience function
that calls the add_individual method of the Snapshot class.

## Usage

``` r
add_individual(snapshot, individual)
```

## Arguments

- snapshot:

  A Snapshot object

- individual:

  An Individual object created with create_individual()

## Value

The updated Snapshot object

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Create a new individual
ind <- create_individual(name = "New Patient", age = 35, weight = 70)

# Add the individual to the snapshot
snapshot <- add_individual(snapshot, ind)
} # }
```
