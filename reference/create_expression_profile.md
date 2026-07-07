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
```
