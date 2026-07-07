# Create a new observer set

Create an
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md)
building block from named arguments. This is a thin factory around
`ObserverSet$new()` that builds the raw list shape for you.

An
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md)
bundles a collection of
[Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
objects (each one a simulation-time formula that computes a derived
quantity from the underlying model) so a simulation can reference the
whole bundle by name.

## Usage

``` r
create_observer_set(name, observers = NULL)
```

## Arguments

- name:

  Character. Name of the observer set (required).

- observers:

  List of
  [Observer](https://esqlabs.github.io/osp.snapshots/reference/Observer.md)
  objects or raw observer lists to include in the set. Entries that
  inherit from `Observer` contribute their underlying raw data; other
  entries are assumed to already be raw observer lists.

## Value

An
[ObserverSet](https://esqlabs.github.io/osp.snapshots/reference/ObserverSet.md)
object.

## Examples

``` r
# Create an empty observer set
empty_set <- create_observer_set(name = "BrainPlasmaConcentration")

# Create an observer set from raw observer lists
raw_set <- create_observer_set(
  name = "BrainPlasmaConcentration",
  observers = list(
    list(
      Name = "brain_plasma_conc",
      Type = "Container",
      Dimension = "Concentration (molar)",
      Formula = list(Formula = "Conc_Br")
    )
  )
)

# Create an observer set from Observer R6 objects
observer <- Observer$new(list(
  Name = "brain_plasma_conc",
  Type = "Container",
  Dimension = "Concentration (molar)",
  Formula = list(Formula = "Conc_Br")
))
observer_set <- create_observer_set(
  name = "BrainPlasmaConcentration",
  observers = list(observer)
)
```
