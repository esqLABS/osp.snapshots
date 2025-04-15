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

test_that("Snapshot data can be exported and reimported", {
  # Create a snapshot object from test data
  snapshot <- test_snapshot$clone()

  # Use local_tempfile instead of on.exit
  temp_file <- withr::local_tempfile(fileext = ".json")

  # Export to file
  snapshot$export(temp_file)
  expect_true(file.exists(temp_file))

  # Import the file as a list rather than creating another temporary Snapshot
  exported_data <- jsonlite::fromJSON(temp_file, simplifyDataFrame = FALSE)

  # Create a new snapshot directly from the parsed data
  snapshot2 <- Snapshot$new(exported_data)

  # Use a more targeted approach to verify critical parts of the data
  # Check version
  expect_equal(snapshot$data$Version, snapshot2$data$Version)

  # Check Compounds if they exist
  if (!is.null(snapshot$data$Compounds)) {
    expect_equal(
      length(snapshot$data$Compounds),
      length(snapshot2$data$Compounds)
    )
    if (length(snapshot$data$Compounds) > 0) {
      # Check compound names
      expect_equal(
        sapply(snapshot$data$Compounds, function(x) x$Name),
        sapply(snapshot2$data$Compounds, function(x) x$Name)
      )
    }
  }

  # Check Individuals if they exist
  if (!is.null(snapshot$data$Individuals)) {
    expect_equal(
      length(snapshot$data$Individuals),
      length(snapshot2$data$Individuals)
    )
    if (length(snapshot$data$Individuals) > 0) {
      # Check individual names
      expect_equal(
        sapply(snapshot$data$Individuals, function(x) x$Name),
        sapply(snapshot2$data$Individuals, function(x) x$Name)
      )

      # Check individual parameters
      for (i in seq_along(snapshot$data$Individuals)) {
        if (!is.null(snapshot$data$Individuals[[i]]$Parameters)) {
          expect_equal(
            length(snapshot$data$Individuals[[i]]$Parameters),
            length(snapshot2$data$Individuals[[i]]$Parameters)
          )
        }
      }
    }
  }

  # Check other important sections
  for (section in c("Simulations", "Protocols", "Observers")) {
    if (!is.null(snapshot$data[[section]])) {
      expect_equal(
        length(snapshot$data[[section]]),
        length(snapshot2$data[[section]])
      )
    }
  }
})

test_that("Snapshot print method works", {
  # Create a snapshot object
  snapshot <- Snapshot$new(test_snapshot_path)

  expect_snapshot(snapshot)
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
    suppressWarnings(load_snapshot(
      "https://not-a-real-url.example/snapshot.json"
    )),
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

  # Use our new helper function to create invalid JSON file
  invalid_json_content <- "This is not valid JSON"
  invalid_json_file <- withr::local_tempfile(fileext = ".json")
  writeLines(invalid_json_content, invalid_json_file)

  # This should error with a JSON parsing error - use regex to match the error message
  expect_error(
    Snapshot$new(invalid_json_file),
    "lexical error: invalid char in json text"
  )
})

test_that("Snapshot$export creates a valid JSON file", {
  # Create a snapshot using our local_snapshot helper
  snapshot_data <- list(
    Version = 80,
    Compounds = list(),
    Individuals = list()
  )

  snapshot <- local_snapshot(snapshot_data)

  # Export to a temporary file
  temp_file <- withr::local_tempfile(fileext = ".json")
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
  # Use a local definition with withr for test scoping
  expect_no_error(skip_if_offline())
})
