test_that("create_output_mapping happy path", {
  mapping <- create_output_mapping(
    path = "Organism|Plasma",
    observed_data = "Study A",
    scaling = "Log",
    weight = 1
  )

  expect_s3_class(mapping, "OutputMapping")
  expect_equal(mapping$path, "Organism|Plasma")
  expect_equal(mapping$observed_data, "Study A")
  expect_equal(mapping$scaling, "Log")
  expect_equal(mapping$weight, 1)
})

test_that("create_output_mapping serializes only supplied args", {
  mapping <- create_output_mapping(path = "p")
  expect_named(mapping$data, "Path")
})

test_that("create_output_mapping serializes weights as a list", {
  mapping <- create_output_mapping(weights = c(1, 0.5, 0.25))
  expect_equal(mapping$data$Weights, list(1, 0.5, 0.25))
})

test_that("create_output_mapping validates argument types", {
  expect_snapshot(error = TRUE, create_output_mapping(weight = "x"))
  expect_snapshot(error = TRUE, create_output_mapping(weights = "x"))
})

test_that("create_output_mapping validates scaling against the enum", {
  expect_snapshot(error = TRUE, create_output_mapping(scaling = "Sqrt"))
  mapping <- create_output_mapping(scaling = "Log")
  expect_equal(mapping$scaling, "Log")
})
