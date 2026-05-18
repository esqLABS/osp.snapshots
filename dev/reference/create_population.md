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
  advanced_parameters = NULL
)
```

## Arguments

- name:

  Character. Name of the population (required).

- number_of_individuals:

  Integer. Number of subjects to generate (required, must be a positive
  integer).

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
```
