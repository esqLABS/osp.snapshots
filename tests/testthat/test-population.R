# ---- Population logic tests ----
# (Add any population class logic tests here if they exist)

# ---- Population test fixtures ----
# Create test data for a complete population
complete_population_data <- list(
  Name = "Test Population",
  Seed = 12345,
  Settings = list(
    NumberOfIndividuals = 100,
    ProportionOfFemales = 50,
    Age = list(
      Min = 20.0,
      Max = 60.0,
      Unit = "year(s)"
    ),
    Weight = list(
      Min = 50.0,
      Max = 90.0,
      Unit = "kg"
    ),
    Height = list(
      Min = 150.0,
      Max = 190.0,
      Unit = "cm"
    ),
    BMI = list(
      Min = 18.5,
      Max = 30.0,
      Unit = "kg/m²"
    ),
    Individual = list(
      Name = "European Reference",
      OriginData = list(
        Species = "Human",
        Population = "European_ICRP_2002"
      )
    ),
    DiseaseStateParameters = list(
      list(
        Name = "eGFR",
        Min = 60.0,
        Max = 120.0,
        Unit = "ml/min/1.73m²"
      )
    )
  ),
  AdvancedParameters = list(
    list(
      Name = "Liver Volume",
      Seed = 54321,
      DistributionType = "Normal",
      Parameters = list(
        list(
          Name = "Mean",
          Value = 1.5,
          Unit = "l",
          ValueOrigin = list(
            Source = "Publication",
            Description = "Reference value"
          )
        ),
        list(
          Name = "Geometric SD",
          Value = 1.2
        )
      )
    )
  )
)

# Create minimal population data
minimal_population_data <- list(
  Name = "Minimal Population",
  Settings = list(
    NumberOfIndividuals = 10,
    ProportionOfFemales = 0,
    Age = list(
      Min = 30.0,
      Max = 40.0,
      Unit = "year(s)"
    )
  )
)

# Create rich population data exercising the fields added in #118
rich_population_data <- list(
  Name = "Rich Population",
  Description = "A richly configured cohort",
  Settings = list(
    NumberOfIndividuals = 50,
    ProportionOfFemales = 50,
    GestationalAge = list(
      Min = 37.0,
      Max = 42.0,
      Unit = "week(s)"
    ),
    Individual = list(
      Name = "Base",
      OriginData = list(
        Species = "Human",
        Population = "European_ICRP_2002",
        Gender = "MALE"
      )
    ),
    DiseaseStateParameters = list(
      list(
        Name = "eGFR",
        Min = 60.0,
        Max = 120.0,
        Unit = "ml/min/1.73m²"
      ),
      list(
        Name = "Tumour Volume",
        Min = 1.0,
        Max = 5.0,
        Unit = "l"
      )
    )
  )
)

# ---- Population class logic tests ----
test_that("Population class initialization works", {
  # Create test population objects
  complete_population <- Population$new(complete_population_data)
  minimal_population <- Population$new(minimal_population_data)

  # Test that objects are created and are of correct class
  expect_s3_class(complete_population, "R6")
  expect_true("Population" %in% class(complete_population))
  expect_s3_class(minimal_population, "R6")
  expect_true("Population" %in% class(minimal_population))

  # Test that data is stored correctly
  expect_equal(complete_population$data, complete_population_data)
  expect_equal(minimal_population$data, minimal_population_data)
})

