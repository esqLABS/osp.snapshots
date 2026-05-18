test_that("create_event creates a minimal Event", {
  event <- create_event(
    name = "Breakfast",
    template = "Meal: Standard (Human)"
  )

  expect_s3_class(event, "Event")
  expect_equal(event$name, "Breakfast")
  expect_equal(event$template, "Meal: Standard (Human)")
  expect_length(event$parameters, 0)
})

test_that("create_event stores parameters with Name keys", {
  event <- create_event(
    name = "Breakfast",
    template = "Meal: Standard (Human)",
    parameters = list(
      create_parameter(
        name = "Meal energy content",
        value = 500,
        unit = "kcal"
      ),
      create_parameter(name = "Meal volume", value = 0.3, unit = "l")
    )
  )

  expect_length(event$parameters, 2)
  expect_equal(event$parameters[[1]]$name, "Meal energy content")
  expect_equal(event$parameters[[1]]$value, 500)
  expect_equal(event$parameters[[1]]$unit, "kcal")
  expect_equal(event$data$Parameters[[1]]$Name, "Meal energy content")
})

test_that("create_event validates required arguments", {
  expect_snapshot(error = TRUE, create_event())
  expect_snapshot(error = TRUE, create_event(name = "E"))
  expect_snapshot(error = TRUE, create_event(name = "", template = "T"))
  expect_snapshot(
    error = TRUE,
    create_event(name = "E", template = "T", parameters = "nope")
  )
})
