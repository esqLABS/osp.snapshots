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

  # Test print outputs
  expect_snapshot(print(complete_population))
  expect_snapshot(print(minimal_population))
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
    "Number of individuals must be a positive number"
  )
  expect_error(
    population$number_of_individuals <- -10,
    "Number of individuals must be a positive number"
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

# ---- Population snapshot interaction tests ----
# (Merged from test-snapshot-populations.R)
