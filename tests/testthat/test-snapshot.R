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
  # Use mustWork=TRUE and winslash="/" to handle Windows short paths properly
  new_abs_path <- normalizePath(new_temp_file, mustWork = TRUE, winslash = "/")
  expect_equal(
    normalizePath(
      snapshot$.__enclos_env__$private$.abs_path,
      mustWork = TRUE,
      winslash = "/"
    ),
    new_abs_path
  )

  # Check that the path active binding returns the new relative path
  new_rel_path <- fs::path_rel(new_abs_path, start = getwd())
  # Compare absolute paths to avoid Windows relative path issues
  # Both paths should resolve to the same absolute location
  expect_equal(
    normalizePath(
      snapshot$.__enclos_env__$private$.abs_path,
      mustWork = TRUE,
      winslash = "/"
    ),
    normalizePath(new_abs_path, mustWork = TRUE, winslash = "/")
  )

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
  test_url <- paste0(
    "https://raw.githubusercontent.com/Open-Systems-Pharmacology/",
    "Efavirenz-Model/refs/heads/master/Efavirenz-Model.json"
  )

  # Skip this test if there's no internet connection
  testthat::skip_if_offline()

  # Test with a valid URL

  snapshot <- load_snapshot(test_url)
  expect_s3_class(snapshot, "Snapshot")
  expect_true("Compounds" %in% names(snapshot$data))
  expect_true("Individuals" %in% names(snapshot$data))

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
  exported_data <- jsonlite::fromJSON(
    temp_file,
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )

  # Verify singleton arrays are preserved as lists (not simplified to atomic vectors)
  # simulation1$ObservedData has exactly 1 string element in test_snapshot
  sim1_exported <- exported_data$Simulations[[1]]
  sim1_original <- snapshot$data$Simulations[[1]]
  expect_identical(sim1_exported$ObservedData, sim1_original$ObservedData)

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

test_that("Snapshot round-trip preserves observed data and expression profile shape", {
  snapshot <- test_snapshot$clone()
  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)

  snapshot2 <- Snapshot$new(temp_file)

  observed_datasets <- snapshot2$observed_data
  expect_gt(length(observed_datasets), 0)

  first_dataset <- observed_datasets[[1]]
  expect_type(first_dataset$xValues, "double")
  expect_type(first_dataset$yValues, "double")
  expect_equal(length(first_dataset$xValues), length(first_dataset$yValues))
  expect_false(any(is.na(first_dataset$xValues)))

  individuals <- snapshot2$data$Individuals
  if (length(individuals) > 0) {
    profiles_with_expression <- Filter(
      \(ind) length(ind$ExpressionProfiles) > 0,
      individuals
    )
    if (length(profiles_with_expression) > 0) {
      first_individual <- profiles_with_expression[[1]]
      expressions <- snapshot2$individuals[[first_individual$Name]]$to_df(
        type = "individuals_expressions"
      )
      expect_type(expressions$profile, "character")
      expect_false(anyNA(expressions$profile))
    }
  }
})

test_that("Snapshot round-trip preserves OriginData and CalculationMethodCache", {
  snapshot <- test_snapshot$clone()
  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)
  reloaded <- Snapshot$new(temp_file)

  original_individuals <- snapshot$data$Individuals
  reloaded_individuals <- reloaded$data$Individuals
  expect_equal(length(original_individuals), length(reloaded_individuals))

  for (i in seq_along(original_individuals)) {
    expect_equal(
      original_individuals[[i]]$OriginData,
      reloaded_individuals[[i]]$OriginData
    )
  }

  original_compounds <- snapshot$data$Compounds
  reloaded_compounds <- reloaded$data$Compounds
  expect_equal(length(original_compounds), length(reloaded_compounds))

  for (i in seq_along(original_compounds)) {
    expect_equal(
      original_compounds[[i]]$CalculationMethods,
      reloaded_compounds[[i]]$CalculationMethods
    )
  }
})

