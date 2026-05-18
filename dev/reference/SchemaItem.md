# SchemaItem class for OSP advanced protocols

An R6 class that represents one application inside a \[Schema\] of an
Advanced \[Protocol\]. A schema item carries an application type, an
optional formulation key, target organ and compartment, and the
application-level parameters (dose, start time, ...).

In an OSP snapshot, each schema item is one entry of the \`SchemaItems\`
array nested inside a \`Schemas\` entry of a \`Protocols\` building
block.

## Active bindings

- `data`:

  The raw \`SchemaItem\` list as it appears in the snapshot JSON,
  refreshed from the wrapped parameters (read-only).

- `name`:

  The name of the schema item.

- `application_type`:

  The application type of the schema item (for example \`"Oral"\`,
  \`"IntravenousBolus"\`).

- `formulation_key`:

  The formulation key, linking the schema item to a formulation
  selection in the owning simulation.

- `target_organ`:

  The target organ for the application.

- `target_compartment`:

  The target compartment for the application.

- `parameters`:

  The schema item's application-level \[Parameter\] objects (dose, start
  time, ...).

## Methods

### Public methods

- [`SchemaItem$new()`](#method-SchemaItem-initialize)

- [`SchemaItem$print()`](#method-SchemaItem-print)

- [`SchemaItem$clone()`](#method-SchemaItem-clone)

------------------------------------------------------------------------

### `SchemaItem$new()`

Create a new SchemaItem object.

#### Usage

    SchemaItem$new(data = list())

#### Arguments

- `data`:

  Raw \`SchemaItem\` list from a snapshot. May be \`NULL\` or an empty
  list, both of which create an empty schema item.

#### Returns

A new SchemaItem object

------------------------------------------------------------------------

### `SchemaItem$print()`

Print a summary of the schema item.

#### Usage

    SchemaItem$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the SchemaItem object

------------------------------------------------------------------------

### `SchemaItem$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SchemaItem$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
