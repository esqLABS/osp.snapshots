snapshot <- test_snapshot$clone()


# Initialization and printing --------------------------------------------

test_that("Compounds are correctly initialized within test Snapshot", {
  expect_no_error(snapshot$compounds)
})

test_that("Compound collection is printed correctly", {
  expect_snapshot(print(snapshot$compounds))
})

test_that("Compounds are printed correctly", {
  for (compound in snapshot$compounds) {
    expect_snapshot(print(compound))
  }
})

test_that("Compound prints when is_small_molecule is unset", {
  compound <- create_compound(name = "NoFlag")
  expect_equal(compound$is_small_molecule, NA)
  expect_snapshot(print(compound))
})

test_that("Compounds sections can be accessed and are correctly printed", {
  expect_no_error({
    snapshot$compounds[[1]]$name
    snapshot$compounds[[1]]$is_small_molecule
    snapshot$compounds[[1]]$plasma_protein_binding_partner
    snapshot$compounds[[1]]$molecular_weight
    snapshot$compounds[[1]]$molecular_weight_unit
  })
  expect_snapshot(snapshot$compounds[[1]]$lipophilicity)
  expect_snapshot(snapshot$compounds[[2]]$parameters)
  expect_snapshot(snapshot$compounds[[1]]$calculation_methods)
})


# Active bindings --------------------------------------------------------

test_that("Compounds active binding data are of the same size than the raw data", {
  for (compound in test_snapshot$compounds) {
    expect_equal(
      length(compound$data$Parameters) - 1,
      length(compound$parameters)
    ) # -1 because molecular weight is removed from parameters
    expect_equal(
      length(compound$data$Lipophilicity),
      length(compound$lipophilicity)
    )
    expect_equal(
      length(compound$data$FractionUnbound),
      length(compound$fraction_unbound)
    )
    expect_equal(length(compound$data$Solubility), length(compound$solubility))
    expect_equal(
      length(compound$data$IntestinalPermeability),
      length(compound$intestinal_permeability)
    )

    # pkA types
    expect_equal(
      length(compound$data$PkaTypes),
      length(compound$pka_types)
    )
    expect_equal(length(compound$data$Processes), length(compound$processes))

    expect_equal(
      length(compound$data$CalculationMethods),
      compound$calculation_methods$length
    )
  }
})


# Dataframe representation -----------------------------------------------

test_that("Compounds can be converted to dataframes", {
  snapshot <- test_snapshot$clone()

  dfs <- get_compounds_dfs(snapshot)
  expect_named(dfs, c("properties", "processes"))
  expect_s3_class(dfs$properties, "tbl_df")
  expect_s3_class(dfs$processes, "tbl_df")

  expect_snapshot(print(dfs$properties, n = Inf))
  expect_snapshot(print(dfs$processes, n = Inf))
})

test_that("permeability is surfaced in print and the properties tibble", {
  compound <- create_compound(
    name = "X",
    is_small_molecule = TRUE,
    molecular_weight = 250,
    permeability = permeability(0.0069)
  )

  expect_snapshot(print(compound))

  snap <- add_compound(create_snapshot(), compound)
  properties <- get_compounds_dfs(snap)$properties
  perm_rows <- properties[properties$type == "permeability", ]
  expect_equal(nrow(perm_rows), 1)
  expect_equal(unname(perm_rows$value), "0.0069")
  expect_equal(unname(perm_rows$unit), "cm/min")
})


# Process accessor -------------------------------------------------------

test_that("$processes returns a flat named list of Process objects", {
  compound <- test_snapshot$compounds[[1]]
  processes <- compound$processes

  expect_type(processes, "list")
  expect_equal(length(processes), length(compound$data$Processes))
  expect_named(processes)
  for (p in processes) {
    expect_s3_class(p, "Process")
  }
})

test_that("Compound round-trips Processes byte-for-byte through $data", {
  snap <- Snapshot$new(testthat::test_path("data", "test_snapshot.json"))
  original <- jsonlite::fromJSON(
    txt = testthat::test_path("data", "test_snapshot.json"),
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )

  for (i in seq_along(snap$compounds)) {
    # Force every active binding that exercises the Processes path.
    procs <- snap$compounds[[i]]$processes
    for (p in procs) {
      invisible(p$category)
      invisible(p$internal_name)
      invisible(p$parameters)
    }
    expect_identical(
      snap$compounds[[i]]$data$Processes,
      original$Compounds[[i]]$Processes
    )
  }
})


# Deprecated category accessors ------------------------------------------

test_that("Deprecated category accessors warn", {
  compound <- test_snapshot$compounds[[1]]
  rlang::local_options(lifecycle_verbosity = "warning")
  expect_snapshot(invisible(compound$protein_binding_partners))
  expect_snapshot(invisible(compound$metabolizing_enzymes))
  expect_snapshot(invisible(compound$hepatic_clearance))
  expect_snapshot(invisible(compound$transporter_proteins))
  expect_snapshot(invisible(compound$renal_clearance))
  expect_snapshot(invisible(compound$biliary_clearance))
  expect_snapshot(invisible(compound$inhibition))
  expect_snapshot(invisible(compound$induction))
})


