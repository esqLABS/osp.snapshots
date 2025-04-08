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
    expected_version <- switch(as.character(raw_version),
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

test_that("Snapshot data can be exported and reimported", {
  # Create a snapshot object from test data
  snapshot <- test_snapshot$clone()

  # We still need to test file export functionality, but we can minimize temp file usage
  temp_file <- tempfile(fileext = ".json")
  on.exit(unlink(temp_file), add = TRUE)

  # Export to file
  snapshot$export(temp_file)
  expect_true(file.exists(temp_file))

  # Import the file as a list rather than creating another temporary Snapshot
  exported_data <- jsonlite::fromJSON(temp_file, simplifyDataFrame = FALSE)

  # Create a new snapshot directly from the parsed data
  snapshot2 <- Snapshot$new(exported_data)

  # Verify the data matches the original
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

test_that("add_individual method works", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Create a new individual
  new_individual <- create_individual(
    name = "New Test Individual",
    species = "Human",
    gender = "MALE",
    age = 25,
    weight = 75,
    height = 180
  )

  # Add the individual to the snapshot
  snapshot$add_individual(new_individual)

  # Check that the individual was added
  expect_true("New Test Individual" %in% names(snapshot$individuals))
  expect_equal(snapshot$individuals[["New Test Individual"]], new_individual)

  # Check that the individual is included in the data
  expect_true(
    any(sapply(
      snapshot$data$Individuals,
      function(ind) ind$Name == "New Test Individual"
    ))
  )

  # Test with invalid input
  expect_error(
    snapshot$add_individual("not an individual"),
    "Expected an Individual object"
  )
})

test_that("add_individual_to_snapshot function works", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Create a new individual
  new_individual <- create_individual(
    name = "Function Test Individual",
    species = "Human",
    gender = "MALE",
    age = 40,
    weight = 85,
    height = 190
  )

  # Add the individual using the function
  result <- add_individual_to_snapshot(snapshot, new_individual)

  # Check that the individual was added
  expect_true("Function Test Individual" %in% names(snapshot$individuals))
  expect_equal(
    snapshot$individuals[["Function Test Individual"]],
    new_individual
  )

  # Check that the function returns the updated snapshot
  expect_equal(result, snapshot)

  # Test with invalid input
  expect_error(
    add_individual_to_snapshot("not a snapshot", new_individual),
    "Expected a Snapshot object"
  )
})

test_that("load_snapshot handles local file paths", {
  # Test with an existing file
  snapshot <- load_snapshot(test_snapshot_path)
  expect_s3_class(snapshot, "Snapshot")
  expect_equal(snapshot$path, test_snapshot_path)

  # Test with invalid input
  expect_error(load_snapshot(NULL), "Source must be a single character string")
  expect_error(
    load_snapshot(c("file1.json", "file2.json")),
    "Source must be a single character string"
  )
  expect_error(load_snapshot(123), "Source must be a single character string")
})

test_that("Snapshot compounds are initialized correctly", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  # Skip if there are no compounds in the test snapshot
  if (is.null(snapshot$data$Compounds)) {
    skip("Test snapshot does not contain compounds")
  }

  # Test compounds are initialized
  expect_s3_class(snapshot$compounds, "compound_collection")
  expect_s3_class(snapshot$compounds, "list")

  # Test compounds count matches raw data
  expect_equal(length(snapshot$compounds), length(snapshot$data$Compounds))

  # Test compound objects are properly created
  if (length(snapshot$compounds) > 0) {
    # Get the first compound
    first_compound_name <- names(snapshot$compounds)[1]
    first_compound <- snapshot$compounds[[first_compound_name]]

    # Test it's a Compound object
    expect_s3_class(first_compound, "Compound")

    # Test name matches (allowing for disambiguation)
    expect_true(
      startsWith(first_compound_name, first_compound$name) ||
        first_compound_name == first_compound$name
    )
  }
})

test_that("Snapshot handles duplicated individual and compound names correctly", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Add a duplicate individual
  if (length(snapshot$individuals) > 0) {
    first_individual <- snapshot$individuals[[1]]
    duplicate_individual <- create_individual(name = first_individual$name)
    snapshot$add_individual(duplicate_individual)

    # Check that the names are disambiguated
    individual_names <- names(snapshot$individuals)
    expect_true(
      paste0(first_individual$name, "_1") %in%
        individual_names ||
        paste0(first_individual$name, "_2") %in% individual_names
    )
  }
})


test_that("Snapshot initialization handles empty Compounds and Individuals", {
  # Use the minimal snapshot created in helper.R
  snapshot <- minimal_snapshot$clone()

  # Test that empty collections are initialized properly
  expect_s3_class(snapshot$compounds, "compound_collection")
  expect_length(snapshot$compounds, 0)

  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_length(snapshot$individuals, 0)
})

