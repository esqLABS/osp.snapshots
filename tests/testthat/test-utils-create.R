test_that("to_raw_r6_or_list returns $data for R6 entries", {
  item <- SchemaItem$new(list(Name = "Item 1", ApplicationType = "Oral"))
  result <- to_raw_r6_or_list(list(item), "SchemaItem", "items")
  expect_equal(result, list(item$data))
})

test_that("to_raw_r6_or_list returns raw lists as-is", {
  raw <- list(Name = "Item 1", ApplicationType = "Oral")
  result <- to_raw_r6_or_list(list(raw), "SchemaItem", "items")
  expect_equal(result, list(raw))
})

test_that("to_raw_r6_or_list mixes R6 and raw entries", {
  item <- SchemaItem$new(list(Name = "Item 1", ApplicationType = "Oral"))
  raw <- list(Name = "Item 2", ApplicationType = "Oral")
  result <- to_raw_r6_or_list(list(item, raw), "SchemaItem", "items")
  expect_equal(result, list(item$data, raw))
})

test_that("to_raw_r6_or_list drops outer names", {
  raw <- list(Name = "Item 1", ApplicationType = "Oral")
  result <- to_raw_r6_or_list(list(a = raw), "SchemaItem", "items")
  expect_null(names(result))
})

test_that("to_raw_r6_or_list rejects non-R6 non-list entries", {
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list(list("not valid"), "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list rejects a bare R6 as the outer collection", {
  item <- SchemaItem$new(list(Name = "Item 1", ApplicationType = "Oral"))
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list(item, "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list rejects a non-list outer collection", {
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list("not a list", "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list rejects a wrong-class R6 entry", {
  compound <- Compound$new(list(Name = "Aspirin"))
  expect_snapshot(
    error = TRUE,
    to_raw_r6_or_list(list(compound), "SchemaItem", "items")
  )
})

test_that("to_raw_r6_or_list returns an empty list for empty input", {
  result <- to_raw_r6_or_list(list(), "SchemaItem", "items")
  expect_equal(result, list())
})
