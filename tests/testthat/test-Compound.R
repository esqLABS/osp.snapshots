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

test_that("is_small_molecule requires a single logical or NULL", {
  compound <- create_compound(name = "X")
  compound$is_small_molecule <- TRUE
  expect_true(compound$is_small_molecule)
  expect_snapshot(error = TRUE, compound$is_small_molecule <- "yes")
  compound$is_small_molecule <- NULL
  expect_equal(compound$is_small_molecule, NA)
})

test_that("name requires a non-empty scalar string", {
  compound <- create_compound(name = "X")
  compound$name <- "Renamed"
  expect_equal(compound$name, "Renamed")
  expect_snapshot(error = TRUE, compound$name <- "")
  expect_snapshot(error = TRUE, compound$name <- NA_character_)
  expect_snapshot(error = TRUE, compound$name <- 5)
  expect_snapshot(error = TRUE, compound$name <- c("a", "b"))
})

test_that("plasma_protein_binding_partner is validated against the enum", {
  compound <- create_compound(name = "X")
  compound$plasma_protein_binding_partner <- "Albumin"
  expect_equal(compound$plasma_protein_binding_partner, "Albumin")
  expect_snapshot(
    error = TRUE,
    compound$plasma_protein_binding_partner <- "Casein"
  )
  compound$plasma_protein_binding_partner <- NULL
  expect_null(compound$plasma_protein_binding_partner)
})

test_that("plasma_protein_binding_partner rejects non-scalar-character input", {
  compound <- create_compound(name = "X")
  expect_snapshot(
    error = TRUE,
    compound$plasma_protein_binding_partner <- character(0)
  )
  expect_snapshot(
    error = TRUE,
    compound$plasma_protein_binding_partner <- c("Albumin", "Unknown")
  )
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

test_that("solubility extraction defaults reference pH to 7 when it is omitted", {
  # PK-Sim omits the `Reference pH` parameter from the snapshot when it holds
  # the default value, so a reference-pH alternative can carry only the
  # `Solubility at reference pH` parameter.
  compound <- Compound$new(list(
    Name = "OmittedRefPh",
    Parameters = list(list(
      Name = "Molecular weight",
      Value = 250,
      Unit = "g/mol"
    )),
    Solubility = list(list(
      Name = "Water",
      Parameters = list(list(
        Name = "Solubility at reference pH",
        Value = 2800,
        Unit = "mg/l"
      ))
    ))
  ))

  properties <- compound$to_df()
  sol_rows <- properties[properties$type == "solubility", ]

  expect_equal(nrow(sol_rows), 1)
  expect_equal(unname(sol_rows$parameter), "pH 7")
  expect_equal(unname(sol_rows$value), "2800")
  expect_equal(unname(sol_rows$unit), "mg/l")
})

test_that("to_df() handles a compound with no top-level Parameters", {
  # A compound whose only property is a value-object alternative (here
  # lipophilicity) has no top-level `Parameters` array, so
  # `.extract_parameters()` receives `NULL` for the molecular-weight lookup.
  # It must not error.
  compound <- create_compound(name = "X", lipophilicity = lipophilicity(2.5))

  properties <- compound$to_df()

  lipo_rows <- properties[properties$type == "lipophilicity", ]
  expect_equal(nrow(lipo_rows), 1)
  expect_equal(unname(lipo_rows$value), "2.5")
  expect_equal(nrow(properties[properties$type == "molecular_weight", ]), 0)
})

test_that("to_df() handles a compound whose process has empty Parameters", {
  # PK-Sim exports a parameterless process (e.g. `GlomerularFiltration`) with
  # `"Parameters": []`. Combined with a compound that has no top-level
  # `Parameters`, this exercises both empty-input paths at once.
  compound <- create_compound(
    name = "Fluvoxamine",
    lipophilicity = lipophilicity(2.5),
    processes = list(
      create_process(
        internal_name = "GlomerularFiltration",
        data_source = "Publication"
      )
    )
  )

  properties <- compound$to_df()

  # The parameterless process contributes no process rows, and the
  # physicochemical property still comes through.
  expect_equal(nrow(properties[properties$category == "renal_clearance", ]), 0)
  expect_equal(nrow(properties[properties$type == "lipophilicity", ]), 1)
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

test_that("single-parameter physicochemical fields are writable by helper", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$lipophilicity <- lipophilicity(3.3)
  expect_equal(
    compound$data$Lipophilicity[[1]]$Parameters[[1]]$Value,
    3.3
  )
  expect_equal(compound$data$Lipophilicity[[1]]$Name, "User defined")

  compound$fraction_unbound <- fraction_unbound(0.2)
  fu <- compound$data$FractionUnbound[[1]]$Parameters[[1]]
  expect_equal(fu$Value, 0.2)
  expect_null(fu$Unit)
  expect_equal(compound$data$FractionUnbound[[1]]$Species, "Human")

  compound$solubility <- solubility(500)
  sol <- compound$data$Solubility[[1]]$Parameters[[1]]
  expect_equal(sol$Name, "Solubility at reference pH")
  expect_equal(sol$Value, 500)
  expect_equal(sol$Unit, "mg/l")

  compound$intestinal_permeability <- intestinal_permeability(2e-05)
  ip <- compound$data$IntestinalPermeability[[1]]$Parameters[[1]]
  expect_equal(ip$Value, 2e-05)
  expect_equal(ip$Unit, "cm/min")
})

test_that("fraction_unbound field setter carries the species override", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  compound$fraction_unbound <- fraction_unbound(1, species = "Rat")
  expect_equal(compound$data$FractionUnbound[[1]]$Species, "Rat")
})

test_that("permeability field reads and writes on a compound without the key", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)

  expect_null(compound$permeability)

  compound$permeability <- permeability(0.007)
  expect_s3_class(compound$permeability, "physicochemical_property")
  param <- compound$data$Permeability[[1]]$Parameters[[1]]
  expect_equal(param$Name, "Permeability")
  expect_equal(param$Value, 0.007)
  expect_equal(param$Unit, "cm/min")
})

test_that("bare numeric scalars are rejected for physicochemical fields", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  expect_snapshot(error = TRUE, compound$lipophilicity <- 2.5)
  expect_snapshot(error = TRUE, compound$fraction_unbound <- 0.2)
  expect_snapshot(error = TRUE, compound$solubility <- 500)
  expect_snapshot(error = TRUE, compound$intestinal_permeability <- 2e-05)
  expect_snapshot(error = TRUE, compound$permeability <- 0.007)
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

  # Non-first explicit default: the field-assignment path must match the
  # factory path exactly (FR-6).
  compound$solubility <- list(
    solubility(9999, name = "Aqueous"),
    solubility(200, name = "FaSSIF", default = TRUE)
  )
  factory_default <- create_compound(
    name = "X",
    solubility = list(
      solubility(9999, name = "Aqueous"),
      solubility(200, name = "FaSSIF", default = TRUE)
    )
  )
  expect_equal(compound$data$Solubility, factory_default$data$Solubility)
})

test_that("assigning a physicochemical field with two defaults aborts, matching the factory", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  expect_snapshot(
    error = TRUE,
    compound$solubility <- list(
      solubility(9999, name = "Aqueous", default = TRUE),
      solubility(200, name = "FaSSIF", default = TRUE)
    )
  )
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
  compound$permeability <- permeability(0.007)
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

  compound$lipophilicity <- lipophilicity(4.2)
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
