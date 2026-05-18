test_that("create_schema_item builds from create_parameter()", {
  item <- create_schema_item(
    name = "Item 1",
    application_type = "Oral",
    parameters = list(
      create_parameter(name = "Start time", value = 0, unit = "h"),
      create_parameter(name = "InputDose", value = 10, unit = "mg")
    )
  )

  expect_r6_class(item, "SchemaItem")
  expect_equal(item$name, "Item 1")
  expect_equal(item$application_type, "Oral")
  expect_length(item$parameters, 2)
})

test_that("create_schema_item parameters use Name keys (not Path)", {
  item <- create_schema_item(
    name = "Item 1",
    application_type = "Oral",
    parameters = list(
      create_parameter(name = "InputDose", value = 5, unit = "mg")
    )
  )

  raw <- item$data
  expect_named(
    raw$Parameters[[1]],
    c("Name", "Value", "Unit"),
    ignore.order = TRUE
  )
  expect_null(raw$Parameters[[1]]$Path)
})

test_that("create_schema_item accepts raw parameter lists", {
  item <- create_schema_item(
    name = "Item 1",
    application_type = "IntravenousBolus",
    parameters = list(
      list(Name = "InputDose", Value = 5, Unit = "mg")
    )
  )

  expect_r6_class(item, "SchemaItem")
  expect_equal(item$application_type, "IntravenousBolus")
  expect_length(item$parameters, 1)
})

test_that("create_schema_item carries optional fields through", {
  item <- create_schema_item(
    name = "Item 1",
    application_type = "Oral",
    formulation_key = "Tablet",
    target_organ = "ProximalSmallIntestine",
    target_compartment = "Lumen"
  )

  expect_equal(item$formulation_key, "Tablet")
  expect_equal(item$target_organ, "ProximalSmallIntestine")
  expect_equal(item$target_compartment, "Lumen")
})

test_that("create_schema_item validates required arguments", {
  expect_snapshot(error = TRUE, create_schema_item())
  expect_snapshot(error = TRUE, create_schema_item(name = ""))
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "Item", application_type = NULL)
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "Item", application_type = "NotARealType")
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "Item",
      application_type = "Oral",
      parameters = "not a list"
    )
  )
})
