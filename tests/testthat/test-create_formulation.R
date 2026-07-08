test_that("create_formulation accepts an unknown FormulationType verbatim", {
  raw_key <- create_formulation(name = "X", type = "Formulation_BrandNew")
  expect_equal(raw_key$formulation_type, "Formulation_BrandNew")

  human_label <- create_formulation(
    name = "X",
    type = "Some Human Label Not In Map"
  )
  expect_equal(human_label$formulation_type, "Some Human Label Not In Map")
})

test_that("create_formulation maps curated aliases and known keys", {
  aliased <- create_formulation(name = "X", type = "Weibull")
  expect_equal(aliased$formulation_type, "Formulation_Tablet_Weibull")

  keyed <- create_formulation(name = "X", type = "Formulation_Tablet_Weibull")
  expect_equal(keyed$formulation_type, "Formulation_Tablet_Weibull")
})

test_that("create_formulation accepts raw parameters on Dissolved", {
  form <- create_formulation(
    name = "X",
    type = "Dissolved",
    parameters = list(create_parameter(name = "Use as suspension", value = 1))
  )

  expect_equal(form$formulation_type, "Formulation_Dissolved")
  expect_equal(form$parameters[["Use as suspension"]]$value, 1)
  expect_equal(form$data$Parameters[[1]]$Name, "Use as suspension")
})

test_that("create_formulation accepts a real snapshot Name on a known type", {
  form <- create_formulation(
    name = "X",
    type = "Weibull",
    parameters = list(create_parameter(name = "Dissolution shape", value = 0.7))
  )

  expect_equal(form$formulation_type, "Formulation_Tablet_Weibull")
  expect_equal(form$parameters[["Dissolution shape"]]$value, 0.7)
})

test_that("create_formulation accepts raw parameter dicts", {
  form <- create_formulation(
    name = "X",
    type = "Dissolved",
    parameters = list(list(Name = "t1/2", Value = 0.02, Unit = "min"))
  )

  expect_equal(form$parameters[["t1/2"]]$value, 0.02)
  expect_equal(form$parameters[["t1/2"]]$unit, "min")
})

test_that("create_formulation preserves ValueOrigin from raw parameters", {
  form <- create_formulation(
    name = "X",
    type = "Weibull",
    parameters = list(create_parameter(
      name = "Dissolution shape",
      value = 0.9,
      source = "Lit",
      description = "ref"
    ))
  )

  expect_snapshot(form$parameters[["Dissolution shape"]]$value_origin)
})

test_that("create_formulation preserves a custom TableFormula on any type", {
  # Custom TableFormula via table_points on a non-Table type.
  from_points <- create_formulation(
    name = "X",
    type = "Dissolved",
    parameters = list(create_parameter(
      name = "Fraction (dose)",
      value = 0,
      table_points = list(list(x = 0, y = 0), list(x = 60, y = 1)),
      x_name = "Custom X",
      y_name = "Custom Y",
      x_unit = "min",
      x_dimension = "Time",
      y_dimension = "Fraction"
    ))
  )
  expect_snapshot(from_points$parameters[[1]]$table_formula)

  # A fully custom TableFormula (including UseDerivedValues = FALSE) on an
  # unknown type.
  from_formula <- create_formulation(
    name = "X",
    type = "Formulation_BrandNew",
    parameters = list(create_parameter(
      name = "Fraction (dose)",
      value = 0,
      table_formula = list(
        Name = "Fraction (dose)",
        XName = "Time",
        YName = "Fraction",
        XDimension = "Time",
        YDimension = "Fraction",
        XUnit = "min",
        UseDerivedValues = FALSE,
        Points = list(list(X = 0, Y = 0, RestartSolver = FALSE))
      )
    ))
  )
  expect_snapshot(from_formula$parameters[[1]]$table_formula)
})

test_that("create_formulation curated form still errors on out-of-vocabulary alias", {
  expect_snapshot(
    error = TRUE,
    create_formulation(
      name = "X",
      type = "Weibull",
      parameters = list(not_a_param = 1)
    )
  )
})

test_that("create_formulation rejects curated-looking parameters for an unknown type", {
  expect_snapshot(
    error = TRUE,
    create_formulation(
      name = "X",
      type = "Formulation_BrandNew",
      parameters = list(some_alias = 1)
    )
  )
})

test_that("create_formulation validates name and type", {
  expect_snapshot(error = TRUE, create_formulation())
  expect_snapshot(error = TRUE, create_formulation(name = "X"))
  expect_snapshot(
    error = TRUE,
    create_formulation(name = "", type = "Dissolved")
  )
  expect_snapshot(
    error = TRUE,
    create_formulation(name = "X", type = "Dissolved", parameters = "nope")
  )
})

test_that("create_formulation validates curated unit sub-parameters", {
  expect_snapshot(
    error = TRUE,
    create_formulation(
      name = "F",
      type = "Weibull",
      parameters = list(dissolution_time_unit = "banana")
    )
  )
  form <- create_formulation(
    name = "F",
    type = "Weibull",
    parameters = list(dissolution_time_unit = "min")
  )
  expect_equal(form$data$Parameters[[1]]$Unit, "min")
})

test_that("create_formulation curated Table shape is unchanged", {
  expect_snapshot({
    form <- create_formulation(
      name = "X",
      type = "Table",
      parameters = list(tableX = c(0, 1), tableY = c(0, 1))
    )
    form$data$Parameters
  })
})

test_that("raw-form formulation round-trips through export", {
  snapshot <- load_snapshot(test_path("data", "empty_snapshot.json"))

  form <- create_formulation(
    name = "Novel",
    type = "Formulation_BrandNew",
    parameters = list(
      create_parameter(
        name = "Use as suspension",
        value = 1,
        source = "Lit",
        description = "ref"
      ),
      create_parameter(
        name = "Fraction (dose)",
        value = 0,
        table_formula = list(
          Name = "Fraction (dose)",
          XName = "Time",
          YName = "Fraction",
          XDimension = "Time",
          YDimension = "Fraction",
          XUnit = "min",
          UseDerivedValues = FALSE,
          Points = list(list(X = 0, Y = 0, RestartSolver = FALSE))
        )
      )
    )
  )

  snapshot <- add_formulation(snapshot, form)

  out <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snapshot, out)
  reloaded <- load_snapshot(out)

  reloaded_form <- reloaded$formulations[["Novel"]]
  expect_equal(reloaded_form$formulation_type, "Formulation_BrandNew")
  expect_snapshot(reloaded_form$data$Parameters)
})
