# EventSelection class for Simulation event references

An R6 class representing one entry in a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)'s
`Events` array. Resolves to an
[Event](https://esqlabs.github.io/osp.snapshots/dev/reference/Event.md)
building block by name and carries the simulation-local `StartTime`
[Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
used by the event.

## Active bindings

- `data`:

  The raw data of the selection (read-only). Rebuilt from the cached
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  so that mutations on `$start_time` flow back to the export payload.

- `name`:

  The name of the event building block. Writable: must be a non-empty
  scalar string.

- `start_time`:

  The
  [Parameter](https://esqlabs.github.io/osp.snapshots/dev/reference/Parameter.md)
  used as start time for the event.

## Methods

### Public methods

- [`EventSelection$new()`](#method-EventSelection-initialize)

- [`EventSelection$clone()`](#method-EventSelection-clone)

------------------------------------------------------------------------

### `EventSelection$new()`

Create a new EventSelection object.

#### Usage

    EventSelection$new(data)

#### Arguments

- `data`:

  Raw `EventSelection` data from a snapshot.

#### Returns

A new EventSelection object.

------------------------------------------------------------------------

### `EventSelection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    EventSelection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
