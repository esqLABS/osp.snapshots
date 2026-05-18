test_that("CalculationMethodCache constructs from a character vector", {
  cache <- CalculationMethodCache$new(c("Method A", "Method B"))
  expect_r6_class(cache, "CalculationMethodCache")
  expect_equal(cache$methods, c("Method A", "Method B"))
  expect_equal(cache$length, 2L)
})

test_that("CalculationMethodCache treats NULL and missing input as empty", {
  expect_equal(CalculationMethodCache$new()$methods, character())
  expect_equal(CalculationMethodCache$new(NULL)$methods, character())
  expect_equal(CalculationMethodCache$new(list())$length, 0L)
})

test_that("CalculationMethodCache constructs from a list of strings", {
  cache <- CalculationMethodCache$new(list("M1", "M2", "M3"))
  expect_equal(cache$methods, c("M1", "M2", "M3"))
})

test_that("CalculationMethodCache rejects NA method names", {
  expect_snapshot(error = TRUE, CalculationMethodCache$new(c("a", NA)))
})

test_that("CalculationMethodCache$add appends a method", {
  cache <- CalculationMethodCache$new("First")
  cache$add("Second")
  expect_equal(cache$methods, c("First", "Second"))
})

test_that("CalculationMethodCache$add validates the input", {
  cache <- CalculationMethodCache$new()
  expect_snapshot(error = TRUE, cache$add(c("a", "b")))
  expect_snapshot(error = TRUE, cache$add(NA_character_))
})

test_that("CalculationMethodCache$remove drops a method when present", {
  cache <- CalculationMethodCache$new(c("a", "b", "c"))
  cache$remove("b")
  expect_equal(cache$methods, c("a", "c"))
})

test_that("CalculationMethodCache$remove is a no-op when absent", {
  cache <- CalculationMethodCache$new(c("a", "b"))
  cache$remove("missing")
  expect_equal(cache$methods, c("a", "b"))
})

test_that("CalculationMethodCache$methods can be reassigned", {
  cache <- CalculationMethodCache$new("Original")
  cache$methods <- c("New", "Other")
  expect_equal(cache$methods, c("New", "Other"))
  cache$methods <- NULL
  expect_equal(cache$length, 0L)
})

test_that("CalculationMethodCache$to_list mirrors the snapshot raw shape", {
  expect_null(CalculationMethodCache$new()$to_list())
  raw <- CalculationMethodCache$new(c("a", "b"))$to_list()
  expect_type(raw, "list")
  expect_equal(unlist(raw), c("a", "b"))
})

test_that("CalculationMethodCache prints its contents", {
  expect_snapshot(CalculationMethodCache$new())
  expect_snapshot(CalculationMethodCache$new(c("Mosteller", "Rodgers")))
})

test_that("length() on CalculationMethodCache matches $length", {
  cache <- CalculationMethodCache$new(c("a", "b", "c"))
  expect_equal(length(cache), cache$length)
  expect_equal(length(cache), 3L)
  expect_equal(length(CalculationMethodCache$new()), 0L)
})
