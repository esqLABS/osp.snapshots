# SolverSettings class for simulation solver configuration

An R6 class representing the `Solver` block of a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md).
Each field is optional and inherits the PK-Sim solver default when
absent; the underlying raw data list stays sparse so missing fields
remain absent on export.

## Active bindings

- `data`:

  The raw data of the solver settings (read-only). An empty solver is
  always returned as a named-empty list so the JSON serialiser writes it
  as [`{}`](https://rdrr.io/r/base/Paren.html) (an object), not `[]` (an
  array). PK-Sim's snapshot mapper requires the object shape.

- `abs_tol`:

  Absolute solver tolerance. Writable: a single numeric value, or `NULL`
  to clear.

- `rel_tol`:

  Relative solver tolerance. Writable: a single numeric value, or `NULL`
  to clear.

- `use_jacobian`:

  Whether to use the Jacobian during integration. Writable: a single
  logical value, or `NULL` to clear.

- `h0`:

  Initial step size. Writable: a single numeric value, or `NULL` to
  clear.

- `h_min`:

  Minimum step size. Writable: a single numeric value, or `NULL` to
  clear.

- `h_max`:

  Maximum step size. Writable: a single numeric value, or `NULL` to
  clear.

- `mx_step`:

  Maximum number of internal solver steps. Writable: a single positive
  whole number (stored as an integer), or `NULL` to clear.

## Methods

### Public methods

- [`SolverSettings$new()`](#method-SolverSettings-initialize)

- [`SolverSettings$clone()`](#method-SolverSettings-clone)

------------------------------------------------------------------------

### `SolverSettings$new()`

Create a new SolverSettings object.

#### Usage

    SolverSettings$new(data)

#### Arguments

- `data`:

  Raw `Solver` data from a snapshot (may be an empty list).

#### Returns

A new SolverSettings object.

------------------------------------------------------------------------

### `SolverSettings$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SolverSettings$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
