test_that("Populations can be accessed from snapshot", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Check that populations can be accessed
  expect_true(is.list(snapshot$populations))
  expect_true(length(snapshot$populations) > 0)
  expect_true(inherits(snapshot$populations, "population_collection"))

  # Print population collection
  expect_snapshot(snapshot$populations)

  # Check that each population is a Population object
  for (pop in snapshot$populations) {
    expect_true(inherits(pop, "Population"))
  }

  # Check for expected properties
  pop <- snapshot$populations[[1]]
  expect_true(is.character(pop$name))
  expect_true(is.numeric(pop$seed))
  expect_true(is.numeric(pop$number_of_individuals))
  expect_true(is.numeric(pop$proportion_of_females))

  # Check age range
  expect_true(inherits(pop$age_range, "Range"))
  expect_true(is.numeric(pop$age_range$min))
  expect_true(is.numeric(pop$age_range$max))
  expect_true(is.character(pop$age_range$unit))

  # Print population
  expect_snapshot(print(pop))
})

test_that("Populations can be modified from the snapshot object and snapshot data is updated", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Get the first population
  pop <- snapshot$populations[[1]]

  # Changes properties
  original_name <- pop$name
  pop$name <- glue::glue("{original_name}_modified")
  pop$seed <- 12345678
  pop$number_of_individuals <- pop$number_of_individuals + 10
  pop$proportion_of_females <- 75

  # Check that the changes were applied to the population object
  expect_equal(pop$name, glue::glue("{original_name}_modified"))
  expect_equal(pop$seed, 12345678)
  expect_equal(pop$proportion_of_females, 75)

  # Check that the changes were reflected in the snapshot data
  population_data <- snapshot$data$Populations[[1]]
  expect_equal(population_data$Name, glue::glue("{original_name}_modified"))
  expect_equal(population_data$Seed, 12345678)
  expect_equal(population_data$Settings$ProportionOfFemales, 75)

  # Take a snapshot of the modified data for reference
  expect_snapshot(snapshot$data$Populations[[1]])
})

test_that("Populations can be added and removed from snapshot", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()
  initial_count <- length(snapshot$populations)

  # Create a new population
  new_pop <- create_population(
    name = "Test Population",
    number_of_individuals = 50,
    proportion_of_females = 60,
    age_min = 30,
    age_max = 60,
    weight_min = 60,
    weight_max = 90,
    height_min = 160,
    height_max = 180
  )

  # Add the population to the snapshot
  snapshot$add_population(new_pop)

  # Check that the population was added
  expect_equal(length(snapshot$populations), initial_count + 1)
  expect_true("Test Population" %in% names(snapshot$populations))
  expect_equal(
    snapshot$populations[["Test Population"]]$number_of_individuals,
    50
  )

  # Remove the population
  snapshot$remove_population("Test Population")

  # Check that the population was removed
  expect_equal(length(snapshot$populations), initial_count)
  expect_false("Test Population" %in% names(snapshot$populations))

  # Try to remove a non-existent population (should warn but not error)
  expect_warning(
    snapshot$remove_population("NonExistentPopulation"),
    "not found"
  )
})

