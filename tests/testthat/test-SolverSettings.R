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

test_that("SolverSettings numeric fields reject non-numeric or non-scalar values", {
  solver <- SolverSettings$new(list())
  for (field in c("abs_tol", "rel_tol", "h0", "h_min", "h_max")) {
    expect_snapshot(error = TRUE, solver[[field]] <- "x")
    expect_snapshot(error = TRUE, solver[[field]] <- c(1, 2))
  }
})

test_that("SolverSettings$use_jacobian requires a single logical", {
  solver <- SolverSettings$new(list())
  solver$use_jacobian <- TRUE
  expect_true(solver$use_jacobian)
  expect_snapshot(error = TRUE, solver$use_jacobian <- 1)
})

test_that("SolverSettings$mx_step requires a single positive whole number", {
  solver <- SolverSettings$new(list())
  solver$mx_step <- 100000
  expect_identical(solver$mx_step, 100000L)
  expect_snapshot(error = TRUE, solver$mx_step <- 3.5)
  expect_snapshot(error = TRUE, solver$mx_step <- 0)
  expect_snapshot(error = TRUE, solver$mx_step <- -1)
})

test_that("SolverSettings$mx_step rejects values beyond the integer range", {
  solver <- SolverSettings$new(list())
  expect_snapshot(error = TRUE, solver$mx_step <- 3e9)
  solver$mx_step <- .Machine$integer.max
  expect_identical(solver$mx_step, .Machine$integer.max)
})

test_that("SolverSettings fields accept NULL to clear", {
  solver <- SolverSettings$new(list(AbsTol = 1e-6, MxStep = 100L))
  solver$abs_tol <- NULL
  expect_null(solver$abs_tol)
  solver$mx_step <- NULL
  expect_null(solver$mx_step)
})
