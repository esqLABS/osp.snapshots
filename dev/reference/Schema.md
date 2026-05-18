# Schema class for OSP advanced protocols

An R6 class that represents a repeatable block inside an Advanced
\[Protocol\]. A schema has its own name, schema-level parameters
(typically \`Start time\`, \`NumberOfRepetitions\`,
\`TimeBetweenRepetitions\`), and an ordered list of \[SchemaItem\]
applications.

In an OSP snapshot, each schema is one entry of the \`Schemas\` array
inside a \`Protocols\` building block.

## Active bindings

- `data`:

  The raw \`Schema\` list as it appears in the snapshot JSON, refreshed
  from the wrapped schema items and parameters (read-only).

- `name`:

  The name of the schema.

- `parameters`:

  The schema-level \[Parameter\] objects (number of repetitions, time
  between repetitions, ...).

- `items`:

  List of \[SchemaItem\] objects in the schema, in declaration order.

## Methods

### Public methods

- [`Schema$new()`](#method-Schema-initialize)

- [`Schema$print()`](#method-Schema-print)

- [`Schema$clone()`](#method-Schema-clone)

------------------------------------------------------------------------

### `Schema$new()`

Create a new Schema object.

#### Usage

    Schema$new(data = list())

#### Arguments

- `data`:

  Raw \`Schema\` list from a snapshot. May be \`NULL\` or an empty list,
  both of which create an empty schema.

#### Returns

A new Schema object

------------------------------------------------------------------------

### `Schema$print()`

Print a summary of the schema.

#### Usage

    Schema$print(...)

#### Arguments

- `...`:

  Additional arguments passed to print methods

#### Returns

Invisibly returns the Schema object

------------------------------------------------------------------------

### `Schema$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Schema$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
