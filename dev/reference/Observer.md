# Observer class for OSP snapshot observer sets

An R6 class that represents a single observer inside an
[ObserverSet](https://esqlabs.github.io/osp.snapshots/dev/reference/ObserverSet.md).
An observer is a simulation-time formula that computes a derived
quantity from the underlying model (for example an amount observer or a
container observer), used to expose values that are not natural model
outputs.

In an OSP snapshot, each observer is one entry of the `Observers` array
nested inside an `ObserverSets` building block. An observer is not
itself a building block; it lives inside an `ObserverSet`.

## Active bindings

- `data`:

  The raw `Observer` list as it appears in the snapshot JSON
  (read-only).

- `name`:

  The name of the observer.

- `type`:

  The observer type. PK-Sim recognises `"Amount"` (an
  `AmountObserverBuilder`) and `"Container"` (a
  `ContainerObserverBuilder`).

- `dimension`:

  The dimension of the observed quantity, resolved in PK-Sim via
  `IDimensionRepository.DimensionByName()`.

- `formula`:

  The formula expression string. Read from the inner `Formula$Formula`
  field of the underlying `ExplicitFormula` object; this binding does
  not expose `References` or `Dimension`. Setting this field writes back
  to `Formula$Formula` only. To access the full `ExplicitFormula`, use
  `observer$data$Formula`.

- `container_tags`:

  The `Tag` values from the observer's `ContainerCriteria`, joined with
  `|`. There is no `ContainerPath` field in the snapshot JSON; this
  binding is synthesized from the tags found in `ContainerCriteria`.
  `NULL` when the observer carries no container criteria.

## Methods

### Public methods

- [`Observer$new()`](#method-Observer-initialize)

- [`Observer$print()`](#method-Observer-print)

- [`Observer$to_df()`](#method-Observer-to_df)

- [`Observer$clone()`](#method-Observer-clone)

------------------------------------------------------------------------

### `Observer$new()`

Create a new Observer object.

#### Usage

    Observer$new(data = list())

#### Arguments

- `data`:

  Raw `Observer` list from a snapshot. May be `NULL` or an empty list,
  both of which create an empty observer.

#### Returns

A new Observer object

------------------------------------------------------------------------

### `Observer$print()`

Print a short summary of the observer.

#### Usage

    Observer$print(...)

#### Arguments

- `...`:

  Additional arguments (unused).

#### Returns

Invisibly returns the Observer object.

------------------------------------------------------------------------

### `Observer$to_df()`

Convert the observer to a single-row tibble suitable for the
tibble-layer exporter. Columns are `name`, `type`, `dimension`,
`formula`, and `container_tags`.

#### Usage

    Observer$to_df()

#### Returns

A tibble with one row.

------------------------------------------------------------------------

### `Observer$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Observer$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
observer <- Observer$new(list(
  Name = "brain_plasma_conc",
  Type = "Container",
  Dimension = "Concentration (molar)",
  Formula = list(Formula = "Conc_Br")
))
observer$name
#> [1] "brain_plasma_conc"
observer$type
#> [1] "Container"
observer$dimension
#> [1] "Concentration (molar)"
```
