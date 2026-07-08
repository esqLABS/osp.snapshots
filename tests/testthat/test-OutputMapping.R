test_that("OutputMapping exposes every field", {
  raw <- list(
    Path = "Organism|Plasma",
    ObservedData = "Study A",
    Scaling = "Log",
    Weight = 1,
    Weights = list(1, 0.5)
  )
  mapping <- OutputMapping$new(raw)

  expect_s3_class(mapping, "OutputMapping")
  expect_equal(mapping$path, "Organism|Plasma")
  expect_equal(mapping$observed_data, "Study A")
  expect_equal(mapping$scaling, "Log")
  expect_equal(mapping$weight, 1)
  expect_equal(mapping$weights, list(1, 0.5))
  expect_identical(mapping$data, raw)
})

test_that("OutputMapping setters mutate raw data", {
  mapping <- OutputMapping$new(list(Path = "p"))
  mapping$scaling <- "Linear"
  expect_equal(mapping$data$Scaling, "Linear")
})

test_that("OutputMapping$path and $observed_data require non-empty strings", {
  mapping <- OutputMapping$new(list())
  mapping$path <- "Organism|..."
  expect_equal(mapping$path, "Organism|...")
  expect_snapshot(error = TRUE, mapping$path <- "")
  expect_snapshot(error = TRUE, mapping$path <- 5)

  mapping$observed_data <- "Study A"
  expect_equal(mapping$observed_data, "Study A")
  expect_snapshot(error = TRUE, mapping$observed_data <- "")
  expect_snapshot(error = TRUE, mapping$observed_data <- 5)
})

test_that("OutputMapping$scaling is validated against the enum", {
  mapping <- OutputMapping$new(list())
  mapping$scaling <- "Log"
  expect_equal(mapping$scaling, "Log")
  expect_snapshot(error = TRUE, mapping$scaling <- "Sqrt")
  mapping$scaling <- NULL
  expect_null(mapping$scaling)
})

test_that("OutputMapping$weight and $weights are type-checked", {
  mapping <- OutputMapping$new(list())
  mapping$weight <- 1
  expect_equal(mapping$weight, 1)
  expect_snapshot(error = TRUE, mapping$weight <- c(1, 2))
  expect_snapshot(error = TRUE, mapping$weight <- "x")

  mapping$weights <- c(1, 2, 3)
  expect_equal(mapping$weights, c(1, 2, 3))
  expect_snapshot(error = TRUE, mapping$weights <- "x")
})
