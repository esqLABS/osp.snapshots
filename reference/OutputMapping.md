# OutputMapping class for simulation output-to-observed-data mappings

An R6 class representing one entry in a
[Simulation](https://esqlabs.github.io/osp.snapshots/reference/Simulation.md)'s
`OutputMappings` array. Each entry maps a simulation output quantity
path to an observed-data repository name and records the scaling and
weight(s) used when comparing the two.

## Active bindings

- `data`:

  The raw data of the mapping (read-only).

- `path`:

  The simulation output quantity path.

- `observed_data`:

  The observed-data repository name.

- `scaling`:

  The scaling used for the mapping.

- `weight`:

  A single weight applied to all points of the mapping.

- `weights`:

  A per-point weight vector.

## Methods

### Public methods

- [`OutputMapping$new()`](#method-OutputMapping-initialize)

- [`OutputMapping$clone()`](#method-OutputMapping-clone)

------------------------------------------------------------------------

### `OutputMapping$new()`

Create a new OutputMapping object.

#### Usage

    OutputMapping$new(data)

#### Arguments

- `data`:

  Raw `OutputMapping` data from a snapshot.

#### Returns

A new OutputMapping object.

------------------------------------------------------------------------

### `OutputMapping$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OutputMapping$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
