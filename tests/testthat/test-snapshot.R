test_that("Snapshot class works", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Test that snapshot loads correctly
  expect_s3_class(snapshot, "Snapshot")
  expect_type(snapshot$data, "list")
  expect_false(is.null(snapshot$path))

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


test_that("Snapshot path handling works correctly", {
  # Create a temporary JSON file
  temp_file <- withr::local_tempfile(fileext = ".json")

  # Create minimal snapshot data
  snapshot_data <- list(Version = 80)
  jsonlite::write_json(snapshot_data, temp_file)

  # Get absolute path
  abs_path <- normalizePath(temp_file)

  # Load snapshot from file
  snapshot <- Snapshot$new(temp_file)

  # Test that the path is stored as absolute path internally
  expect_equal(snapshot$.__enclos_env__$private$.abs_path, abs_path)

  # Test that path active binding returns relative path
  expected_rel_path <- fs::path_rel(abs_path, start = getwd())
  expect_equal(snapshot$path, expected_rel_path)

  # Test exporting to a new location
  new_temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(new_temp_file)

  # Check that the new path is stored correctly
  new_abs_path <- normalizePath(new_temp_file)
  expect_equal(snapshot$.__enclos_env__$private$.abs_path, new_abs_path)

  # Check that the path active binding returns the new relative path
  new_rel_path <- fs::path_rel(new_abs_path, start = getwd())
  expect_equal(snapshot$path, new_rel_path)

  expect_equal(
    test_snapshot$path,
    fs::path_rel(testthat::test_path("data", "test_snapshot.json"))
  )
})


test_that("load_snapshot handles local file paths", {
  # Test with an existing file
  snapshot <- test_snapshot$clone()
  expect_s3_class(snapshot, "Snapshot")

  # Test with invalid input
  expect_error(load_snapshot(NULL), "Source must be a single character string")
  expect_error(
    load_snapshot(c("file1.json", "file2.json")),
    "Source must be a single character string"
  )
  expect_error(load_snapshot(123), "Source must be a single character string")
})

test_that("load_snapshot handles OSP Models", {
  expect_snapshot(load_snapshot("Rifampicin"))
})


test_that("load_snapshot handles URL input", {
  # Define a real URL to use for testing
  test_url <- "https://raw.githubusercontent.com/Open-Systems-Pharmacology/Efavirenz-Model/refs/heads/master/Efavirenz-Model.json"

  # Skip this test if there's no internet connection
  testthat::skip_if_offline()

  # Test with a valid URL
  tryCatch(
    {
      snapshot <- load_snapshot(test_url)
      expect_s3_class(snapshot, "Snapshot")
      expect_equal(snapshot$path, test_url) # path should be the URL for URL-based snapshots
      expect_true("Compounds" %in% names(snapshot$data))
      expect_true("Individuals" %in% names(snapshot$data))
    },
    error = function(e) {
      skip(glue::glue("Could not access test URL: {e$message}"))
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
  snapshot <- test_snapshot$clone()

  expect_snapshot(snapshot)
})

test_that("Snapshot compounds are initialized correctly", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

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
      glue::glue("{first_individual$name}_1") %in%
        individual_names ||
        glue::glue("{first_individual$name}_2") %in% individual_names
    )
  }
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
  expect_no_error(testthat::skip_if_offline())
})

test_that("All main sections are empty in an empty snapshot", {
  snapshot <- empty_snapshot$clone()
  expect_s3_class(snapshot, "Snapshot")
  expect_s3_class(snapshot$compounds, "compound_collection")
  expect_length(snapshot$compounds, 0)
  expect_s3_class(snapshot$individuals, "individual_collection")
  expect_length(snapshot$individuals, 0)
  expect_s3_class(snapshot$populations, "population_collection")
  expect_length(snapshot$populations, 0)
  expect_s3_class(snapshot$formulations, "formulation_collection")
  expect_length(snapshot$formulations, 0)
  expect_s3_class(snapshot$expression_profiles, "expression_profile_collection")
  expect_length(snapshot$expression_profiles, 0)
  expect_s3_class(snapshot$events, "event_collection")
  expect_length(snapshot$events, 0)
  # Check data field for all main sections
  expect_equal(snapshot$data$Compounds, list())
  expect_equal(snapshot$data$Individuals, list())
  expect_equal(snapshot$data$Populations, list())
  expect_equal(snapshot$data$Formulations, list())
  expect_equal(snapshot$data$ExpressionProfiles, list())
  expect_equal(snapshot$data$Events, list())
  expect_equal(snapshot$data$Simulations, list())
  expect_equal(snapshot$data$Protocols, list())
  expect_equal(snapshot$data$ObserverSets, list())
  expect_equal(snapshot$data$ObservedData, list())
  expect_equal(snapshot$data$ObservedDataClassifications, list())
  expect_equal(snapshot$data$ParameterIdentifications, list())
})

test_that("export_snapshot function works correctly", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Test with valid inputs
  temp_file <- withr::local_tempfile(fileext = ".json")
  result <- export_snapshot(snapshot, temp_file)

  # Check that the function returns the snapshot invisibly
  expect_s3_class(result, "Snapshot")
  expect_identical(result, snapshot)

  # Check that the file was created
  expect_true(file.exists(temp_file))

  # Verify the exported data is valid JSON
  exported_data <- jsonlite::fromJSON(temp_file, simplifyDataFrame = FALSE)
  expect_equal(exported_data$Version, snapshot$data$Version)

  # Test error handling for invalid snapshot input
  expect_error(
    export_snapshot("not_a_snapshot", temp_file),
    "Expected a Snapshot object"
  )

  expect_error(
    export_snapshot(NULL, temp_file),
    "Expected a Snapshot object"
  )

  # Test error handling for invalid path input
  expect_error(
    export_snapshot(snapshot, NULL),
    "Path must be a single character string"
  )

  expect_error(
    export_snapshot(snapshot, c("path1", "path2")),
    "Path must be a single character string"
  )

  expect_error(
    export_snapshot(snapshot, 123),
    "Path must be a single character string"
  )

  # Test missing path argument
  expect_error(
    export_snapshot(snapshot),
    "Path must be a single character string"
  )
})
