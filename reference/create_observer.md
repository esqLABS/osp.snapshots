# Create a new observer

Create a single
[Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
from named arguments. This is a thin factory around `Observer$new()`
that builds the raw list shape for you and composes with
[`create_observer_set()`](https://esqlabs.github.io/osp.snapshots/reference/create_observer_set.md)
via `create_observer_set(observers = list(...))`.

An observer is a simulation-time formula that computes a derived
quantity from the underlying model (for example an amount observer or a
container observer). It is not itself a building block; it lives inside
an
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md).

## Usage

``` r
create_observer(
  name,
  type,
  dimension = NULL,
  formula = NULL,
  formula_references = NULL,
  container_criteria = NULL,
  molecule_list = NULL
)
```

## Arguments

- name:

  Character. Name of the observer (required).

- type:

  Character. The observer type, one of `"Amount"` (an
  `AmountObserverBuilder`) or `"Container"` (a
  `ContainerObserverBuilder`). Any other value aborts (required).

- dimension:

  Character. The dimension of the observed quantity. Omitted when
  `NULL`.

- formula:

  The observer's formula. Either a bare expression string (which becomes
  the inner `Formula$Formula`), or a full `ExplicitFormula` raw list
  used as the whole `Formula`. Omitted when `NULL`.

- formula_references:

  List of formula references, each a
  [`create_formula_reference()`](https://esqlabs.github.io/osp.snapshots/reference/create_formula_reference.md)
  output or an equivalent raw `{Alias, Path, Dimension}` list. Written
  to the formula's `References`; supplying these without `formula`
  yields a `Formula` carrying only `References`. When `formula` is a
  full `ExplicitFormula` list that already carries its own `References`,
  this argument overrides them. Omitted when `NULL`.

- container_criteria:

  List of container criteria, each a
  [`create_descriptor_condition()`](https://esqlabs.github.io/osp.snapshots/reference/create_descriptor_condition.md)
  output or an equivalent raw `{Tag, Type}` list. Written to
  `ContainerCriteria`. Omitted when `NULL`.

- molecule_list:

  A
  [`create_molecule_list()`](https://esqlabs.github.io/osp.snapshots/reference/create_molecule_list.md)
  output or an equivalent raw list. Written to `MoleculeList`. Omitted
  when `NULL`.

## Value

An
[Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
object.

## Examples

``` r
# Minimal amount observer
create_observer(name = "drug_amount", type = "Amount")
#> 
#> ── Observer: drug_amount 
#> • Type: Amount

# Container observer with all sub-properties
obs <- create_observer(
  name = "brain_plasma_conc",
  type = "Container",
  dimension = "Concentration (molar)",
  formula = "Conc_Br",
  formula_references = list(
    create_formula_reference(
      "Conc_Br",
      "Organism|Brain|Plasma|Drug|Concentration"
    )
  ),
  container_criteria = list(
    create_descriptor_condition("Brain", "InContainer")
  ),
  molecule_list = create_molecule_list(for_all = FALSE, include = "Drug")
)

# Compose into an observer set
create_observer_set(name = "BrainPlasmaConcentration", observers = list(obs))
#> 
#> ── ObserverSet: BrainPlasmaConcentration ───────────────────────────────────────
#> • 1 observer
```
