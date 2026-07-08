test_that("EventSelection wraps name and start_time Parameter", {
  raw <- list(
    Name = "GB emptying",
    StartTime = list(Value = 12, Unit = "h")
  )
  sel <- EventSelection$new(raw)

  expect_s3_class(sel, "EventSelection")
  expect_equal(sel$name, "GB emptying")
  expect_s3_class(sel$start_time, "Parameter")
  expect_equal(sel$start_time$value, 12)
  expect_equal(sel$start_time$unit, "h")
})

test_that("EventSelection$data round-trips raw input", {
  raw <- list(
    Name = "GB emptying",
    StartTime = list(Value = 12, Unit = "h")
  )
  sel <- EventSelection$new(raw)
  expect_identical(sel$data, raw)
})

test_that("EventSelection setters mutate raw data", {
  sel <- EventSelection$new(list(
    Name = "A",
    StartTime = list(Value = 1, Unit = "h")
  ))

  sel$name <- "B"
  expect_equal(sel$data$Name, "B")

  sel$start_time <- list(Value = 5, Unit = "h")
  expect_equal(sel$data$StartTime$Value, 5)
})

test_that("EventSelection start_time setter accepts Parameter R6", {
  sel <- EventSelection$new(list(
    Name = "A",
    StartTime = list(Value = 1, Unit = "h")
  ))
  sel$start_time <- Parameter$new(list(Value = 7, Unit = "h"))
  expect_equal(sel$data$StartTime$Value, 7)
})

test_that("EventSelection$name requires a non-empty scalar string", {
  sel <- EventSelection$new(list(
    Name = "A",
    StartTime = list(Value = 1, Unit = "h")
  ))
  expect_snapshot(error = TRUE, sel$name <- "")
  expect_snapshot(error = TRUE, sel$name <- 5)
})
