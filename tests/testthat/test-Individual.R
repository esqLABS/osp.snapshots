# ---- Individual class logic tests ----
test_that("Individual class initialization works", {
  # Test that object is created and is of correct class
  expect_s3_class(complete_individual, "R6")
  expect_true("Individual" %in% class(complete_individual))

  # Test that data is stored correctly
  expect_equal(complete_individual$data, complete_individual_data)
})

test_that("Individual active bindings work correctly", {
  # Test each active binding
  expect_equal(complete_individual$name, "Test Individual")
  expect_equal(complete_individual$seed, 12345)
  expect_equal(
    complete_individual$expression_profiles,
    complete_individual_data$ExpressionProfiles
  )

  # Test parameters are converted to Parameter objects
  expect_true(all(vapply(
    complete_individual$parameters,
    function(p) inherits(p, "Parameter"),
    logical(1)
  )))
})

test_that("Individual print method returns formatted output", {
  expect_snapshot(print(complete_individual))
})

test_that("Individual handles missing data gracefully", {
  # Test that accessing missing data returns NULL or appropriate default
  expect_null(minimal_individual$seed)
  expect_s3_class(minimal_individual$parameters, "parameter_collection")
  expect_length(minimal_individual$parameters, 0)
  expect_null(minimal_individual$expression_profiles)

  # Test print output with missing data
  expect_snapshot(print(minimal_individual))
})

test_that("Individual creation with modified data works", {
  # Create an individual with modified data to test specific cases
  modified_data <- complete_individual_data
  modified_data$OriginData$DiseaseState <- "CKD"
  modified_data$OriginData$DiseaseStateParameters <- list(
    list(
      Name = "eGFR",
      Value = 45.0,
      Unit = "ml/min/1.73m²"
    )
  )

  modified_individual <- Individual$new(modified_data)

  # Test disease state specific output
  expect_snapshot(print(modified_individual))
})

test_that("Individual fields can be modified through active bindings", {
  # Create a new individual for testing modifications
  test_individual <- Individual$new(complete_individual_data)

  # Test modifying simple fields
  test_individual$name <- "Modified Name"
  expect_equal(test_individual$name, "Modified Name")

  test_individual$seed <- 54321
  expect_equal(test_individual$seed, 54321)

  # Test modifying species, population, and gender with valid values
  test_individual$species <- ospsuite::Species[1]
  expect_equal(test_individual$species, ospsuite::Species[1])

  test_individual$population <- ospsuite::HumanPopulation[1]
  expect_equal(test_individual$population, ospsuite::HumanPopulation[1])

  test_individual$gender <- ospsuite::Gender[1]
  expect_equal(test_individual$gender, ospsuite::Gender[1])

  # Test modifying measurements (age, weight, height)
  test_individual$age <- 25
  expect_equal(test_individual$age, 25)
  expect_equal(test_individual$age_unit, "year(s)") # Default unit preserved

  test_individual$weight <- 80
  expect_equal(test_individual$weight, 80)
  expect_equal(test_individual$weight_unit, "kg") # Default unit preserved

  test_individual$height <- 180
  expect_equal(test_individual$height, 180)
  expect_equal(test_individual$height_unit, "cm") # Default unit preserved

  # Test modifying gestational age
  test_individual$gestational_age <- 28
  expect_equal(test_individual$gestational_age, 28)
  expect_equal(test_individual$gestational_age_unit, "week(s)") # Default unit preserved

  # Test the print output after modifications
  expect_snapshot(print(test_individual))
})

test_that("Individual validates species, population, and gender", {
  test_individual <- Individual$new(complete_individual_data)

  # Test invalid species
  expect_error(
    test_individual$species <- "InvalidSpecies",
    "Invalid species: InvalidSpecies"
  )

  # Test invalid population
  expect_error(
    test_individual$population <- "InvalidPopulation",
    "Invalid population: InvalidPopulation"
  )

  # Test invalid gender
  expect_error(
    test_individual$gender <- "InvalidGender",
    "Invalid gender: InvalidGender"
  )

  # Test all valid species
  for (species in ospsuite::Species) {
    expect_no_error(test_individual$species <- species)
    expect_equal(test_individual$species, species)
  }

  # Test all valid populations
  for (population in ospsuite::HumanPopulation) {
    expect_no_error(test_individual$population <- population)
    expect_equal(test_individual$population, population)
  }

  # Test all valid genders
  for (gender in ospsuite::Gender) {
    expect_no_error(test_individual$gender <- gender)
    expect_equal(test_individual$gender, gender)
  }
})

