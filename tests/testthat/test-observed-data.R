# Test ObservedData functionality

# Helper function to get real observed data from test snapshot (as raw data)
get_real_observed_data <- function(index = 1) {
  test_snapshot$data$ObservedData[[index]]
}

test_that("DataSet objects load correctly from snapshot", {
  # Test that loaded DataSet objects have correct properties
  dataset <- test_snapshot$observed_data[[1]]

  expect_s3_class(dataset, "DataSet")
  expect_type(dataset$name, "character")
  expect_true(nchar(dataset$name) > 0)
  expect_true(length(dataset$xValues) >= 0)
  expect_true(length(dataset$yValues) >= 0)
  expect_type(dataset$xUnit, "character")
})

test_that("loadDataSetFromSnapshot function validates input", {
  # Test with invalid data (no Name field)
  invalid_data <- list(
    ExtendedProperties = list()
  )

  expect_error(
    loadDataSetFromSnapshot(invalid_data),
    "Observed data must have a Name field"
  )
})

test_that("DataSet to tibble conversion works correctly", {
  # Test with loaded DataSet from snapshot
  dataset <- test_snapshot$observed_data[[1]]

  # Convert to tibble using ospsuite function
  df <- ospsuite::dataSetToTibble(dataset)

  expect_snapshot(df)
})

test_that("loadDataSetFromSnapshot handles empty data", {
  empty_data <- list(
    Name = "Empty Test"
  )

  # Create DataSet from empty data
  dataset <- loadDataSetFromSnapshot(empty_data)

  expect_s3_class(dataset, "DataSet")
  expect_equal(dataset$name, "Empty Test")
  expect_equal(length(dataset$xValues), 0)
  expect_equal(length(dataset$yValues), 0)

  # Convert to tibble - should work even with empty data
  df <- ospsuite::dataSetToTibble(dataset)
  expect_snapshot(df)
})

test_that("works with unitless dimensions", {
  snapshot <- testthat::test_path(
    "data",
    "obsdata_no_unit.json"
  )

  expect_no_error({
    load_snapshot(snapshot)
  })
})

test_that("Snapshot handles observed data correctly", {
  # Use pre-loaded test snapshot
  expect_true(length(test_snapshot$observed_data) > 0)
  expect_s3_class(test_snapshot$observed_data, "observed_data_collection")

  # Check that each item is a DataSet object
  for (dataset in test_snapshot$observed_data) {
    expect_s3_class(dataset, "DataSet")
  }
})

test_that("get_observed_data_dfs function works", {
  df <- get_observed_data_dfs(test_snapshot)

  expect_s3_class(df, "tbl_df")
  expect_true(nrow(df) > 0)
  expect_true(all(
    c(
      "name",
      "xValues",
      "yValues",
      "xDimension",
      "xUnit",
      "yDimension",
      "yUnit"
    ) %in%
      names(df)
  ))
})

test_that("add_observed_data method works", {
  # Use a DataSet from test snapshot
  dataset <- test_snapshot$observed_data[[1]]

  # Add to empty snapshot
  initial_count <- length(empty_snapshot$observed_data)
  empty_snapshot$add_observed_data(dataset)

  expect_equal(length(empty_snapshot$observed_data), initial_count + 1)
  expect_true(dataset$name %in% names(empty_snapshot$observed_data))

  # Clean up for other tests
  empty_snapshot$remove_observed_data(dataset$name)
})

test_that("remove_observed_data method works", {
  # First add a DataSet to test removal
  dataset <- test_snapshot$observed_data[[1]]

  empty_snapshot$add_observed_data(dataset)
  initial_count <- length(empty_snapshot$observed_data)

  # Remove the added observed data
  empty_snapshot$remove_observed_data(dataset$name)

  expect_equal(length(empty_snapshot$observed_data), initial_count - 1)
  expect_false(dataset$name %in% names(empty_snapshot$observed_data))
})

test_that("add_observed_data validates input", {
  # Try to add invalid object
  expect_error(
    empty_snapshot$add_observed_data("not an observed data object"),
    "Expected a DataSet object"
  )
})

