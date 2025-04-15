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

    # Use expect_snapshot to verify dataframe structure and content
    expect_snapshot(dfs)
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

    # Use expect_snapshot to verify empty dataframes
    expect_snapshot(dfs)
})


test_that("to_df returns specific tables when requested", {
    # Test Weibull formulation

    # Test parameters data
    params_df <- complete_formulation$to_df("parameters")
    expect_s3_class(params_df, "tbl_df")
    expect_snapshot(params_df)

    # Test "all" returns all tables
    all_dfs <- complete_formulation$to_df("all")
    expect_type(all_dfs, "list")
    expect_named(all_dfs, c("basic", "parameters"))
    expect_snapshot(all_dfs)
})

test_that("to_df handles formulations without parameters", {
    # Test minimal dissolved formulation
    dfs <- minimal_formulation$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("basic", "parameters"))

    # Use expect_snapshot to verify dataframes
    expect_snapshot(dfs)
})
