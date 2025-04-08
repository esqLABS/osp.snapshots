test_that("Snapshot class works", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  # Test that snapshot loads correctly
  expect_s3_class(snapshot, "Snapshot")
  expect_type(snapshot$data, "list")
  expect_false(is.null(snapshot$path))
  expect_equal(snapshot$path, test_snapshot_path)

  # Test pksim_version mapping
  if (!is.null(snapshot$data$Version)) {
    raw_version <- as.integer(snapshot$data$Version)
    expected_version <- switch(
      as.character(raw_version),
      "80" = "12.0",
      "79" = "11.2",
      "78" = "10.0",
      "77" = "9.1",
      "Unknown"
    )
    expect_equal(snapshot$pksim_version, expected_version)
  }

  # Test that snapshot has basic structure
  expect_true(
    any(
      c("Compounds", "Individuals", "Simulations", "Protocols") %in%
        names(snapshot$data)
    ),
    "Snapshot is missing expected sections"
  )
})

test_that("Snapshot export works", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  # Create a temporary file for export
  temp_file <- tempfile(fileext = ".json")
  on.exit(unlink(temp_file), add = TRUE)

  # Export and verify the file exists
  snapshot$export(temp_file)
  expect_true(file.exists(temp_file))

  # Import the exported file and verify it matches the original
  snapshot2 <- Snapshot$new(temp_file)
  expect_equal(snapshot$data, snapshot2$data)
})

test_that("Snapshot print method works", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  expect_snapshot(snapshot)
})

test_that("Snapshot individuals are initialized correctly", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  # Skip if there are no individuals in the test snapshot
  if (is.null(snapshot$data$Individuals)) {
    skip("Test snapshot does not contain individuals")
  }

  # Test individuals are initialized
  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_s3_class(snapshot$individuals, "list")

  # Test individuals count matches raw data
  expect_equal(length(snapshot$individuals), length(snapshot$data$Individuals))

  # Test individual objects are properly created
  if (length(snapshot$individuals) > 0) {
    # Get the first individual
    first_individual_name <- names(snapshot$individuals)[1]
    first_individual <- snapshot$individuals[[first_individual_name]]

    # Test it's an Individual object
    expect_s3_class(first_individual, "Individual")

    # Test name matches (allowing for disambiguation)
    expect_true(
      startsWith(first_individual_name, first_individual$name) ||
        first_individual_name == first_individual$name
    )
  }
})

test_that("Individual collection print method works", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  # Skip if there are no individuals in the test snapshot
  if (is.null(snapshot$data$Individuals)) {
    skip("Test snapshot does not contain individuals")
  }

  # Create a test with some individuals for a more predictable test
  test_individuals <- list(
    Individual$new(list(Name = "Individual 1")),
    Individual$new(list(Name = "Individual 2")),
    Individual$new(list(Name = "Individual 3"))
  )

  # Create a named list
  individuals_named <- list(
    "Individual 1" = test_individuals[[1]],
    "Individual 2" = test_individuals[[2]],
    "Individual 3" = test_individuals[[3]]
  )

  # Set the class for printing
  class(individuals_named) <- c("individual_collection", "list")

  # Test the print method
  expect_snapshot(print(individuals_named))
})

test_that("Individuals can be modified from the snapshot object and snapshot data is updated", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Get the first individual
  individual <- snapshot$individuals[[1]]

  # Changes properties
  individual$name <- paste0(individual$name, "_modified")
  individual$age <- individual$age + 10
  individual$species <- ospsuite::Species[1]
  # Modify weight and height
  individual$weight <- individual$weight + 5
  individual$height <- individual$height + 10

  # Switch gender to a different valid option
  current_gender <- individual$gender
  available_genders <- ospsuite::Gender
  new_gender <- available_genders[available_genders != current_gender][1]
  individual$gender <- new_gender

  # Change to a different population
  current_population <- individual$population
  available_populations <- ospsuite::HumanPopulation
  new_population <- available_populations[
    available_populations != current_population
  ][1]
  individual$population <- new_population

  # Get the first parameter and modify its value
  param_name <- names(individual$parameters)[1]
  original_value <- individual$parameters[[param_name]]$value
  individual$parameters[[param_name]]$value <- original_value * 1.2 # Increase by 20%

  expect_snapshot(snapshot$data$Individuals[[1]])
  expect_snapshot(snapshot$individuals[[1]])
})
