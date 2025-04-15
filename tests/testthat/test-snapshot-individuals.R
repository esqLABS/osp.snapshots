test_that("Snapshot individuals are initialized correctly", {
    # Create a snapshot object
    snapshot <- Snapshot$new(test_snapshot_path)

    # Skip if there are no individuals in the test snapshot
    if (is.null(snapshot$data$Individuals)) {
        skip("Test snapshot does not contain individuals")
    }

    # Test individuals are initialized
    expect_s3_class(snapshot$individuals, "individual_collection")
    expect_s3_class(snapshot$individuals, "list")

    # Test individuals count matches raw data
    expect_equal(
        length(snapshot$individuals),
        length(snapshot$data$Individuals)
    )

    # Test individual objects are properly created
    if (length(snapshot$individuals) > 0) {
        # Get the first individual
        first_individual_name <- names(snapshot$individuals)[1]
        first_individual <- snapshot$individuals[[first_individual_name]]

        # Test it's an Individual object
        expect_s3_class(first_individual, "Individual")

        # Test name matches (allowing for disambiguation)
        expect_true(
            startsWith(first_individual_name, first_individual$name) ||
                first_individual_name == first_individual$name
        )
    }
})

test_that("Individual collection print method works", {
    # Create a snapshot object
    snapshot <- Snapshot$new(test_snapshot_path)

    # Skip if there are no individuals in the test snapshot
    if (is.null(snapshot$data$Individuals)) {
        skip("Test snapshot does not contain individuals")
    }

    # Create a test with some individuals for a more predictable test
    test_individuals <- list(
        Individual$new(list(Name = "Individual 1")),
        Individual$new(list(Name = "Individual 2")),
        Individual$new(list(Name = "Individual 3"))
    )

    # Create a named list
    individuals_named <- list(
        "Individual 1" = test_individuals[[1]],
        "Individual 2" = test_individuals[[2]],
        "Individual 3" = test_individuals[[3]]
    )

    # Set the class for printing
    class(individuals_named) <- c("individual_collection", "list")

    # Test the print method
    expect_snapshot(print(individuals_named))
})

test_that("Individuals can be modified from the snapshot object and snapshot data is updated", {
    # Create a snapshot object
    snapshot <- test_snapshot$clone()

    # Get the first individual
    individual <- snapshot$individuals[[1]]

    # Changes properties
    individual$name <- paste0(individual$name, "_modified")
    individual$age <- individual$age + 10
    individual$species <- ospsuite::Species[1]
    # Modify weight and height
    individual$weight <- individual$weight + 5
    individual$height <- individual$height + 10

    # Switch gender to a different valid option
    current_gender <- individual$gender
    available_genders <- ospsuite::Gender
    new_gender <- available_genders[available_genders != current_gender][1]
    individual$gender <- new_gender

    # Change to a different population
    current_population <- individual$population
    available_populations <- ospsuite::HumanPopulation
    new_population <- available_populations[
        available_populations != current_population
    ][1]
    individual$population <- new_population

    # Get the first parameter and modify its value
    param_name <- names(individual$parameters)[1]
    original_value <- individual$parameters[[param_name]]$value
    individual$parameters[[param_name]]$value <- original_value * 1.2 # Increase by 20%

    expect_snapshot(snapshot$data$Individuals[[1]])
    expect_snapshot(snapshot$individuals[[1]])
})

test_that("add_individual method works", {
    # Create a snapshot object
    snapshot <- test_snapshot$clone()

    # Create a new individual
    new_individual <- create_individual(
        name = "New Test Individual",
        species = "Human",
        gender = "MALE",
        age = 25,
        weight = 75,
        height = 180
    )

    # Add the individual to the snapshot
    snapshot$add_individual(new_individual)

    # Check that the individual was added
    expect_true("New Test Individual" %in% names(snapshot$individuals))
    expect_equal(snapshot$individuals[["New Test Individual"]], new_individual)

    # Check that the individual is included in the data
    expect_true(
        any(sapply(
            snapshot$data$Individuals,
            function(ind) ind$Name == "New Test Individual"
        ))
    )

    # Test with invalid input
    expect_error(
        snapshot$add_individual("not an individual"),
        "Expected an Individual object"
    )
})

test_that("add_individual function works", {
    # Create a snapshot object
    snapshot <- test_snapshot$clone()

    # Create a new individual
    new_individual <- create_individual(
        name = "Function Test Individual",
        species = "Human",
        gender = "MALE",
        age = 40,
        weight = 85,
        height = 190
    )

    # Add the individual using the function
    result <- add_individual(snapshot, new_individual)

    # Check that the individual was added
    expect_true("Function Test Individual" %in% names(snapshot$individuals))
    expect_equal(
        snapshot$individuals[["Function Test Individual"]],
        new_individual
    )

    # Check that the function returns the updated snapshot
    expect_equal(result, snapshot)

    # Test with invalid input
    expect_error(
        add_individual("not a snapshot", new_individual),
        "Expected a Snapshot object"
    )
})

test_that("remove_individual function works", {
    # Create a snapshot with individuals
    snapshot_data <- list(
        Version = 80,
        Individuals = list(
            list(Name = "Individual 1", Species = "Human"),
            list(Name = "Individual 2", Species = "Human"),
            list(Name = "Individual 3", Species = "Human")
        )
    )

    snapshot <- Snapshot$new(snapshot_data)
    expect_length(snapshot$individuals, 3)

    # Remove a single individual via class method
    snapshot$remove_individual("Individual 1")
    expect_length(snapshot$individuals, 2)
    expect_equal(names(snapshot$individuals), c("Individual 2", "Individual 3"))

    # Remove multiple individuals via helper function
    snapshot <- remove_individual(
        snapshot,
        c("Individual 2", "Individual 3")
    )
    expect_length(snapshot$individuals, 0)

    # Test warning for non-existent individual
    expect_warning(snapshot$remove_individual("NonExistent"))
})

test_that("Snapshot handles duplicated individual names correctly", {
    # Create a snapshot with duplicate individual names
    snapshot_data <- list(
        Version = 80,
        Compounds = NULL,
        Individuals = list(
            list(Name = "IndividualA", Species = "Human"),
            list(Name = "IndividualA", Species = "Rat"),
            list(Name = "IndividualB", Species = "Human")
        )
    )

    snapshot <- Snapshot$new(snapshot_data)

    # Check that individuals were created
    expect_s3_class(snapshot$individuals, "individual_collection")
    expect_length(snapshot$individuals, 3)

    # Check for disambiguated names
    expect_true("IndividualA_1" %in% names(snapshot$individuals))
    expect_true("IndividualA_2" %in% names(snapshot$individuals))
    expect_true("IndividualB" %in% names(snapshot$individuals))

    # Check the original data is preserved
    expect_equal(snapshot$individuals$IndividualA_1$name, "IndividualA")
    expect_equal(snapshot$individuals$IndividualA_1$data$Species, "Human")
    expect_equal(snapshot$individuals$IndividualA_2$name, "IndividualA")
    expect_equal(snapshot$individuals$IndividualA_2$data$Species, "Rat")
})
