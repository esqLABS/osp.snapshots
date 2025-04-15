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

test_that("get_formulations_dfs validates input is a Snapshot", {
    # Test with invalid input
    expect_error(
        get_formulations_dfs("not a snapshot"),
        "Input must be a Snapshot object"
    )

    # Test with NULL
    expect_error(
        get_formulations_dfs(NULL),
        "Input must be a Snapshot object"
    )
})

test_that("get_formulations_basic_df returns just the basic dataframe", {
    # Create a test snapshot with multiple formulations
    snapshot_data <- list(Version = "80", Formulations = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Add multiple formulations
    snapshot$add_formulation(minimal_formulation)
    snapshot$add_formulation(zero_order_formulation)

    # Get basic data frame
    basic_df <- get_formulations_basic_df(snapshot)

    # Verify it's a tibble
    expect_s3_class(basic_df, "tbl_df")

    # Verify it has expected columns
    expect_true(all(
        c(
            "formulation_id",
            "name",
            "formulation_type",
            "formulation_type_human"
        ) %in%
            names(basic_df)
    ))

    # Verify it has the right number of rows
    expect_equal(nrow(basic_df), 2)

    # Snapshot the basic dataframe
    expect_snapshot({
        print(basic_df, width = Inf)
    })
})

test_that("get_formulations_parameters_df returns just the parameters dataframe", {
    # Create a test snapshot with formulations that have parameters
    snapshot_data <- list(Version = "80", Formulations = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Add formulations with parameters
    snapshot$add_formulation(complete_formulation)
    snapshot$add_formulation(first_order_formulation)

    # Get parameters data frame
    params_df <- get_formulations_parameters_df(snapshot)

    # Verify it's a tibble
    expect_s3_class(params_df, "tbl_df")

    # Verify it has expected columns
    expect_true(all(
        c(
            "formulation_id",
            "name",
            "value",
            "unit"
        ) %in%
            names(params_df)
    ))

    # Verify it has the right number of rows (should be greater than 0)
    expect_true(nrow(params_df) > 0)

    # Snapshot the parameters dataframe
    expect_snapshot({
        print(params_df, width = Inf)
    })
})

test_that("to_df returns all tables by default for various formulation types", {
    # Test various formulation types using fixtures from helper-Formulation.R

    # Test Weibull formulation
    dfs <- complete_formulation$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("basic", "parameters"))
    expect_s3_class(dfs$basic, "tbl_df")
    expect_s3_class(dfs$parameters, "tbl_df")

    # Snapshot all tables
    expect_snapshot({
        print(dfs$basic, width = Inf)
        print(dfs$parameters, width = Inf)
    })

    # Test Table formulation
    dfs <- table_formulation$to_df()
    expect_snapshot({
        print(dfs$basic, width = Inf)
        print(dfs$parameters, width = Inf)
    })
})

test_that("to_df returns specific tables when requested", {
    # Test Weibull formulation

    # Test basic data
    basic_df <- complete_formulation$to_df("basic")
    expect_s3_class(basic_df, "tbl_df")
    expect_snapshot(print(basic_df, width = Inf))

    # Test parameters data
    params_df <- complete_formulation$to_df("parameters")
    expect_s3_class(params_df, "tbl_df")
    expect_snapshot(print(params_df, width = Inf))
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
