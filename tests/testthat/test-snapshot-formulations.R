test_that("Snapshot initializes formulations correctly", {
    # Create a minimal snapshot with formulations
    snapshot_data <- list(
        Version = 80,
        Formulations = list(
            list(
                Name = "Test Tablet",
                FormulationType = "Formulation_Tablet_Weibull",
                Parameters = list(
                    list(
                        Name = "Dissolution time (50% dissolved)",
                        Value = 60.0,
                        Unit = "min"
                    )
                )
            ),
            list(
                Name = "Test Solution",
                FormulationType = "Formulation_Dissolved"
            )
        )
    )

    snapshot <- Snapshot$new(snapshot_data)

    # Test that formulations are initialized
    expect_s3_class(snapshot$formulations, "formulation_collection")
    expect_length(snapshot$formulations, 2)

    # Test that formulations have proper names
    expect_equal(
        names(snapshot$formulations),
        c("Test Tablet", "Test Solution")
    )

    # Test that formulations are the correct class
    expect_true(all(sapply(
        snapshot$formulations,
        function(f) inherits(f, "Formulation")
    )))
})

test_that("Adding formulations to snapshots works", {
    # Create an empty snapshot
    snapshot <- Snapshot$new(list(Version = 80))

    # Create a formulation to add
    formulation <- create_formulation(
        name = "New Tablet",
        type = "Weibull",
        parameters = list(
            dissolution_time = 30,
            dissolution_time_unit = "min",
            lag_time = 5,
            lag_time_unit = "min",
            dissolution_shape = 0.85,
            suspension = TRUE
        )
    )

    # Add formulation via class method
    snapshot$add_formulation(formulation)

    # Check that formulation was added
    expect_length(snapshot$formulations, 1)
    expect_equal(names(snapshot$formulations), "New Tablet")
    expect_s3_class(snapshot$formulations$`New Tablet`, "Formulation")

    # Add another formulation via helper function
    dissolved <- create_formulation(name = "Test Solution", type = "Dissolved")
    snapshot <- add_formulation(snapshot, dissolved)

    # Check that both formulations are present
    expect_length(snapshot$formulations, 2)
    expect_equal(names(snapshot$formulations), c("New Tablet", "Test Solution"))

    # Check snapshot data structure
    expect_length(snapshot$data$Formulations, 2)
    expect_equal(snapshot$data$Formulations[[1]]$Name, "New Tablet")
    expect_equal(snapshot$data$Formulations[[2]]$Name, "Test Solution")
})

test_that("Removing formulations from snapshots works", {
    # Create a snapshot with multiple formulations
    snapshot_data <- list(
        Version = 80,
        Formulations = list(
            list(
                Name = "Tablet 1",
                FormulationType = "Formulation_Tablet_Weibull"
            ),
            list(
                Name = "Tablet 2",
                FormulationType = "Formulation_Tablet_Weibull"
            ),
            list(
                Name = "Solution",
                FormulationType = "Formulation_Dissolved"
            )
        )
    )

    snapshot <- Snapshot$new(snapshot_data)
    expect_length(snapshot$formulations, 3)

    # Remove a single formulation via class method
    snapshot$remove_formulation("Tablet 1")
    expect_length(snapshot$formulations, 2)
    expect_equal(names(snapshot$formulations), c("Tablet 2", "Solution"))

    # Remove multiple formulations via helper function
    snapshot <- remove_formulation(
        snapshot,
        c("Tablet 2", "Solution")
    )
    expect_length(snapshot$formulations, 0)

    # Test warning for non-existent formulation
    expect_warning(snapshot$remove_formulation("NonExistent"))
})

test_that("Formulations are preserved when exporting and importing snapshots", {
    # Skip test if file operations not allowed
    skip_on_ci()

    # Create a snapshot with formulations using our local_snapshot helper
    snapshot <- local_snapshot(list(Version = 80))

    # Add a formulation
    tablet <- create_formulation(
        name = "Test Tablet",
        type = "Weibull",
        parameters = list(
            dissolution_time = 30,
            dissolution_time_unit = "min",
            lag_time = 0,
            lag_time_unit = "min",
            dissolution_shape = 0.9,
            suspension = TRUE
        )
    )
    snapshot$add_formulation(tablet)

    # Export to a temporary file using withr::local_tempfile for automatic cleanup
    temp_file <- withr::local_tempfile(fileext = ".json")
    snapshot$export(temp_file)

    # Import back
    imported_snapshot <- Snapshot$new(temp_file)

    # Check formulation preservation
    expect_length(imported_snapshot$formulations, 1)
    expect_equal(names(imported_snapshot$formulations), "Test Tablet")

    # Check details of the formulation were preserved
    imported_formulation <- imported_snapshot$formulations$`Test Tablet`
    expect_equal(
        imported_formulation$formulation_type,
        "Formulation_Tablet_Weibull"
    )

    # Check parameters were preserved (using unclass to avoid class comparison issues)
    original_params <- unclass(tablet$parameters)
    imported_params <- unclass(imported_formulation$parameters)

    # Check params have same names and values
    expect_equal(
        lapply(original_params, function(p) p$Name),
        lapply(imported_params, function(p) p$Name)
    )
    expect_equal(
        lapply(original_params, function(p) p$Value),
        lapply(imported_params, function(p) p$Value)
    )
})

test_that("Snapshot formulations field returns proper collection", {
    # Create a snapshot with formulations
    snapshot_data <- list(
        Version = 80,
        Formulations = list(
            list(
                Name = "Test Tablet",
                FormulationType = "Formulation_Tablet_Weibull"
            ),
            list(
                Name = "Test Solution",
                FormulationType = "Formulation_Dissolved"
            )
        )
    )

    snapshot <- Snapshot$new(snapshot_data)

    # Test active binding
    formulations <- snapshot$formulations
    expect_s3_class(formulations, "formulation_collection")
    expect_length(formulations, 2)

    # Test print method
    expect_snapshot(print(formulations))

    # Test that snapshot with no formulations returns empty collection
    empty_snapshot <- Snapshot$new(list(Version = 80))
    expect_s3_class(empty_snapshot$formulations, "formulation_collection")
    expect_length(empty_snapshot$formulations, 0)
})
