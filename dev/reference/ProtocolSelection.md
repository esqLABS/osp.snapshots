# ProtocolSelection class for Simulation compound protocol assignments

An R6 class representing the `Protocol` field of a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md).
References a
[Protocol](https://esqlabs.github.io/osp.snapshots/dev/reference/Protocol.md)
building block by name and lists per-application
[FormulationSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/FormulationSelection.md)s
mapping formulation keys to formulation building blocks.

## Active bindings

- `data`:

  The raw data of the selection (read-only). Rebuilt from the cached
  [FormulationSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/FormulationSelection.md)
  list so that mutations flow back to the export payload.

- `name`:

  The name of the protocol building block.

- `formulations`:

  List of
  [FormulationSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/FormulationSelection.md)
  objects.

## Methods

### Public methods

- [`ProtocolSelection$new()`](#method-ProtocolSelection-initialize)

- [`ProtocolSelection$clone()`](#method-ProtocolSelection-clone)

------------------------------------------------------------------------

### `ProtocolSelection$new()`

Create a new ProtocolSelection object.

#### Usage

    ProtocolSelection$new(data)

#### Arguments

- `data`:

  Raw `ProtocolSelection` data from a snapshot.

#### Returns

A new ProtocolSelection object.

------------------------------------------------------------------------

### `ProtocolSelection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ProtocolSelection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
