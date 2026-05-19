# CalculationMethods class for OSP snapshots

An R6 class that wraps the set of calculation methods PK-Sim uses to
derive compound quantities (e.g. partition coefficient method, cellular
permeability method, body surface area method). In an OSP snapshot, the
calculation methods are serialised as an array of method name strings.
They appear in two places: directly on a
[Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
and inside an
[OriginData](https://esqlabs.github.io/osp.snapshots/dev/reference/OriginData.md)
of an
[Individual](https://esqlabs.github.io/osp.snapshots/dev/reference/Individual.md).

## Active bindings

- `names`:

  Character vector of method names.

- `length`:

  Number of methods currently held (read-only).

## Methods

### Public methods

- [`CalculationMethods$new()`](#method-CalculationMethods-initialize)

- [`CalculationMethods$print()`](#method-CalculationMethods-print)

- [`CalculationMethods$add()`](#method-CalculationMethods-add)

- [`CalculationMethods$remove()`](#method-CalculationMethods-remove)

- [`CalculationMethods$to_list()`](#method-CalculationMethods-to_list)

- [`CalculationMethods$clone()`](#method-CalculationMethods-clone)

------------------------------------------------------------------------

### `CalculationMethods$new()`

Create a new CalculationMethods object

#### Usage

    CalculationMethods$new(names = character())

#### Arguments

- `names`:

  Character vector of method names. May be `NULL` or an empty vector,
  both of which result in an empty set.

#### Returns

A new CalculationMethods object

------------------------------------------------------------------------

### `CalculationMethods$print()`

Print a summary of the calculation methods

#### Usage

    CalculationMethods$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the CalculationMethods object

------------------------------------------------------------------------

### `CalculationMethods$add()`

Add a method name. Duplicates are kept to mirror the snapshot's raw
representation.

#### Usage

    CalculationMethods$add(name)

#### Arguments

- `name`:

  Character. Name of the calculation method to add.

#### Returns

Invisibly returns the CalculationMethods object

------------------------------------------------------------------------

### `CalculationMethods$remove()`

Remove a method name. If `name` is not present, the set is unchanged.
Note the asymmetry with `$add()`: `$add()` keeps duplicates to mirror
the snapshot's raw representation, whereas `$remove()` deletes every
occurrence of `name` in a single call.

#### Usage

    CalculationMethods$remove(name)

#### Arguments

- `name`:

  Character. Name of the calculation method to remove.

#### Returns

Invisibly returns the CalculationMethods object

------------------------------------------------------------------------

### `CalculationMethods$to_list()`

Convert back to the raw snapshot representation: a list of method-name
strings, or `NULL` when empty. A list is used (rather than a character
vector) so that single-method sets round-trip as JSON arrays.

#### Usage

    CalculationMethods$to_list()

#### Returns

A list of method-name strings, or `NULL` when empty.

------------------------------------------------------------------------

### `CalculationMethods$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CalculationMethods$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