test_that("Population active bindings work correctly", {
  # Create test population object
  population <- Population$new(complete_population_data)

  # Test basic properties
  expect_equal(population$name, "Test Population")
  expect_equal(population$seed, 12345)
  expect_equal(population$number_of_individuals, 100)
  expect_equal(population$proportion_of_females, 50)
  expect_equal(population$individual_name, "European Reference")
  expect_equal(population$source_population, "European_ICRP_2002")

  # Test ranges
  expect_s3_class(population$age_range, "Range")
  expect_equal(population$age_range$min, 20.0)
  expect_equal(population$age_range$max, 60.0)
  expect_equal(population$age_range$unit, "year(s)")

  expect_s3_class(population$weight_range, "Range")
  expect_equal(population$weight_range$min, 50.0)
  expect_equal(population$weight_range$max, 90.0)
  expect_equal(population$weight_range$unit, "kg")

  expect_s3_class(population$height_range, "Range")
  expect_equal(population$height_range$min, 150.0)
  expect_equal(population$height_range$max, 190.0)
  expect_equal(population$height_range$unit, "cm")

  expect_s3_class(population$bmi_range, "Range")
  expect_equal(population$bmi_range$min, 18.5)
  expect_equal(population$bmi_range$max, 30.0)
  expect_equal(population$bmi_range$unit, "kg/m²")

  expect_s3_class(population$egfr_range, "Range")
  expect_equal(population$egfr_range$min, 60.0)
  expect_equal(population$egfr_range$max, 120.0)
  expect_equal(population$egfr_range$unit, "ml/min/1.73m²")

  # Test advanced parameters
  expect_type(population$advanced_parameters, "list")
  expect_length(population$advanced_parameters, 1)
  expect_s3_class(population$advanced_parameters[[1]], "AdvancedParameter")
  expect_equal(population$advanced_parameters[[1]]$name, "Liver Volume")
  expect_equal(population$advanced_parameters[[1]]$seed, 54321)
  expect_equal(population$advanced_parameters[[1]]$distribution_type, "Normal")
})

test_that("Population handles missing data gracefully", {
  # Create a population with minimal data
  minimal_population <- Population$new(minimal_population_data)

  # Test that missing ranges return NULL
  expect_null(minimal_population$weight_range)
  expect_null(minimal_population$height_range)
  expect_null(minimal_population$bmi_range)
  expect_null(minimal_population$egfr_range)

  # Test that missing advanced parameters return an empty list
  expect_type(minimal_population$advanced_parameters, "list")
  expect_length(minimal_population$advanced_parameters, 0)

  # Test missing but optional fields
  expect_null(minimal_population$source_population)
  expect_null(minimal_population$individual_name)
})

test_that("Population print method returns formatted output", {
  # Create test population objects
  complete_population <- Population$new(complete_population_data)
  minimal_population <- Population$new(minimal_population_data)
  rich_population <- Population$new(rich_population_data)

  # Test print outputs
  expect_snapshot(print(complete_population))
  expect_snapshot(print(minimal_population))
  expect_snapshot(print(rich_population))
})

test_that("Population fields can be modified through active bindings", {
  # Create a test population for modifications
  population <- Population$new(complete_population_data)

  # Test modifying simple fields
  population$name <- "Modified Population"
  expect_equal(population$name, "Modified Population")

  population$seed <- 54321
  expect_equal(population$seed, 54321)

  population$number_of_individuals <- 200
  expect_equal(population$number_of_individuals, 200)

  population$proportion_of_females <- 75
  expect_equal(population$proportion_of_females, 75)

  # Test modifying ranges
  # Create new ranges
  new_age_range <- Range$new(25, 65, "year(s)")
  new_weight_range <- Range$new(55, 95, "kg")
  new_height_range <- Range$new(155, 195, "cm")
  new_bmi_range <- Range$new(19, 32, "kg/m²")

  # Set new ranges
  population$age_range <- new_age_range
  expect_equal(population$age_range$min, 25)
  expect_equal(population$age_range$max, 65)
  expect_equal(population$age_range$unit, "year(s)")

  population$weight_range <- new_weight_range
  expect_equal(population$weight_range$min, 55)
  expect_equal(population$weight_range$max, 95)
  expect_equal(population$weight_range$unit, "kg")

  population$height_range <- new_height_range
  expect_equal(population$height_range$min, 155)
  expect_equal(population$height_range$max, 195)
  expect_equal(population$height_range$unit, "cm")

  population$bmi_range <- new_bmi_range
  expect_equal(population$bmi_range$min, 19)
  expect_equal(population$bmi_range$max, 32)
  expect_equal(population$bmi_range$unit, "kg/m²")
})

