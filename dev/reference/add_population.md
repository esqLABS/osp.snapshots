# Add a population to a snapshot

Add a \[Population\] object to a \[Snapshot\].

## Usage

``` r
add_population(snapshot, population)
```

## Arguments

- snapshot:

  A \[Snapshot\] object.

- population:

  A \[Population\] object created with \[create_population()\].

## Value

The updated \[Snapshot\] object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
pop <- create_population(name = "Adults", number_of_individuals = 100)
snapshot <- load_snapshot("Midazolam") |>
  add_population(pop)
} # }
```
