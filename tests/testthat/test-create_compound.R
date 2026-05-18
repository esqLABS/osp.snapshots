test_that("create_compound creates a minimal Compound", {
  compound <- create_compound(name = "Drug X")

  expect_s3_class(compound, "Compound")
  expect_equal(compound$name, "Drug X")
  expect_equal(compound$data$Name, "Drug X")
})

test_that("create_compound stores common fields on the Compound", {
  compound <- create_compound(
    name = "Drug X",
    is_small_molecule = TRUE,
    plasma_protein_binding_partner = "Albumin",
    molecular_weight = 250.3,
    calculation_methods = c("Partition coefficient - Schmitt"),
    description = "Test compound"
  )

  expect_equal(compound$is_small_molecule, TRUE)
  expect_equal(compound$plasma_protein_binding_partner, "Albumin")
  expect_equal(compound$molecular_weight, 250.3)
  expect_equal(compound$molecular_weight_unit, "g/mol")
  expect_equal(compound$data$Description, "Test compound")
  expect_equal(
    compound$data$CalculationMethods,
    list("Partition coefficient - Schmitt")
  )
})

test_that("create_compound accepts Parameter objects in parameters", {
  param <- create_parameter(name = "Cl_spec", value = 5, unit = "ml/min/kg")
  compound <- create_compound(name = "Drug X", parameters = list(param))

  expect_length(compound$parameters, 1)
  expect_equal(compound$parameters[[1]]$Name, "Cl_spec")
  expect_equal(compound$parameters[[1]]$Value, 5)
})

test_that("create_compound validates required arguments", {
  expect_snapshot(error = TRUE, create_compound())
  expect_snapshot(error = TRUE, create_compound(name = ""))
  expect_snapshot(
    error = TRUE,
    create_compound(name = "Drug", is_small_molecule = "yes")
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "Drug", molecular_weight = "heavy")
  )
  expect_snapshot(
    error = TRUE,
    create_compound(name = "Drug", parameters = "not a list")
  )
})