test_that("Populations can be converted to data frames", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Get data frames for all populations
  dfs <- get_populations_dfs(snapshot)

  # Check that all expected data frames are present
  expect_true(all(
    c("characteristics", "advanced_parameters") %in%
      names(dfs)
  ))

  # Check characteristics dataframe structure
  expect_true(inherits(dfs$characteristics, "tbl"))
  expect_true(all(
    c(
      "population_id",
      "name",
      "seed",
      "number_of_individuals",
      "proportion_of_females",
      "age_min",
      "age_max",
      "age_unit",
      "weight_min",
      "weight_max",
      "weight_unit"
    ) %in%
      names(dfs$characteristics)
  ))
  expect_equal(nrow(dfs$characteristics), length(snapshot$populations))

  # Check advanced parameters dataframe structure
  expect_true(inherits(dfs$advanced_parameters, "tbl"))
  expect_true(all(
    c("population_id", "parameter", "distribution_type", "seed") %in%
      names(dfs$advanced_parameters)
  ))

  # Test NULL min/max values
  # Create a population with only min or only max
  pop_with_open_range <- create_population(
    name = "Open Range Population",
    number_of_individuals = 100,
    proportion_of_females = 50,
    age_min = 18,
    age_max = 65
  )

  # Set weight range with only min
  pop_with_open_range$weight_range <- range(60, NULL, "kg")

  # Set height range with only max
  pop_with_open_range$height_range <- range(NULL, 180, "cm")

  # Add to snapshot
  snapshot$add_population(pop_with_open_range)

  # Get data frames again
  dfs <- get_populations_dfs(snapshot)

  # Find the row for our test population
  open_range_row <- dfs$characteristics[
    dfs$characteristics$name == "Open Range Population",
  ]

  # Check that weight has only min
  expect_equal(open_range_row$weight_min, 60)
  expect_true(is.na(open_range_row$weight_max))
  expect_equal(open_range_row$weight_unit, "kg")

  # Check that height has only max
  expect_true(is.na(open_range_row$height_min))
  expect_equal(open_range_row$height_max, 180)
  expect_equal(open_range_row$height_unit, "cm")
})

test_that("create_population creates valid population objects", {
  # Create a minimal population
  pop1 <- create_population(
    name = "Minimal Population",
    number_of_individuals = 100,
    proportion_of_females = 50,
    age_min = 18,
    age_max = 65
  )

  # Check that the population was created with expected properties
  expect_true(inherits(pop1, "Population"))
  expect_equal(pop1$name, "Minimal Population")
  expect_equal(pop1$number_of_individuals, 100)
  expect_equal(pop1$proportion_of_females, 50)
  expect_equal(pop1$age_range$min, 18)
  expect_equal(pop1$age_range$max, 65)
  expect_equal(pop1$age_range$unit, "year(s)")

  # Create a more detailed population
  pop2 <- create_population(
    name = "Detailed Population",
    number_of_individuals = 50,
    proportion_of_females = 60,
    age_min = 30,
    age_max = 60,
    age_unit = "year(s)",
    weight_min = 60,
    weight_max = 90,
    weight_unit = "kg",
    height_min = 160,
    height_max = 180,
    height_unit = "cm",
    seed = 12345
  )

  # Check that the population was created with expected properties
  expect_true(inherits(pop2, "Population"))
  expect_equal(pop2$name, "Detailed Population")
  expect_equal(pop2$number_of_individuals, 50)
  expect_equal(pop2$proportion_of_females, 60)
  expect_equal(pop2$seed, 12345)
  expect_equal(pop2$age_range$min, 30)
  expect_equal(pop2$age_range$max, 60)
  expect_equal(pop2$weight_range$min, 60)
  expect_equal(pop2$weight_range$max, 90)
  expect_equal(pop2$height_range$min, 160)
  expect_equal(pop2$height_range$max, 180)

  # Check validation errors
  expect_error(
    create_population(
      name = "Invalid Population",
      number_of_individuals = -5
    ),
    "must be a positive number"
  )

  expect_error(
    create_population(
      name = "Invalid Population",
      proportion_of_females = 150
    ),
    "must be a number between 0 and 100"
  )

  expect_error(
    create_population(
      name = "Invalid Population",
      age_min = 65,
      age_max = 18
    ),
    "Age min must be less than age max"
  )
})

