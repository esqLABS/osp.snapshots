test_that("create_expression_profile creates a minimal profile", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme"
  )

  expect_s3_class(profile, "ExpressionProfile")
  expect_equal(profile$molecule, "CYP3A4")
  expect_equal(profile$species, "Human")
  expect_equal(profile$category, "Healthy")
  expect_equal(profile$type, "Enzyme")
})

test_that("create_expression_profile stores optional fields", {
  profile <- create_expression_profile(
    molecule = "P-gp",
    species = "Human",
    category = "Healthy",
    type = "Transporter",
    localization = "Intracellular",
    transport_type = "Efflux",
    ontogeny = "P-gp",
    description = "Test profile"
  )

  expect_equal(profile$localization, "Intracellular")
  expect_equal(profile$transportType, "Efflux")
  expect_equal(profile$ontogeny, list(Name = "P-gp"))
  expect_equal(profile$data$Description, "Test profile")
})

test_that("create_expression_profile accepts Parameter objects", {
  param <- create_parameter(
    name = "CYP3A4|Reference concentration",
    value = 4.32,
    unit = "umol/l"
  )
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    parameters = list(param)
  )

  expect_length(profile$parameters, 1)
  expect_equal(profile$parameters[[1]]$Path, "CYP3A4|Reference concentration")
  expect_equal(profile$parameters[[1]]$Value, 4.32)
})

test_that("create_expression_profile validates required arguments", {
  expect_snapshot(error = TRUE, create_expression_profile())
  expect_snapshot(
    error = TRUE,
    create_expression_profile(molecule = "CYP3A4")
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      ontogeny = 1
    )
  )
})
