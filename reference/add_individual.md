# Add one or more individuals to a snapshot

Add one or more
[Individual](https://esqlabs.github.io/osp.snapshots/reference/Individual.md)
objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md).

## Usage

``` r
add_individual(snapshot, individual)
```

## Arguments

- snapshot:

  A Snapshot object

- individual:

  An Individual object created with
  [`create_individual()`](https://esqlabs.github.io/osp.snapshots/reference/create_individual.md),
  or a list of such objects.

## Value

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
# Load a snapshot
snapshot <- load_snapshot("Midazolam")

# Add a single individual
ind <- create_individual(name = "New Patient", age = 35, weight = 70)
snapshot <- add_individual(snapshot, ind)

# Add several at once
patients <- list(
  create_individual("Patient_A", age = 25),
  create_individual("Patient_B", age = 45)
)
snapshot <- add_individual(snapshot, patients)
} # }
```
