test_that("create_process builds a minimal Process", {
  p <- create_process(
    internal_name = "SpecificBinding",
    data_source = "Publication A"
  )

  expect_s3_class(p, "Process")
  expect_equal(p$internal_name, "SpecificBinding")
  expect_equal(p$data_source, "Publication A")
  expect_equal(p$category, "protein_binding_partners")
})

test_that("create_process passes through optional fields", {
  p <- create_process(
    internal_name = "MetabolizationSpecific_MM",
    data_source = "Optimized",
    molecule = "CYP3A4",
    metabolite = "X-OH",
    species = "Human"
  )

  expect_equal(p$molecule, "CYP3A4")
  expect_equal(p$metabolite, "X-OH")
  expect_equal(p$species, "Human")
})

test_that("create_process accepts Parameter objects in parameters", {
  param <- create_parameter(name = "Km", value = 1.2, unit = "µmol/l")
  p <- create_process(
    internal_name = "MetabolizationSpecific_MM",
    data_source = "Optimized",
    parameters = list(param)
  )

  expect_length(p$parameters, 1)
  expect_s3_class(p$parameters[[1]], "Parameter")
  expect_equal(p$parameters[[1]]$name, "Km")
  expect_equal(p$parameters[[1]]$value, 1.2)
  expect_equal(p$parameters[[1]]$unit, "µmol/l")
})

test_that("create_process validates required arguments", {
  expect_snapshot(error = TRUE, create_process())
  expect_snapshot(
    error = TRUE,
    create_process(internal_name = "SpecificBinding")
  )
  expect_snapshot(
    error = TRUE,
    create_process(internal_name = "", data_source = "A")
  )
  expect_snapshot(
    error = TRUE,
    create_process(
      internal_name = "SpecificBinding",
      data_source = "A",
      parameters = "not a list"
    )
  )
})
