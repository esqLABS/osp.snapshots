test_that("Process$new() wraps raw data and exposes core fields", {
  p <- Process$new(list(
    InternalName = "SpecificBinding",
    DataSource = "Source A",
    Molecule = "Albumin",
    Parameters = list(
      list(Name = "Kd", Value = 1.2, Unit = "nmol/l")
    )
  ))

  expect_s3_class(p, "Process")
  expect_equal(p$internal_name, "SpecificBinding")
  expect_equal(p$data_source, "Source A")
  expect_equal(p$molecule, "Albumin")
  expect_null(p$metabolite)
  expect_null(p$species)
  expect_length(p$parameters, 1)
  expect_s3_class(p$parameters[[1]], "Parameter")
  expect_equal(p$parameters[[1]]$name, "Kd")
  expect_equal(p$parameters[[1]]$value, 1.2)
  expect_equal(p$parameters[[1]]$unit, "nmol/l")
  expect_named(p$parameters, "Kd")
})

test_that("Process$new() copes with empty data", {
  p <- Process$new(NULL)
  expect_null(p$internal_name)
  expect_null(p$data_source)
  expect_length(p$parameters, 0)
  expect_equal(p$category, NA_character_)
})

test_that("category is derived from internal_name for every subtype", {
  cases <- list(
    list(name = "SpecificBinding", category = "protein_binding_partners"),
    list(
      name = "MetabolizationSpecific_MM",
      category = "metabolizing_enzymes"
    ),
    list(name = "rCYP450_MM", category = "metabolizing_enzymes"),
    list(name = "LiverClearance", category = "hepatic_clearance"),
    list(name = "Hepatocytes", category = "hepatic_clearance"),
    list(name = "LiverMicrosomeHalfTime", category = "hepatic_clearance"),
    list(name = "LiverMicrosomeRes", category = "hepatic_clearance"),
    list(
      name = "ActiveTransportSpecific_MM",
      category = "transporter_proteins"
    ),
    list(name = "GlomerularFiltration", category = "renal_clearance"),
    list(name = "TubularSecretion_MM", category = "renal_clearance"),
    list(name = "KidneyClearance", category = "renal_clearance"),
    list(name = "BiliaryClearance", category = "biliary_clearance"),
    list(name = "CompetitiveInhibition", category = "inhibition"),
    list(name = "IrreversibleInhibition", category = "inhibition"),
    list(name = "Induction", category = "induction"),
    list(name = "SomethingExotic", category = NA_character_)
  )

  for (case in cases) {
    p <- Process$new(list(InternalName = case$name))
    expect_equal(
      p$category,
      case$category,
      info = paste("InternalName:", case$name)
    )
  }
})

test_that("Process active bindings allow mutation", {
  p <- Process$new(list(
    InternalName = "SpecificBinding",
    DataSource = "Source A"
  ))

  p$molecule <- "Albumin"
  p$metabolite <- "X-OH"
  p$species <- "Human"
  p$parameters <- list(list(Name = "Kd", Value = 1))

  expect_equal(p$molecule, "Albumin")
  expect_equal(p$metabolite, "X-OH")
  expect_equal(p$species, "Human")
  expect_length(p$parameters, 1)
  expect_s3_class(p$parameters[[1]], "Parameter")
  expect_equal(p$parameters[[1]]$name, "Kd")
})

test_that("Process parameters setter accepts Parameter R6 objects", {
  p <- Process$new(list(InternalName = "SpecificBinding"))
  param <- create_parameter(name = "Kd", value = 1.2, unit = "nmol/l")
  p$parameters <- list(param)

  expect_length(p$parameters, 1)
  expect_s3_class(p$parameters[[1]], "Parameter")
  expect_equal(p$parameters[[1]]$value, 1.2)
  expect_equal(p$data$Parameters[[1]]$Name, "Kd")
  expect_equal(p$data$Parameters[[1]]$Value, 1.2)
})

test_that("Process state persists across $parameters accesses", {
  p <- Process$new(list(
    InternalName = "MetabolizationSpecific_MM",
    DataSource = "Source A",
    Parameters = list(list(Name = "Km", Value = 1, Unit = "µmol/l"))
  ))

  param <- p$parameters[[1]]
  param$value <- 42

  expect_equal(p$parameters[[1]]$value, 42)
})

test_that("Process print is stable", {
  p <- Process$new(list(
    InternalName = "MetabolizationSpecific_MM",
    DataSource = "Optimized",
    Molecule = "CYP3A4",
    Metabolite = "X-OH",
    Parameters = list(list(Name = "Km", Value = 1.2, Unit = "µmol/l"))
  ))
  expect_snapshot(print(p))
})

test_that("build_processes_from_raw disambiguates duplicate names", {
  raw <- list(
    list(InternalName = "SpecificBinding", DataSource = "ds1", Molecule = "X"),
    list(InternalName = "SpecificBinding", DataSource = "ds1", Molecule = "X"),
    list(InternalName = "SpecificBinding", DataSource = "ds2", Molecule = "X")
  )

  processes <- build_processes_from_raw(raw)
  expect_length(processes, 3)
  expect_equal(
    names(processes),
    c(
      "SpecificBinding, ds1, X_1",
      "SpecificBinding, ds1, X_2",
      "SpecificBinding, ds2, X"
    )
  )
  for (p in processes) {
    expect_s3_class(p, "Process")
  }
})