test_that("Individual measurement units can be modified", {
  # Create a new individual for testing unit modifications
  test_individual <- Individual$new(complete_individual_data)

  # Test modifying age unit
  test_individual$age_unit <- "month(s)"
  expect_equal(test_individual$age_unit, "month(s)")
  expect_equal(test_individual$age, 30) # Value preserved

  # Test modifying weight unit
  test_individual$weight_unit <- "g"
  expect_equal(test_individual$weight_unit, "g")
  expect_equal(test_individual$weight, 70) # Value preserved

  # Test modifying height unit
  test_individual$height_unit <- "m"
  expect_equal(test_individual$height_unit, "m")
  expect_equal(test_individual$height, 175) # Value preserved

  # Test modifying gestational age unit
  test_individual$gestational_age <- 30 # First set a value
  test_individual$gestational_age_unit <- "day(s)"
  expect_equal(test_individual$gestational_age_unit, "day(s)")
  expect_equal(test_individual$gestational_age, 30) # Value preserved

  # Test invalid units
  expect_error(test_individual$age_unit <- "invalid")
  expect_error(test_individual$weight_unit <- "invalid")
  expect_error(test_individual$height_unit <- "invalid")
  expect_error(test_individual$gestational_age_unit <- "invalid")

  # Test the print output after unit modifications
  expect_snapshot(print(test_individual))
})

test_that("Individual disease state can be modified", {
  # Create a new individual for testing disease state modifications
  test_individual <- Individual$new(complete_individual_data)

  # Test setting disease state
  test_individual$disease_state <- "CKD"
  expect_equal(test_individual$disease_state, "CKD")

  # Test setting disease state parameters
  test_individual$disease_state_parameters <- list(
    list(
      Name = "eGFR",
      Value = 45.0,
      Unit = "ml/min/1.73m²"
    )
  )
  expect_equal(
    test_individual$disease_state_parameters,
    list(
      list(
        Name = "eGFR",
        Value = 45.0,
        Unit = "ml/min/1.73m²"
      )
    )
  )

  # Test the print output after disease state modifications
  expect_snapshot(print(test_individual))
})

test_that("Individual initializes parameters correctly", {
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

  # Test parameter collection has correct class
  expect_s3_class(individual$parameters, "parameter_collection")
  expect_s3_class(individual$parameters, "list")

  # Test individual parameters are Parameter objects
  expect_s3_class(individual$parameters[["Organism|Liver|Volume"]], "Parameter")
  expect_s3_class(individual$parameters[["Organism|Kidney|GFR"]], "Parameter")

  # Test parameter values through direct access
  expect_equal(
    individual$parameters[["Organism|Liver|Volume"]]$name,
    "Organism|Liver|Volume"
  )
  expect_equal(individual$parameters[["Organism|Liver|Volume"]]$value, 1.5)
  expect_equal(individual$parameters[["Organism|Liver|Volume"]]$unit, "L")

  expect_equal(
    individual$parameters[["Organism|Kidney|GFR"]]$name,
    "Organism|Kidney|GFR"
  )
  expect_equal(individual$parameters[["Organism|Kidney|GFR"]]$value, 120)
  expect_equal(individual$parameters[["Organism|Kidney|GFR"]]$unit, "ml/min")
})

test_that("create_individual creates minimal individual", {
  # Test with just a name
  individual <- create_individual(name = "Test Individual")
  expect_s3_class(individual, "Individual")
  expect_equal(individual$name, "Test Individual")
  expect_null(individual$species)
  expect_null(individual$population)
  expect_null(individual$gender)
  expect_null(individual$age)
  expect_null(individual$weight)
  expect_null(individual$height)

  # Test default name
  default_individual <- create_individual()
  expect_equal(default_individual$name, "New Individual")
})

