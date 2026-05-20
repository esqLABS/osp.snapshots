test_that("create_output_interval happy path", {
  interval <- create_output_interval(
    start_time = 0,
    end_time = 24,
    resolution = 20
  )

  expect_s3_class(interval, "OutputInterval")
  expect_equal(interval$parameters[["Start time"]]$value, 0)
  expect_equal(interval$parameters[["End time"]]$value, 24)
  expect_equal(interval$parameters[["Resolution"]]$value, 20)
  expect_equal(interval$data$Parameters[[3]]$Unit, "pts/h")
})

test_that("create_output_interval keeps optional name when given", {
  interval <- create_output_interval(
    name = "Early phase",
    start_time = 0,
    end_time = 2,
    resolution = 20
  )

  expect_equal(interval$name, "Early phase")
})

test_that("create_output_interval validates arguments", {
  expect_snapshot(error = TRUE, create_output_interval())
  expect_snapshot(
    error = TRUE,
    create_output_interval(start_time = "x", end_time = 1, resolution = 1)
  )
})
