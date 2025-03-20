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
                             "Unknown")
    expect_equal(snapshot$pksim_version, expected_version)
  }
  
  # Test that snapshot has basic structure
  expect_true(any(c("Compounds", "Individuals", "Simulations", "Protocols") %in% names(snapshot$data)),
              "Snapshot is missing expected sections")
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
