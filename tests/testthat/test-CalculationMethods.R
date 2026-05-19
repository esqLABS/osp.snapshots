test_that("CalculationMethods constructs from a character vector", {
  cm <- CalculationMethods$new(c("Method A", "Method B"))
  expect_r6_class(cm, "CalculationMethods")
  expect_equal(cm$names, c("Method A", "Method B"))
  expect_equal(cm$length, 2L)
})

test_that("CalculationMethods treats NULL and missing input as empty", {
  expect_equal(CalculationMethods$new()$names, character())
  expect_equal(CalculationMethods$new(NULL)$names, character())
  expect_equal(CalculationMethods$new(list())$length, 0L)
})

test_that("CalculationMethods constructs from a list of strings", {
  cm <- CalculationMethods$new(list("M1", "M2", "M3"))
  expect_equal(cm$names, c("M1", "M2", "M3"))
})

test_that("CalculationMethods rejects NA method names", {
  expect_snapshot(error = TRUE, CalculationMethods$new(c("a", NA)))
})

test_that("CalculationMethods$add appends a method", {
  cm <- CalculationMethods$new("First")
  cm$add("Second")
  expect_equal(cm$names, c("First", "Second"))
})

test_that("CalculationMethods$add validates the input", {
  cm <- CalculationMethods$new()
  expect_snapshot(error = TRUE, cm$add(c("a", "b")))
  expect_snapshot(error = TRUE, cm$add(NA_character_))
})

test_that("CalculationMethods$remove drops a method when present", {
  cm <- CalculationMethods$new(c("a", "b", "c"))
  cm$remove("b")
  expect_equal(cm$names, c("a", "c"))
})

test_that("CalculationMethods$remove is a no-op when absent", {
  cm <- CalculationMethods$new(c("a", "b"))
  cm$remove("missing")
  expect_equal(cm$names, c("a", "b"))
})

test_that("CalculationMethods$names can be reassigned", {
  cm <- CalculationMethods$new("Original")
  cm$names <- c("New", "Other")
  expect_equal(cm$names, c("New", "Other"))
  cm$names <- NULL
  expect_equal(cm$length, 0L)
})

test_that("CalculationMethods$to_list mirrors the snapshot raw shape", {
  expect_null(CalculationMethods$new()$to_list())
  raw <- CalculationMethods$new(c("a", "b"))$to_list()
  expect_type(raw, "list")
  expect_equal(unlist(raw), c("a", "b"))
})

test_that("CalculationMethods prints its contents", {
  expect_snapshot(CalculationMethods$new())
  expect_snapshot(CalculationMethods$new(c("Mosteller", "Rodgers")))
})

test_that("length() on CalculationMethods matches $length", {
  cm <- CalculationMethods$new(c("a", "b", "c"))
  expect_equal(length(cm), cm$length)
  expect_equal(length(cm), 3L)
  expect_equal(length(CalculationMethods$new()), 0L)
})