# Writable physicochemical fields ----------------------------------------

test_that("single-parameter physicochemical fields are writable by scalar", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$lipophilicity <- 3.3
  expect_equal(
    compound$data$Lipophilicity[[1]]$Parameters[[1]]$Value,
    3.3
  )
  expect_equal(compound$data$Lipophilicity[[1]]$Name, "User defined")

  compound$fraction_unbound <- 0.2
  fu <- compound$data$FractionUnbound[[1]]$Parameters[[1]]
  expect_equal(fu$Value, 0.2)
  expect_null(fu$Unit)

  compound$solubility <- 500
  sol <- compound$data$Solubility[[1]]$Parameters[[1]]
  expect_equal(sol$Name, "Solubility at reference pH")
  expect_equal(sol$Value, 500)
  expect_equal(sol$Unit, "mg/l")

  compound$intestinal_permeability <- 2e-05
  ip <- compound$data$IntestinalPermeability[[1]]$Parameters[[1]]
  expect_equal(ip$Value, 2e-05)
  expect_equal(ip$Unit, "cm/min")
})

test_that("permeability field reads and writes on a compound without the key", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  expect_null(compound$permeability)

  compound$permeability <- 0.007
  expect_s3_class(compound$permeability, "physicochemical_property")
  param <- compound$data$Permeability[[1]]$Parameters[[1]]
  expect_equal(param$Name, "Permeability")
  expect_equal(param$Value, 0.007)
  expect_equal(param$Unit, "cm/min")
})

test_that("physicochemical fields accept helper objects identically to scalars", {
  helper <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  scalar <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  helper$lipophilicity <- lipophilicity(2.5)
  scalar$lipophilicity <- 2.5
  expect_equal(helper$data$Lipophilicity, scalar$data$Lipophilicity)

  helper$fraction_unbound <- fraction_unbound(0.2)
  scalar$fraction_unbound <- 0.2
  expect_equal(helper$data$FractionUnbound, scalar$data$FractionUnbound)

  helper$intestinal_permeability <- intestinal_permeability(2e-05)
  scalar$intestinal_permeability <- 2e-05
  expect_equal(
    helper$data$IntestinalPermeability,
    scalar$data$IntestinalPermeability
  )
})

test_that("solubility field accepts a helper matching the factory raw shape", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$solubility <- solubility(9999, reference_pH = 7)
  factory <- create_compound(
    name = "X",
    solubility = solubility(9999, reference_pH = 7)
  )
  expect_equal(compound$data$Solubility, factory$data$Solubility)
})

test_that("physicochemical fields accept a list of value objects matching the factory", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$solubility <- list(
    solubility(9999, name = "Aqueous"),
    solubility(200, name = "FaSSIF")
  )
  factory <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, name = "Aqueous"),
      solubility(200, name = "FaSSIF")
    )
  )
  expect_equal(compound$data$Solubility, factory$data$Solubility)

  compound$lipophilicity <- list(
    lipophilicity(2.5, name = "Measured"),
    lipophilicity(3.1, name = "Predicted")
  )
  factory_lipo <- create_compound(
    name = "X",
    lipophilicity = list(
      lipophilicity(2.5, name = "Measured"),
      lipophilicity(3.1, name = "Predicted")
    )
  )
  expect_equal(compound$data$Lipophilicity, factory_lipo$data$Lipophilicity)
})

test_that("solubility field rejects a list containing a non-matching helper", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  expect_snapshot(
    error = TRUE,
    compound$solubility <- list(solubility(9999), lipophilicity(2.5))
  )
})

test_that("solubility field rejects duplicate alternative names", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  expect_snapshot(
    error = TRUE,
    compound$solubility <- list(solubility(9999), solubility(200))
  )
})

test_that("assigning the wrong helper to a physicochemical field aborts", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  expect_snapshot(error = TRUE, compound$lipophilicity <- weight(70))
  expect_snapshot(error = TRUE, compound$solubility <- lipophilicity(2.5))
})

test_that("physicochemical fields accept a raw alternative list verbatim", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  raw <- list(list(
    Name = "Custom",
    IsDefault = TRUE,
    Parameters = list(
      list(Name = "Solubility at reference pH", Value = 12, Unit = "mg/l"),
      list(Name = "Reference pH", Value = 7)
    )
  ))
  compound$solubility <- raw
  expect_equal(compound$data$Solubility, raw)
})

test_that("pka_types is writable via list shape and raw shape", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$pka_types <- list(list(type = "Base", value = 7.9))
  expect_equal(
    compound$data$PkaTypes,
    list(list(Type = "Base", Pka = 7.9))
  )

  compound$pka_types <- list(list(Type = "Acid", Pka = 1.2))
  expect_equal(
    compound$data$PkaTypes,
    list(list(Type = "Acid", Pka = 1.2))
  )
})