test_that("Population validates input values", {
  # Create a test population
  population <- Population$new(complete_population_data)

  # Test invalid number of individuals
  expect_error(
    population$number_of_individuals <- 0,
    "must be a positive integer"
  )
  expect_error(
    population$number_of_individuals <- -10,
    "must be a positive integer"
  )
  expect_error(
    population$number_of_individuals <- 3.5,
    "must be a positive integer"
  )
  expect_error(
    population$number_of_individuals <- "many",
    "must be a positive integer"
  )

  # Test invalid proportion of females
  expect_error(
    population$proportion_of_females <- -10,
    "Proportion of females must be a number between 0 and 100"
  )
  expect_error(
    population$proportion_of_females <- 110,
    "Proportion of females must be a number between 0 and 100"
  )

  # Test invalid ranges (not Range objects)
  expect_error(
    population$age_range <- list(min = 20, max = 60),
    "age_range must be a Range object"
  )
  expect_error(
    population$weight_range <- "invalid",
    "weight_range must be a Range object"
  )
})

test_that("Population range setters validate the unit against the field dimension", {
  population <- Population$new(complete_population_data)

  expect_snapshot(
    error = TRUE,
    population$age_range <- range(20, 60, "banana")
  )
  expect_snapshot(
    error = TRUE,
    population$weight_range <- range(50, 90, "banana")
  )
  expect_snapshot(
    error = TRUE,
    population$height_range <- range(150, 190, "banana")
  )
  expect_snapshot(
    error = TRUE,
    population$gestational_age_range <- range(38, 41, "banana")
  )

  skip_if_not(
    tryCatch(
      {
        ospsuite::getUnitsForDimension("BMI")
        TRUE
      },
      error = function(e) FALSE
    ),
    "BMI dimension not resolvable in this ospsuite version"
  )
  expect_snapshot(
    error = TRUE,
    population$bmi_range <- range(19, 32, "banana")
  )
})

test_that("Population ranges can be set to NULL", {
  # Create a test population
  population <- Population$new(complete_population_data)

  # Test setting ranges to NULL
  population$weight_range <- NULL
  expect_null(population$weight_range)
  expect_null(population$data$Settings$Weight)

  population$height_range <- NULL
  expect_null(population$height_range)
  expect_null(population$data$Settings$Height)

  population$bmi_range <- NULL
  expect_null(population$bmi_range)
  expect_null(population$data$Settings$BMI)

  population$egfr_range <- NULL
  expect_null(population$egfr_range)
})

test_that("Read-only fields cannot be modified", {
  # Create a test population
  population <- Population$new(complete_population_data)

  # Test read-only fields
  # Using tryCatch to test the error messages for read-only fields
  expect_error(
    tryCatch(
      {
        population$source_population <- "New Population"
        NULL
      },
      error = function(e) stop(e$message)
    ),
    "source_population is read-only"
  )
  expect_error(
    tryCatch(
      {
        population$individual_name <- "New Individual"
        NULL
      },
      error = function(e) stop(e$message)
    ),
    "individual_name is read-only"
  )
  expect_error(
    tryCatch(
      {
        population$individual <- create_individual(species = "Human")
        NULL
      },
      error = function(e) stop(e$message)
    ),
    "individual is read-only"
  )
})

test_that("Population description binding reads and writes", {
  population <- Population$new(rich_population_data)
  expect_equal(population$description, "A richly configured cohort")

  population$description <- "Updated description"
  expect_equal(population$description, "Updated description")
  expect_equal(population$data$Description, "Updated description")
})

test_that("Population gestational_age_range binding reads and writes", {
  population <- Population$new(rich_population_data)

  expect_s3_class(population$gestational_age_range, "Range")
  expect_equal(population$gestational_age_range$min, 37)
  expect_equal(population$gestational_age_range$max, 42)
  expect_equal(population$gestational_age_range$unit, "week(s)")

  population$gestational_age_range <- Range$new(38, 41, "week(s)")
  expect_equal(
    population$data$Settings$GestationalAge,
    list(Min = 38, Max = 41, Unit = "week(s)")
  )

  population$gestational_age_range <- NULL
  expect_null(population$gestational_age_range)
  expect_null(population$data$Settings$GestationalAge)
})

