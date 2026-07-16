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
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      disease = "CKD"
    )
  )
})

test_that("create_expression_profile promotes reference_concentration", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    reference_concentration = 4.32
  )

  expect_equal(
    profile$data$Parameters,
    list(list(
      Path = "CYP3A4|Reference concentration",
      Value = 4.32,
      Unit = "µmol/l"
    ))
  )
  expect_null(names(profile$data$Parameters))

  # A promoted argument and the equivalent hand-authored parameter produce
  # byte-identical JSON.
  hand <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    parameters = list(create_parameter(
      path = "CYP3A4|Reference concentration",
      value = 4.32,
      unit = "µmol/l"
    ))
  )
  expect_equal(profile$data$Parameters, hand$data$Parameters)
})

test_that("create_expression_profile promotes half_life_liver", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    half_life_liver = 36
  )

  expect_equal(
    profile$data$Parameters,
    list(list(Path = "CYP3A4|t1/2 (liver)", Value = 36, Unit = "h"))
  )
})

test_that("create_expression_profile promotes half_life_intestine", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    half_life_intestine = 23
  )

  expect_equal(
    profile$data$Parameters,
    list(list(Path = "CYP3A4|t1/2 (intestine)", Value = 23, Unit = "h"))
  )
})

test_that("create_expression_profile accepts a non-default promoted unit", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    half_life_liver = 30,
    half_life_liver_unit = "min"
  )

  expect_equal(
    profile$data$Parameters,
    list(list(Path = "CYP3A4|t1/2 (liver)", Value = 30, Unit = "min"))
  )
})

test_that("create_expression_profile rejects an invalid promoted unit", {
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = 1,
      reference_concentration_unit = "umol/l"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      half_life_liver = 1,
      half_life_liver_unit = "bogus"
    )
  )
})

test_that("create_expression_profile rejects an invalid promoted value", {
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = NA
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = "x"
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = c(1, 2)
    )
  )
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = Inf
    )
  )
})

test_that("create_expression_profile rejects a Path conflict", {
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = 4.32,
      parameters = list(create_parameter(
        path = "CYP3A4|Reference concentration",
        value = 4.32,
        unit = "µmol/l"
      ))
    )
  )
})

test_that("create_expression_profile rejects a Name-only conflict", {
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = 4.32,
      parameters = list(create_parameter(
        name = "CYP3A4|Reference concentration",
        value = 4.32,
        unit = "µmol/l"
      ))
    )
  )
})

test_that("create_expression_profile reports all conflicting promoted arguments at once", {
  expect_snapshot(
    error = TRUE,
    create_expression_profile(
      molecule = "CYP3A4",
      species = "Human",
      category = "Healthy",
      type = "Enzyme",
      reference_concentration = 4.32,
      half_life_liver = 36,
      half_life_intestine = 24,
      parameters = list(
        create_parameter(
          path = "CYP3A4|Reference concentration",
          value = 4.32,
          unit = "µmol/l"
        ),
        create_parameter(
          path = "CYP3A4|t1/2 (liver)",
          value = 36,
          unit = "h"
        ),
        create_parameter(
          path = "CYP3A4|t1/2 (intestine)",
          value = 24,
          unit = "h"
        )
      )
    )
  )
})

test_that("create_expression_profile does not conflict when a parameter is set only via parameters", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    parameters = list(create_parameter(
      path = "CYP3A4|Reference concentration",
      value = 4.32,
      unit = "µmol/l"
    ))
  )

  expect_equal(
    profile$data$Parameters,
    list(list(
      Path = "CYP3A4|Reference concentration",
      Value = 4.32,
      Unit = "µmol/l"
    ))
  )
})

test_that("create_expression_profile merges promoted entries before parameters", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme",
    half_life_liver = 36,
    parameters = list(create_parameter(
      path = "Organism|Liver|Pericentral|Intracellular|CYP3A4|Relative expression",
      value = 1
    ))
  )

  expect_length(profile$data$Parameters, 2)
  expect_equal(
    profile$data$Parameters[[1]],
    list(Path = "CYP3A4|t1/2 (liver)", Value = 36, Unit = "h")
  )
  expect_equal(
    profile$data$Parameters[[2]]$Path,
    "Organism|Liver|Pericentral|Intracellular|CYP3A4|Relative expression"
  )
})

test_that("create_expression_profile emits no Parameters when all promoted args omitted", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme"
  )

  expect_null(profile$data$Parameters)
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
