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


# Deep clone -------------------------------------------------------------

test_that("Compound$clone(deep = TRUE) isolates calculation_methods", {
  compound <- test_snapshot$clone()$compounds[[1]]$clone(deep = TRUE)
  compound$calculation_methods <- c("Original")
  cloned <- compound$clone(deep = TRUE)
  cloned$calculation_methods$add("Mutated")

  expect_equal(compound$calculation_methods$methods, "Original")
  expect_equal(
    cloned$calculation_methods$methods,
    c("Original", "Mutated")
  )
})
