# CalculationMethodCache class for OSP snapshots

An R6 class that wraps the set of calculation methods PK-Sim uses to
derive compound quantities (e.g. partition coefficient method, cellular
permeability method, body surface area method). In an OSP snapshot, the
calculation method cache is serialised as an array of method name
strings. It appears in two places: directly on a \[Compound\] and inside
an \[OriginData\] of an \[Individual\].

## Active bindings

- `methods`:

  Character vector of method names in the cache.

- `length`:

  Number of methods currently in the cache (read-only).

## Methods

### Public methods

- [`CalculationMethodCache$new()`](#method-CalculationMethodCache-initialize)

- [`CalculationMethodCache$print()`](#method-CalculationMethodCache-print)

- [`CalculationMethodCache$add()`](#method-CalculationMethodCache-add)

- [`CalculationMethodCache$remove()`](#method-CalculationMethodCache-remove)

- [`CalculationMethodCache$to_list()`](#method-CalculationMethodCache-to_list)

- [`CalculationMethodCache$clone()`](#method-CalculationMethodCache-clone)

------------------------------------------------------------------------

### `CalculationMethodCache$new()`

Create a new CalculationMethodCache object

#### Usage

    CalculationMethodCache$new(methods = character())

#### Arguments

- `methods`:

  Character vector of method names. May be \`NULL\` or an empty vector,
  both of which result in an empty cache.

#### Returns

A new CalculationMethodCache object

------------------------------------------------------------------------

### `CalculationMethodCache$print()`

Print a summary of the calculation method cache

#### Usage

    CalculationMethodCache$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the CalculationMethodCache object

------------------------------------------------------------------------

### `CalculationMethodCache$add()`

Add a method name to the cache. Duplicates are kept to mirror the
snapshot's raw representation.

#### Usage

    CalculationMethodCache$add(method)

#### Arguments

- `method`:

  Character. Name of the calculation method to add.

#### Returns

Invisibly returns the CalculationMethodCache object

------------------------------------------------------------------------

### `CalculationMethodCache$remove()`

Remove a method name from the cache. If \`method\` is not present, the
cache is unchanged. Note the asymmetry with \`\$add()\`: \`\$add()\`
keeps duplicates to mirror the snapshot's raw representation, whereas
\`\$remove()\` deletes every occurrence of \`method\` in a single call.

#### Usage

    CalculationMethodCache$remove(method)

#### Arguments

- `method`:

  Character. Name of the calculation method to remove.

#### Returns

Invisibly returns the CalculationMethodCache object

------------------------------------------------------------------------

### `CalculationMethodCache$to_list()`

Convert the cache back to its raw snapshot representation: a list of
method-name strings, or \`NULL\` when the cache is empty. A list is used
(rather than a character vector) so that single-method caches round-trip
as JSON arrays.

#### Usage

    CalculationMethodCache$to_list()

#### Returns

A list of method-name strings, or \`NULL\` when empty.

------------------------------------------------------------------------

### `CalculationMethodCache$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CalculationMethodCache$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
