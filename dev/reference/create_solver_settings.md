# Create a solver settings object for a simulation

Build a
[SolverSettings](https://esqlabs.github.io/osp.snapshots/dev/reference/SolverSettings.md)
object, used inside a
[Simulation](https://esqlabs.github.io/osp.snapshots/dev/reference/Simulation.md).
All arguments are optional; absent fields fall back to PK-Sim solver
defaults at load time.

## Usage

``` r
create_solver_settings(
  abs_tol = NULL,
  rel_tol = NULL,
  use_jacobian = NULL,
  h0 = NULL,
  h_min = NULL,
  h_max = NULL,
  mx_step = NULL
)
```

## Arguments

- abs_tol:

  Numeric. Absolute solver tolerance.

- rel_tol:

  Numeric. Relative solver tolerance.

- use_jacobian:

  Logical. Whether to use the Jacobian during integration.

- h0:

  Numeric. Initial step size.

- h_min:

  Numeric. Minimum step size.

- h_max:

  Numeric. Maximum step size.

- mx_step:

  Integer. Maximum number of internal solver steps.

## Value

A
[SolverSettings](https://esqlabs.github.io/osp.snapshots/dev/reference/SolverSettings.md)
object.

## Examples

``` r
create_solver_settings()
#> <SolverSettings>
#>   Public:
#>     abs_tol: active binding
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     h0: active binding
#>     h_max: active binding
#>     h_min: active binding
#>     initialize: function (data) 
#>     mx_step: active binding
#>     rel_tol: active binding
#>     use_jacobian: active binding
#>   Private:
#>     .data: list

create_solver_settings(abs_tol = 1e-9, rel_tol = 1e-9, mx_step = 100000)
#> <SolverSettings>
#>   Public:
#>     abs_tol: active binding
#>     clone: function (deep = FALSE) 
#>     data: active binding
#>     h0: active binding
#>     h_max: active binding
#>     h_min: active binding
#>     initialize: function (data) 
#>     mx_step: active binding
#>     rel_tol: active binding
#>     use_jacobian: active binding
#>   Private:
#>     .data: list
```