test_that("create_individual creates complete individual", {
  # Create individual with all basic fields
  individual <- create_individual(
    name = "John Doe",
    species = ospsuite::Species[1],
    population = ospsuite::HumanPopulation[1],
    gender = ospsuite::Gender[1],
    age = 30,
    weight = 70,
    height = 175,
    seed = 12345
  )

  # Test all fields are set correctly
  expect_equal(individual$name, "John Doe")
  expect_equal(individual$species, ospsuite::Species[1])
  expect_equal(individual$population, ospsuite::HumanPopulation[1])
  expect_equal(individual$gender, ospsuite::Gender[1])
  expect_equal(individual$age, 30)
  expect_equal(individual$age_unit, "year(s)")
  expect_equal(individual$weight, 70)
  expect_equal(individual$weight_unit, "kg")
  expect_equal(individual$height, 175)
  expect_equal(individual$height_unit, "cm")
  expect_equal(individual$seed, 12345)
})

test_that("create_individual handles custom units", {
  # Create individual with custom units
  individual <- create_individual(
    name = "Custom Units",
    age = 360,
    age_unit = "month(s)",
    weight = 70000,
    weight_unit = "g",
    height = 1.75,
    height_unit = "m"
  )

  # Test values and units are set correctly
  expect_equal(individual$age, 360)
  expect_equal(individual$age_unit, "month(s)")
  expect_equal(individual$weight, 70000)
  expect_equal(individual$weight_unit, "g")
  expect_equal(individual$height, 1.75)
  expect_equal(individual$height_unit, "m")
})

test_that("create_individual validates inputs", {
  # Test invalid species
  expect_error(
    create_individual(species = "InvalidSpecies"),
    "Invalid species"
  )

  # Test invalid population
  expect_error(
    create_individual(population = "InvalidPopulation"),
    "Invalid population"
  )

  # Test invalid gender
  expect_error(
    create_individual(gender = "InvalidGender"),
    "Invalid gender"
  )

  # Test invalid units
  expect_error(
    create_individual(age = 30, age_unit = "invalid"),
    "Invalid unit"
  )
  expect_error(
    create_individual(weight = 70, weight_unit = "invalid"),
    "Invalid unit"
  )
  expect_error(
    create_individual(height = 175, height_unit = "invalid"),
    "Invalid unit"
  )
})

test_that("Individual parameters can be accessed and modified", {
  # Create test data with parameters
  test_data <- list(
    Name = "Test Individual",
    Parameters = list(
      list(
        Path = "param_1",
        Value = 10,
        Unit = "mg"
      ),
      list(
        Path = "param_2",
        Value = 20,
        Unit = "ml"
      )
    )
  )

  individual <- Individual$new(test_data)

  # Test parameter access
  expect_equal(individual$parameters$param_1$value, 10)
  expect_equal(individual$parameters$param_2$value, 20)
  expect_equal(individual$parameters$param_1$unit, "mg")
  expect_equal(individual$parameters$param_2$unit, "ml")

  # Test parameter modification
  individual$parameters$param_1$value <- 15
  expect_equal(individual$parameters$param_1$value, 15)
  # Verify raw data is updated
  expect_equal(individual$data$Parameters[[1]]$Value, 15)

  # Test parameter unit modification
  individual$parameters$param_2$unit <- "l"
  expect_equal(individual$parameters$param_2$unit, "l")
  expect_equal(individual$data$Parameters[[2]]$Unit, "l")

  # Test parameter collection methods
  param <- individual$parameters$param_1
  expect_equal(param$value, 15)
  expect_equal(param$unit, "mg")
})


test_that("Individual parameters maintain sync with raw data", {
  # Create test data with parameters
  test_data <- list(
    Name = "Test Individual",
    Parameters = list(
      list(
        Path = "param_1",
        Value = 10,
        Unit = "mg"
      )
    )
  )

  individual <- Individual$new(test_data)

  # Modify parameter
  individual$parameters$param_1$value <- 25
  expect_equal(individual$data$Parameters[[1]]$Value, 25)

  # Modify unit
  individual$parameters$param_1$unit <- "g"
  expect_equal(individual$data$Parameters[[1]]$Unit, "g")
})

