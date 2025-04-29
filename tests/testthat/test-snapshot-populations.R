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

test_that("Populations can be removed from snapshot", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()
  initial_count <- length(snapshot$populations)

  # Get a population name to remove
  if (initial_count > 0) {
    pop_name <- names(snapshot$populations)[1]

    # Remove the population
    snapshot$remove_population(pop_name)

    # Check that the population was removed
    expect_equal(length(snapshot$populations), initial_count - 1)
    expect_false(pop_name %in% names(snapshot$populations))
  } else {
    # If no populations, just test that warning is issued but no error
    expect_warning(
      snapshot$remove_population("NonExistentPopulation"),
      "not found"
    )
  }

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
    c("characteristics", "parameters") %in%
      names(dfs)
  ))

  # Check characteristics dataframe structure
  expect_true(inherits(dfs$characteristics, "tbl"))

  expect_equal(nrow(dfs$characteristics), length(snapshot$populations))

  # Check advanced parameters dataframe structure
  expect_true(inherits(dfs$parameters, "tbl"))

  # Snapshot the outputs
  expect_snapshot(knitr::kable(dfs))
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
    "Min must be less than or equal to max"
  )

  expect_error(
    weight_range$max <- 50,
    "Max must be greater than or equal to min"
  )

  expect_error(
    weight_range$min <- "invalid",
    "Min must be a numeric value"
  )

  # Test with equal min and max
  equal_range <- Range$new(50, 50, "kg")
  expect_equal(equal_range$min, 50)
  expect_equal(equal_range$max, 50)

  # Test setting min equal to max
  weight_range$min <- 95
  expect_equal(weight_range$min, 95)

  # Test setting max equal to min
  weight_range$min <- 60
  weight_range$max <- 60
  expect_equal(weight_range$min, 60)
  expect_equal(weight_range$max, 60)

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
  expect_equal(weight_range$max, 60)

  weight_range$min <- 50 # Reset min
  weight_range$max <- NULL
  expect_equal(weight_range$min, 50)
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

  # Test with equal min and max
  equal_range <- range(70, 70, "cm")
  expect_equal(equal_range$min, 70)
  expect_equal(equal_range$max, 70)

  # Error for invalid range
  expect_error(
    range(180, 160, "cm"),
    "Min must be less than or equal to max"
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
  # Use a population from the test snapshot
  snapshot <- test_snapshot$clone()

  population <- snapshot$populations[[6]]

  # Capture initial weight values for reference
  initial_age_min <- population$age_range$min
  initial_age_max <- population$age_range$max

  # Modify individual properties
  population$age_range$max <- initial_age_max + 5
  expect_equal(population$age_range$max, initial_age_max + 5)
  expect_equal(population$data$Settings$Age$Max, initial_age_max + 5)

  population$age_range$min <- initial_age_min + 5
  expect_equal(population$age_range$min, initial_age_min + 5)
  expect_equal(population$data$Settings$Age$Min, initial_age_min + 5)

  population$age_range$unit <- "years"
  expect_equal(population$age_range$unit, "years")
  expect_equal(population$data$Settings$Age$Unit, "years")

  # Replace the entire range
  new_range <- range(70, 100, "years")
  population$age_range <- new_range

  expect_equal(population$age_range$min, 70)
  expect_equal(population$age_range$max, 100)
  expect_equal(population$age_range$unit, "years")

  expect_equal(population$data$Settings$Age$Min, 70)
  expect_equal(population$data$Settings$Age$Max, 100)
  expect_equal(population$data$Settings$Age$Unit, "years")

  # Test with NULL bounds
  population$age_range$max <- NULL
  expect_equal(population$age_range$min, 70)
  expect_null(population$age_range$max)
  expect_equal(population$data$Settings$Age$Min, 70)
  expect_null(population$data$Settings$Age$Max)

  # Reset the range with only max
  population$age_range <- range(NULL, 90, "years")
  expect_null(population$age_range$min)
  expect_equal(population$age_range$max, 90)
  expect_null(population$data$Settings$Age$Min)
  expect_equal(population$data$Settings$Age$Max, 90)

  # Test error message when modifying min, max or unit of a NULL range
  expect_error(
    population$height_range$min <- 60
  )
  expect_error(
    population$height_range$max <- 180
  )
  expect_error(
    population$height_range$unit <- "cm"
  )

  # Test adding a new range instead of NULL
  population$height_range <- range(160, 180, "cm")
  expect_equal(population$height_range$min, 160)
  expect_equal(population$height_range$max, 180)
  expect_equal(population$height_range$unit, "cm")
})