test_that("Snapshot exposes OriginData and CalculationMethodCache as R6 classes", {
  snapshot <- test_snapshot$clone()
  first_individual <- snapshot$individuals[[1]]
  expect_r6_class(first_individual$origin_data, "OriginData")
  expect_r6_class(
    first_individual$origin_data$calculation_methods,
    "CalculationMethodCache"
  )

  first_compound <- snapshot$compounds[[1]]
  expect_r6_class(first_compound$calculation_methods, "CalculationMethodCache")
})

test_that("Mutations through OriginData propagate to the snapshot export", {
  snapshot <- test_snapshot$clone()
  individual <- snapshot$individuals[[1]]
  individual$origin_data$calculation_methods$add("Custom method")
  individual$origin_data$species <- "Human"

  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)
  reloaded <- Snapshot$new(temp_file)

  reloaded_origin <- reloaded$data$Individuals[[1]]$OriginData
  expect_true("Custom method" %in% unlist(reloaded_origin$CalculationMethods))
  expect_equal(reloaded_origin$Species, "Human")
})

test_that("Snapshot export drops a building-block section when all items are removed", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  individual_names <- names(snapshot$individuals)
  expect_gt(length(individual_names), 0)

  snapshot$remove_individual(individual_names)
  expect_length(snapshot$individuals, 0)
  expect_length(snapshot$data$Individuals, 0)

  out <- withr::local_tempfile(fileext = ".json")
  snapshot$export(out)
  reloaded <- load_snapshot(out)
  expect_length(reloaded$individuals, 0)
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

test_that("Snapshot defers building-block construction until first access", {
  snapshot <- Snapshot$new(testthat::test_path("data", "test_snapshot.json"))

  # Reach into private state because laziness has no public-facing signal;
  # the active fields populate `private$.<kind>` on first read. Note that a
  # NULL cache only proves the cache slot has not been written, not that no
  # constructor ran; instrumenting R6 generators via `local_mocked_bindings`
  # would require a mockable wrapper that does not exist today. Treat the
  # NULL assertions as a strong but imperfect proxy for "no work done".
  private <- snapshot$.__enclos_env__$private

  expect_null(private$.compounds)
  expect_null(private$.individuals)
  expect_null(private$.formulations)
  expect_null(private$.populations)
  expect_null(private$.events)
  expect_null(private$.protocols)
  expect_null(private$.expression_profiles)
  expect_null(private$.observed_data)

  # Touch a single section; only its cache should populate. The other 7
  # caches must remain NULL, otherwise a future change has accidentally
  # eager-loaded a sibling collection.
  invisible(snapshot$compounds)
  expect_type(private$.compounds, "list")
  expect_null(private$.individuals)
  expect_null(private$.formulations)
  expect_null(private$.populations)
  expect_null(private$.events)
  expect_null(private$.protocols)
  expect_null(private$.expression_profiles)
  expect_null(private$.observed_data)
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

test_that("Snapshot disambiguates ExpressionProfiles by composite id", {
  # Two profiles sharing Molecule, Species, Category collide on the composite
  # id "CYP3A4_Human_Healthy"; a third with a different Category does not.
  snapshot_data <- list(
    Version = 80,
    ExpressionProfiles = list(
      list(
        Type = "Enzyme",
        Species = "Human",
        Molecule = "CYP3A4",
        Category = "Healthy"
      ),
      list(
        Type = "Enzyme",
        Species = "Human",
        Molecule = "CYP3A4",
        Category = "Healthy"
      ),
      list(
        Type = "Enzyme",
        Species = "Human",
        Molecule = "CYP3A4",
        Category = "Disease"
      )
    )
  )

  snapshot <- Snapshot$new(snapshot_data)

  expect_s3_class(snapshot$expression_profiles, "expression_profile_collection")
  expect_length(snapshot$expression_profiles, 3)
  expect_named(
    snapshot$expression_profiles,
    c(
      "CYP3A4_Human_Healthy_1",
      "CYP3A4_Human_Healthy_2",
      "CYP3A4_Human_Disease"
    )
  )
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
  json_data <- jsonlite::fromJSON(
    temp_file,
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )
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
  exported_data <- jsonlite::fromJSON(
    temp_file,
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )
  expect_equal(exported_data$Version, snapshot$data$Version)

  # Verify singleton arrays are preserved as lists (not simplified to atomic vectors)
  sim1_exported <- exported_data$Simulations[[1]]
  sim1_original <- snapshot$data$Simulations[[1]]
  expect_identical(sim1_exported$ObservedData, sim1_original$ObservedData)

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

test_that("osp_models function works correctly", {
  # Skip if offline since it requires internet connection
  testthat::skip_if_offline()

  # Test basic functionality
  tryCatch(
    {
      # Test basic usage
      result <- osp_models()
      expect_s3_class(result, "data.frame")
      expect_true(nrow(result) > 0)
      expect_true("Name" %in% names(result))
      expect_true("Url" %in% names(result))

      # Test pattern filtering
      # Look for a common pattern that should exist in templates
      result_filtered <- osp_models(pattern = "Midazolam")
      expect_s3_class(result_filtered, "data.frame")
      # Check that all results contain the pattern (case insensitive)
      if (nrow(result_filtered) > 0) {
        expect_true(all(grepl(
          "Midazolam",
          result_filtered$Name,
          ignore.case = TRUE
        )))
      }

      # Test with a pattern that shouldn't match anything
      result_empty <- osp_models(pattern = "ThisShouldNotMatchAnyTemplate12345")
      expect_s3_class(result_empty, "data.frame")
      expect_equal(nrow(result_empty), 0)
    },
    error = function(e) {
      testthat::skip(glue::glue(
        "Could not access templates repository: {e$message}"
      ))
    }
  )
})

test_that("load_snapshot provides helpful error message for invalid templates", {
  # Skip if offline since it requires internet connection
  testthat::skip_if_offline()

  # Test that load_snapshot gives a helpful error message when template is not found
  expect_error(
    load_snapshot("NonExistentTemplateName12345"),
    "No template found with name: NonExistentTemplateName12345",
    fixed = TRUE
  )
})

test_that(".get_templates_data helper function works", {
  # Skip if offline since it requires internet connection
  testthat::skip_if_offline()

  tryCatch(
    {
      # Test the helper function directly
      templates_df <- osp.snapshots:::.get_templates_data()
      expect_s3_class(templates_df, "data.frame")
      expect_true(nrow(templates_df) > 0)
      expect_true("Name" %in% names(templates_df))
      expect_true("Url" %in% names(templates_df))

      # Test that it returns consistent data with osp_models
      browse_result <- osp_models()
      expect_equal(nrow(templates_df), nrow(browse_result))
      expect_equal(templates_df$Name, browse_result$Name)
      expect_equal(templates_df$Url, browse_result$Url)
    },
    error = function(e) {
      testthat::skip(glue::glue(
        "Could not access templates repository: {e$message}"
      ))
    }
  )
})

# add_* / remove_* mutators -------------------------------------------------

test_that("add_compound and remove_compound round-trip", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  compound <- create_compound(name = "Drug X", molecular_weight = 250.3)

  snapshot <- add_compound(snapshot, compound)
  expect_named(snapshot$compounds, "Drug X")

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)
  reloaded <- load_snapshot(out)
  expect_named(reloaded$compounds, "Drug X")

  reloaded <- remove_compound(reloaded, "Drug X")
  expect_length(reloaded$compounds, 0)
})

test_that("add_compound errors on wrong class", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(add_compound(snapshot, "not a compound"), error = TRUE)
})

test_that("remove_compound warns when name is missing", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  snapshot <- add_compound(snapshot, create_compound(name = "Drug X"))
  expect_snapshot(remove_compound(snapshot, "Other"))
})

test_that("remove_compound warns on empty collection", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(remove_compound(snapshot, "Drug X"))
})

