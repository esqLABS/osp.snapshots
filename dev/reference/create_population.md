# Create a new population

Create a
[Population](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
building block from named arguments. This is a thin factory around
`Population$new()` that builds the raw `Settings` shape for you.

A
[Population](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
is a recipe for generating subjects: it owns the settings PK-Sim uses to
sample a cohort at simulation time. Subjects themselves are not stored
in the snapshot.

## Usage

``` r
create_population(
  name,
  number_of_individuals,
  proportion_of_females = 50,
  individual_name = NULL,
  species = NULL,
  source_population = NULL,
  age_range = NULL,
  weight_range = NULL,
  height_range = NULL,
  bmi_range = NULL,
  seed = NULL,
  advanced_parameters = NULL,
  description = NULL,
  gestational_age_range = NULL,
  disease_state_parameters = NULL,
  individual = NULL
)
```

## Arguments

- name:

  Character. Name of the population (required).

- number_of_individuals:

  Integer. Number of subjects to generate (required, a whole number
  between 2 and 10000, matching PK-Sim's population-creation bounds).

- proportion_of_females:

  Numeric. Percentage of females in the population, between 0 and 100.
  Defaults to `50`.

- individual_name:

  Character. Name of the base
  [Individual](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md)
  building block the population samples from.

- species:

  Character. Species used for the base individual when `individual_name`
  is not provided.

- source_population:

  Character. Population name used for the base individual (for example
  `"European_ICRP_2002"`).

- age_range:

  A
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object describing the age bounds (see
  [`range()`](https://esqlabs.github.io/osp.snapshots/dev/reference/range.md)).

- weight_range:

  A
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object describing the weight bounds.

- height_range:

  A
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object describing the height bounds.

- bmi_range:

  A
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object describing the BMI bounds.

- seed:

  Integer. Random seed for population generation.

- advanced_parameters:

  List of
  [AdvancedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/AdvancedParameter.md)
  objects or raw advanced-parameter lists that override default
  variability distributions.

- description:

  Character. Free-text description of the population.

- gestational_age_range:

  A
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object describing the gestational age range used for population
  generation (see
  [`range()`](https://esqlabs.github.io/osp.snapshots/dev/reference/range.md)).
  This is the population-settings range, distinct from the base
  individual's own scalar gestational age.

- disease_state_parameters:

  A named list mapping a disease-state parameter name to a
  [Range](https://esqlabs.github.io/osp.snapshots/dev/reference/Range-class.md)
  object, for example `list(eGFR = range(60, 120, "ml/min/1.73m²"))`.
  Each entry becomes one range in the population settings. This
  population-level name-to-`Range` map is distinct from the base
  individual's own `disease_state_parameters`, which carries scalar
  parameter values.

- individual:

  An
  [Individual](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md)
  object (typically from
  [`create_individual()`](https://esqlabs.github.io/osp.snapshots/dev/reference/create_individual.md))
  used as the base individual the population samples from. When
  supplied, it fully configures the base individual (gender, origin
  data, calculation methods, seed, description, parameters) and cannot
  be combined with `individual_name`, `species`, or `source_population`.

## Value

A
[Population](https://esqlabs.github.io/osp.snapshots/dev/reference/Population.md)
object.

## Examples

``` r
# Create a minimal population
pop <- create_population(
  name = "Adults",
  number_of_individuals = 100
)

# Create a population with demographic ranges
pop <- create_population(
  name = "Healthy Adults",
  number_of_individuals = 50,
  proportion_of_females = 50,
  species = "Human",
  source_population = "European_ICRP_2002",
  age_range = range(20, 60, "year(s)"),
  weight_range = range(50, 90, "kg")
)

# Compose a base individual and set a disease-state parameter
pop <- create_population(
  name = "Renal Impairment",
  number_of_individuals = 25,
  individual = create_individual(
    name = "Base",
    species = "Human",
    population = "European_ICRP_2002",
    gender = "MALE"
  ),
  gestational_age_range = range(37, 42, "week(s)"),
  disease_state_parameters = list(
    eGFR = range(60, 120, "ml/min/1.73m²")
  ),
  description = "Adults with reduced renal function"
)
```
