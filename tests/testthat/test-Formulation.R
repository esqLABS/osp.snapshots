# ---- Formulation logic tests ----
test_that("Formulation class initialization works", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get any formulation from test snapshot
  test_formulation <- snapshot_clone$formulations[[1]]

  # Ensure we found a formulation
  expect_false(is.null(test_formulation))

  # Test that object is of correct class
  expect_s3_class(test_formulation, "R6")
  expect_true("Formulation" %in% class(test_formulation))
})

test_that("Formulation active bindings work correctly", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get any formulation from test snapshot
  test_formulation <- snapshot_clone$formulations[[1]]

  # Ensure we found a formulation
  expect_false(is.null(test_formulation))

  # Test that formulation type is accessible
  expect_type(test_formulation$formulation_type, "character")
  expect_true(nchar(test_formulation$formulation_type) > 0)

  # Test that parameters have the correct class
  expect_s3_class(
    test_formulation$parameters,
    "parameter_collection"
  )

  # Test that each parameter is a Parameter object if there are parameters
  if (length(test_formulation$parameters) > 0) {
    expect_true(all(sapply(
      test_formulation$parameters,
      function(p) inherits(p, "Parameter")
    )))
  }
})

test_that("Formulation print method returns formatted output", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get the first formulation
  formulation1 <- snapshot_clone$formulations[[1]]

  # Get the second formulation (if available)
  formulation2 <- NULL
  if (length(snapshot_clone$formulations) > 1) {
    formulation2 <- snapshot_clone$formulations[[2]]
  }

  # Get a formulation with parameters (if available)
  formulation_with_params <- NULL
  for (form in snapshot_clone$formulations) {
    if (length(form$parameters) > 0) {
      formulation_with_params <- form
      break
    }
  }

  # Ensure we found at least one formulation
  expect_false(is.null(formulation1))

  # Test print output for first formulation
  expect_snapshot(print(formulation1))

  # Test print output for second formulation if available
  if (!is.null(formulation2)) {
    expect_snapshot(print(formulation2))
  }

  # Test print output for formulation with parameters if available and different from formulation1
  if (
    !is.null(formulation_with_params) &&
      formulation_with_params$name != formulation1$name
  ) {
    expect_snapshot(print(formulation_with_params))
  }
})

test_that("Formulation handles table-based formulations correctly", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get table formulation from test snapshot
  table_formulation <- NULL
  for (form in snapshot_clone$formulations) {
    if (form$formulation_type == "Formulation_Table") {
      table_formulation <- form
      break
    }
  }

  # Skip test if no table formulation is found
  if (is.null(table_formulation)) {
    skip("No table formulation found in test_snapshot")
  }

  # Ensure formulation type is correct
  expect_equal(table_formulation$formulation_type, "Formulation_Table")

  # Test print output for table formulation
  expect_snapshot(print(table_formulation))

  # Test dataframe conversion for table formulation
  expect_snapshot(table_formulation$to_df())
})

test_that("Formulation fields can be modified through active bindings", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get any formulation from test snapshot
  test_formulation <- snapshot_clone$formulations[[1]]$clone()

  # Ensure we found a formulation
  expect_false(is.null(test_formulation))

  # Test modifying name
  original_name <- test_formulation$name
  test_formulation$name <- "Modified Formulation"
  expect_equal(test_formulation$name, "Modified Formulation")

  # Test modifying formulation type
  original_type <- test_formulation$formulation_type
  # Find a different valid type to change to
  new_type <- NULL
  for (type in VALID_FORMULATION_TYPES) {
    if (type != original_type) {
      new_type <- type
      break
    }
  }

  if (!is.null(new_type)) {
    test_formulation$formulation_type <- new_type
    expect_equal(test_formulation$formulation_type, new_type)
  }

  # Test modifying parameters (if any)
  # Create a new Parameter object
  new_param <- create_parameter(
    name = "New Parameter",
    value = 100.0,
    unit = "mg"
  )

  # Convert to a named list
  new_params <- list(new_param)
  names(new_params) <- "New Parameter"
  class(new_params) <- c("parameter_collection", "list")

  test_formulation$parameters <- new_params

  expect_s3_class(
    test_formulation$parameters,
    "parameter_collection"
  )

  # Check parameter values
  expect_equal(test_formulation$parameters[[1]]$name, "New Parameter")
  expect_equal(test_formulation$parameters[[1]]$value, 100.0)
  expect_equal(test_formulation$parameters[[1]]$unit, "mg")

  # Test the print output after modifications
  expect_snapshot(print(test_formulation))
})

test_that("Formulation validates formulation type", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get any formulation from test snapshot
  test_formulation <- snapshot_clone$formulations[[1]]$clone()

  # Ensure we found a formulation
  expect_false(is.null(test_formulation))

  # Test valid formulation types
  valid_types <- c(
    "Formulation_Dissolved",
    "Formulation_Tablet_Weibull",
    "Formulation_Tablet_Lint80",
    "Formulation_Particles",
    "Formulation_Table",
    "Formulation_ZeroOrder",
    "Formulation_FirstOrder"
  )

  for (type in valid_types) {
    expect_no_error(test_formulation$formulation_type <- type)
    expect_equal(test_formulation$formulation_type, type)
  }

  # Test invalid formulation type
  expect_error(
    test_formulation$formulation_type <- "InvalidType",
    "Invalid formulation type: InvalidType"
  )
})

