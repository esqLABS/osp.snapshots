test_that("ObserverSetSelection exposes name", {
  raw <- list(Name = "BrainPlasmaConcentration")
  sel <- ObserverSetSelection$new(raw)

  expect_s3_class(sel, "ObserverSetSelection")
  expect_equal(sel$name, "BrainPlasmaConcentration")
  expect_identical(sel$data, raw)
})

test_that("ObserverSetSelection setter mutates raw data", {
  sel <- ObserverSetSelection$new(list(Name = "A"))
  sel$name <- "B"
  expect_equal(sel$data$Name, "B")
})

test_that("ObserverSetSelection$data is read-only", {
  sel <- ObserverSetSelection$new(list(Name = "A"))
  expect_snapshot(error = TRUE, sel$data <- list())
})
