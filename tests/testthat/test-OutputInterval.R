test_that("OutputInterval wraps name and Name-keyed parameters", {
  raw <- list(
    Name = "Early phase",
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "End time", Value = 2, Unit = "h"),
      list(Name = "Resolution", Value = 20, Unit = "pts/h")
    )
  )
  interval <- OutputInterval$new(raw)

  expect_s3_class(interval, "OutputInterval")
  expect_equal(interval$name, "Early phase")
  expect_length(interval$parameters, 3)
  expect_named(interval$parameters, c("Start time", "End time", "Resolution"))
  expect_equal(interval$parameters[["Start time"]]$value, 0)
})

test_that("OutputInterval$data round-trips raw input", {
  raw <- list(
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "End time", Value = 2, Unit = "h"),
      list(Name = "Resolution", Value = 20, Unit = "pts/h")
    )
  )
  interval <- OutputInterval$new(raw)
  expect_identical(interval$data, raw)
})

test_that("OutputInterval reflects parameter mutations in $data", {
  raw <- list(
    Parameters = list(
      list(Name = "Start time", Value = 0, Unit = "h"),
      list(Name = "End time", Value = 2, Unit = "h"),
      list(Name = "Resolution", Value = 20, Unit = "pts/h")
    )
  )
  interval <- OutputInterval$new(raw)
  interval$parameters[["End time"]]$value <- 24
  expect_equal(interval$data$Parameters[[2]]$Value, 24)
})
