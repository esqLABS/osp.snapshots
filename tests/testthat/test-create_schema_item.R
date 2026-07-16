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

test_that("positional call binds the third argument to formulation_key", {
  item <- create_schema_item("I", "Oral", "Tablet")

  expect_equal(item$formulation_key, "Tablet")
  expect_null(item$data$Parameters)
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

test_that("promoted dose emits a single InputDose parameter", {
  item <- create_schema_item(
    name = "I",
    application_type = "Oral",
    dose = 10
  )

  params <- item$data$Parameters
  expect_length(params, 1)
  expect_equal(vapply(params, \(p) p$Name, character(1)), "InputDose")
  expect_equal(params[[1]]$Value, 10)
  expect_equal(params[[1]]$Unit, "mg")
})

test_that("dose_unit selects the dose family, still one InputDose", {
  item_weight <- create_schema_item(
    name = "I",
    application_type = "Oral",
    dose = 5,
    dose_unit = "mg/kg"
  )
  params_weight <- item_weight$data$Parameters
  expect_length(params_weight, 1)
  expect_equal(params_weight[[1]]$Name, "InputDose")
  expect_equal(params_weight[[1]]$Unit, "mg/kg")

  item_bsa <- create_schema_item(
    name = "I",
    application_type = "Oral",
    dose = 5,
    dose_unit = "mg/m²"
  )
  params_bsa <- item_bsa$data$Parameters
  expect_length(params_bsa, 1)
  expect_equal(params_bsa[[1]]$Name, "InputDose")
  expect_equal(params_bsa[[1]]$Unit, "mg/m²")
})

test_that("promoted start_time emits a single Start time parameter", {
  item_default <- create_schema_item(
    name = "I",
    application_type = "Oral",
    start_time = 0
  )
  params_default <- item_default$data$Parameters
  expect_length(params_default, 1)
  expect_equal(params_default[[1]]$Name, "Start time")
  expect_equal(params_default[[1]]$Value, 0)
  expect_equal(params_default[[1]]$Unit, "h")

  item_min <- create_schema_item(
    name = "I",
    application_type = "Oral",
    start_time = 2,
    start_time_unit = "min"
  )
  params_min <- item_min$data$Parameters
  expect_length(params_min, 1)
  expect_equal(params_min[[1]]$Unit, "min")
})

test_that("promoted dose and start_time coexist with a passthrough entry", {
  item <- create_schema_item(
    name = "I",
    application_type = "IntravenousInfusion",
    dose = 10,
    start_time = 0,
    parameters = list(
      create_parameter(name = "Infusion time", value = 30, unit = "min")
    )
  )

  params <- item$data$Parameters
  expect_length(params, 3)
  expect_equal(
    vapply(params, \(p) p$Name, character(1)),
    c("InputDose", "Start time", "Infusion time")
  )
})

test_that("invalid dose unit aborts, attributed to create_schema_item()", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 10,
      dose_unit = "h"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 10,
      dose_unit = "not-a-unit"
    )
  )
})

test_that("NULL or non-scalar dose_unit aborts with the invalid-unit error", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 5,
      dose_unit = NULL
    )
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 5,
      dose_unit = c("mg", "mg/kg")
    )
  )
})

test_that("invalid start_time_unit aborts", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      start_time = 0,
      start_time_unit = "mg"
    )
  )
})

test_that("non-finite or non-scalar dose aborts", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "I", application_type = "Oral", dose = "10")
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "I", application_type = "Oral", dose = c(1, 2))
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "I", application_type = "Oral", dose = NA_real_)
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "I", application_type = "Oral", dose = Inf)
  )
})

test_that("non-finite or non-scalar start_time aborts", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "I", application_type = "Oral", start_time = "10")
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      start_time = c(1, 2)
    )
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      start_time = NA_real_
    )
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(name = "I", application_type = "Oral", start_time = Inf)
  )
})

test_that("dose conflicts with an InputDose entry in parameters", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 10,
      parameters = list(
        create_parameter(name = "InputDose", value = 5, unit = "mg")
      )
    )
  )
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 10,
      parameters = list(list(Name = "InputDose", Value = 5, Unit = "mg"))
    )
  )
})

test_that("a Path-form InputDose entry conflicts with promoted dose", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 10,
      parameters = list(
        create_parameter(path = "InputDose", value = 5, unit = "mg")
      )
    )
  )
})

test_that("start_time conflicts with a Start time entry in parameters", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      start_time = 0,
      parameters = list(
        create_parameter(name = "Start time", value = 1, unit = "h")
      )
    )
  )
})

test_that("all conflicting promoted arguments are reported in one error", {
  expect_snapshot(
    error = TRUE,
    create_schema_item(
      name = "I",
      application_type = "Oral",
      dose = 10,
      start_time = 0,
      parameters = list(
        create_parameter(name = "InputDose", value = 5, unit = "mg"),
        create_parameter(name = "Start time", value = 1, unit = "h")
      )
    )
  )
})

test_that("differently-named entries raise no false conflict", {
  item <- create_schema_item(
    name = "I",
    application_type = "Oral",
    dose = 10,
    parameters = list(
      create_parameter(name = "Start time", value = 0, unit = "h")
    )
  )
  params <- item$data$Parameters
  expect_length(params, 2)
  expect_equal(
    vapply(params, \(p) p$Name, character(1)),
    c("InputDose", "Start time")
  )

  # Case-sensitivity guard: "inputdose" is a distinct name from "InputDose",
  # so it does not conflict with the promoted dose.
  item_case <- create_schema_item(
    name = "I",
    application_type = "Oral",
    dose = 10,
    parameters = list(
      create_parameter(name = "inputdose", value = 5, unit = "mg")
    )
  )
  params_case <- item_case$data$Parameters
  expect_length(params_case, 2)
  expect_equal(
    vapply(params_case, \(p) p$Name, character(1)),
    c("InputDose", "inputdose")
  )
})
