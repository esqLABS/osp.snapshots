# ---- ExpressionProfile logic tests ----
test_that("ExpressionProfile class initialization works", {
  # Test with complete data
  profile <- ExpressionProfile$new(complete_expression_profile_data)
  expect_s3_class(profile, "R6")
  expect_true("ExpressionProfile" %in% class(profile))
  expect_equal(profile$molecule, "CYP3A4")
  expect_equal(profile$type, "Enzyme")
  expect_equal(profile$species, "Human")
  expect_equal(profile$category, "Healthy")
  expect_equal(profile$localization, "Intracellular, BloodCellsIntracellular")
  expect_equal(profile$transportType, "Efflux")
  expect_equal(profile$ontogeny$Name, "CYP3A4")
  expect_length(profile$parameters, 3)

  # Test with minimal data
  simple_profile <- ExpressionProfile$new(minimal_expression_profile_data)
  expect_s3_class(simple_profile, "R6")
  expect_equal(simple_profile$molecule, "P-gp")
  expect_equal(simple_profile$type, "Transporter")
  expect_equal(simple_profile$species, "Human")
  expect_equal(simple_profile$category, "Healthy")
  expect_null(simple_profile$localization)
  expect_null(simple_profile$transportType)
  expect_null(simple_profile$ontogeny)
  expect_length(simple_profile$parameters, 0)

  # Test without category
  without_category <- ExpressionProfile$new(
    without_category_expression_profile_data
  )
  expect_s3_class(without_category, "R6")
  expect_equal(without_category$molecule, "OATP1B1")
  expect_equal(without_category$type, "Transporter")
  expect_equal(without_category$species, "Rat")
  expect_null(without_category$category)
  expect_length(without_category$parameters, 1)
})

test_that("ExpressionProfile getters work", {
  profile <- ExpressionProfile$new(complete_expression_profile_data)

  # Test getters
  expect_equal(profile$molecule, "CYP3A4")
  expect_equal(profile$type, "Enzyme")
  expect_equal(profile$species, "Human")
  expect_equal(profile$category, "Healthy")
  expect_equal(profile$localization, "Intracellular, BloodCellsIntracellular")
  expect_equal(profile$transportType, "Efflux")
  expect_equal(profile$ontogeny$Name, "CYP3A4")
  expect_equal(profile$data, complete_expression_profile_data)

  # Test id generation
  expect_equal(profile$id, "CYP3A4_Human_Healthy")

  # Test id generation without category
  without_category <- ExpressionProfile$new(
    without_category_expression_profile_data
  )
  expect_equal(without_category$id, "OATP1B1_Rat_NA")
})

test_that("ExpressionProfile print method works", {
  # Test printing (output captured by testthat)
  expect_snapshot(print(complete_expression_profile))
  expect_snapshot(print(minimal_expression_profile))
  expect_snapshot(print(without_category_expression_profile))
})

test_that("print.expression_profile_collection works", {
  # Create a collection
  profiles <- list(
    complete_expression_profile,
    minimal_expression_profile,
    without_category_expression_profile
  )
  names(profiles) <- c(
    "CYP3A4|Human|Healthy",
    "P-gp|Human|Healthy",
    "OATP1B1|Rat|NA"
  )
  class(profiles) <- c(
    "expression_profile_collection",
    "snapshot_collection",
    "list"
  )

  # Test printing
  expect_snapshot(print(profiles))

  # Test empty collection
  empty_profiles <- list()
  class(empty_profiles) <- c(
    "expression_profile_collection",
    "snapshot_collection",
    "list"
  )
  expect_snapshot(print(empty_profiles))
})