test_that("Population disease_state_parameters getter and setter work", {
  population <- Population$new(rich_population_data)

  params <- population$disease_state_parameters
  expect_named(params, c("eGFR", "Tumour Volume"))
  expect_s3_class(params$eGFR, "Range")
  expect_equal(params$eGFR$min, 60)
  expect_equal(params[["Tumour Volume"]]$max, 5)

  population$disease_state_parameters <- list(
    eGFR = range(30, 90, "ml/min/1.73m²")
  )
  expect_length(population$data$Settings$DiseaseStateParameters, 1)
  expect_equal(
    population$data$Settings$DiseaseStateParameters[[1]],
    list(Name = "eGFR", Min = 30, Max = 90, Unit = "ml/min/1.73m²")
  )
  expect_equal(population$egfr_range$min, 30)

  population$disease_state_parameters <- NULL
  expect_null(population$data$Settings$DiseaseStateParameters)
  expect_null(population$egfr_range)
})

test_that("Population disease_state_parameters rejects non-Range values", {
  population <- Population$new(rich_population_data)
  expect_snapshot(
    error = TRUE,
    population$disease_state_parameters <- list(eGFR = list(min = 60))
  )
})

test_that("egfr_range setter persists into population data", {
  population <- Population$new(rich_population_data)

  population$egfr_range <- range(30, 90, "ml/min/1.73m²")
  egfr_entry <- Filter(
    function(p) tolower(p$Name) == "egfr",
    population$data$Settings$DiseaseStateParameters
  )
  expect_length(egfr_entry, 1)
  expect_equal(egfr_entry[[1]]$Min, 30)
  expect_equal(egfr_entry[[1]]$Max, 90)
  expect_equal(
    population$disease_state_parameters[["eGFR"]]$min,
    30
  )
  # Other entries are preserved
  expect_length(population$data$Settings$DiseaseStateParameters, 2)

  population$egfr_range <- NULL
  expect_null(population$egfr_range)
  egfr_after <- Filter(
    function(p) tolower(p$Name) == "egfr",
    population$data$Settings$DiseaseStateParameters
  )
  expect_length(egfr_after, 0)
  # The non-eGFR entry survives removal of eGFR
  expect_length(population$data$Settings$DiseaseStateParameters, 1)
})

test_that("egfr_range set to NULL drops empty DiseaseStateParameters key", {
  population <- Population$new(complete_population_data)
  population$egfr_range <- NULL
  expect_null(population$data$Settings$DiseaseStateParameters)
})

test_that("Population individual binding is read-only and derived", {
  population <- Population$new(rich_population_data)
  expect_s3_class(population$individual, "Individual")
  expect_equal(population$individual$name, "Base")

  minimal_population <- Population$new(minimal_population_data)
  expect_null(minimal_population$individual)
})

test_that("Population round-trips all fields added in #118", {
  pop <- create_population(
    name = "Round Trip",
    number_of_individuals = 25,
    individual = create_individual(
      name = "Base",
      species = "Human",
      population = "European_ICRP_2002",
      gender = "MALE"
    ),
    gestational_age_range = range(37, 42, "week(s)"),
    disease_state_parameters = list(eGFR = range(60, 120, "ml/min/1.73m²")),
    description = "Adults with reduced renal function"
  )
  expect_equal(Population$new(pop$data)$data, pop$data)
})

