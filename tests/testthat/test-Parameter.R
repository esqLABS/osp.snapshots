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

test_that("Parameter handles table-based parameters correctly", {
  # Create a table parameter directly
  table_param_data <- list(
    Path = "Fraction (dose)",
    Value = 0.0,
    TableFormula = list(
      Name = "Fraction (dose)",
      XName = "Time",
      XDimension = "Time",
      XUnit = "h",
      YName = "Fraction (dose)",
      YDimension = "Dimensionless",
      UseDerivedValues = TRUE,
      Points = list(
        list(X = 0.0, Y = 0.0, RestartSolver = FALSE),
        list(X = 0.5, Y = 0.2, RestartSolver = FALSE),
        list(X = 1.0, Y = 0.4, RestartSolver = FALSE),
        list(X = 2.0, Y = 0.6, RestartSolver = FALSE),
        list(X = 4.0, Y = 0.8, RestartSolver = FALSE),
        list(X = 8.0, Y = 1.0, RestartSolver = FALSE)
      )
    )
  )

  # Create parameter object
  table_param <- Parameter$new(table_param_data)

  # Test that object is created and is of correct class
  expect_s3_class(table_param, "R6")
  expect_true("Parameter" %in% class(table_param))

  # Test table_formula structure using expect_snapshot
  expect_snapshot({
    str(table_param$table_formula)
  })

  # Test the values of specific points using expect_snapshot
  expect_snapshot({
    cat("First point:\n")
    str(table_param$table_formula$Points[[1]])
    cat("\nLast point:\n")
    str(table_param$table_formula$Points[[6]])
  })

  # Extract all X and Y values for verification
  x_values <- sapply(table_param$table_formula$Points, function(p) p$X)
  y_values <- sapply(table_param$table_formula$Points, function(p) p$Y)

  # Test the X and Y values using expect_snapshot
  expect_snapshot({
    cat("X values: ", glue::glue_collapse(x_values, sep = ", "), "\n")
    cat("Y values: ", glue::glue_collapse(y_values, sep = ", "), "\n")
  })

  # Test print output for table parameter
  expect_snapshot(print(table_param))

  # Test to_df function returns both parameter and points data
  df_result <- table_param$to_df()
  expect_type(df_result, "list")
  expect_true("parameter" %in% names(df_result))
  expect_true("points" %in% names(df_result))

  # Check parameter data structure using expect_snapshot
  expect_snapshot({
    str(df_result$parameter)
  })

  # Check points data structure using expect_snapshot
  expect_snapshot({
    str(df_result$points)
  })
})

test_that("create_parameter creates table parameters correctly", {
  # Create table parameter
  table_param <- create_parameter(
    name = "Fraction (dose)",
    value = 0.0,
    table_points = list(
      list(x = 0.0, y = 0.0),
      list(x = 1.0, y = 0.5),
      list(x = 2.0, y = 0.8),
      list(x = 4.0, y = 1.0)
    ),
    x_name = "Time",
    y_name = "Fraction (dose)",
    x_unit = "h",
    x_dimension = "Time",
    y_dimension = "Dimensionless"
  )

  # Test the structure of the created parameter using expect_snapshot
  expect_snapshot({
    str(table_param$data)
  })

  # Test print output
  expect_snapshot(print(table_param))
})

test_that("Parameter table_formula can be modified", {
  # Create parameter object
  param <- create_parameter(
    name = "Test",
    value = 0,
    table_points = list(
      list(x = 0, y = 0),
      list(x = 1, y = 1)
    )
  )

  # Test initial table formula
  expect_equal(length(param$table_formula$Points), 2)

  # Modify table formula
  new_table_formula <- list(
    Name = "Modified",
    XName = "NewX",
    YName = "NewY",
    XUnit = "min",
    Points = list(
      list(X = 0, Y = 0, RestartSolver = FALSE),
      list(X = 1, Y = 0.5, RestartSolver = FALSE),
      list(X = 2, Y = 1, RestartSolver = FALSE)
    )
  )

  param$table_formula <- new_table_formula
  expect_equal(param$table_formula, new_table_formula)
  expect_equal(param$table_formula$XName, "NewX")
  expect_equal(length(param$table_formula$Points), 3)

  # Remove table formula
  param$table_formula <- NULL
  expect_null(param$table_formula)
})

test_that("to_df method correctly handles table parameters", {
  # Create a table parameter with defined x and y values
  test_param <- create_parameter(
    name = "Dissolution Profile",
    value = 0.0,
    table_points = list(
      list(x = 0.0, y = 0.0),
      list(x = 0.25, y = 0.1),
      list(x = 0.5, y = 0.3),
      list(x = 1.0, y = 0.6),
      list(x = 2.0, y = 0.9),
      list(x = 3.0, y = 1.0)
    ),
    x_name = "Time",
    y_name = "Fraction Released",
    x_unit = "h",
    x_dimension = "Time",
    y_dimension = "Dimensionless"
  )

  # Test the to_df conversion
  result <- test_param$to_df()

  # Verify the result structure
  expect_type(result, "list")
  expect_length(result, 2)
  expect_true(all(c("parameter", "points") %in% names(result)))

  # Use expect_snapshot to verify the parameter dataframe
  expect_snapshot({
    print(result$parameter)
  })

  # Use expect_snapshot to verify the points dataframe
  expect_snapshot({
    print(result$points)
  })

  # Test converting to a data frame for plotting
  plot_data <- result$points

  # Verify structure with expect_snapshot
  expect_snapshot({
    str(plot_data)
  })

  # Verify min/max values for plot data
  expect_snapshot({
    cat("X range:", min(plot_data$x), "to", max(plot_data$x), "\n")
    cat("Y range:", min(plot_data$y), "to", max(plot_data$y), "\n")
  })
})

test_that("Regular parameters handle to_df correctly after table support added", {
  # Create a regular parameter
  regular_param <- create_parameter(
    name = "Regular Param",
    value = 42,
    unit = "mg",
    source = "Test"
  )

  # Test to_df returns a dataframe directly for regular parameters
  df_result <- regular_param$to_df()

  # Use expect_snapshot to verify dataframe content
  expect_snapshot({
    print(df_result)
  })
})
