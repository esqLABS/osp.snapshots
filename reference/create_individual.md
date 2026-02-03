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
  age_unit = "year(s)",
  weight = NULL,
  weight_unit = "kg",
  height = NULL,
  height_unit = "cm",
  gestational_age = NULL,
  gestational_age_unit = "week(s)",
  calculation_methods = NULL,
  disease_state = NULL,
  disease_state_parameters = NULL,
  seed = NULL
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

  Numeric. Age of the individual

- age_unit:

  Character. Unit for age (must be valid unit for "Age in years")

- weight:

  Numeric. Weight of the individual

- weight_unit:

  Character. Unit for weight (must be valid unit for "Mass")

- height:

  Numeric. Height of the individual

- height_unit:

  Character. Unit for height (must be valid unit for "Length")

- gestational_age:

  Numeric. Gestational age of the individual (for infant/preterm
  individuals)

- gestational_age_unit:

  Character. Unit for gestational age (must be valid unit for "Time")

- calculation_methods:

  Character vector. Calculation methods used for the individual

- disease_state:

  Character. Disease state of the individual (optional)

- disease_state_parameters:

  List. Parameters for disease state (optional)

- seed:

  Integer. Simulation seed (optional)

## Value

An Individual object

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
  age = 30,
  weight = 70,
  height = 175
)

# Create an individual with calculation methods
individual <- create_individual(
  name = "Test Individual",
  calculation_methods = c("Method 1", "Method 2", "Method 3")
)

# Create an individual with disease state
individual <- create_individual(
  name = "Patient",
  disease_state = "CKD",
  disease_state_parameters = list(
    list(Name = "eGFR", Value = 45.0, Unit = "ml/min/1.73m²")
  )
)
```
