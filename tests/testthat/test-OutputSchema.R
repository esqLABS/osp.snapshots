test_that("OutputSchema wraps a list of OutputIntervals", {
  raw <- list(
    list(
      Parameters = list(
        list(Name = "Start time", Value = 0, Unit = "h"),
        list(Name = "End time", Value = 2, Unit = "h"),
        list(Name = "Resolution", Value = 20, Unit = "pts/h")
      )
    )
  )
  schema <- OutputSchema$new(raw)

  expect_s3_class(schema, "OutputSchema")
  expect_length(schema$intervals, 1)
  expect_s3_class(schema$intervals[[1]], "OutputInterval")
  expect_identical(schema$data, raw)
})

test_that("OutputSchema with NULL or empty input yields empty intervals", {
  expect_length(OutputSchema$new(NULL)$intervals, 0)
  expect_length(OutputSchema$new(list())$intervals, 0)
})

test_that("OutputSchema reflects interval mutations in $data", {
  schema <- OutputSchema$new(list(
    list(
      Parameters = list(
        list(Name = "Start time", Value = 0, Unit = "h"),
        list(Name = "End time", Value = 2, Unit = "h"),
        list(Name = "Resolution", Value = 20, Unit = "pts/h")
      )
    )
  ))
  schema$intervals[[1]]$parameters[["End time"]]$value <- 99
  expect_equal(schema$data[[1]]$Parameters[[2]]$Value, 99)
})
