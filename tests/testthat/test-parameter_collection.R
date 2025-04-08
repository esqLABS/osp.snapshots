test_that("Individual parameter collection is initialized correctly", {
  # Create individual with parameters in raw data
  raw_data <- list(
    Name = "Test Individual",
    Parameters = list(
      list(
        Path = "Organism|Liver|Volume",
        Value = 1.5,
        Unit = "L"
      ),
      list(
        Path = "Organism|Kidney|GFR",
        Value = 120,
        Unit = "ml/min"
      )
    )
  )

  individual <- Individual$new(raw_data)

  # Test parameters were initialized correctly
  expect_length(individual$parameters, 2)

  # Test parameters have correct class
  expect_s3_class(individual$parameters, "parameter_collection")
  expect_s3_class(individual$parameters, "list")

  # Test parameter values through direct access
  expect_equal(individual$parameters[["Organism|Liver|Volume"]]$value, 1.5)
  expect_equal(individual$parameters[["Organism|Kidney|GFR"]]$value, 120)
})

test_that("Individual parameters can be accessed and modified", {
  # Create individual with parameters
  raw_data <- list(
    Name = "Test Individual",
    Parameters = list(
      list(
        Path = "Organism|Liver|Volume",
        Value = 1.5,
        Unit = "L"
      )
    )
  )

  individual <- Individual$new(raw_data)

  # Test access by name works
  liver_param <- individual$parameters[["Organism|Liver|Volume"]]
  expect_equal(liver_param$value, 1.5)
  expect_equal(liver_param$unit, "L")

  # Test modifying the parameter value
  liver_param$value <- 2.0
  expect_equal(individual$parameters[["Organism|Liver|Volume"]]$value, 2.0)

  # Test adding a new parameter
  new_param <- create_parameter(
    path = "Organism|Kidney|GFR",
    value = 120,
    unit = "ml/min"
  )

  # Add to the parameters collection
  params <- individual$parameters
  params[["Organism|Kidney|GFR"]] <- new_param
  individual$parameters <- params

  # Verify parameters were updated
  expect_length(individual$parameters, 2)
  expect_equal(individual$parameters[["Organism|Kidney|GFR"]]$value, 120)
  expect_equal(individual$parameters[["Organism|Kidney|GFR"]]$unit, "ml/min")

  # Verify raw data is updated
  expect_length(individual$data$Parameters, 2)

  # Check one parameter in raw data
  param_paths <- sapply(individual$data$Parameters, function(p) p$Path)
  expect_true("Organism|Kidney|GFR" %in% param_paths)
})

test_that("Individual with empty parameters still has parameter_collection class", {
  # Create individual with no parameters
  individual <- create_individual(name = "No Parameters")

  # Test empty parameters is still a parameter_collection
  expect_s3_class(individual$parameters, "parameter_collection")
  expect_length(individual$parameters, 0)

  # Test can add parameter
  new_param <- create_parameter(
    path = "Organism|Weight",
    value = 70,
    unit = "kg"
  )

  params <- individual$parameters
  params[["Organism|Weight"]] <- new_param
  individual$parameters <- params

  # Verify parameter was added
  expect_length(individual$parameters, 1)
  expect_equal(individual$parameters[["Organism|Weight"]]$value, 70)
})

test_that("print.parameter_collection produces correct output", {
  # Create parameters
  param1 <- create_parameter(
    path = "Organism|Liver|Volume",
    value = 1.5,
    unit = "L"
  )
  param2 <- create_parameter(
    path = "Organism|Kidney|GFR",
    value = 120,
    unit = "ml/min"
  )

  # Create parameter collection
  params <- list(
    "Organism|Liver|Volume" = param1,
    "Organism|Kidney|GFR" = param2
  )
  class(params) <- c("parameter_collection", "list")

  # Test print output
  expect_snapshot(print(params))

  # Test empty collection
  empty_params <- list()
  class(empty_params) <- c("parameter_collection", "list")
  expect_snapshot(print(empty_params))

  # Test very long path (should be truncated)
  long_path <- paste(rep("Very|Long|Path|", 10), collapse = "")
  param_long <- create_parameter(path = long_path, value = 42, unit = "units")

  params_with_long <- list(
    "Organism|Liver|Volume" = param1,
    "Organism|Kidney|GFR" = param2,
    long_path = param_long
  )
  class(params_with_long) <- c("parameter_collection", "list")

  expect_snapshot(print(params_with_long))
})

test_that("Parameters with NULL units display correctly", {
  # Create test data with a parameter with NULL unit
  raw_data <- list(
    Name = "Test Individual",
    Parameters = list(
      list(
        Path = "Test Parameter",
        Value = 1.0
        # No Unit field
      )
    )
  )

  # Initialize individual with the raw data
  individual <- Individual$new(raw_data)

  # Capture the output
  output <- capture.output(print(individual$parameters))

  # Verify the output contains the parameter
  expect_true(any(grepl("Test Parameter", output)))
  expect_true(any(grepl("1", output)))

  # Test with the complete_individual which has a parameter without unit
  output_complete <- capture.output(print(complete_individual$parameters))

  # Verify the output contains the parameters
  # First parameter without unit
  expect_true(any(grepl(
    "Organism\\|Liver\\|EHC continuous fraction",
    output_complete
  )))
  expect_true(any(grepl("1", output_complete)))

  # Second parameter with all fields
  expect_true(any(grepl("Organism\\|Kidney\\|GFR", output_complete)))
  expect_true(any(grepl("120.5", output_complete)))
  expect_true(any(grepl("ml/min", output_complete)))
})

test_that("Individual print method shows parameters correctly", {
  # Capture the output of complete_individual with multiple parameters
  output <- capture.output(print(complete_individual))

  # Check that both parameters are shown with their values
  expect_true(any(grepl(
    "Organism\\|Liver\\|EHC continuous fraction: 1",
    output
  )))
  expect_true(any(grepl(
    "Organism\\|Kidney\\|GFR: 120.5 ml/min",
    output
  )))

  # Create an individual with a parameter with a value origin
  test_data <- list(
    Name = "Test Individual",
    Parameters = list(
      list(
        Path = "Path With All Fields",
        Value = 42.0,
        Unit = "dimensionless",
        ValueOrigin = list(
          Source = "Testing",
          Description = "This is a test",
          Id = 123
        )
      )
    )
  )

  individual <- Individual$new(test_data)

  # Test the parameter object directly
  param <- individual$parameters[["Path With All Fields"]]
  expect_equal(param$path, "Path With All Fields")
  expect_equal(param$value, 42.0)
  expect_equal(param$unit, "dimensionless")
  expect_equal(param$value_origin$Source, "Testing")
  expect_equal(param$value_origin$Description, "This is a test")
  expect_equal(param$value_origin$Id, 123)

  # Test capturing the print output of this parameter
  param_output <- capture.output(print(param))
  expect_true(any(grepl("Parameter: Path With All Fields", param_output)))
  expect_true(any(grepl("Value: 42", param_output)))
  expect_true(any(grepl("Unit: dimensionless", param_output)))
  expect_true(any(grepl("Source: Testing", param_output)))
  expect_true(any(grepl("Description: This is a test", param_output)))
})