test_that("to_df converts expression profile to tibble correctly", {
  # Test with a complete expression profile
  profile <- ExpressionProfile$new(complete_expression_profile_data)
  result <- profile$to_df()

  # Check structure
  expect_type(result, "list")
  expect_named(
    result,
    c("expression_profiles", "expression_profiles_parameters")
  )

  # Check basic dataframe
  expect_s3_class(result$expression_profiles, "tbl_df")
  expect_equal(nrow(result$expression_profiles), 1)
  expect_equal(result$expression_profiles$molecule, "CYP3A4")
  expect_equal(result$expression_profiles$type, "Enzyme")
  expect_equal(result$expression_profiles$species, "Human")
  expect_equal(result$expression_profiles$transport_type, "Efflux")
  expect_equal(result$expression_profiles$ontogeny, "CYP3A4")

  # Check parameters dataframe
  expect_s3_class(result$expression_profiles_parameters, "tbl_df")
  expect_equal(nrow(result$expression_profiles_parameters), 3)
  expect_true("parameter" %in% colnames(result$expression_profiles_parameters))
  expect_true("value" %in% colnames(result$expression_profiles_parameters))
  expect_true("unit" %in% colnames(result$expression_profiles_parameters))
  expect_true("source" %in% colnames(result$expression_profiles_parameters))

  # Check specific parameter
  ref_conc_row <- result$expression_profiles_parameters[
    result$expression_profiles_parameters$parameter ==
      "CYP3A4|Reference concentration",
  ]
  expect_equal(ref_conc_row$value, 4.32)
  expect_equal(ref_conc_row$unit, "µmol/l")
  expect_equal(ref_conc_row$source, "Other")

  # Test with a minimal expression profile (no parameters)
  minimal_profile <- ExpressionProfile$new(minimal_expression_profile_data)
  minimal_result <- minimal_profile$to_df()

  # Check structure
  expect_type(minimal_result, "list")
  expect_named(
    minimal_result,
    c("expression_profiles", "expression_profiles_parameters")
  )

  # Check basic dataframe
  expect_s3_class(minimal_result$expression_profiles, "tbl_df")
  expect_equal(nrow(minimal_result$expression_profiles), 1)
  expect_equal(minimal_result$expression_profiles$molecule, "P-gp")

  # Check parameters is NULL
  expect_null(minimal_result$expression_profiles_parameters)

  # Test with profile without category
  without_category <- ExpressionProfile$new(
    without_category_expression_profile_data
  )
  result_no_cat <- without_category$to_df()

  # Check basic dataframe
  expect_s3_class(result_no_cat$expression_profiles, "tbl_df")
  expect_equal(nrow(result_no_cat$expression_profiles), 1)
  expect_equal(result_no_cat$expression_profiles$molecule, "OATP1B1")
  expect_true(is.na(result_no_cat$expression_profiles$category))

  # Check parameters dataframe
  expect_s3_class(result_no_cat$expression_profiles_parameters, "tbl_df")
  expect_equal(nrow(result_no_cat$expression_profiles_parameters), 1)
})

test_that("ExpressionProfile$expression is a read/write binding", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme"
  )
  expect_null(profile$expression)

  profile$expression <- data.frame(
    name = c("Liver", "Kidney"),
    value = c(1, 0.5)
  )
  expect_equal(
    profile$expression,
    list(list(Name = "Liver", Value = 1), list(Name = "Kidney", Value = 0.5))
  )
  expect_equal(profile$data$Expression, profile$expression)

  profile$expression <- NULL
  expect_null(profile$data$Expression)
  expect_false("Expression" %in% names(profile$data))
})

test_that("ExpressionProfile$disease is a read/write binding", {
  profile <- create_expression_profile(
    molecule = "CYP3A4",
    species = "Human",
    category = "Healthy",
    type = "Enzyme"
  )
  expect_null(profile$disease)

  profile$disease <- list(name = "CKD")
  expect_equal(profile$disease, list(Name = "CKD"))
  expect_equal(profile$data$Disease, profile$disease)

  profile$disease <- NULL
  expect_null(profile$data$Disease)
  expect_false("Disease" %in% names(profile$data))
})

