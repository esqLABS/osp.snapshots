test_that("as_tibbles() returns the compounds tibble", {
  result <- as_tibbles(test_snapshot, "compounds")

  expect_s3_class(result, "tbl_df")
  expect_named(
    result,
    c(
      "compound",
      "category",
      "type",
      "parameter",
      "value",
      "unit",
      "data_source",
      "source"
    )
  )
  expect_gt(nrow(result), 0)
})

test_that("as_tibbles() returns the individuals list", {
  result <- as_tibbles(test_snapshot, "individuals")

  expect_named(
    result,
    c("individuals", "individuals_parameters", "individuals_expressions")
  )
  expect_s3_class(result$individuals, "tbl_df")
  expect_s3_class(result$individuals_parameters, "tbl_df")
  expect_s3_class(result$individuals_expressions, "tbl_df")
  expect_gt(nrow(result$individuals), 0)
})

test_that("as_tibbles() returns the formulations list", {
  result <- as_tibbles(test_snapshot, "formulations")

  expect_named(result, c("formulations", "formulations_parameters"))
  expect_s3_class(result$formulations, "tbl_df")
  expect_s3_class(result$formulations_parameters, "tbl_df")
})

test_that("as_tibbles() returns the populations list", {
  result <- as_tibbles(test_snapshot, "populations")

  expect_named(result, c("populations", "populations_parameters"))
  expect_s3_class(result$populations, "tbl_df")
  expect_s3_class(result$populations_parameters, "tbl_df")
})

test_that("as_tibbles() returns the events list", {
  result <- as_tibbles(test_snapshot, "events")

  expect_named(result, c("events", "events_parameters"))
  expect_s3_class(result$events, "tbl_df")
  expect_s3_class(result$events_parameters, "tbl_df")
})

test_that("as_tibbles() returns the expression profiles list", {
  result <- as_tibbles(test_snapshot, "expression_profiles")

  expect_named(
    result,
    c("expression_profiles", "expression_profiles_parameters")
  )
  expect_s3_class(result$expression_profiles, "tbl_df")
  expect_s3_class(result$expression_profiles_parameters, "tbl_df")
  expect_gt(nrow(result$expression_profiles), 0)
})

test_that("as_tibbles() returns the protocols tibble", {
  result <- as_tibbles(test_snapshot, "protocols")

  expect_s3_class(result, "tbl_df")
  expect_true("protocol_name" %in% names(result))
  expect_gt(nrow(result), 0)
})

test_that("as_tibbles() returns the observed_data tibble", {
  result <- as_tibbles(test_snapshot, "observed_data")

  expect_s3_class(result, "tbl_df")
  expect_true("name" %in% names(result))
  expect_true("xValues" %in% names(result))
})

test_that("as_tibbles() returns empty shapes for an empty snapshot", {
  for (kind in c(
    "compounds",
    "individuals",
    "formulations",
    "populations",
    "events",
    "expression_profiles",
    "protocols",
    "observed_data"
  )) {
    result <- as_tibbles(empty_snapshot, kind)
    if (is.data.frame(result)) {
      expect_equal(nrow(result), 0)
    } else {
      for (slot in names(result)) {
        expect_equal(nrow(result[[slot]]), 0)
      }
    }
  }
})

test_that("as_tibbles() errors for non-Snapshot input", {
  expect_snapshot(error = TRUE, as_tibbles(list(), "compounds"))
})

test_that("as_tibbles() errors for unknown kind", {
  expect_snapshot(error = TRUE, as_tibbles(test_snapshot, "nope"))
})

test_that("as_tibbles() errors for malformed kind", {
  expect_snapshot(error = TRUE, as_tibbles(test_snapshot, c("a", "b")))
  expect_snapshot(error = TRUE, as_tibbles(test_snapshot, NA_character_))
})

test_that("legacy get_*_dfs wrappers match as_tibbles output", {
  expect_identical(
    get_compounds_dfs(test_snapshot),
    as_tibbles(test_snapshot, "compounds")
  )
  expect_identical(
    get_individuals_dfs(test_snapshot),
    as_tibbles(test_snapshot, "individuals")
  )
  expect_identical(
    get_formulations_dfs(test_snapshot),
    as_tibbles(test_snapshot, "formulations")
  )
  expect_identical(
    get_populations_dfs(test_snapshot),
    as_tibbles(test_snapshot, "populations")
  )
  expect_identical(
    get_events_dfs(test_snapshot),
    as_tibbles(test_snapshot, "events")
  )
  expect_identical(
    get_expression_profiles_dfs(test_snapshot),
    as_tibbles(test_snapshot, "expression_profiles")
  )
  expect_identical(
    get_protocols_dfs(test_snapshot),
    as_tibbles(test_snapshot, "protocols")
  )
  expect_identical(
    get_observed_data_dfs(test_snapshot),
    as_tibbles(test_snapshot, "observed_data")
  )
})