test_that("load_snapshot handles URL input", {
  # Define a real URL to use for testing
  test_url <- "https://raw.githubusercontent.com/Open-Systems-Pharmacology/Efavirenz-Model/refs/heads/master/Efavirenz-Model.json"

  # Skip this test if there's no internet connection
  skip_if_offline()

  # Test with a valid URL
  tryCatch(
    {
      snapshot <- load_snapshot(test_url)
      expect_s3_class(snapshot, "Snapshot")
      expect_null(snapshot$path) # path should be NULL for URL-based snapshots
      expect_true("Compounds" %in% names(snapshot$data))
      expect_true("Individuals" %in% names(snapshot$data))
    },
    error = function(e) {
      skip(paste("Could not access test URL:", e$message))
    }
  )

  # Test with an invalid URL
  expect_error(
    suppressWarnings(load_snapshot("https://not-a-real-url.example/snapshot.json")),
    "Failed to download snapshot from URL"
  )
})

test_that("load_snapshot handles template names", {
  # Skip this test if there's no internet connection
  skip_if_offline()

  # This test will try to access the template repository
  # and may fail if there are network issues or repository changes
  tryCatch(
    {
      # Mock the template lookup process by redefining the jsonlite::fromJSON function
      mock_fromJSON <- function(txt, ...) {
        if (grepl("templates.json", txt)) {
          return(list(
            Templates = data.frame(
              Name = c("Test1", "Test2"),
              Url = c(
                "https://raw.githubusercontent.com/Open-Systems-Pharmacology/Efavirenz-Model/refs/heads/master/Efavirenz-Model.json",
                "https://another-url.example/snapshot.json"
              )
            )
          ))
        } else {
          # For the actual template content, return the minimal snapshot data
          return(minimal_snapshot_data)
        }
      }

      testthat::with_mocked_bindings(
        {
          snapshot <- load_snapshot("Test1")
          expect_s3_class(snapshot, "Snapshot")
          expect_error(
            load_snapshot("NonExistentTemplate"),
            "No template found with name"
          )
        },
        fromJSON = mock_fromJSON,
        .package = "jsonlite"
      )
    },
    error = function(e) {
      skip(paste("Could not test template functionality:", e$message))
    }
  )
})

test_that("Snapshot handles duplicated compound names correctly", {
  # Create a snapshot with duplicate compound names
  snapshot_data <- list(
    Version = 80,
    Compounds = list(
      list(Name = "CompoundA", Path = "Path1"),
      list(Name = "CompoundA", Path = "Path2"),
      list(Name = "CompoundB", Path = "Path3")
    ),
    Individuals = NULL
  )

  snapshot <- Snapshot$new(snapshot_data)

  # Check that compounds were created
  expect_s3_class(snapshot$compounds, "compound_collection")
  expect_length(snapshot$compounds, 3)

  # Check for disambiguated names
  expect_true("CompoundA_1" %in% names(snapshot$compounds))
  expect_true("CompoundA_2" %in% names(snapshot$compounds))
  expect_true("CompoundB" %in% names(snapshot$compounds))

  # Check the original data is preserved
  expect_equal(snapshot$compounds$CompoundA_1$data$Name, "CompoundA")
  expect_equal(snapshot$compounds$CompoundA_1$data$Path, "Path1")
  expect_equal(snapshot$compounds$CompoundA_2$data$Name, "CompoundA")
  expect_equal(snapshot$compounds$CompoundA_2$data$Path, "Path2")
})

test_that("Snapshot handles duplicated individual names correctly", {
  # Create a snapshot with duplicate individual names
  snapshot_data <- list(
    Version = 80,
    Compounds = NULL,
    Individuals = list(
      list(Name = "IndividualA", Species = "Human"),
      list(Name = "IndividualA", Species = "Rat"),
      list(Name = "IndividualB", Species = "Human")
    )
  )

  snapshot <- Snapshot$new(snapshot_data)

  # Check that individuals were created
  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_length(snapshot$individuals, 3)

  # Check for disambiguated names
  expect_true("IndividualA_1" %in% names(snapshot$individuals))
  expect_true("IndividualA_2" %in% names(snapshot$individuals))
  expect_true("IndividualB" %in% names(snapshot$individuals))

  # Check the original data is preserved
  expect_equal(snapshot$individuals$IndividualA_1$name, "IndividualA")
  expect_equal(snapshot$individuals$IndividualA_1$data$Species, "Human")
  expect_equal(snapshot$individuals$IndividualA_2$name, "IndividualA")
  expect_equal(snapshot$individuals$IndividualA_2$data$Species, "Rat")
})

