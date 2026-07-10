# FormulationSelection class for Simulation compound formulations

An R6 class representing one entry in a
[ProtocolSelection](https://esqlabs.github.io/osp.snapshots/reference/ProtocolSelection.md)'s
`Formulations` array. Each entry maps a formulation building-block name
to a formulation key used by an application within the protocol.

## Active bindings

- `data`:

  The raw data of the selection (read-only).

- `name`:

  The name of the formulation building block. Writable: must be a
  non-empty scalar string.

- `key`:

  The formulation key (application slot) inside the protocol. Writable:
  must be a non-empty scalar string.

## Methods

### Public methods

- [`FormulationSelection$new()`](#method-FormulationSelection-initialize)

- [`FormulationSelection$clone()`](#method-FormulationSelection-clone)

------------------------------------------------------------------------

### `FormulationSelection$new()`

Create a new FormulationSelection object.

#### Usage

    FormulationSelection$new(data)

#### Arguments

- `data`:

  Raw `FormulationSelection` data from a snapshot.

#### Returns

A new FormulationSelection object.

------------------------------------------------------------------------

### `FormulationSelection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FormulationSelection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