test_that("Individual print method displays calculation methods", {
  # Create an individual with calculation methods
  individual_data <- list(
    Name = "Test Individual with Methods",
    OriginData = list(
      Species = "Human",
      CalculationMethods = c(
        "Method 1",
        "Method 2",
        "Method 3"
      )
    )
  )

  test_individual <- Individual$new(individual_data)

  # Test that calculation methods are accessible
  expect_equal(
    test_individual$calculation_methods,
    c("Method 1", "Method 2", "Method 3")
  )

  # Test calculation methods appear in print output
  expect_snapshot(print(test_individual))
})

test_that("Individual can be created with calculation methods", {
  # Create individual using the create_individual function with calculation methods
  individual <- create_individual(
    name = "Method Test Individual",
    calculation_methods = c("Test Method 1", "Test Method 2")
  )

  # Check the calculation methods were set correctly
  expect_equal(
    individual$calculation_methods,
    c("Test Method 1", "Test Method 2")
  )

  # Test print output shows the methods
  expect_snapshot(print(individual))
})

test_that("Individual creation with null values works", {
  # Test creating an individual with various combinations of null values
  null_individual <- create_individual(
    name = "Null Test",
    seed = 12345
  )

  # Check null fields return NULL
  expect_null(null_individual$species)
  expect_null(null_individual$population)
  expect_null(null_individual$gender)
  expect_null(null_individual$age)
  expect_null(null_individual$weight)
  expect_null(null_individual$height)
  expect_null(null_individual$disease_state)
  expect_null(null_individual$disease_state_parameters)
  expect_null(null_individual$calculation_methods)

  # Test that setting new values works correctly
  null_individual$species <- "Human"
  expect_equal(null_individual$species, "Human")

  null_individual$age <- 45
  expect_equal(null_individual$age, 45)
  expect_equal(null_individual$age_unit, "year(s)")

  null_individual$weight <- 80
  expect_equal(null_individual$weight, 80)
  expect_equal(null_individual$weight_unit, "kg")

  null_individual$height <- 180
  expect_equal(null_individual$height, 180)
  expect_equal(null_individual$height_unit, "cm")
})

test_that("Individual parameters can be modified", {
  # Create a test individual with parameters
  test_individual <- Individual$new(complete_individual_data)
  param_list <- test_individual$parameters

  # Get first parameter
  first_param <- param_list[[1]]
  original_value <- first_param$value

  # Modify the parameter
  first_param$value <- original_value * 2

  # Check that parameter was modified in the parameters list
  expect_equal(param_list[[1]]$value, original_value * 2)

  # Set parameters to NULL
  test_individual$parameters <- NULL
  expect_length(test_individual$parameters, 0)
  expect_equal(test_individual$data$Parameters, list())

  # Set parameters to a new list
  new_params <- list(
    Parameter$new(list(Path = "Test|Path", Value = 123))
  )
  names(new_params) <- "Test|Path"
  class(new_params) <- c("parameter_collection", "list")

  test_individual$parameters <- new_params
  expect_equal(test_individual$parameters, new_params)
  expect_equal(test_individual$data$Parameters[[1]]$Path, "Test|Path")
  expect_equal(test_individual$data$Parameters[[1]]$Value, 123)
})

test_that("Individual expression_profiles is read-only", {
  # Create a test individual with expression profiles
  test_individual <- Individual$new(complete_individual_data)

  # Check expression profiles are returned correctly
  expect_equal(
    test_individual$expression_profiles,
    complete_individual_data$ExpressionProfiles
  )
})

test_that("create_individual validates all inputs properly", {
  # Test valid inputs with all parameters
  expect_no_error(
    create_individual(
      name = "Valid Individual",
      species = "Human",
      population = ospsuite::HumanPopulation[1],
      gender = ospsuite::Gender[1],
      age = 30,
      age_unit = "year(s)",
      weight = 70,
      weight_unit = "kg",
      height = 180,
      height_unit = "cm",
      calculation_methods = c("Method1", "Method2"),
      disease_state = "CKD",
      disease_state_parameters = list(
        list(Name = "eGFR", Value = 45, Unit = "ml/min/1.73m²")
      ),
      seed = 12345
    )
  )

  # Test invalid units
  expect_error(
    create_individual(age_unit = "invalid_unit")
  )

  expect_error(
    create_individual(weight_unit = "invalid_unit")
  )

  expect_error(
    create_individual(height_unit = "invalid_unit")
  )
})

