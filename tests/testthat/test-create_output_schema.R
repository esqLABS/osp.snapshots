test_that("create_output_schema happy path", {
  schema <- create_output_schema(
    intervals = list(
      create_output_interval(start_time = 0, end_time = 2, resolution = 20),
      create_output_interval(start_time = 2, end_time = 24, resolution = 20)
    )
  )

  expect_s3_class(schema, "OutputSchema")
  expect_length(schema$intervals, 2)
})

test_that("create_output_schema defaults to empty intervals", {
  schema <- create_output_schema()
  expect_length(schema$intervals, 0)
  expect_equal(schema$data, list())
})

test_that("create_output_schema validates intervals", {
  expect_snapshot(error = TRUE, create_output_schema(intervals = "nope"))
})