test_that("ExpressionProfile reads raw Expression and Disease from load", {
  snapshot_clone <- Snapshot$new(test_snapshot$data)
  profile <- snapshot_clone$expression_profiles[["P-gp_Human_Healthy"]]

  expect_equal(
    profile$expression[[1]],
    list(
      Name = "Bone",
      TransportDirection = "EffluxIntracellularToInterstitial",
      CompartmentName = "Intracellular"
    )
  )

  disease_profile <- ExpressionProfile$new(list(
    Type = "Enzyme",
    Species = "Human",
    Molecule = "CYP3A4",
    Category = "Healthy",
    Disease = list(Name = "CKD")
  ))
  expect_equal(disease_profile$disease, list(Name = "CKD"))
})

test_that("expression and disease round-trip through export and reload", {
  profile <- create_expression_profile(
    molecule = "P-gp",
    species = "Human",
    category = "Healthy",
    type = "Transporter",
    expression = data.frame(
      name = c("Liver", "Kidney", "Kidney"),
      value = c(1, NA, NA),
      compartment = c(NA, "Intracellular", "Interstitial"),
      transport_direction = c(NA, "Efflux", "Influx")
    ),
    disease = list(
      name = "CKD",
      parameters = list(create_parameter(name = "p", value = 1))
    )
  )
  snapshot <- empty_snapshot$clone()
  snapshot$add_expression_profile(profile)

  path <- withr::local_tempfile(fileext = ".json")
  snapshot$export(path)

  reloaded <- Snapshot$new(path)
  reloaded_profile <- reloaded$expression_profiles[["P-gp_Human_Healthy"]]

  expect_equal(reloaded_profile$expression, profile$expression)
  expect_equal(reloaded_profile$disease, profile$disease)
})

test_that("expression_profile_collection from cloned test snapshot works", {
  # Clone the test snapshot to avoid mutating the shared object
  snapshot_clone <- Snapshot$new(test_snapshot$data)
  profiles <- snapshot_clone$expression_profiles

  # Check class and length
  expect_s3_class(profiles, "expression_profile_collection")
  expect_gt(length(profiles), 0)

  # Check that known profile names are present
  expect_true(
    "CYP3A4_Human_Healthy" %in%
      names(profiles) ||
      "CYP3A4|Human|Healthy" %in% names(profiles)
  )
  expect_true(
    "P-gp_Human_Healthy" %in%
      names(profiles) ||
      "P-gp|Human|Healthy" %in% names(profiles)
  )

  # Print for snapshot testing
  expect_snapshot(print(profiles))
})

test_that("Snapshot with empty expression profiles is handled correctly", {
  snapshot <- empty_snapshot$clone()
  expect_s3_class(snapshot$expression_profiles, "expression_profile_collection")
  expect_length(snapshot$expression_profiles, 0)

  # Dataframe transformation should return empty tibbles with correct columns
  dfs <- get_expression_profiles_dfs(snapshot)
  expect_type(dfs, "list")
  expect_named(dfs, c("expression_profiles", "expression_profiles_parameters"))
  expect_s3_class(dfs$expression_profiles, "tbl_df")
  expect_s3_class(dfs$expression_profiles_parameters, "tbl_df")
  expect_equal(nrow(dfs$expression_profiles), 0)
  expect_equal(nrow(dfs$expression_profiles_parameters), 0)
  expect_snapshot(knitr::kable(dfs$expression_profiles))
  expect_snapshot(knitr::kable(dfs$expression_profiles_parameters))
})

test_that("expression_profile transportType is correctly extracted from snapshot", {
  # Clone the test snapshot to avoid mutating the shared object
  snapshot_clone <- test_snapshot$clone()

  # Get dataframes from snapshot
  dfs <- get_expression_profiles_dfs(snapshot_clone)

  # Check that transport_type column exists
  expect_snapshot(knitr::kable(dfs$expression_profiles))
  expect_snapshot(knitr::kable(dfs$expression_profiles_parameters))
})

test_that("ExpressionProfile$data is read-only", {
  profile <- ExpressionProfile$new(complete_expression_profile_data)
  expect_snapshot(error = TRUE, profile$data <- list())
  expect_equal(profile$data, complete_expression_profile_data)
})
