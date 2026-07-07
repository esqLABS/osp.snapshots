# Add one or more formulations to a snapshot

Add one or more
[Formulation](https://esqlabs.github.io/osp.snapshots/reference/Formulation.md)
objects to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/reference/Snapshot.md).

## Usage

``` r
add_formulation(snapshot, formulation)
```

## Arguments

- snapshot:

  A Snapshot object

- formulation:

  A Formulation object created with
  [`create_formulation()`](https://esqlabs.github.io/osp.snapshots/reference/create_formulation.md),
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

# Add a single formulation
form <- create_formulation(name = "Tablet", type = "Weibull")
snapshot <- add_formulation(snapshot, form)

# Add several at once
forms <- list(
  create_formulation("Tablet", type = "Weibull"),
  create_formulation("Oral solution", type = "First Order")
)
snapshot <- add_formulation(snapshot, forms)
} # }
```