test_that("Range class works correctly", {
  # Create a Range object
  weight_range <- Range$new(60, 90, "kg")

  # Check properties
  expect_true(inherits(weight_range, "Range"))
  expect_equal(weight_range$min, 60)
  expect_equal(weight_range$max, 90)
  expect_equal(weight_range$unit, "kg")

  # Test property modification
  weight_range$min <- 65
  expect_equal(weight_range$min, 65)

  weight_range$max <- 95
  expect_equal(weight_range$max, 95)

  weight_range$unit <- "g"
  expect_equal(weight_range$unit, "g")

  # Test validation
  expect_error(
    weight_range$min <- 100,
    "Min must be less than max"
  )

  expect_error(
    weight_range$max <- 50,
    "Max must be greater than min"
  )

  expect_error(
    weight_range$min <- "invalid",
    "Min must be a numeric value"
  )

  # Test print method returns invisibly
  expect_identical(weight_range, suppressMessages(weight_range$print()))

  # Test with NULL bounds
  min_only_range <- Range$new(60, NULL, "kg")
  expect_equal(min_only_range$min, 60)
  expect_null(min_only_range$max)

  max_only_range <- Range$new(NULL, 90, "kg")
  expect_null(max_only_range$min)
  expect_equal(max_only_range$max, 90)

  # Test setting bounds to NULL
  weight_range$min <- NULL
  expect_null(weight_range$min)
  expect_equal(weight_range$max, 95)

  weight_range$min <- 60 # Reset min
  weight_range$max <- NULL
  expect_equal(weight_range$min, 60)
  expect_null(weight_range$max)

  # Test validation with NULL bounds
  expect_error(
    Range$new(NULL, NULL, "kg"),
    "At least one of min or max must be specified"
  )

  expect_error(
    weight_range$min <- NULL,
    "Cannot set min to NULL when max is also NULL"
  )
})

test_that("range() function creates valid Range objects", {
  # Create a range
  height_range <- range(160, 180, "cm")

  # Check it's a Range object with correct properties
  expect_true(inherits(height_range, "Range"))
  expect_equal(height_range$min, 160)
  expect_equal(height_range$max, 180)
  expect_equal(height_range$unit, "cm")

  # Error for invalid range
  expect_error(
    range(180, 160, "cm"),
    "Min must be less than max"
  )

  # Test with NULL values
  min_only <- range(100, NULL, "cm")
  expect_equal(min_only$min, 100)
  expect_null(min_only$max)

  max_only <- range(NULL, 200, "cm")
  expect_null(max_only$min)
  expect_equal(max_only$max, 200)
})

test_that("Population ranges can be modified properly", {
  # Create a population
  population <- create_population(
    name = "Test Population",
    number_of_individuals = 100,
    proportion_of_females = 50,
    age_min = 18,
    age_max = 65,
    weight_min = 60,
    weight_max = 90,
    weight_unit = "kg"
  )

  # Check initial ranges
  expect_equal(population$weight_range$min, 60)
  expect_equal(population$weight_range$max, 90)
  expect_equal(population$weight_range$unit, "kg")

  # Modify individual properties
  population$weight_range$min <- 65
  expect_equal(population$weight_range$min, 65)
  expect_equal(population$data$Settings$Weight$Min, 65)

  population$weight_range$max <- 95
  expect_equal(population$weight_range$max, 95)
  expect_equal(population$data$Settings$Weight$Max, 95)

  population$weight_range$unit <- "lb"
  expect_equal(population$weight_range$unit, "lb")
  expect_equal(population$data$Settings$Weight$Unit, "lb")

  # Replace the entire range
  new_range <- range(70, 100, "kg")
  population$weight_range <- new_range

  expect_equal(population$weight_range$min, 70)
  expect_equal(population$weight_range$max, 100)
  expect_equal(population$weight_range$unit, "kg")

  expect_equal(population$data$Settings$Weight$Min, 70)
  expect_equal(population$data$Settings$Weight$Max, 100)
  expect_equal(population$data$Settings$Weight$Unit, "kg")

  # Test with NULL bounds
  population$weight_range$max <- NULL
  expect_equal(population$weight_range$min, 70)
  expect_null(population$weight_range$max)
  expect_equal(population$data$Settings$Weight$Min, 70)
  expect_null(population$data$Settings$Weight$Max)

  # Reset the range with only max
  population$weight_range <- range(NULL, 90, "kg")
  expect_null(population$weight_range$min)
  expect_equal(population$weight_range$max, 90)
  expect_null(population$data$Settings$Weight$Min)
  expect_equal(population$data$Settings$Weight$Max, 90)

  # Try to assign an invalid value
  expect_error(
    population$weight_range <- 100,
    "weight_range must be a Range object"
  )

  # Test setting a range to NULL
  population$weight_range <- NULL
  expect_null(population$weight_range)
  expect_null(population$data$Settings$Weight)
})
