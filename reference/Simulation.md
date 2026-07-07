# Simulation class for OSP snapshot simulations

An R6 class that represents a simulation in an OSP snapshot. A
simulation references building blocks (compounds, events, formulations,
observer sets, observed data, protocols, plus exactly one of an
individual or a population) and binds them together with a solver
configuration, an output schema, and parameter overrides.

## Subject type

Exactly one of `Individual` / `Population` must be non-empty. Setting or
clearing one through the active bindings is the user's responsibility;
the initialiser only checks the inbound raw data.

## Passthrough fields

Four fields are preserved byte-equivalent from the input rather than
parsed: `Interactions`, `AlteredBuildingBlocks`, `IndividualAnalyses`,
and `PopulationAnalyses`. They survive round-trip without modelling.

## Active bindings

- `data`:

  The raw data of the simulation (read-only). Rebuilt from the nested
  caches so that mutations on wrapped objects flow back to the export
  payload. Passthrough fields are preserved byte-equivalent.

- `name`:

  The name of the simulation.

- `description`:

  Free-text description of the simulation.

- `model`:

  The PK-Sim model used to build the simulation (e.g. `"4Comp"`).

- `allow_aging`:

  Whether the simulation allows aging.

- `individual`:

  Name of the individual building block (or `NULL` for a population
  simulation).

- `population`:

  Name of the population building block (or `NULL` for an individual
  simulation).

- `solver`:

  The
  [SolverSettings](https://esqlabs.github.io/osp.snapshots/reference/SolverSettings.md)
  object.

- `output_schema`:

  The
  [OutputSchema](https://esqlabs.github.io/osp.snapshots/reference/OutputSchema.md)
  object.

- `compounds`:

  List of
  [CompoundProperties](https://esqlabs.github.io/osp.snapshots/reference/CompoundProperties.md)
  objects.

- `events`:

  List of
  [EventSelection](https://esqlabs.github.io/osp.snapshots/reference/EventSelection.md)
  objects.

- `observer_sets`:

  List of
  [ObserverSetSelection](https://esqlabs.github.io/osp.snapshots/reference/ObserverSetSelection.md)
  objects.

- `observed_data_names`:

  Character vector of observed-data building-block names referenced by
  this simulation.

- `output_selections`:

  Character vector of output quantity paths selected for reporting.

- `output_mappings`:

  List of
  [OutputMapping](https://esqlabs.github.io/osp.snapshots/reference/OutputMapping.md)
  objects.

- `parameters`:

  Named list of
  [LocalizedParameter](https://esqlabs.github.io/osp.snapshots/reference/LocalizedParameter.md)
  objects (keyed by path) overriding parameters in the simulation's
  tree.

- `advanced_parameters`:

  List of
  [AdvancedParameter](https://esqlabs.github.io/osp.snapshots/reference/AdvancedParameter.md)
  objects (population simulations only).

## Methods

### Public methods

- [`Simulation$new()`](#method-Simulation-initialize)

- [`Simulation$print()`](#method-Simulation-print)

- [`Simulation$clone()`](#method-Simulation-clone)

------------------------------------------------------------------------

### `Simulation$new()`

Create a new Simulation object.

#### Usage

    Simulation$new(data)

#### Arguments

- `data`:

  Raw simulation data from a snapshot.

#### Returns

A new Simulation object.

------------------------------------------------------------------------

### `Simulation$print()`

Print a summary of the simulation.

#### Usage

    Simulation$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods.

#### Returns

Invisibly returns the simulation object.

------------------------------------------------------------------------

### `Simulation$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Simulation$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
