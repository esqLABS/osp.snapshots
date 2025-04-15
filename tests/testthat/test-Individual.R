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
