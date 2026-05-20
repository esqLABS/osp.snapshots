# Create a simulation building block

Build a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
from named arguments. Exactly one of `individual` or `population` must
be supplied; the other must be left `NULL`.

## Usage

``` r
create_simulation(
  name,
  model = "4Comp",
  individual = NULL,
  population = NULL,
  compounds = NULL,
  events = NULL,
  observer_sets = NULL,
  observed_data_names = NULL,
  solver = NULL,
  output_schema = NULL,
  output_selections = NULL,
  output_mappings = NULL,
  parameters = NULL,
  advanced_parameters = NULL,
  description = NULL,
  allow_aging = NULL
)
```

## Arguments

- name:

  Character. Simulation name (required).

- model:

  Character. PK-Sim model name (defaults to `"4Comp"`).

- individual:

  Character. Name of the individual building block. Mutually exclusive
  with `population`.

- population:

  Character. Name of the population building block. Mutually exclusive
  with `individual`.

- compounds:

  List of
  [CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
  objects or raw lists.

- events:

  List of
  [EventSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/EventSelection.md)
  objects or raw lists.

- observer_sets:

  List of
  [ObserverSetSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ObserverSetSelection.md)
  objects or raw lists.

- observed_data_names:

  Character vector of observed-data names referenced by the simulation.

- solver:

  A
  [SolverSettings](https://esqlabs.github.io/osp.snapshots/dev/reference/SolverSettings.md)
  object or raw list. Defaults to PK-Sim defaults.

- output_schema:

  An
  [OutputSchema](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputSchema.md)
  object or raw list. Defaults to an empty schema.

- output_selections:

  Character vector of output quantity paths.

- output_mappings:

  List of
  [OutputMapping](https://esqlabs.github.io/osp.snapshots/dev/reference/OutputMapping.md)
  objects or raw lists.

- parameters:

  List of
  [LocalizedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/LocalizedParameter.md)
  objects (created with `create_parameter(path = ..., ...)`) or raw
  parameter lists.

- advanced_parameters:

  List of
  [AdvancedParameter](https://esqlabs.github.io/osp.snapshots/dev/reference/AdvancedParameter.md)
  objects or raw lists (population simulations only).

- description:

  Character. Free-text description of the simulation.

- allow_aging:

  Logical. Whether the simulation allows aging.

## Value

A
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
object.

## Examples

``` r
create_simulation(
  name = "Sim 1",
  individual = "Adult",
  compounds = list(create_compound_properties(name = "Drug X"))
)
#> 
#> ── Simulation: Sim 1 ───────────────────────────────────────────────────────────
#> • Model: 4Comp
#> • Individual: Adult
#> 
#> ── Compounds (1) ──
#> 
#> • Drug X
```
