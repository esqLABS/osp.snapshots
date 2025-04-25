# Test for Range class numeric conversion
test_that("Range class correctly handles numeric values", {
  # Test with numeric values
  expect_no_error(Range$new(10, 20, "years"))

  # Test with string numbers
  expect_no_error(Range$new("10", "20", "years"))

  # Test with empty strings - now treated as NULL
  expect_no_error(Range$new("", 20, "years"))
  expect_no_error(Range$new(10, "", "years"))

  # Test with non-numeric strings
  expect_error(Range$new("abc", 20, "years"), "Min must be a numeric value")
  expect_error(Range$new(10, "abc", "years"), "Max must be a numeric value")

  # Test with NULL values
  expect_error(
    Range$new(NULL, NULL, "years"),
    "At least one of min or max must be specified"
  )
  expect_no_error(Range$new(NULL, 20, "years"))
  expect_no_error(Range$new(10, NULL, "years"))

  # Test with valid but non-standard numeric representations
  expect_no_error(Range$new("10.0", "20.0", "years"))
  expect_no_error(Range$new(" 10 ", " 20 ", "years")) # With spaces
})

# Test for snapshot export and import with different types of range values
test_that("Snapshot handles different types of range values in populations", {
  # Create a minimal snapshot with a population
  snapshot <- Snapshot$new({
    data <- list(
      Version = 70,
      Compounds = list(),
      Individuals = list(),
      Populations = list(
        list(
          Name = "Test Population",
          NumberOfIndividuals = 100,
          ProportionOfFemales = 50,
          Settings = list(
            Age = list(
              Min = 18,
              Max = 65,
              Unit = "years"
            ),
            Weight = list(
              Min = "60", # String representation
              Max = "90", # String representation
              Unit = "kg"
            ),
            Height = list(
              Min = "", # Empty string
              Max = 190,
              Unit = "cm"
            ),
            BMI = list(
              Min = 20,
              Max = 30, # Changed from NULL to a proper number
              Unit = "kg/m²"
            )
          )
        )
      )
    )
    data
  })

  # Temporary file for export
  temp_file <- withr::local_tempfile(fileext = ".json")

  # Export snapshot
  snapshot$export(temp_file)

  # Re-import and check for errors
  imported_data <- jsonlite::fromJSON(temp_file, simplifyDataFrame = FALSE)

  # Check the structure of the imported data
  cat("Age field structure:\n")
  print(str(imported_data$Populations[[1]]$Settings$Age))

  cat("\nWeight field structure:\n")
  print(str(imported_data$Populations[[1]]$Settings$Weight))

  cat("\nHeight field structure:\n")
  print(str(imported_data$Populations[[1]]$Settings$Height))

  cat("\nBMI field structure:\n")
  print(str(imported_data$Populations[[1]]$Settings$BMI))

  # Try to load the snapshot from the imported data
  # This should reveal if there are issues with the data types
  expect_no_error({
    new_snapshot <- Snapshot$new(imported_data)
  })
})