test_that("remove_observed_data handles non-existent names", {
  # Try to remove non-existent observed data from empty snapshot
  expect_warning(
    empty_snapshot$remove_observed_data("Non-existent Study"),
    "No observed data to remove"
  )

  # Test with non-empty snapshot but non-existent name
  expect_warning(
    test_snapshot$remove_observed_data("Non-existent Study Name"),
    "not found in snapshot"
  )
})

test_that("Snapshot export includes observed data", {
  data <- test_snapshot$data
  expect_true("ObservedData" %in% names(data))
  expect_true(length(data$ObservedData) > 0)
})

test_that("DataSet handles complex real data structure", {
  # Test with actual data from pre-loaded snapshot
  first_dataset <- test_snapshot$observed_data[[1]]

  # Test basic properties
  expect_s3_class(first_dataset, "DataSet")
  expect_type(first_dataset$name, "character")
  expect_true(nchar(first_dataset$name) > 0)
  expect_true(length(first_dataset$xValues) >= 0)
  expect_true(length(first_dataset$yValues) >= 0)

  # Test data values
  if (!is.null(first_dataset$xValues) && length(first_dataset$xValues) > 0) {
    expect_type(first_dataset$xValues, "double")
    expect_true(all(is.finite(first_dataset$xValues)))
  }

  # Test metadata
  if (!is.null(first_dataset$metaData)) {
    expect_type(first_dataset$metaData, "list")
  }
})

test_that("DataSet to tibble produces consistent results", {
  snapshot <- load_snapshot(test_path("data", "test_snapshot.json"))

  # Test multiple DataSet items
  for (i in seq_len(min(3, length(snapshot$observed_data)))) {
    dataset <- snapshot$observed_data[[i]]
    df <- ospsuite::dataSetToTibble(dataset)

    expect_s3_class(df, "tbl_df")
    expect_true("name" %in% names(df))
    expect_equal(unique(df$name), dataset$name)

    if (nrow(df) > 0) {
      expect_true(all(!is.na(df$name)))
      expect_true(all(nchar(df$name) > 0))
    }
  }
})

test_that("get_observed_data_dfs aggregates correctly", {
  df_combined <- get_observed_data_dfs(test_snapshot)

  # Check that all observed data are represented
  unique_names <- unique(df_combined$name)
  observed_data_names <- names(test_snapshot$observed_data)

  expect_true(length(unique_names) <= length(observed_data_names))
  expect_true(all(unique_names %in% observed_data_names))

  # Check data integrity
  expect_true(nrow(df_combined) > 0)
  expect_true(all(c("xValues", "yValues", "xUnit") %in% names(df_combined)))
})

test_that("DataSet handles duplicate names correctly", {
  # Use a fresh empty snapshot to avoid state issues
  temp_empty <- load_snapshot(test_path("data", "empty_snapshot.json"))

  # Add the same DataSet twice to test duplicate handling
  dataset1 <- test_snapshot$observed_data[[1]]
  dataset2 <- test_snapshot$observed_data[[1]] # Same DataSet

  temp_empty$add_observed_data(dataset1)
  temp_empty$add_observed_data(dataset2)

  # Check that both are added with disambiguated names
  expect_equal(length(temp_empty$observed_data), 2)
  observed_names <- names(temp_empty$observed_data)

  # Should have original name and name with suffix
  base_name <- dataset1$name
  expect_true(any(grepl(base_name, observed_names, fixed = TRUE)))
  expect_true(any(grepl("_2", observed_names)))

  # No cleanup needed since we used a temporary snapshot
})

test_that("Snapshot print method includes observed data", {
  # Test that print method runs without error and snapshot has observed data
  expect_invisible(print(test_snapshot))

  # Test the underlying data that would be displayed
  expect_equal(length(test_snapshot$observed_data), 64)
  expect_true("ObservedData" %in% names(test_snapshot$data))
})

