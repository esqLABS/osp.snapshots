# create_solver_settings validates argument types

    Code
      create_solver_settings(abs_tol = "x")
    Condition
      Error in `create_solver_settings()`:
      ! `abs_tol` must be a single numeric value

---

    Code
      create_solver_settings(use_jacobian = "x")
    Condition
      Error in `create_solver_settings()`:
      ! `use_jacobian` must be a single logical value

---

    Code
      create_solver_settings(mx_step = "x")
    Condition
      Error in `create_solver_settings()`:
      ! `mx_step` must be a single positive whole number