test_that("processes field is writable", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$processes <- list(
    create_process(
      internal_name = "GlomerularFiltration",
      data_source = "Publication X"
    )
  )
  expect_length(compound$processes, 1)
  expect_equal(compound$processes[[1]]$category, "renal_clearance")
  expect_null(names(compound$data$Processes))
})

test_that("assigning NULL clears the single-parameter physicochemical keys", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$lipophilicity <- NULL
  compound$fraction_unbound <- NULL
  compound$solubility <- NULL
  compound$intestinal_permeability <- NULL
  compound$permeability <- 0.007
  compound$permeability <- NULL

  expect_null(compound$data$Lipophilicity)
  expect_null(compound$data$FractionUnbound)
  expect_null(compound$data$Solubility)
  expect_null(compound$data$IntestinalPermeability)
  expect_null(compound$data$Permeability)
})

test_that("clearing pka_types and processes with NULL or list()", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$pka_types <- NULL
  expect_null(compound$data$PkaTypes)

  compound$pka_types <- list(list(type = "Base", value = 7.9))
  compound$pka_types <- list()
  expect_null(compound$data$PkaTypes)

  compound$processes <- list()
  expect_length(compound$processes, 0)
  expect_null(compound$data$Processes)

  compound$processes <- list(
    create_process(internal_name = "GlomerularFiltration", data_source = "X")
  )
  compound$processes <- NULL
  expect_length(compound$processes, 0)
  expect_null(compound$data$Processes)
})

test_that("invalid physicochemical field assignments abort", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  expect_snapshot(error = TRUE, compound$lipophilicity <- "high")
  expect_snapshot(error = TRUE, compound$permeability <- "high")
})


# Round trip -------------------------------------------------------------

test_that("compound built with new arguments round-trips through export", {
  compound <- create_compound(
    name = "RTX",
    lipophilicity = lipophilicity(2.5),
    fraction_unbound = fraction_unbound(1),
    solubility = solubility(9999, reference_pH = 7, gain_per_charge = 1000),
    intestinal_permeability = intestinal_permeability(1.14e-05),
    permeability = permeability(0.0069),
    pKa = list(list(type = "Base", value = 10.02)),
    processes = list(
      create_process(
        internal_name = "GlomerularFiltration",
        data_source = "X"
      )
    )
  )
  snap <- add_compound(create_snapshot(), compound)

  path <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snap, path)
  reloaded <- load_snapshot(path)
  rc <- reloaded$compounds[[1]]

  expect_equal(rc$data$Lipophilicity, compound$data$Lipophilicity)
  expect_equal(rc$data$FractionUnbound, compound$data$FractionUnbound)
  expect_equal(rc$data$Solubility, compound$data$Solubility)
  expect_equal(
    rc$data$IntestinalPermeability,
    compound$data$IntestinalPermeability
  )
  expect_equal(rc$data$Permeability, compound$data$Permeability)
  expect_equal(rc$data$PkaTypes, compound$data$PkaTypes)
  expect_equal(rc$data$Processes, compound$data$Processes)
})

test_that("mutating a loaded compound leaves unreassigned sections intact", {
  original <- jsonlite::fromJSON(
    txt = testthat::test_path("data", "test_snapshot.json"),
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )
  snap <- load_snapshot(testthat::test_path("data", "test_snapshot.json"))
  compound <- snap$compounds[[1]]

  compound$lipophilicity <- 4.2
  compound$pka_types <- list(list(type = "Base", value = 5.5))

  path <- withr::local_tempfile(fileext = ".json")
  export_snapshot(snap, path)
  reloaded <- jsonlite::fromJSON(
    txt = path,
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )

  # Value equality, not byte-identity: exporting whole-number doubles and
  # re-parsing them can flip their JSON storage type (double <-> integer),
  # a pre-existing artifact of the export path that is unrelated to whether
  # a section was mutated.
  expect_equal(
    reloaded$Compounds[[1]]$Parameters,
    original$Compounds[[1]]$Parameters
  )
  expect_equal(
    reloaded$Compounds[[1]]$CalculationMethods,
    original$Compounds[[1]]$CalculationMethods
  )
  expect_equal(
    reloaded$Compounds[[1]]$Solubility,
    original$Compounds[[1]]$Solubility
  )
})


# Deep clone -------------------------------------------------------------

test_that("Compound$clone(deep = TRUE) isolates calculation_methods", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  compound$calculation_methods <- c("Original")
  cloned <- compound$clone(deep = TRUE)
  cloned$calculation_methods$add("Mutated")

  expect_equal(compound$calculation_methods$names, "Original")
  expect_equal(
    cloned$calculation_methods$names,
    c("Original", "Mutated")
  )
})
