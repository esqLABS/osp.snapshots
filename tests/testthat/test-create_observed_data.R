test_that("create_observed_data creates a DataSet with time and values", {
  obs <- create_observed_data(
    name = "Subject 001",
    time = time(c(0, 1, 2, 4, 8)),
    values = values(c(0, 12, 18, 11, 5), dimension = "Concentration (mass)")
  )

  expect_s3_class(obs, "DataSet")
  expect_equal(obs$name, "Subject 001")
  expect_equal(obs$xValues, c(0, 1, 2, 4, 8), tolerance = 1e-5)
  expect_equal(obs$yValues, c(0, 12, 18, 11, 5), tolerance = 1e-5)
})

test_that("create_observed_data stores error series and metadata", {
  obs <- create_observed_data(
    name = "Subject 001",
    time = time(c(0, 1, 2, 4, 8), unit = "h"),
    values = values(
      c(0, 12, 18, 11, 5),
      unit = "mg/l",
      dimension = "Concentration (mass)"
    ),
    error = error(c(0, 1.2, 1.5, 1.1, 0.6), type = "ArithmeticStdDev")
  )

  expect_equal(obs$yErrorValues, c(0, 1.2, 1.5, 1.1, 0.6), tolerance = 1e-5)
  expect_equal(obs$yErrorType, "ArithmeticStdDev")
  expect_equal(obs$yUnit, "mg/l")
})

test_that("create_observed_data validates required arguments", {
  expect_snapshot(error = TRUE, create_observed_data())
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = time(1:4),
      values = values(1:5, dimension = "Concentration (mass)")
    )
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = time(1:3),
      values = values(1:3, dimension = "Concentration (mass)"),
      error = error(1:2)
    )
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = time(1:3),
      values = values(1:3, dimension = "Concentration (mass)"),
      metadata = list("missing-key")
    )
  )
})

test_that("create_observed_data rejects a plain vector or the wrong helper", {
  expect_snapshot(
    error = TRUE,
    create_observed_data(
      name = "X",
      time = 1:3,
      values = values(1:3, dimension = "Concentration (mass)")
    )
  )
  expect_snapshot(
    error = TRUE,
    create_observed_data(name = "X", time = time(1:3), values = time(1:3))
  )
})

test_that("values() requires a dimension", {
  # The required-dimension error now surfaces at the values() call.
  expect_snapshot(error = TRUE, values(1:3))
})

test_that("create_observed_data validates time and value units", {
  # Unit validation now happens in the time()/values() helpers.
  expect_snapshot(error = TRUE, time(1:3, unit = "not-a-unit"))
  expect_snapshot(
    error = TRUE,
    values(1:3, unit = "not-a-unit", dimension = "Concentration (mass)")
  )
})
