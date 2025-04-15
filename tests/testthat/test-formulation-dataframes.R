test_that("get_formulations_dfs returns combined data frames from all formulations", {
    # Create a test snapshot with minimal data structure
    snapshot_data <- list(Version = "80", Formulations = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Add multiple formulation types from helper-Formulation.R
    snapshot$add_formulation(complete_formulation) # Weibull tablet
    snapshot$add_formulation(minimal_formulation) # Dissolved
    snapshot$add_formulation(table_formulation) # Table-based
    snapshot$add_formulation(particle_formulation) # Particle

    # Get combined data frames
    dfs <- get_formulations_dfs(snapshot)

    # Verify structure
    expect_type(dfs, "list")
    expect_named(dfs, c("basic", "parameters"))
    expect_s3_class(dfs$basic, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Check number of rows
    expect_equal(nrow(dfs$basic), 4)

    # Check that formulation names are included in basic df
    form_names <- dfs$basic$name
    expect_true("Test Tablet" %in% form_names)
    expect_true("Oral Solution" %in% form_names)
    expect_true("Custom Release" %in% form_names)
    expect_true("Particle Formulation" %in% form_names)

    # Check formulation_id is used to link tables
    expect_true(all(
        dfs$parameters$formulation_id %in% dfs$basic$formulation_id
    ))

    # Test snapshot for all data frames
    expect_snapshot({
        print(dfs$basic, width = Inf)
        print(dfs$parameters, width = Inf)
    })
})

test_that("get_formulations_dfs handles snapshots with no formulations", {
    # Create a test snapshot with no formulations
    snapshot_data <- list(Version = "80")
    snapshot <- Snapshot$new(snapshot_data)

    # Get combined data frames
    dfs <- get_formulations_dfs(snapshot)

    # Verify structure
    expect_type(dfs, "list")
    expect_named(dfs, c("basic", "parameters"))
    expect_s3_class(dfs$basic, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Check that data frames are empty
    expect_equal(nrow(dfs$basic), 0)
    expect_equal(nrow(dfs$parameters), 0)

    # Snapshot empty data frames
    expect_snapshot({
        print(dfs$basic, width = Inf)
        print(dfs$parameters, width = Inf)
    })
})


test_that("to_df returns specific tables when requested", {
    # Test Weibull formulation

    # Test parameters data
    params_df <- complete_formulation$to_df("parameters")
    expect_s3_class(params_df, "tbl_df")
    expect_snapshot(print(params_df, width = Inf))

    # Test "all" returns all tables
    all_dfs <- complete_formulation$to_df("all")
    expect_type(all_dfs, "list")
    expect_named(all_dfs, c("basic", "parameters"))
    expect_s3_class(all_dfs$basic, "tbl_df")
    expect_snapshot(print(all_dfs$basic, width = Inf))
})

test_that("to_df handles formulations without parameters", {
    # Test minimal dissolved formulation
    dfs <- minimal_formulation$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("basic", "parameters"))

    # Snapshot all tables
    expect_snapshot({
        print(dfs$basic, width = Inf)
        print(dfs$parameters, width = Inf)
    })
})
