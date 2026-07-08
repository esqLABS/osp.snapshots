# Build a simulation from a snapshot and attach it

Build a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
from named arguments and attach it to a
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md),
or attach a pre-built
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md).

A simulation is almost pure references into the snapshot, so the
snapshot is its entry point. In build mode, with the snapshot in hand,
`add_simulation()` resolves compound references and derives sensible
defaults (calculation methods, formulation key, alternatives) from the
referenced building blocks before attaching. Supply `name` plus exactly
one of `individual` / `population`, and configure each compound inline
through `compounds`, selecting a specific alternative by friendly
property name and label, or a multi-slot protocol's formulations, where
the derived defaults are not enough. References to building blocks not
yet in the snapshot trigger one informational warning per simulation;
the add proceeds either way.

## Usage

``` r
add_simulation(
  snapshot,
  simulation = NULL,
  name = NULL,
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

- snapshot:

  A
  [Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
  object.

- simulation:

  A pre-built
  [Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
  object, or a list of such objects. Leave `NULL` to build a simulation
  from the named arguments.

- name:

  Character. Simulation name (required in build mode).

- model:

  Character. PK-Sim model name (defaults to `"4Comp"`).

- individual:

  Character. Name of the individual building block. Mutually exclusive
  with `population`.

- population:

  Character. Name of the population building block. Mutually exclusive
  with `individual`.

- compounds:

  List of inline compound-config lists
  (`list(name =, protocol =, formulation =, processes =, calculation_methods =, alternatives =)`).
  Each entry is resolved against the snapshot. `alternatives` is a named
  character vector (or named list of length-one strings) mapping a
  friendly property name (`lipophilicity`, `fraction_unbound`,
  `solubility`, `intestinal_permeability`, `permeability`) to the
  alternative label to select on that compound, for example
  `alternatives = c(solubility = "FaSSIF")`; it overrides the derived
  default for the named groups only, every other group is still
  defaulted from the compound. `formulation` accepts a single string
  (bound to the protocol's inferred first slot key, unchanged) or a
  named character vector (or named list of length-one strings) mapping
  application-slot key to formulation name for a multi-slot protocol,
  for example
  `formulation = c(Formulation = "Oral solution", "Formulation 2" = "IV solution")`.

- events:

  List of
  [EventSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/EventSelection.md)
  objects or raw lists.

- observer_sets:

  List of
  [ObserverSetSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ObserverSetSelection.md)
  objects or raw lists.

- observed_data_names:

  Character vector of observed-data names.

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

The updated
[Snapshot](https://esqlabs.github.io/osp.snapshots/dev/reference/Snapshot.md)
object, returned invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
snapshot <- load_snapshot("Midazolam") |>
  add_simulation(
    name = "Sim 1",
    individual = "Korean (Yu 2004 study)",
    compounds = list(list(
      name = "Rifampicin",
      protocol = "Yu 2004 - Rifampicin - 600 mg MD OD 10 days",
      formulation = "Oral solution",
      processes = c("Hepatic"),
      alternatives = c(solubility = "FaSSIF")
    ))
  )
} # }
```
