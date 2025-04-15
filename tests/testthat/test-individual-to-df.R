test_that("to_df returns all tables by default", {
    # Create individual with all fields populated, adding more data from test_snapshot.json
    ind <- create_individual(
        name = "Mouly2002",
        species = "Human",
        population = "WhiteAmerican_NHANES_1997",
        gender = "MALE",
        age = 29.9,
        age_unit = "year(s)",
        weight = 70,
        weight_unit = "kg",
        height = 175,
        height_unit = "cm",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        disease_state = "Healthy",
        seed = 1300547185
    )

    # Add parameters with more complete data including ValueOrigin
    ind$parameters <- list(
        Parameter$new(list(
            Path = "Organism|Gallbladder|Gallbladder ejection fraction",
            Value = 0.8,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        )),
        Parameter$new(list(
            Path = "Organism|Liver|EHC continuous fraction",
            Value = 1.0,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        ))
    )

    # Add expression profiles from test_snapshot.json
    data <- ind$data
    data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind <- Individual$new(data)

    # Get all tables
    dfs <- ind$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))

    # Use expect_snapshot to verify dataframe structure and content
    expect_snapshot(dfs)
})

test_that("to_df returns specific tables when requested", {
    # Create individual with all data based on test_snapshot.json
    ind <- create_individual(
        name = "European",
        species = "Human",
        population = "European_ICRP_2002",
        gender = "MALE",
        age = 30.0,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 186687441
    )

    # Add expression profiles
    data <- ind$data
    data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind <- Individual$new(data)

    # Test origin data
    origin_df <- ind$to_df("origin")
    expect_s3_class(origin_df, "tbl_df")
    expect_snapshot(origin_df)

    # Test parameters data
    params_df <- ind$to_df("parameters")
    expect_s3_class(params_df, "tbl_df")
    expect_snapshot(params_df)

    # Test expression profiles data
    expr_df <- ind$to_df("expressions")
    expect_s3_class(expr_df, "tbl_df")
    expect_snapshot(expr_df)
})

test_that("to_df handles missing values", {
    # Create minimal individual
    ind <- create_individual(name = "Minimal")

    # Get all tables
    dfs <- ind$to_df()

    # Check structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))

    # Snapshot all tables
    expect_snapshot(dfs)
})

test_that("to_df includes gestational age", {
    # Create individual with gestational age
    ind <- create_individual(
        name = "Preterm Baby",
        species = "Human",
        population = "Preterm",
        gender = "MALE",
        age = 10.0,
        age_unit = "day(s)",
        gestational_age = 30.0,
        gestational_age_unit = "week(s)",
        weight = 1.5,
        weight_unit = "kg",
        height = 40,
        height_unit = "cm"
    )

    # Get origin data
    origin_df <- ind$to_df("origin")

    # Check that gestational age is included
    expect_true("gestational_age" %in% names(origin_df))
    expect_true("gestational_age_unit" %in% names(origin_df))

    # Use expect_snapshot to verify dataframe content
    expect_snapshot(origin_df)
})

test_that("to_df validates type argument", {
    ind <- create_individual("Test")
    expect_error(
        ind$to_df("invalid"),
        "type must be one of: all, origin, parameters, expressions"
    )
})

test_that("get_individuals_dfs returns combined data frames from all individuals", {
    # Create a test snapshot with minimal data structure
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Add first individual with parameters from test_snapshot.json
    ind1 <- create_individual(
        name = "Mouly2002",
        species = "Human",
        population = "WhiteAmerican_NHANES_1997",
        gender = "MALE",
        age = 29.9,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 1300547185
    )

    ind1$parameters <- list(
        Parameter$new(list(
            Path = "Organism|Gallbladder|Gallbladder ejection fraction",
            Value = 0.8,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        )),
        Parameter$new(list(
            Path = "Organism|Liver|EHC continuous fraction",
            Value = 1.0,
            ValueOrigin = list(
                Source = "Publication",
                Description = "R24-4081"
            )
        ))
    )

    # Add expression profiles to first individual
    ind1_data <- ind1$data
    ind1_data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind1 <- Individual$new(ind1_data)
    snapshot$add_individual(ind1)

    # Add second individual from test_snapshot.json
    ind2 <- create_individual(
        name = "European",
        species = "Human",
        population = "European_ICRP_2002",
        gender = "MALE",
        age = 30.0,
        age_unit = "year(s)",
        calculation_methods = c(
            "SurfaceAreaPlsInt_VAR1",
            "Body surface area - Mosteller"
        ),
        seed = 186687441
    )

    # Add expression profiles to second individual
    ind2_data <- ind2$data
    ind2_data$ExpressionProfiles <- c(
        "CYP1A2|Human|Healthy",
        "CYP2B6|Human|Healthy"
    )
    ind2 <- Individual$new(ind2_data)
    snapshot$add_individual(ind2)

    # Get combined data frames
    dfs <- get_individuals_dfs(snapshot)

    # Verify structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))

    # Use expect_snapshot to verify dataframe content
    expect_snapshot(dfs)
})

test_that("get_individuals_dfs handles empty snapshot", {
    # Create empty snapshot
    snapshot_data <- list(Version = "80", Individuals = list())
    snapshot <- Snapshot$new(snapshot_data)

    # Get data frames
    dfs <- get_individuals_dfs(snapshot)

    # Verify structure
    expect_type(dfs, "list")
    expect_named(dfs, c("origin", "parameters", "expressions"))

    # Use expect_snapshot to verify empty dataframes
    expect_snapshot(dfs)
})
