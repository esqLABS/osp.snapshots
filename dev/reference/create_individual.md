# Create a new individual

Create a new individual with the specified properties. All arguments are
optional and will use default values if not provided.

## Usage

``` r
create_individual(
  name = "New Individual",
  species = NULL,
  population = NULL,
  gender = NULL,
  age = NULL,
  weight = NULL,
  height = NULL,
  gestational_age = NULL,
  calculation_methods = NULL,
  disease_state = NULL,
  disease_state_parameters = NULL,
  seed = NULL,
  expression_profiles = NULL,
  description = NULL,
  parameters = NULL
)
```

## Arguments

- name:

  Character. Name of the individual

- species:

  Character. Species of the individual (must be valid ospsuite Species)

- population:

  Character. Population of the individual (must be valid ospsuite
  HumanPopulation)

- gender:

  Character. Gender of the individual (must be valid ospsuite Gender)

- age:

  An
  [`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md)
  object, or `NULL`.

- weight:

  A
  [`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md)
  object, or `NULL`.

- height:

  A
  [`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md)
  object, or `NULL`.

- gestational_age:

  A
  [`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md)
  object, or `NULL` (for infant/preterm individuals).

- calculation_methods:

  Character vector. Calculation methods used for the individual

- disease_state:

  Character. Disease-state name of the individual (optional). Together
  with `disease_state_parameters` it feeds the modern `Disease` object
  (`{ Name, Parameters }`) emitted under `OriginData$Disease`, matching
  [`create_expression_profile()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_expression_profile.md).

- disease_state_parameters:

  List. Parameters for the disease state (optional), keyed on `Name` in
  the emitted `Disease` object.

- seed:

  Integer. Simulation seed (optional)

- expression_profiles:

  Character vector of expression-profile composite names
  (`Molecule|Species|Category`) to attach to the individual. Default
  `NULL` (no profiles).

- description:

  Character. Free-text description of the individual. Default `NULL` (no
  description).

- parameters:

  List of localized parameters (each created with
  `create_parameter(path = ...)`), or the equivalent raw list form the
  loader consumes, applied as the individual's `Parameters` overrides.
  Each entry must be path-bearing. Default `NULL` (no parameter
  overrides).

## Value

An Individual object

## See also

[`age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/age.md),
[`weight()`](https://esqlabs.github.io/osp.snapshots/dev/reference/weight.md),
[`height()`](https://esqlabs.github.io/osp.snapshots/dev/reference/height.md),
[`gestational_age()`](https://esqlabs.github.io/osp.snapshots/dev/reference/gestational_age.md)
for the demographic value-object helpers.

## Examples

``` r
# Create a minimal individual
individual <- create_individual(name = "Test Individual")

# Create a complete individual
individual <- create_individual(
  name = "John Doe",
  species = "Human",
  population = "European_ICRP_2002",
  gender = "MALE",
  age = age(30),
  weight = weight(70),
  height = height(175)
)

# Create an individual with calculation methods
individual <- create_individual(
  name = "Test Individual",
  calculation_methods = c("Method 1", "Method 2", "Method 3")
)

# Create an individual with disease state (emitted as the modern
# `Disease` object: `OriginData$Disease = { Name, Parameters }`)
individual <- create_individual(
  name = "Patient",
  disease_state = "CKD",
  disease_state_parameters = list(
    list(Name = "eGFR", Value = 45.0, Unit = "ml/min/1.73m²")
  )
)

# Create an individual referencing expression profiles with a localized
# parameter and a description
individual <- create_individual(
  name = "Subject 1",
  expression_profiles = c("CYP3A4|Human|Healthy", "P-gp|Human|Healthy"),
  description = "Reference healthy adult",
  parameters = list(
    create_parameter(
      path = "Organism|Liver|EHC continuous fraction",
      value = 1
    )
  )
)
```
