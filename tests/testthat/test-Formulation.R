# ---- Formulation logic tests ----
test_that("Formulation class initialization works", {
  # Create a formulation object using fixture data
  test_formulation <- Formulation$new(complete_formulation_data)

  # Test that object is created and is of correct class
  expect_s3_class(test_formulation, "R6")
  expect_true("Formulation" %in% class(test_formulation))

  # Test that data is stored correctly
  expect_equal(test_formulation$data, complete_formulation_data)

  # Test minimal formulation (dissolved type, no parameters)
  dissolved_formulation <- Formulation$new(minimal_formulation_data)
  expect_s3_class(dissolved_formulation, "R6")
  expect_true("Formulation" %in% class(dissolved_formulation))
  expect_equal(dissolved_formulation$data, minimal_formulation_data)
})

test_that("Formulation active bindings work correctly", {
  # Use fixture data
  test_formulation <- Formulation$new(complete_formulation_data)

  # Test each active binding
  expect_equal(test_formulation$name, "Test Tablet")
  expect_equal(
    test_formulation$formulation_type,
    "Formulation_Tablet_Weibull"
  )

  # Test that parameters have the correct class
  expect_s3_class(
    test_formulation$parameters,
    "parameter_collection"
  )

  # Test that each parameter is a Parameter object
  expect_true(all(sapply(
    test_formulation$parameters,
    function(p) inherits(p, "Parameter")
  )))
})

test_that("Formulation print method returns formatted output", {
  # Use fixture data
  test_formulation <- Formulation$new(complete_formulation_data)

  # Test print output
  expect_snapshot(print(test_formulation))

  # Test dissolved formulation (no parameters)
  dissolved_formulation <- Formulation$new(minimal_formulation_data)
  expect_snapshot(print(dissolved_formulation))
})

test_that("Formulation handles table-based formulations correctly", {
  # Use table_formulation fixture from helper file
  table_formulation <- Formulation$new(table_formulation_data)

  # Test that object is created correctly
  expect_s3_class(table_formulation, "R6")
  expect_true("Formulation" %in% class(table_formulation))

  # Test that data is stored correctly
  expect_equal(table_formulation$data, table_formulation_data)

  # Test print output for table formulation
  expect_snapshot(print(table_formulation))
})

