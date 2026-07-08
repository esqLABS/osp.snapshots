# Create compound properties for a simulation

Build a
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
entry, used inside a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md)
to configure a
[Compound](https://esqlabs.github.io/osp.snapshots/dev/reference/Compound.md)
building block: which calculation methods to apply, which alternatives,
processes, and protocol to use. Internal machinery only:
[`add_simulation()`](https://esqlabs.github.io/osp.snapshots/dev/reference/add_simulation.md)'s
inline `compounds` argument (a friendly config list, with `alternatives`
selected by property name and label) is the user-facing way to configure
a compound for a simulation; this constructor is not part of the public
API.

## Usage

``` r
create_compound_properties(
  name,
  calculation_methods = NULL,
  alternatives = NULL,
  processes = NULL,
  protocol = NULL
)
```

## Arguments

- name:

  Character. Name of the compound building block (required).

- calculation_methods:

  Character vector. Calculation method names that override the
  compound's defaults for this simulation.

- alternatives:

  List of
  [CompoundGroupSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundGroupSelection.md)
  objects or raw lists.

- processes:

  List of
  [CompoundProcessSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProcessSelection.md)
  objects or raw lists.

- protocol:

  A
  [ProtocolSelection](https://esqlabs.github.io/osp.snapshots/dev/reference/ProtocolSelection.md)
  object or raw list.

## Value

A
[CompoundProperties](https://esqlabs.github.io/osp.snapshots/dev/reference/CompoundProperties.md)
object.