test_that("formulation to_df method works correctly", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get a formulation from test snapshot
  test_formulation <- snapshot_clone$formulations[[1]]

  # Get a different formulation if there are more than one
  second_formulation <- NULL
  if (length(snapshot_clone$formulations) > 1) {
    second_formulation <- snapshot_clone$formulations[[2]]
  }

  # Ensure we found at least one formulation
  expect_false(is.null(test_formulation))

  # Test to_df with "all" type
  all_df <- test_formulation$to_df("all")
  expect_type(all_df, "list")
  expect_true(all(
    c("formulations", "formulations_parameters") %in% names(all_df)
  ))

  # Use expect_snapshot to verify dataframe structure and content
  expect_snapshot(all_df)

  # Test to_df with specific type
  params_df <- test_formulation$to_df("parameters")
  expect_s3_class(params_df, "tbl_df")
  expect_snapshot(params_df)

  # Test invalid type
  expect_error(
    test_formulation$to_df("invalid")
  )

  # Test another formulation if available
  if (!is.null(second_formulation)) {
    second_df <- second_formulation$to_df()
    expect_snapshot(second_df)
  }
})

test_that("to_df correctly extracts table parameter points", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Get table formulation from test snapshot
  table_form <- NULL
  for (form in snapshot_clone$formulations) {
    if (form$formulation_type == "Formulation_Table") {
      table_form <- form
      break
    }
  }

  # Skip test if no table formulation is found
  if (is.null(table_form)) {
    skip("No table formulation found in test_snapshot")
  }

  # Convert to dataframes
  dfs <- table_form$to_df()

  # Use expect_snapshot for comprehensive validation
  expect_snapshot(dfs)

  # Basic structure tests
  expect_true("formulations_parameters" %in% names(dfs))
  expect_s3_class(dfs$formulations_parameters, "tbl_df")

  # Verify columns
  expect_named(
    dfs$formulations_parameters,
    c(
      "formulation_id",
      "name",
      "value",
      "unit",
      "is_table_point",
      "x_value",
      "y_value",
      "table_name"
    )
  )

  # Get only the table points
  points <- dfs$formulations_parameters[
    dfs$formulations_parameters$is_table_point,
  ]

  # Check we have table points
  expect_true(nrow(points) > 0)
  expect_true(all(points$is_table_point))

  # Check all x_value and y_value are numeric
  expect_true(all(!is.na(points$x_value)))
  expect_true(all(!is.na(points$y_value)))
})

# Test that formulation tables points are correctly extracted from a real snapshot
test_that("Table formulation correctly extracts parameter table points from test_snapshot", {
  # Get the parameters dataframe
  dfs <- get_formulations_dfs(test_snapshot)

  # Use expect_snapshot for comprehensive validation
  expect_snapshot(print(dfs$formulations, n = Inf))
  expect_snapshot(print(dfs$formulations_parameters, n = Inf))
})

test_that("get_human_formulation_type method works correctly", {
  # Clone test_snapshot to avoid modifying the original
  snapshot_clone <- test_snapshot$clone()

  # Map of formulation types to human-readable names
  type_map <- list(
    "Formulation_Dissolved" = "Dissolved",
    "Formulation_Tablet_Weibull" = "Weibull",
    "Formulation_Tablet_Lint80" = "Lint80",
    "Formulation_Particles" = "Particle",
    "Formulation_Table" = "Table",
    "Formulation_ZeroOrder" = "Zero Order",
    "Formulation_FirstOrder" = "First Order"
  )

  # Test method using any formulation from snapshot
  test_form <- snapshot_clone$formulations[[1]]
  expect_type(test_form$get_human_formulation_type(), "character")

  # Expected value should match the map or be the original if not in map
  expected_type <- type_map[[test_form$formulation_type]] %||%
    test_form$formulation_type
  expect_equal(test_form$get_human_formulation_type(), expected_type)

  # Test unknown type
  unknown_formulation <- Formulation$new(list(
    Name = "Unknown",
    FormulationType = "Formulation_Unknown"
  ))

  expect_equal(
    unknown_formulation$get_human_formulation_type(),
    "Formulation_Unknown"
  )
})

# ---- Formulation dataframe tests ----
test_that("get_formulations_dfs returns correct data frames", {
  # Test with a snapshot containing formulations
  dfs <- get_formulations_dfs(test_snapshot)

  # Use expect_snapshot for comprehensive validation
  expect_snapshot(dfs)

  # Basic structural tests
  expect_type(dfs, "list")
  expect_named(dfs, c("formulations", "formulations_parameters"))
  expect_s3_class(dfs$formulations, "tbl_df")
  expect_s3_class(dfs$formulations_parameters, "tbl_df")

  # Test with an empty snapshot
  dfs_empty <- get_formulations_dfs(empty_snapshot)

  # Use expect_snapshot for comprehensive validation
  expect_snapshot(dfs_empty)

  # Basic structural tests
  expect_type(dfs_empty, "list")
  expect_named(dfs_empty, c("formulations", "formulations_parameters"))
  expect_s3_class(dfs_empty$formulations, "tbl_df")
  expect_s3_class(dfs_empty$formulations_parameters, "tbl_df")
})
