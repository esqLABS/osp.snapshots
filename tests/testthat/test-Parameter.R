test_that("Parameter class initialization works", {
  # Create test data
  param_data <- list(
    Path = "Organism|Liver|Volume",
    Value = 1.5,
    Unit = "L",
    ValueOrigin = list(
      Source = "Publication",
      Description = "Test reference"
    )
  )

  # Create parameter object
  param <- Parameter$new(param_data)

  # Test that object is created and is of correct class
  expect_s3_class(param, "R6")
  expect_true("Parameter" %in% class(param))

  # Test that data is stored correctly
  expect_equal(param$data, param_data)
})

test_that("Parameter active bindings work correctly", {
  # Create parameter object
  param <- Parameter$new(list(
    Path = "Organism|Liver|Volume",
    Value = 1.5,
    Unit = "L",
    ValueOrigin = list(
      Source = "Publication",
      Description = "Test reference"
    )
  ))

  # Test each active binding
  expect_equal(param$name, "Organism|Liver|Volume")
  expect_equal(param$value, 1.5)
  expect_equal(param$unit, "L")
  expect_equal(
    param$value_origin,
    list(Source = "Publication", Description = "Test reference")
  )
})

test_that("Parameter print method returns formatted output", {
  # Create parameter object
  param <- Parameter$new(list(
    Path = "Organism|Liver|Volume",
    Value = 1.5,
    Unit = "L",
    ValueOrigin = list(
      Source = "Publication",
      Description = "Test reference"
    )
  ))

  # Test print output
  expect_snapshot(print(param))
})

test_that("create_parameter creates parameters correctly", {
  # Test basic parameter
  basic_param <- create_parameter(
    name = "Organism|Liver|Volume",
    value = 1.5
  )
  expect_s3_class(basic_param, "Parameter")
  expect_equal(basic_param$name, "Organism|Liver|Volume")
  expect_equal(basic_param$value, 1.5)
  expect_null(basic_param$unit)
  expect_null(basic_param$value_origin)

  # Test parameter with unit
  unit_param <- create_parameter(
    name = "Organism|Liver|Volume",
    value = 1.5,
    unit = "L"
  )
  expect_equal(unit_param$unit, "L")

  # Test parameter with value origin
  full_param <- create_parameter(
    name = "Organism|Liver|Volume",
    value = 1.5,
    unit = "L",
    source = "Publication",
    description = "Test reference",
    source_id = 123
  )
  expect_equal(
    full_param$value_origin,
    list(
      Source = "Publication",
      Description = "Test reference",
      Id = 123
    )
  )
})

test_that("Parameter fields can be modified", {
  # Create parameter object
  param <- create_parameter(
    name = "Organism|Liver|Volume",
    value = 1.5
  )

  # Test modifying name
  param$name <- "Organism|Liver|Weight"
  expect_equal(param$name, "Organism|Liver|Weight")

  # Test modifying value
  param$value <- 2.0
  expect_equal(param$value, 2.0)

  # Test modifying unit
  param$unit <- "kg"
  expect_equal(param$unit, "kg")

  # Test modifying value origin
  param$value_origin <- list(Source = "Database")
  expect_equal(param$value_origin, list(Source = "Database"))

  # Test modifying value origin with additional info
  param$value_origin <- list(Description = "Test")
  expect_equal(
    param$value_origin,
    list(Source = "Database", Description = "Test")
  )

  # Test removing value origin
  param$value_origin <- NULL
  expect_null(param$value_origin)
})
