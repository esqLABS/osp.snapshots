# Helpers in isolation ---------------------------------------------------

test_that("each helper returns the expected class and default slots", {
  expect_s3_class(lipophilicity(2.5), c("lipophilicity_spec", "osp_value_spec"))
  expect_snapshot(unclass(lipophilicity(2.5)))
  expect_snapshot(unclass(fraction_unbound(0.1)))
  expect_snapshot(unclass(solubility(9999)))
  expect_snapshot(unclass(solubility(
    9999,
    reference_pH = 7,
    gain_per_charge = 1000
  )))
  expect_snapshot(unclass(intestinal_permeability(1.14e-05)))
  expect_snapshot(unclass(permeability(0.0069)))
  expect_snapshot(unclass(age(30)))
  expect_snapshot(unclass(weight(70)))
  expect_snapshot(unclass(height(175)))
  expect_snapshot(unclass(gestational_age(38)))
  expect_snapshot(unclass(time(c(0, 1, 2))))
  expect_snapshot(unclass(values(
    c(0, 12),
    unit = "mg/l",
    dimension = "Concentration (mass)"
  )))
  expect_snapshot(unclass(error(c(0, 1))))
})

test_that("all value specs share the osp_value_spec parent class", {
  specs <- list(
    lipophilicity(2.5),
    fraction_unbound(0.1),
    solubility(9999),
    intestinal_permeability(1.14e-05),
    permeability(0.0069),
    age(30),
    weight(70),
    height(175),
    gestational_age(38),
    time(c(0, 1)),
    values(c(0, 1), dimension = "Concentration (mass)"),
    error(c(0, 1))
  )
  expect_true(all(vapply(
    specs,
    function(s) inherits(s, "osp_value_spec"),
    logical(1)
  )))
})

test_that("helpers validate units against their dimension", {
  expect_snapshot(error = TRUE, lipophilicity(2.5, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, solubility(9999, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, intestinal_permeability(1, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, permeability(1, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, age(30, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, weight(70, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, height(175, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, gestational_age(38, unit = "not-a-unit"))
  expect_snapshot(error = TRUE, time(c(0, 1), unit = "not-a-unit"))
  expect_snapshot(
    error = TRUE,
    values(c(0, 1), unit = "not-a-unit", dimension = "Concentration (mass)")
  )
})

test_that("fraction_unbound() carries no unit slot", {
  spec <- fraction_unbound(0.1)
  expect_named(unclass(spec), c("value", "name", "default", "species"))
})

test_that("single-value helpers reject non-numeric or non-scalar values", {
  expect_snapshot(error = TRUE, lipophilicity("x"))
  expect_snapshot(error = TRUE, lipophilicity(c(1, 2)))
  expect_snapshot(error = TRUE, age("x"))
})

test_that("single-value helpers reject missing values", {
  expect_snapshot(error = TRUE, lipophilicity(NA))
  expect_snapshot(error = TRUE, lipophilicity(NA_real_))
  expect_snapshot(error = TRUE, age(NA_real_))
})

test_that("series helpers reject non-numeric or empty vectors", {
  expect_snapshot(error = TRUE, time("x"))
  expect_snapshot(error = TRUE, time(numeric(0)))
  expect_snapshot(
    error = TRUE,
    values(numeric(0), dimension = "Concentration (mass)")
  )
  expect_snapshot(error = TRUE, error(numeric(0)))
})

test_that("series helpers reject vectors containing missing values", {
  expect_snapshot(error = TRUE, time(c(0, NA, 2)))
  expect_snapshot(
    error = TRUE,
    values(c(0, NA), dimension = "Concentration (mass)")
  )
  expect_snapshot(error = TRUE, error(c(0, NA)))
})

test_that("error() validates type against the schema AuxiliaryType values", {
  # The off-schema legacy value is rejected.
  expect_snapshot(error = TRUE, error(c(1, 2), type = "ArithmeticStdErr"))
  # A clear typo is rejected.
  expect_snapshot(error = TRUE, error(c(1, 2), type = "not-a-type"))
  # A schema-valid value still succeeds and carries the type.
  spec <- error(c(1, 2), type = "GeometricStdDev")
  expect_equal(spec$type, "GeometricStdDev")
})

test_that("solubility() enforces scalar-vs-table exclusivity", {
  df <- data.frame(pH = c(3, 6), value = c(5000, 90))
  expect_snapshot(error = TRUE, solubility(9999, table = df))
  expect_snapshot(error = TRUE, solubility(table = df, reference_pH = 7))
  expect_snapshot(error = TRUE, solubility(table = df, gain_per_charge = 1000))
})

test_that("solubility() requires either a value or a table", {
  expect_snapshot(error = TRUE, solubility())
})

test_that("values() requires a dimension listing valid options", {
  expect_snapshot(error = TRUE, values(1:3))
})

test_that("default flag is validated and carried on the slot", {
  expect_false(lipophilicity(2.5)$default)
  expect_true(lipophilicity(2.5, default = TRUE)$default)
  expect_snapshot(error = TRUE, lipophilicity(2.5, default = "yes"))
  expect_snapshot(error = TRUE, lipophilicity(2.5, default = c(TRUE, FALSE)))

  expect_false(fraction_unbound(0.1)$default)
  expect_true(fraction_unbound(0.1, default = TRUE)$default)

  expect_false(solubility(9999)$default)
  expect_true(solubility(9999, default = TRUE)$default)
  expect_false(
    solubility(table = data.frame(pH = c(3, 6), value = c(5000, 90)))$default
  )
  expect_true(
    solubility(
      table = data.frame(pH = c(3, 6), value = c(5000, 90)),
      default = TRUE
    )$default
  )

  expect_false(intestinal_permeability(1.14e-05)$default)
  expect_true(intestinal_permeability(1.14e-05, default = TRUE)$default)

  expect_false(permeability(0.0069)$default)
  expect_true(permeability(0.0069, default = TRUE)$default)
})

test_that("name defaults to 'User defined' and is carried verbatim", {
  expect_equal(lipophilicity(2.5)$name, "User defined")
  expect_equal(solubility(9999)$name, "User defined")
  expect_equal(lipophilicity(2.5, name = "Custom")$name, "Custom")
  # `name` is distinct from `source`/ValueOrigin: no source slot exists.
  expect_null(lipophilicity(2.5)$source)
})