test_that("Snapshot handles empty individuals and compounds", {
  # Create a snapshot with empty individuals and compounds
  snapshot_data <- list(
    Version = 80,
    Compounds = list(),
    Individuals = list()
  )

  snapshot <- Snapshot$new(snapshot_data)

  # Check that collections were created but are empty
  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_length(snapshot$individuals, 0)

  expect_s3_class(snapshot$compounds, "compound_collection")
  expect_length(snapshot$compounds, 0)

  # Test the data field with empty collections
  expect_equal(snapshot$data$Compounds, list())
  expect_equal(snapshot$data$Individuals, list())
})

test_that("Snapshot handles missing individuals and compounds", {
  # Create a snapshot with no individuals or compounds section
  snapshot_data <- list(
    Version = 80
  )

  snapshot <- Snapshot$new(snapshot_data)

  # Check that collections were created but are empty
  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_length(snapshot$individuals, 0)

  expect_s3_class(snapshot$compounds, "compound_collection")
  expect_length(snapshot$compounds, 0)

  # Test the data field with empty collections
  expect_null(snapshot$data$Compounds)
  expect_null(snapshot$data$Individuals)
})

test_that("Snapshot can generate data with modified compounds and individuals", {
  # Create a snapshot with compounds and individuals
  snapshot_data <- list(
    Version = 80,
    Compounds = list(
      list(Name = "CompoundA", Path = "Path1")
    ),
    Individuals = list(
      list(
        Name = "IndividualA",
        Parameters = list(
          list(Path = "Param1", Value = 10)
        )
      )
    )
  )

  snapshot <- Snapshot$new(snapshot_data)

  # Modify the compound and individual
  snapshot$compounds$CompoundA$data$Path <- "ModifiedPath"
  snapshot$individuals$IndividualA$name <- "ModifiedIndividual"

  # Check the data field reflects the changes
  modified_data <- snapshot$data
  expect_equal(modified_data$Compounds[[1]]$Path, "ModifiedPath")
  expect_equal(modified_data$Individuals[[1]]$Name, "ModifiedIndividual")
})

test_that("Snapshot handles invalid input types", {
  # Test with NULL input
  expect_error(
    Snapshot$new(NULL),
    "Input must be either a path to a JSON file or a list"
  )

  # Test with numeric input
  expect_error(
    Snapshot$new(123),
    "Input must be either a path to a JSON file or a list"
  )

  # Instead of using a non-existent file, create a file with invalid JSON content
  invalid_json_file <- tempfile(fileext = ".json")
  on.exit(unlink(invalid_json_file), add = TRUE)

  # Write invalid JSON content
  writeLines("This is not valid JSON", invalid_json_file)

  # This should error with a JSON parsing error - use regex to match the error message
  expect_error(
    Snapshot$new(invalid_json_file),
    "lexical error: invalid char in json text"
  )
})

test_that("Snapshot$export creates a valid JSON file", {
  # Create a simple snapshot with empty lists instead of NULL
  snapshot_data <- list(
    Version = 80,
    Compounds = list(),
    Individuals = list()
  )

  snapshot <- Snapshot$new(snapshot_data)

  # Export to a temporary file
  temp_file <- tempfile(fileext = ".json")
  on.exit(unlink(temp_file), add = TRUE)

  snapshot$export(temp_file)

  # Verify the file exists and can be read
  expect_true(file.exists(temp_file))

  # Read the JSON file to verify structure
  json_data <- jsonlite::fromJSON(temp_file, simplifyDataFrame = FALSE)
  expect_equal(json_data$Version, 80)

  # Test that Compounds and Individuals are lists (may be named or unnamed)
  expect_type(json_data$Compounds, "list")
  expect_length(json_data$Compounds, 0)

  expect_type(json_data$Individuals, "list")
  expect_length(json_data$Individuals, 0)
})

test_that("Snapshot correctly handles version mapping for all known versions", {
  # Test all known version mappings
  versions <- list(
    "80" = "12.0",
    "79" = "11.2",
    "78" = "10.0",
    "77" = "9.1"
  )

  for (v in names(versions)) {
    snapshot_data <- list(Version = as.numeric(v))
    snapshot <- Snapshot$new(snapshot_data)
    expect_equal(snapshot$pksim_version, versions[[v]])
  }

  # Test unknown version
  snapshot_data <- list(Version = 999)
  snapshot <- Snapshot$new(snapshot_data)
  expect_equal(snapshot$pksim_version, "Unknown")
})

test_that("skip_if_offline helper works", {
  # Define a simple helper function to check internet connection
  skip_if_offline <- function() {
    has_connection <- tryCatch(
      {
        con <- url("https://www.r-project.org")
        open(con)
        close(con)
        TRUE
      },
      error = function(e) FALSE
    )

    if (!has_connection) {
      skip("No internet connection available")
    }
  }

  # Just testing that the function doesn't error
  expect_no_error(skip_if_offline())
})
