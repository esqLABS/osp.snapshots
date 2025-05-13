# ---- Event logic tests ----
test_that("Event class initialization works", {
  # Test with parameters
  event <- Event$new(test_event_data)
  expect_s3_class(event, "R6")
  expect_true("Event" %in% class(event))
  expect_equal(event$name, "Test Meal")
  expect_equal(event$template, "Meal: Standard (Human)")
  expect_length(event$parameters, 3)

  # Test without parameters
  simple_event <- Event$new(simple_event_data)
  expect_s3_class(simple_event, "R6")
  expect_equal(simple_event$name, "GB emptying")
  expect_equal(simple_event$template, "Gallbladder emptying")
  expect_length(simple_event$parameters, 0)
})

test_that("Event getters and setters work", {
  event <- Event$new(test_event_data)

  # Test getters
  expect_equal(event$name, "Test Meal")
  expect_equal(event$template, "Meal: Standard (Human)")
  expect_equal(event$data, test_event_data)

  # Test setters
  event$name <- "Modified Meal"
  expect_equal(event$name, "Modified Meal")

  event$template <- "Meal: Modified (Human)"
  expect_equal(event$template, "Meal: Modified (Human)")

  # Test read-only data
  expect_error(event$data <- list(), "data is read-only")
})

test_that("Event parameters work correctly", {
  event <- Event$new(test_event_data)

  # Check parameter access
  expect_length(event$parameters, 3)
  expect_equal(event$parameters[[1]]$name, "Meal energy content")
  expect_equal(event$parameters[[1]]$value, 500)
  expect_equal(event$parameters[[1]]$unit, "kcal")

  # Check parameter modification
  new_params <- list(
    Parameter$new(list(Name = "New param", Value = 42))
  )
  event$parameters <- new_params
  expect_length(event$parameters, 1)
  expect_equal(event$parameters[[1]]$name, "New param")
  expect_equal(event$parameters[[1]]$value, 42)

  # Check raw data is updated
  expect_length(event$data$Parameters, 1)
  expect_equal(event$data$Parameters[[1]]$Name, "New param")
})

test_that("to_dataframe converts event to tibble correctly", {
  event <- Event$new(test_event_data)
  result <- event$to_dataframe()

  # Check event dataframe
  expect_s3_class(result$events, "tbl_df")
  expect_equal(result$events$name, "Test Meal")
  expect_equal(result$events$template, "Meal: Standard (Human)")

  # Check parameters dataframe
  expect_s3_class(result$events_parameters, "tbl_df")
  expect_equal(nrow(result$events_parameters), 3)
  expect_true("param_name" %in% colnames(result$events_parameters))
  expect_true("param_value" %in% colnames(result$events_parameters))
  expect_true("param_unit" %in% colnames(result$events_parameters))

  # Check simple event without parameters
  simple_event <- Event$new(simple_event_data)
  simple_result <- simple_event$to_dataframe()
  expect_s3_class(simple_result$events, "tbl_df")
  expect_equal(simple_result$events$name, "GB emptying")
  expect_null(simple_result$events_parameters)
})

test_that("print.event_collection works", {
  events <- list(
    Event$new(test_event_data),
    Event$new(simple_event_data)
  )
  names(events) <- c("meal", "gb")
  class(events) <- c("event_collection", "list")

  # Test printing (output captured by testthat)
  expect_snapshot(print(events))

  # Test empty collection
  empty_events <- list()
  class(empty_events) <- c("event_collection", "list")
  expect_snapshot(print(empty_events))
})


test_that("Test get_events_dfs", {
  snapshot <- test_snapshot$clone()

  expect_snapshot(snapshot$events)

  dfs <- get_events_dfs(snapshot)
  expect_snapshot(dfs)
})