test_that("create_individual supports gestational age", {
  # Create an individual with gestational age
  individual <- create_individual(
    name = "Preterm Baby",
    species = "Human",
    population = "Preterm",
    gender = "MALE",
    age = 10.0,
    age_unit = "day(s)",
    gestational_age = 30.0,
    gestational_age_unit = "week(s)",
    weight = 1.5,
    height = 40
  )

  # Test that gestational age was set correctly
  expect_equal(individual$gestational_age, 30.0)
  expect_equal(individual$gestational_age_unit, "week(s)")

  # Test the print output for preterm individual
  expect_snapshot(print(individual))
})

test_that("Individual handles gestational age correctly", {
  # Test that preterm individual has correct gestational age
  expect_equal(preterm_individual$gestational_age, 30.0)
  expect_equal(preterm_individual$gestational_age_unit, "week(s)")

  # Test gestational age can be modified
  preterm_individual$gestational_age <- 32.0
  expect_equal(preterm_individual$gestational_age, 32.0)

  # Test gestational age unit can be modified
  preterm_individual$gestational_age_unit <- "day(s)"
  expect_equal(preterm_individual$gestational_age_unit, "day(s)")

  # Test print output shows gestational age
  expect_snapshot(print(preterm_individual))
})

test_that("Snapshot with empty individuals is handled correctly", {
  snapshot <- empty_snapshot$clone()

  # Check that individuals is an empty individual_collection
  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_length(snapshot$individuals, 0)

  # Print should not error and should show minimal info
  expect_snapshot(print(snapshot$individuals))
})


test_that("Individual read-only fields error on set", {
  ind <- Individual$new(complete_individual_data)
  expect_error(ind$data <- list(), "data is read-only")
  expect_error(ind$expression_profiles <- c("A"), "unused argument")
})

test_that("Parameter collection class is always parameter_collection", {
  ind <- Individual$new(complete_individual_data)
  expect_s3_class(ind$parameters, "parameter_collection")
  # Replace with new list
  new_param <- Parameter$new(list(Path = "X", Value = 1))
  ind$parameters <- list(new_param)
  expect_s3_class(ind$parameters, "parameter_collection")
})

test_that("Parameter removal and re-adding works", {
  ind <- Individual$new(complete_individual_data)
  ind$parameters <- NULL
  expect_length(ind$parameters, 0)
  new_param <- Parameter$new(list(Path = "Y", Value = 2))
  ind$parameters <- list(new_param)
  expect_equal(ind$parameters[[1]]$name, "Y")
})

test_that("to_df returns all types and errors on invalid type", {
  ind <- Individual$new(complete_individual_data)
  expect_s3_class(ind$to_df("individuals"), "tbl_df")
  expect_s3_class(ind$to_df("individuals_parameters"), "tbl_df")
  expect_s3_class(ind$to_df("individuals_expressions"), "tbl_df")
  expect_type(ind$to_df(), "list")
  expect_error(ind$to_df("not_a_type"), "type must be one of")
})

test_that("Disease state parameters handle missing fields", {
  ind <- Individual$new(complete_individual_data)
  # Set disease state parameters with missing Unit
  ind$disease_state_parameters <- list(list(Name = "eGFR", Value = 45.0))
  expect_equal(ind$disease_state_parameters[[1]]$Name, "eGFR")
  expect_equal(ind$disease_state_parameters[[1]]$Value, 45.0)
  expect_null(ind$disease_state_parameters[[1]]$Unit)
})

test_that("Calculation methods edge cases", {
  ind <- Individual$new(complete_individual_data)
  ind$calculation_methods <- NULL
  expect_null(ind$calculation_methods)
  ind$calculation_methods <- character(0)
  expect_length(ind$calculation_methods, 0)
  ind$calculation_methods <- c("A", "B")
  expect_equal(ind$calculation_methods, c("A", "B"))
})

test_that("Gestational age can be set to NULL after being set", {
  ind <- Individual$new(complete_individual_data)
  ind$gestational_age <- 30
  expect_equal(ind$gestational_age, 30)
  ind$gestational_age <- NULL
  expect_null(ind$gestational_age)
})

