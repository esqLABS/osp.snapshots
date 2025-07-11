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
  expect_snapshot(snapshot$compounds[[1]]$processes)
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
      length(compound$calculation_methods)
    )
  }
})


# Dataframe representation -----------------------------------------------

test_that("Compounds can be converted to dataframes", {
  # Generate snapshot with legacy code
  snapshot <- test_snapshot$clone()

  for (f in list.files(
    here::here("legacy_code"),
    pattern = "*.R",
    full.names = TRUE
  )) {
    source(f)
  }
  c_data <- get_compound_data(snapshot$data)

  # expect_snapshot(print(get_compound_df(c_data, 5),n=Inf, width = Inf))
  expect_snapshot(print(get_compounds_dfs(snapshot), n = Inf))
})