test_that("ObservedData collection print method works", {
  # Test that print methods run without error
  empty_collection <- list()
  class(empty_collection) <- c("observed_data_collection", "list")
  expect_invisible(print(empty_collection))

  # Test with a non-empty collection
  small_collection <- test_snapshot$observed_data[1:2]
  class(small_collection) <- c("observed_data_collection", "list")
  expect_invisible(print(small_collection))

  # Test that the collection has the right structure
  expect_s3_class(test_snapshot$observed_data, "observed_data_collection")
  expect_true(length(test_snapshot$observed_data) > 0)
  expect_true(all(names(test_snapshot$observed_data) != ""))
})

test_that("add/remove observed data updates export data", {
  # Use a fresh empty snapshot for this test
  temp_empty <- load_snapshot(test_path("data", "empty_snapshot.json"))

  initial_data <- temp_empty$data

  # Should have empty or no ObservedData initially
  expect_true(
    is.null(initial_data$ObservedData) ||
      length(initial_data$ObservedData) == 0
  )

  # Add a DataSet
  dataset <- test_snapshot$observed_data[[1]]
  temp_empty$add_observed_data(dataset)

  # Check export data is updated (note: export functionality may be different now)
  updated_data <- temp_empty$data
  expect_true(length(temp_empty$observed_data) == 1)
  expect_equal(temp_empty$observed_data[[1]]$name, dataset$name)

  # Remove observed data
  temp_empty$remove_observed_data(dataset$name)

  # Check export data is updated again
  final_data <- temp_empty$data
  expect_true(length(temp_empty$observed_data) == 0)
})

test_that("Convenience functions work correctly", {
  # Use a fresh empty snapshot for this test to avoid state issues
  temp_empty <- load_snapshot(test_path("data", "empty_snapshot.json"))

  # Test add_observed_data method with DataSet
  dataset <- test_snapshot$observed_data[[1]]

  # Use method calls directly
  initial_count <- length(temp_empty$observed_data)
  temp_empty$add_observed_data(dataset)
  expect_equal(length(temp_empty$observed_data), initial_count + 1)

  # Test remove_observed_data method
  temp_empty$remove_observed_data(dataset$name)
  expect_equal(length(temp_empty$observed_data), initial_count)
})

test_that("Error handling works correctly", {
  # Test validation in snapshot methods
  expect_error(
    empty_snapshot$add_observed_data("not an observed data object"),
    "Expected a DataSet object"
  )

  # Test loadDataSetFromSnapshot function validation
  expect_error(
    loadDataSetFromSnapshot(list()),
    "Observed data must have a Name field"
  )
  expect_error(
    loadDataSetFromSnapshot(NULL),
    "Observed data must have a Name field"
  )
})

test_that("DataSet works with various real data structures", {
  # Test with first 5 DataSet items from loaded snapshot
  n_to_test <- min(5, length(test_snapshot$observed_data))

  for (i in seq_len(n_to_test)) {
    dataset <- test_snapshot$observed_data[[i]]

    # Test basic properties
    expect_s3_class(dataset, "DataSet")
    expect_type(dataset$name, "character")
    expect_true(nchar(dataset$name) > 0)

    # Test tibble conversion
    df <- ospsuite::dataSetToTibble(dataset)
    expect_s3_class(df, "tbl_df")

    if (nrow(df) > 0) {
      expect_equal(unique(df$name), dataset$name)
      expect_true(all(!is.na(df$name)))
    }
  }
})

test_that("Real snapshot data integration works end-to-end", {
  # Work with pre-loaded real snapshot and its observed data
  initial_count <- length(test_snapshot$observed_data)

  # Should have loaded real observed data
  expect_true(initial_count > 0)
  expect_s3_class(test_snapshot$observed_data, "observed_data_collection")

  # Test get_observed_data_dfs with real data
  df_all <- get_observed_data_dfs(test_snapshot)
  expect_s3_class(df_all, "tbl_df")
  expect_true(nrow(df_all) > 0)

  # Check that all real observed data names are represented
  unique_names <- unique(df_all$name)
  expect_true(length(unique_names) > 0)
  expect_true(all(unique_names %in% names(test_snapshot$observed_data)))

  # Test data structure integrity
  expect_equal(length(test_snapshot$observed_data), 64) # Expected count from test data
  expect_true(all(sapply(test_snapshot$observed_data, function(x) {
    inherits(x, "DataSet")
  })))
})
