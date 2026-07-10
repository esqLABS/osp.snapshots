# CompoundProcessSelection class for compound process selections

An R6 class representing one entry in a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/reference/CompoundProperties.md)'s
`Processes` array. Selects a compound process by some combination of
name, molecule, metabolite, compound, and systemic process type; the
resolver in PK-Sim picks the right placeholder when only a subset of
fields is supplied.

## Active bindings

- `data`:

  The raw data of the selection (read-only).

- `name`:

  The process name. Writable: a non-empty scalar string when supplied,
  or `NULL` to clear.

- `molecule_name`:

  The molecule involved in the process. Writable: a non-empty scalar
  string when supplied, or `NULL` to clear.

- `metabolite_name`:

  The metabolite produced by the process. Writable: a non-empty scalar
  string when supplied, or `NULL` to clear.

- `compound_name`:

  The other compound involved in the process. Writable: a non-empty
  scalar string when supplied, or `NULL` to clear.

- `systemic_process_type`:

  The systemic process type (e.g. `"Hepatic"`, `"Renal"`, `"Biliary"`).
  Writable: a non-empty scalar string when supplied, or `NULL` to clear.
  The closed set is not confirmable from the snapshot schema (only
  examples are given), so a required string is the strongest check
  available.

## Methods

### Public methods

- [`CompoundProcessSelection$new()`](#method-CompoundProcessSelection-initialize)

- [`CompoundProcessSelection$clone()`](#method-CompoundProcessSelection-clone)

------------------------------------------------------------------------

### `CompoundProcessSelection$new()`

Create a new CompoundProcessSelection object.

#### Usage

    CompoundProcessSelection$new(data)

#### Arguments

- `data`:

  Raw `CompoundProcessSelection` data from a snapshot.

#### Returns

A new CompoundProcessSelection object.

------------------------------------------------------------------------

### `CompoundProcessSelection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CompoundProcessSelection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