test_that("Units can be set to NULL after being set", {
  ind <- Individual$new(complete_individual_data)
  ind$age_unit <- "year(s)"
  expect_equal(ind$age_unit, "year(s)")
  ind$weight_unit <- "kg"
  expect_equal(ind$weight_unit, "kg")
  ind$height_unit <- "cm"
  expect_equal(ind$height_unit, "cm")
  # Now set to NULL
  ind$age_unit <- NULL
  expect_null(ind$age_unit)
  ind$weight_unit <- NULL
  expect_null(ind$weight_unit)
  ind$height_unit <- NULL
  expect_null(ind$height_unit)
})

test_that("Replacing entire parameters list works", {
  ind <- Individual$new(complete_individual_data)
  new_params <- list(
    Parameter$new(list(Path = "A", Value = 1)),
    Parameter$new(list(Path = "B", Value = 2))
  )
  names(new_params) <- c("A", "B")
  class(new_params) <- c("parameter_collection", "list")
  ind$parameters <- new_params
  expect_equal(names(ind$parameters), c("A", "B"))
  expect_equal(ind$parameters[["A"]]$value, 1)
  expect_equal(ind$parameters[["B"]]$value, 2)
})

# ---- Individual dataframe tests ----
test_that("get_individuals_dfs returns correct data frames", {
  # Test with a snapshot containing individuals
  dfs <- get_individuals_dfs(test_snapshot)
  expect_type(dfs, "list")
  expect_named(
    dfs,
    c("individuals", "individuals_parameters", "individuals_expressions")
  )
  expect_s3_class(dfs$individuals, "tbl_df")
  expect_s3_class(dfs$individuals_parameters, "tbl_df")
  expect_s3_class(dfs$individuals_expressions, "tbl_df")
  # Check columns for individuals
  expect_named(
    dfs$individuals,
    c(
      "individual_id",
      "name",
      "seed",
      "species",
      "population",
      "gender",
      "age",
      "age_unit",
      "gestational_age",
      "gestational_age_unit",
      "weight",
      "weight_unit",
      "height",
      "height_unit",
      "disease_state",
      "calculation_methods",
      "disease_state_parameters"
    )
  )
  # Check columns for individuals_parameters
  expect_named(
    dfs$individuals_parameters,
    c(
      "individual_id",
      "path",
      "value",
      "unit",
      "source",
      "description",
      "source_id"
    )
  )
  # Check columns for individuals_expressions
  expect_named(
    dfs$individuals_expressions,
    c("individual_id", "profile")
  )
  # Use expect_snapshot to check the dataframes
  expect_snapshot(dfs$individuals)
  expect_snapshot(dfs$individuals_parameters)
  expect_snapshot(dfs$individuals_expressions)

  # Test with an empty snapshot
  dfs_empty <- get_individuals_dfs(empty_snapshot)
  expect_type(dfs_empty, "list")
  expect_named(
    dfs_empty,
    c("individuals", "individuals_parameters", "individuals_expressions")
  )
  expect_s3_class(dfs_empty$individuals, "tbl_df")
  expect_s3_class(dfs_empty$individuals_parameters, "tbl_df")
  expect_s3_class(dfs_empty$individuals_expressions, "tbl_df")
  expect_named(
    dfs_empty$individuals,
    c(
      "individual_id",
      "name",
      "seed",
      "species",
      "population",
      "gender",
      "age",
      "age_unit",
      "gestational_age",
      "gestational_age_unit",
      "weight",
      "weight_unit",
      "height",
      "height_unit",
      "disease_state",
      "calculation_methods",
      "disease_state_parameters"
    )
  )
  expect_named(
    dfs_empty$individuals_parameters,
    c(
      "individual_id",
      "path",
      "value",
      "unit",
      "source",
      "description",
      "source_id"
    )
  )
  expect_named(
    dfs_empty$individuals_expressions,
    c("individual_id", "profile")
  )
  expect_snapshot(dfs_empty$individuals)
  expect_snapshot(dfs_empty$individuals_parameters)
  expect_snapshot(dfs_empty$individuals_expressions)
})

