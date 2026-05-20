test_that("FormulationSelection exposes name and key", {
  raw <- list(Name = "Oral solution", Key = "Formulation")
  sel <- FormulationSelection$new(raw)

  expect_s3_class(sel, "FormulationSelection")
  expect_equal(sel$name, "Oral solution")
  expect_equal(sel$key, "Formulation")
  expect_identical(sel$data, raw)
})

test_that("FormulationSelection setters mutate raw data", {
  sel <- FormulationSelection$new(list(Name = "A", Key = "K1"))
  sel$name <- "B"
  sel$key <- "K2"

  expect_equal(sel$data$Name, "B")
  expect_equal(sel$data$Key, "K2")
})

test_that("FormulationSelection$data is read-only", {
  sel <- FormulationSelection$new(list(Name = "A", Key = "K"))
  expect_snapshot(error = TRUE, sel$data <- list())
})
