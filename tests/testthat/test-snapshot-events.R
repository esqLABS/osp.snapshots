test_that("Snapshot loads events correctly", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Check that events field exists
  expect_true(!is.null(snapshot$events))

  # Check that events are loaded correctly
  expect_true(inherits(snapshot$events, "event_collection"))
  expect_true(length(snapshot$events) > 0)

  # Spot check a few events to make sure they're accessible
  gb_emptying_events <- grep(
    "GB emptying",
    names(snapshot$events),
    value = TRUE
  )
  expect_true(length(gb_emptying_events) > 0)

  # Check that an event is properly loaded as an Event object
  gb_event_name <- gb_emptying_events[1]
  gb_event <- snapshot$events[[gb_event_name]]
  expect_true(inherits(gb_event, "Event"))
  expect_equal(gb_event$template, "Gallbladder emptying")
})

test_that("Events are included in the snapshot data", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Get the full data
  data <- snapshot$data

  # Check that Events section exists and has content
  expect_true(!is.null(data$Events))
  expect_true(length(data$Events) > 0)
})

test_that("get_events_dfs extracts events correctly", {
  # Create a snapshot object
  snapshot <- test_snapshot$clone()

  # Get events dataframes
  dfs <- get_events_dfs(snapshot)

  # Check structure of result
  expect_type(dfs, "list")
  expect_true(all(c("basic", "parameters") %in% names(dfs)))
  expect_s3_class(dfs$basic, "tbl_df")
  expect_s3_class(dfs$parameters, "tbl_df")

  # Check content of basic dataframe
  expect_equal(nrow(dfs$basic), length(snapshot$events))
  expect_true(all(c("event_id", "name", "template") %in% colnames(dfs$basic)))

  # Check that all event IDs match the names in the events collection
  expect_setequal(dfs$basic$event_id, names(snapshot$events))

  # Check parameters dataframe has expected structure and content
  if (nrow(dfs$parameters) > 0) {
    # Print the actual column names for diagnosis
    print("Actual columns in parameters dataframe:")
    print(colnames(dfs$parameters))

    expect_true(all(
      c("event_id", "parameter", "value", "unit") %in%
        colnames(dfs$parameters)
    ))

    # All event_ids in parameters should be in the basic dataframe
    expect_true(all(dfs$parameters$event_id %in% dfs$basic$event_id))
  }
})
