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

test_that("create_expression_profile sets per-organ relative expression", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    expression = data.frame(name = c("Liver", "Kidney"), value = c(1, 0.5))
  )

  expect_equal(
    profile$data$Expression,
    list(
      list(Name = "Liver", Value = 1),
      list(Name = "Kidney", Value = 0.5)
    )
  )
})

test_that("create_expression_profile maps transporter expression rows", {
  profile <- create_expression_profile(
    molecule = "P-gp",
    species = "Human",
    category = "Healthy",
    type = "Transporter",
    expression = data.frame(
      name = "Liver",
      compartment = "Intracellular",
      transport_direction = "EffluxIntracellularToInterstitial"
    )
  )

  expect_equal(
    profile$data$Expression,
    list(list(
      Name = "Liver",
      CompartmentName = "Intracellular",
      TransportDirection = "EffluxIntracellularToInterstitial"
    ))
  )
})

test_that("create_expression_profile preserves order and duplicate names", {
  profile <- create_expression_profile(
    molecule = "P-gp",
    species = "Human",
    category = "Healthy",
    type = "Transporter",
    expression = data.frame(
      name = c("Kidney", "Kidney"),
      transport_direction = c("Efflux", "Influx")
    )
  )

  expect_length(profile$data$Expression, 2)
  expect_equal(profile$data$Expression[[1]]$TransportDirection, "Efflux")
  expect_equal(profile$data$Expression[[2]]$TransportDirection, "Influx")
})

test_that("create_expression_profile accepts a raw expression list", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    expression = list(list(Name = "Liver", Value = 1))
  )

  expect_null(names(profile$data$Expression))
  expect_equal(profile$data$Expression, list(list(Name = "Liver", Value = 1)))
})

test_that("create_expression_profile sets a disease state with parameters", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    disease = list(
      name = "CKD",
      parameters = list(create_parameter(name = "p", value = 1))
    )
  )

  expect_equal(
    profile$data$Disease,
    list(Name = "CKD", Parameters = list(list(Name = "p", Value = 1)))
  )
})

test_that("create_expression_profile sets a disease state without parameters", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    disease = list(name = "CKD")
  )

  expect_equal(profile$data$Disease, list(Name = "CKD"))
  expect_null(profile$data$Disease$Parameters)
})

test_that("create_expression_profile omits Expression and Disease by default", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme"
  )

  expect_null(profile$data$Expression)
  expect_null(profile$data$Disease)
})

test_that("create_expression_profile validates expression and disease", {
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      expression = data.frame(value = 1)
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      expression = data.frame(name = c("Liver", NA), value = c(1, 2))
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      expression = "Liver"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      disease = list(parameters = list())
    )
  )
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
