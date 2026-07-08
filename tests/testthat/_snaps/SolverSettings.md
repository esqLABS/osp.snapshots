# SolverSettings numeric fields reject non-numeric or non-scalar values

    Code
      solver[[field]] <- "x"
    Condition
      Error:
      ! `abs_tol` must be a single numeric value

---

    Code
      solver[[field]] <- c(1, 2)
    Condition
      Error:
      ! `abs_tol` must be a single numeric value

---

    Code
      solver[[field]] <- "x"
    Condition
      Error:
      ! `rel_tol` must be a single numeric value

---

    Code
      solver[[field]] <- c(1, 2)
    Condition
      Error:
      ! `rel_tol` must be a single numeric value

---

    Code
      solver[[field]] <- "x"
    Condition
      Error:
      ! `h0` must be a single numeric value

---

    Code
      solver[[field]] <- c(1, 2)
    Condition
      Error:
      ! `h0` must be a single numeric value

---

    Code
      solver[[field]] <- "x"
    Condition
      Error:
      ! `h_min` must be a single numeric value

---

    Code
      solver[[field]] <- c(1, 2)
    Condition
      Error:
      ! `h_min` must be a single numeric value

---

    Code
      solver[[field]] <- "x"
    Condition
      Error:
      ! `h_max` must be a single numeric value

---

    Code
      solver[[field]] <- c(1, 2)
    Condition
      Error:
      ! `h_max` must be a single numeric value

# SolverSettings$use_jacobian requires a single logical

    Code
      solver$use_jacobian <- 1
    Condition
      Error:
      ! `use_jacobian` must be a single logical value

# SolverSettings$mx_step requires a single positive whole number

    Code
      solver$mx_step <- 3.5
    Condition
      Error:
      ! `mx_step` must be a single positive whole number

---

    Code
      solver$mx_step <- 0
    Condition
      Error:
      ! `mx_step` must be a single positive whole number

---

    Code
      solver$mx_step <- -1
    Condition
      Error:
      ! `mx_step` must be a single positive whole number

# SolverSettings$mx_step rejects values beyond the integer range

    Code
      solver$mx_step <- 3e+09
    Condition
      Error:
      ! `mx_step` must be a single positive whole number