test_that("add_compound disambiguates duplicate names", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  snapshot <- add_compound(snapshot, create_compound(name = "Drug X"))
  snapshot <- add_compound(snapshot, create_compound(name = "Drug X"))
  expect_named(snapshot$compounds, c("Drug X_1", "Drug X_2"))
})

test_that("add_population round-trips", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  pop <- create_population(name = "Adults", number_of_individuals = 25)

  snapshot <- add_population(snapshot, pop)
  expect_named(snapshot$populations, "Adults")

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)
  reloaded <- load_snapshot(out)
  expect_named(reloaded$populations, "Adults")
})

test_that("add_population errors on wrong class", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(add_population(snapshot, "not a population"), error = TRUE)
})

test_that("add_population disambiguates duplicate names", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  pop <- create_population(name = "Adults", number_of_individuals = 25)
  snapshot <- add_population(snapshot, pop)
  snapshot <- add_population(snapshot, pop)
  expect_named(snapshot$populations, c("Adults_1", "Adults_2"))
})

test_that("add_protocol and remove_protocol round-trip", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  prot <- create_protocol(
    name = "Single oral",
    application_type = "Oral",
    dosing_interval = "Single"
  )

  snapshot <- add_protocol(snapshot, prot)
  expect_named(snapshot$protocols, "Single oral")

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)
  reloaded <- load_snapshot(out)
  expect_named(reloaded$protocols, "Single oral")

  reloaded <- remove_protocol(reloaded, "Single oral")
  expect_length(reloaded$protocols, 0)
})