test_that("Population to_df method returns correct data frames", {
  # Create test population objects
  complete_population <- Population$new(complete_population_data)
  minimal_population <- Population$new(minimal_population_data)

  # Get data frames
  complete_dfs <- complete_population$to_df()
  minimal_dfs <- minimal_population$to_df()

  # Test complete population data frames
  expect_type(complete_dfs, "list")
  expect_named(complete_dfs, c("characteristics", "parameters"))
  expect_s3_class(complete_dfs$characteristics, "tbl_df")
  expect_s3_class(complete_dfs$parameters, "tbl_df")

  # Check characteristics data frame
  expect_equal(complete_dfs$characteristics$population_id, "Test Population")
  expect_equal(complete_dfs$characteristics$seed, 12345)
  expect_equal(complete_dfs$characteristics$number_of_individuals, 100)
  expect_equal(complete_dfs$characteristics$proportion_of_females, 50)
  expect_equal(
    complete_dfs$characteristics$source_population,
    "European_ICRP_2002"
  )
  expect_equal(
    complete_dfs$characteristics$individual_name,
    "European Reference"
  )

  # Check parameters data frame for complete population
  expect_gt(nrow(complete_dfs$parameters), 0)
  expect_equal(complete_dfs$parameters$population_id[1], "Test Population")
  expect_equal(complete_dfs$parameters$parameter[1], "Liver Volume")
  expect_equal(complete_dfs$parameters$seed[1], 54321)
  expect_equal(complete_dfs$parameters$distribution_type[1], "Normal")

  # Test minimal population data frames
  expect_type(minimal_dfs, "list")
  expect_named(minimal_dfs, c("characteristics", "parameters"))
  expect_s3_class(minimal_dfs$characteristics, "tbl_df")
  expect_s3_class(minimal_dfs$parameters, "tbl_df")

  # Check characteristics data frame for minimal population
  expect_equal(minimal_dfs$characteristics$population_id, "Minimal Population")
  expect_equal(minimal_dfs$characteristics$number_of_individuals, 10)

  # Check parameters data frame for minimal population (should be empty)
  expect_equal(nrow(minimal_dfs$parameters), 0)
})

test_that("AdvancedParameter class works correctly", {
  # Get advanced parameter from the population
  population <- Population$new(complete_population_data)
  advanced_param <- population$advanced_parameters[[1]]

  # Test properties
  expect_equal(advanced_param$name, "Liver Volume")
  expect_equal(advanced_param$seed, 54321)
  expect_equal(advanced_param$distribution_type, "Normal")
  expect_type(advanced_param$parameters, "list")
  expect_length(advanced_param$parameters, 2)

  # Test parameter values
  expect_equal(advanced_param$parameters[[1]]$Name, "Mean")
  expect_equal(advanced_param$parameters[[1]]$Value, 1.5)
  expect_equal(advanced_param$parameters[[1]]$Unit, "l")

  expect_equal(advanced_param$parameters[[2]]$Name, "Geometric SD")
  expect_equal(advanced_param$parameters[[2]]$Value, 1.2)

  # Test modifying properties
  advanced_param$name <- "Modified Parameter"
  expect_equal(advanced_param$name, "Modified Parameter")

  advanced_param$seed <- 98765
  expect_equal(advanced_param$seed, 98765)

  advanced_param$distribution_type <- "LogNormal"
  expect_equal(advanced_param$distribution_type, "LogNormal")
  expect_snapshot(error = TRUE, advanced_param$distribution_type <- "Weibull")

  # Test print method
  expect_snapshot(print(advanced_param))
})

# ---- Population dataframe tests ----
test_that("get_populations_dfs returns correct data frames", {
  # Test with a snapshot containing populations
  dfs <- get_populations_dfs(test_snapshot)
  expect_type(dfs, "list")
  expect_named(dfs, c("populations", "populations_parameters"))
  expect_s3_class(dfs$populations, "tbl_df")
  expect_s3_class(dfs$populations_parameters, "tbl_df")
  expect_snapshot(dfs$populations)
  expect_snapshot(dfs$populations_parameters)

  # Test with an empty snapshot
  dfs_empty <- get_populations_dfs(empty_snapshot)
  expect_type(dfs_empty, "list")
  expect_named(dfs_empty, c("populations", "populations_parameters"))
  expect_s3_class(dfs_empty$populations, "tbl_df")
  expect_s3_class(dfs_empty$populations_parameters, "tbl_df")
  expect_snapshot(dfs_empty$populations)
  expect_snapshot(dfs_empty$populations_parameters)
})

test_that("Snapshot with empty populations is handled correctly", {
  snapshot <- empty_snapshot$clone()

  # Check that populations is an empty list
  expect_type(snapshot$populations, "list")
  expect_length(snapshot$populations, 0)

  # Print should not error
  expect_snapshot(print(snapshot$populations))
})
