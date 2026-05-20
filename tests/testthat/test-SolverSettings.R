test_that("SolverSettings exposes every field", {
  raw <- list(
    AbsTol = 1e-9,
    RelTol = 1e-9,
    UseJacobian = TRUE,
    H0 = 1e-5,
    HMin = 1e-10,
    HMax = 60,
    MxStep = 100000
  )
  solver <- SolverSettings$new(raw)

  expect_s3_class(solver, "SolverSettings")
  expect_equal(solver$abs_tol, 1e-9)
  expect_equal(solver$rel_tol, 1e-9)
  expect_identical(solver$use_jacobian, TRUE)
  expect_equal(solver$h0, 1e-5)
  expect_equal(solver$h_min, 1e-10)
  expect_equal(solver$h_max, 60)
  expect_equal(solver$mx_step, 100000)
  expect_identical(solver$data, raw)
})

test_that("SolverSettings handles empty data with object-shape JSON", {
  solver <- SolverSettings$new(list())
  expect_null(solver$abs_tol)
  expect_length(solver$data, 0)
  # jsonlite must write the empty solver as `{}` (object) not `[]` (array);
  # PK-Sim's snapshot mapper silently rejects simulations with `Solver: []`.
  expect_equal(
    as.character(jsonlite::toJSON(solver$data, auto_unbox = TRUE)),
    "{}"
  )
})

test_that("SolverSettings handles NULL data with object-shape JSON", {
  solver <- SolverSettings$new(NULL)
  expect_length(solver$data, 0)
  expect_equal(
    as.character(jsonlite::toJSON(solver$data, auto_unbox = TRUE)),
    "{}"
  )
})

test_that("SolverSettings setters mutate raw data", {
  solver <- SolverSettings$new(list())
  solver$abs_tol <- 1e-6
  expect_equal(solver$data$AbsTol, 1e-6)
})