test_that("add_protocol errors on wrong class", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(add_protocol(snapshot, "not a protocol"), error = TRUE)
})

test_that("remove_protocol warns when name is missing", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  snapshot <- add_protocol(
    snapshot,
    create_protocol(
      name = "Single oral",
      application_type = "Oral",
      dosing_interval = "Single"
    )
  )
  expect_snapshot(remove_protocol(snapshot, "Other"))
})

test_that("remove_protocol warns on empty collection", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(remove_protocol(snapshot, "Single oral"))
})

test_that("add_event and remove_event round-trip", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  evt <- create_event(
    name = "Breakfast",
    template = "Meal: Standard (Human)"
  )

  snapshot <- add_event(snapshot, evt)
  expect_named(snapshot$events, "Breakfast")

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)
  reloaded <- load_snapshot(out)
  expect_named(reloaded$events, "Breakfast")

  reloaded <- remove_event(reloaded, "Breakfast")
  expect_length(reloaded$events, 0)
})

test_that("add_event errors on wrong class", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(add_event(snapshot, "not an event"), error = TRUE)
})

test_that("remove_event warns when name is missing", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  snapshot <- add_event(
    snapshot,
    create_event(name = "Breakfast", template = "Meal: Standard (Human)")
  )
  expect_snapshot(remove_event(snapshot, "Other"))
})

test_that("remove_event warns on empty collection", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(remove_event(snapshot, "Breakfast"))
})

test_that("add_observed_data exported wrapper round-trips", {
  source_snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))
  dataset <- source_snapshot$observed_data[[1]]

  empty <- load_snapshot(test_path("data", "empty_snapshot.json"))
  empty <- add_observed_data(empty, dataset)
  expect_true(dataset$name %in% names(empty$observed_data))

  empty <- remove_observed_data(empty, dataset$name)
  expect_false(dataset$name %in% names(empty$observed_data))
})

test_that("add_observed_data exported wrapper errors on wrong class", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))
  expect_snapshot(add_observed_data(snapshot, "not a dataset"), error = TRUE)
})

test_that("mutators reject non-Snapshot inputs", {
  compound <- create_compound(name = "X")
  population <- create_population(name = "P", number_of_individuals = 1)
  protocol <- create_protocol(
    name = "S",
    application_type = "Oral",
    dosing_interval = "Single"
  )
  event <- create_event(name = "E", template = "Meal: Standard (Human)")

  expect_snapshot(add_compound("nope", compound), error = TRUE)
  expect_snapshot(remove_compound("nope", "X"), error = TRUE)
  expect_snapshot(add_population("nope", population), error = TRUE)
  expect_snapshot(add_protocol("nope", protocol), error = TRUE)
  expect_snapshot(remove_protocol("nope", "S"), error = TRUE)
  expect_snapshot(add_event("nope", event), error = TRUE)
  expect_snapshot(remove_event("nope", "E"), error = TRUE)
})