test_that("Formulation fields can be modified through active bindings", {
  # Create a copy of the fixture data to avoid modifying the original
  test_formulation_data <- complete_formulation_data
  test_formulation <- Formulation$new(test_formulation_data)

  # Test modifying name
  test_formulation$name <- "Modified Tablet"
  expect_equal(test_formulation$name, "Modified Tablet")

  # Test modifying formulation type
  test_formulation$formulation_type <- "Formulation_Dissolved"
  expect_equal(test_formulation$formulation_type, "Formulation_Dissolved")

  # Test modifying parameters
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
  test_formulation <- Formulation$new(minimal_formulation_data)

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

test_that("create_formulation function works correctly", {
  # Test creating a dissolved formulation (simple case)
  dissolved <- create_formulation(name = "Oral Solution", type = "Dissolved")
  expect_s3_class(dissolved, "R6")
  expect_true("Formulation" %in% class(dissolved))
  expect_equal(dissolved$name, "Oral Solution")
  expect_equal(dissolved$formulation_type, "Formulation_Dissolved")
  expect_snapshot(print(dissolved))

  # Test creating a Weibull tablet formulation with named parameters
  tablet <- create_formulation(
    name = "Tablet",
    type = "Weibull",
    parameters = list(
      dissolution_time = 60,
      dissolution_time_unit = "min",
      lag_time = 10,
      lag_time_unit = "min",
      dissolution_shape = 0.92,
      suspension = TRUE
    )
  )

  expect_s3_class(tablet, "R6")
  expect_true("Formulation" %in% class(tablet))
  expect_equal(tablet$name, "Tablet")
  expect_equal(tablet$formulation_type, "Formulation_Tablet_Weibull")

  # Check that the parameters were created correctly
  expect_equal(length(tablet$parameters), 4)
  expect_true(all(sapply(
    tablet$parameters,
    function(p) inherits(p, "Parameter")
  )))

  # Extract and verify key parameters
  dissolution_time_param <- tablet$parameters[[1]]
  expect_equal(
    dissolution_time_param$name,
    "Dissolution time (50% dissolved)"
  )
  expect_equal(dissolution_time_param$value, 60)
  expect_equal(dissolution_time_param$unit, "min")

  lag_time_param <- tablet$parameters[[2]]
  expect_equal(lag_time_param$name, "Lag time")
  expect_equal(lag_time_param$value, 10)
  expect_equal(lag_time_param$unit, "min")

  dissolution_shape_param <- tablet$parameters[[3]]
  expect_equal(dissolution_shape_param$name, "Dissolution shape")
  expect_equal(dissolution_shape_param$value, 0.92)

  suspension_param <- tablet$parameters[[4]]
  expect_equal(suspension_param$name, "Use as suspension")
  expect_equal(suspension_param$value, 1) # Converted to numeric

  expect_snapshot(print(tablet))

  # Test creating a particle formulation
  particle <- create_formulation(
    name = "Particle Formulation",
    type = "Particle",
    parameters = list(
      thickness = 25,
      thickness_unit = "µm",
      radius = 5,
      radius_unit = "µm"
    )
  )

  expect_s3_class(particle, "R6")
  expect_true("Formulation" %in% class(particle))
  expect_equal(particle$name, "Particle Formulation")
  expect_equal(particle$formulation_type, "Formulation_Particles")

  # Test table formulation
  table_form <- create_formulation(
    name = "Table Formulation",
    type = "Table",
    parameters = list(
      tableX = c(0, 1, 2, 4, 8),
      tableY = c(0, 0.3, 0.6, 0.9, 1.0),
      suspension = TRUE
    )
  )

  expect_s3_class(table_form, "R6")
  expect_true("Formulation" %in% class(table_form))
  expect_equal(table_form$name, "Table Formulation")
  expect_equal(table_form$formulation_type, "Formulation_Table")

  # Test with invalid formulation type
  expect_error(
    create_formulation(name = "Invalid", type = "Invalid")
  )

  # Test with invalid parameter names
  expect_error(
    create_formulation(
      name = "Invalid Params",
      type = "Weibull",
      parameters = list(invalid_param = 10)
    ),
    "Invalid parameters for Weibull formulation: invalid_param"
  )
})

test_that("formulation to_df method works correctly", {
  # Use fixture data
  test_formulation <- Formulation$new(complete_formulation_data)

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

  # Test formulation with no parameters
  dissolved_formulation <- Formulation$new(minimal_formulation_data)
  dissolved_df <- dissolved_formulation$to_df()
  expect_snapshot(dissolved_df)
})

test_that("get_human_formulation_type method works correctly", {
  # Create test formulations of each type
  formulation_types <- list(
    dissolved = list(
      data = list(
        Name = "Dissolved",
        FormulationType = "Formulation_Dissolved"
      ),
      expected = "Dissolved"
    ),
    weibull = list(
      data = list(
        Name = "Weibull",
        FormulationType = "Formulation_Tablet_Weibull"
      ),
      expected = "Weibull"
    ),
    lint80 = list(
      data = list(
        Name = "Lint80",
        FormulationType = "Formulation_Tablet_Lint80"
      ),
      expected = "Lint80"
    ),
    particle = list(
      data = list(
        Name = "Particle",
        FormulationType = "Formulation_Particles"
      ),
      expected = "Particle"
    ),
    table = list(
      data = list(Name = "Table", FormulationType = "Formulation_Table"),
      expected = "Table"
    ),
    zeroorder = list(
      data = list(
        Name = "ZeroOrder",
        FormulationType = "Formulation_ZeroOrder"
      ),
      expected = "Zero Order"
    ),
    firstorder = list(
      data = list(
        Name = "FirstOrder",
        FormulationType = "Formulation_FirstOrder"
      ),
      expected = "First Order"
    )
  )

  # Test each formulation type
  for (type_name in names(formulation_types)) {
    type_info <- formulation_types[[type_name]]
    formulation <- Formulation$new(type_info$data)

    expect_equal(
      formulation$get_human_formulation_type(),
      type_info$expected,
      info = glue::glue("Testing formulation type: {type_name}")
    )
  }

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
  expect_type(dfs, "list")
  expect_named(dfs, c("formulations", "formulations_parameters"))
  expect_s3_class(dfs$formulations, "tbl_df")
  expect_s3_class(dfs$formulations_parameters, "tbl_df")
  expect_snapshot(dfs$formulations)
  expect_snapshot(dfs$formulations_parameters)

  # Test with an empty snapshot
  dfs_empty <- get_formulations_dfs(empty_snapshot)
  expect_type(dfs_empty, "list")
  expect_named(dfs_empty, c("formulations", "formulations_parameters"))
  expect_s3_class(dfs_empty$formulations, "tbl_df")
  expect_s3_class(dfs_empty$formulations_parameters, "tbl_df")
  expect_snapshot(dfs_empty$formulations)
  expect_snapshot(dfs_empty$formulations_parameters)
})

# ---- Formulation snapshot interaction tests ----
# Copied from test-snapshot-formulations.R
# ... existing code ...
