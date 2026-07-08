# CompoundProperties class for Simulation compound configurations

An R6 class representing one entry in a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)'s
`Compounds` array. Carries the compound reference (by name) plus the
simulation's calculation-method overrides, alternative selections,
process selections, and optional
[ProtocolSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ProtocolSelection.md).
Internal machinery only:
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)'s
inline `compounds` argument is the user-facing way to configure a
compound for a simulation; this class is not part of the public API.

## Active bindings

- `data`:

  The raw data of the entry (read-only). Rebuilt from the nested caches
  so that mutations on the wrapped objects flow back to the export
  payload.

- `name`:

  The name of the compound building block. Writable: must be a non-empty
  scalar string.

- `calculation_methods`:

  Character vector of calculation method names that override the
  compound's defaults in this simulation. Writable: must be a character
  vector, or `NULL` to clear.

- `alternatives`:

  List of
  [CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundGroupSelection.md)
  objects.

- `processes`:

  List of
  [CompoundProcessSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProcessSelection.md)
  objects.

- `protocol`:

  A
  [ProtocolSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ProtocolSelection.md)
  object or `NULL`.

## Methods

### Public methods

- [`CompoundProperties$new()`](#method-CompoundProperties-initialize)

- [`CompoundProperties$clone()`](#method-CompoundProperties-clone)

------------------------------------------------------------------------

### `CompoundProperties$new()`

Create a new CompoundProperties object.

#### Usage

    CompoundProperties$new(data)

#### Arguments

- `data`:

  Raw `CompoundProperties` data from a snapshot.

#### Returns

A new CompoundProperties object.

------------------------------------------------------------------------

### `CompoundProperties$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CompoundProperties$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
