# Create a new expression profile

Create an
[ExpressionProfile](https://esqlabs.github.io/osp.snapshots/reference/ExpressionProfile.md)
building block from named arguments. This is a thin factory around
`ExpressionProfile$new()` that builds the raw list shape for you.

An
[ExpressionProfile](https://esqlabs.github.io/osp.snapshots/reference/ExpressionProfile.md)'s
identity is the composite `Molecule|Species|Category`, so all three of
`molecule`, `species`, and `category` are required.

## Usage

``` r
create_expression_profile(
  molecule,
  species,
  category,
  type,
  localization = NULL,
  transport_type = NULL,
  ontogeny = NULL,
  parameters = NULL,
  expression = NULL,
  disease = NULL,
  description = NULL
)
```

## Arguments

- molecule:

  Character. Name of the molecule (for example `"CYP3A4"`). Required.

- species:

  Character. Species (for example `"Human"`). Required.

- category:

  Character. Category disambiguator (for example `"Healthy"` or
  `"Variability"`). Required.

- type:

  Character. Molecule type, typically one of `"Enzyme"`,
  `"Transporter"`, or `"OtherProtein"`. Required.

- localization:

  Character. Expression localization for proteins.

- transport_type:

  Character. Transporter type (for transporter profiles), for example
  `"Efflux"` or `"Influx"`.

- ontogeny:

  Character or list. Ontogeny name, or a raw ontogeny list. If a string
  is supplied it is wrapped as `list(Name = ontogeny)`.

- parameters:

  List of
  [Parameter](https://esqlabs.github.io/osp.snapshots/reference/Parameter.md)
  objects (created with
  [`create_parameter()`](https://esqlabs.github.io/osp.snapshots/reference/create_parameter.md))
  or raw parameter lists describing relative expression and other
  per-organ values.

- expression:

  Per-organ relative expression, written to the snapshot's `Expression`
  array. Supply a data frame (or tibble), one row per organ/compartment,
  with a required `name` column (organ/container name, for example
  `"Liver"`) and the optional columns `value` (relative expression),
  `compartment` (for example `"Intracellular"`), and
  `transport_direction` (for transporter profiles). Missing (`NA`) or
  absent optional cells emit no key, so a row with only `name` and
  `value` produces a container with just those two fields. Row order is
  preserved and duplicate names are kept. Alternatively supply a raw
  list of container lists (each a named list with any of `Name`,
  `Value`, `CompartmentName`, `TransportDirection`) to pass through
  verbatim. `NULL` or an empty input writes nothing.

- disease:

  Disease state, written to the snapshot's `Disease` object. Supply a
  named list with `name` (required, the `DiseaseState` name) and an
  optional `parameters` list of
  [Parameter](https://esqlabs.github.io/osp.snapshots/reference/Parameter.md)
  objects or raw parameter lists. `NULL` writes nothing.

- description:

  Character. Free-text description of the profile.

## Value

An
[ExpressionProfile](https://esqlabs.github.io/osp.snapshots/reference/ExpressionProfile.md)
object.

## Examples

``` r
# Create a minimal enzyme expression profile
profile <- create_expression_profile(
  molecule = "CYP3A4",
  species = "Human",
  category = "Healthy",
  type = "Enzyme"
)

# Create a transporter expression profile with ontogeny
profile <- create_expression_profile(
  molecule = "P-gp",
  species = "Human",
  category = "Healthy",
  type = "Transporter",
  transport_type = "Efflux",
  ontogeny = "P-gp"
)

# Create an enzyme profile with per-organ relative expression
profile <- create_expression_profile(
  molecule = "CYP3A4",
  species = "Human",
  category = "Healthy",
  type = "Enzyme",
  expression = data.frame(
    name = c("Liver", "Kidney"),
    value = c(1, 0.5)
  )
)
```