test_that("get_individuals_dfs handles individual with characteristics and expression profiles but no parameters", {
  # Create a snapshot with a single such individual
  snapshot <- local_snapshot(list(
    Version = 80,
    Individuals = list(characteristics_expr_individual_data)
  ))

  dfs <- get_individuals_dfs(snapshot)
  expect_type(dfs, "list")
  expect_named(
    dfs,
    c("individuals", "individuals_parameters", "individuals_expressions")
  )
  expect_s3_class(dfs$individuals, "tbl_df")
  expect_s3_class(dfs$individuals_parameters, "tbl_df")
  expect_s3_class(dfs$individuals_expressions, "tbl_df")
  # Use expect_snapshot to check the dataframes
  expect_snapshot(dfs$individuals)
  expect_snapshot(dfs$individuals_parameters)
  expect_snapshot(dfs$individuals_expressions)
})

test_that("get_individuals_dfs handles mixed individuals correctly - first without, second with parameters/expressions", {
  # This test reproduces the bug where first individual has no parameters/expressions
  # but second individual does - the bug would cause the results to be NULL instead of
  # containing data from the second individual

  # Create a snapshot with two individuals:
  # 1. minimal_individual_data - has no parameters or expression profiles
  # 2. complete_individual_data - has both parameters and expression profiles
  snapshot <- local_snapshot(list(
    Version = 80,
    Individuals = list(minimal_individual_data, complete_individual_data)
  ))

  dfs <- get_individuals_dfs(snapshot)

  # Check structure
  expect_type(dfs, "list")
  expect_named(
    dfs,
    c("individuals", "individuals_parameters", "individuals_expressions")
  )
  expect_s3_class(dfs$individuals, "tbl_df")
  expect_s3_class(dfs$individuals_parameters, "tbl_df")
  expect_s3_class(dfs$individuals_expressions, "tbl_df")

  # Check that we have 2 individuals in the main dataframe
  expect_equal(nrow(dfs$individuals), 2)
  expect_equal(dfs$individuals$name, c("Minimal Individual", "Test Individual"))

  # Check that we have parameters from the second individual (the first has none)
  expect_true(nrow(dfs$individuals_parameters) > 0)
  expect_equal(
    unique(dfs$individuals_parameters$individual_id),
    "Test Individual"
  )

  # Check that we have expression profiles from the second individual (the first has none)
  expect_true(nrow(dfs$individuals_expressions) > 0)
  expect_equal(
    unique(dfs$individuals_expressions$individual_id),
    "Test Individual"
  )
  expect_true(all(grepl("Human", dfs$individuals_expressions$profile)))
})

test_that("get_individuals_dfs handles mixed individuals correctly - first with, second without parameters/expressions", {
  # This test checks the opposite scenario - first individual has data, second doesn't

  # Create a snapshot with two individuals in reverse order:
  # 1. complete_individual_data - has both parameters and expression profiles
  # 2. minimal_individual_data - has no parameters or expression profiles
  snapshot <- local_snapshot(list(
    Version = 80,
    Individuals = list(complete_individual_data, minimal_individual_data)
  ))

  dfs <- get_individuals_dfs(snapshot)

  # Check structure
  expect_type(dfs, "list")
  expect_named(
    dfs,
    c("individuals", "individuals_parameters", "individuals_expressions")
  )
  expect_s3_class(dfs$individuals, "tbl_df")
  expect_s3_class(dfs$individuals_parameters, "tbl_df")
  expect_s3_class(dfs$individuals_expressions, "tbl_df")

  # Check that we have 2 individuals in the main dataframe
  expect_equal(nrow(dfs$individuals), 2)
  expect_equal(dfs$individuals$name, c("Test Individual", "Minimal Individual"))

  # Check that we have parameters from the first individual (the second has none)
  expect_true(nrow(dfs$individuals_parameters) > 0)
  expect_equal(
    unique(dfs$individuals_parameters$individual_id),
    "Test Individual"
  )

  # Check that we have expression profiles from the first individual (the second has none)
  expect_true(nrow(dfs$individuals_expressions) > 0)
  expect_equal(
    unique(dfs$individuals_expressions$individual_id),
    "Test Individual"
  )
  expect_true(all(grepl("Human", dfs$individuals_expressions$profile)))
})
