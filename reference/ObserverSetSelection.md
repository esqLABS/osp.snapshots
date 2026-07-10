# ObserverSetSelection class for Simulation observer-set references

An R6 class representing one entry in a
[Simulation](https://esqlabs.github.io/osp.snapshots/reference/Simulation.md)'s
`ObserverSets` array. Resolves to an
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md)
building block by name.

## Active bindings

- `data`:

  The raw data of the selection (read-only).

- `name`:

  The name of the observer-set building block. Writable: must be a
  non-empty scalar string.

## Methods

### Public methods

- [`ObserverSetSelection$new()`](#method-ObserverSetSelection-initialize)

- [`ObserverSetSelection$clone()`](#method-ObserverSetSelection-clone)

------------------------------------------------------------------------

### `ObserverSetSelection$new()`

Create a new ObserverSetSelection object.

#### Usage

    ObserverSetSelection$new(data)

#### Arguments

- `data`:

  Raw `ObserverSetSelection` data from a snapshot.

#### Returns

A new ObserverSetSelection object.

------------------------------------------------------------------------

### `ObserverSetSelection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ObserverSetSelection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
