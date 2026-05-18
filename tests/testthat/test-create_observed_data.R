test_that("create_observed_data creates a DataSet with time and values", {
  obs <- create_observed_data(
    name = "Subject 001",
    time = c(0, 1, 2, 4, 8),
    values = c(0, 12, 18, 11, 5),
    value_dimension = "Concentration (mass)"
  )

  expect_s3_class(obs, "DataSet")
  expect_equal(obs$name, "Subject 001")
  expect_equal(obs$xValues, c(0, 1, 2, 4, 8), tolerance = 1e-5)
  expect_equal(obs$yValues, c(0, 12, 18, 11, 5), tolerance = 1e-5)
})

test_that("create_observed_data stores error series and metadata", {
  obs <- create_observed_data(
    name = "Subject 001",
    time = c(0, 1, 2, 4, 8),
    values = c(0, 12, 18, 11, 5),
    time_unit = "h",
    value_unit = "mg/l",
    value_dimension = "Concentration (mass)",
    error = c(0, 1.2, 1.5, 1.1, 0.6),
    error_type = "ArithmeticStdDev"
  )

  expect_equal(obs$yErrorValues, c(0, 1.2, 1.5, 1.1, 0.6), tolerance = 1e-5)
  expect_equal(obs$yErrorType, "ArithmeticStdDev")
  expect_equal(obs$yUnit, "mg/l")
})

test_that("create_observed_data validates required arguments", {
  expect_snapshot(error = TRUE, create_observed_data())
  expect_snapshot(
    error = TRUE,
    create_observed_data(name = "X", time = numeric(), values = numeric())
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(name = "X", time = 1:5, values = 1:4)
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(name = "X", time = 1:3, values = 1:3)
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = 1:3,
      values = 1:3,
      value_dimension = "Concentration (mass)",
      error = 1:2
    )
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = 1:3,
      values = 1:3,
      value_dimension = "Concentration (mass)",
      metadata = list("missing-key")
    )
  )
})

test_that("create_observed_data validates time and value units", {
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = 1:3,
      values = 1:3,
      time_unit = "not-a-unit",
      value_dimension = "Concentration (mass)"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = 1:3,
      values = 1:3,
      value_dimension = "Concentration (mass)",
      value_unit = "not-a-unit"
    )
  )
})
