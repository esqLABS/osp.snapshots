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
