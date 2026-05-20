test_that("create_event_selection happy path", {
  sel <- create_event_selection(name = "GB emptying", start_time = 12)

  expect_s3_class(sel, "EventSelection")
  expect_equal(sel$name, "GB emptying")
  expect_equal(sel$start_time$value, 12)
  expect_equal(sel$start_time$unit, "h")
  expect_equal(sel$data$StartTime$Unit, "h")
})

test_that("create_event_selection validates arguments", {
  expect_snapshot(error = TRUE, create_event_selection())
  expect_snapshot(error = TRUE, create_event_selection(name = "E"))
  expect_snapshot(
    error = TRUE,
    create_event_selection(name = "E", start_time = "x")
  )
})
