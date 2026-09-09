test_that("create_solver_settings happy path", {
  solver <- create_solver_settings(
    abs_tol = 1e-9,
    rel_tol = 1e-9,
    mx_step = 100000
  )

  expect_s3_class(solver, "SolverSettings")
  expect_equal(solver$abs_tol, 1e-9)
  expect_equal(solver$rel_tol, 1e-9)
  expect_equal(solver$mx_step, 100000)
})

test_that("create_solver_settings with no args is empty and JSON-objectish", {
  solver <- create_solver_settings()
  expect_length(solver$data, 0)
  expect_equal(
    as.character(jsonlite::toJSON(solver$data, auto_unbox = TRUE)),
    "{}"
  )
})

test_that("create_solver_settings writes the v81 negative-value field", {
  # Absent means the PK-Sim default (`TRUE`), so only `FALSE` is worth
  # writing; an absent argument must leave the solver empty.
  solver <- create_solver_settings(check_for_negative_values = FALSE)
  expect_identical(solver$data$CheckForNegativeValues, FALSE)
  expect_length(create_solver_settings()$data, 0)
})

test_that("create_solver_settings validates argument types", {
  expect_snapshot(error = TRUE, create_solver_settings(abs_tol = "x"))
  expect_snapshot(error = TRUE, create_solver_settings(use_jacobian = "x"))
  expect_snapshot(error = TRUE, create_solver_settings(mx_step = "x"))
  expect_snapshot(
    error = TRUE,
    create_solver_settings(check_for_negative_values = "x")
  )
})
