test_that("Simulation wraps fixture data", {
  snap <- jsonlite::fromJSON(
    test_path("data", "test_snapshot.json"),
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  raw <- snap$Simulations[[1]]
  sim <- Simulation$new(raw)

  expect_s3_class(sim, "Simulation")
  expect_equal(sim$name, "simulation1")
  expect_equal(sim$model, "4Comp")
  expect_equal(sim$individual, "Korean (Yu 2004 study)")
  expect_null(sim$population)
  expect_s3_class(sim$solver, "SolverSettings")
  expect_s3_class(sim$output_schema, "OutputSchema")
  expect_length(sim$output_schema$intervals, 2)
  expect_length(sim$compounds, 1)
  expect_s3_class(sim$compounds[[1]], "CompoundProperties")
  expect_length(sim$events, 1)
  expect_length(sim$observer_sets, 1)
  expect_length(sim$parameters, 13)
  expect_s3_class(sim$parameters[[1]], "LocalizedParameter")
})

test_that("Simulation preserves passthrough fields byte-equivalent", {
  snap <- jsonlite::fromJSON(
    test_path("data", "test_snapshot.json"),
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  raw <- snap$Simulations[[1]]
  sim <- Simulation$new(raw)

  expect_identical(sim$data$Interactions, raw$Interactions)
  expect_identical(sim$data$IndividualAnalyses, raw$IndividualAnalyses)
  expect_identical(sim$data$HasResults, raw$HasResults)
})

test_that("Simulation preserves all four documented passthrough fields", {
  altered <- list(list(Name = "Compound A", Type = "Compound"))
  pop_analyses <- list(list(Name = "Pop chart 1", Type = "PopulationAnalysis"))
  raw <- list(
    Name = "S",
    Model = "4Comp",
    Population = "Adults",
    Interactions = list(list(Name = "Int1", MoleculeName = "M1")),
    AlteredBuildingBlocks = altered,
    IndividualAnalyses = list(list(Name = "Chart 1")),
    PopulationAnalyses = pop_analyses
  )
  sim <- Simulation$new(raw)

  # Mutate an unrelated field to force the $data rebuild path.
  sim$description <- "demo"

  expect_identical(sim$data$Interactions, raw$Interactions)
  expect_identical(sim$data$AlteredBuildingBlocks, altered)
  expect_identical(sim$data$IndividualAnalyses, raw$IndividualAnalyses)
  expect_identical(sim$data$PopulationAnalyses, pop_analyses)
})

test_that("Simulation reflects compound mutations in $data", {
  raw <- list(
    Name = "S",
    Model = "4Comp",
    Individual = "Adult",
    Compounds = list(list(Name = "Drug X"))
  )
  sim <- Simulation$new(raw)
  sim$compounds[[1]]$name <- "Drug Y"
  expect_equal(sim$data$Compounds[[1]]$Name, "Drug Y")
})

test_that("Simulation aborts when both Individual and Population are set", {
  expect_snapshot(
    error = TRUE,
    Simulation$new(list(
      Name = "S",
      Model = "4Comp",
      Individual = "A",
      Population = "P"
    ))
  )
})

test_that("Simulation aborts when neither Individual nor Population is set", {
  expect_snapshot(
    error = TRUE,
    Simulation$new(list(Name = "S", Model = "4Comp"))
  )
})

test_that("Snapshot lazily wraps Simulations as Simulation R6 objects", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  sims <- snap$simulations
  expect_length(sims, 2)
  expect_s3_class(sims[[1]], "Simulation")
  expect_named(sims, c("simulation1", "simulation2"))
})

test_that("add_simulation appends a single Simulation", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  sim <- create_simulation(
    name = "NewSim",
    individual = "Korean (Yu 2004 study)",
    compounds = list(create_compound_properties(name = "Rifampicin"))
  )

  suppressMessages(snap$add_simulation(sim))

  expect_length(snap$simulations, 3)
  expect_equal(snap$simulations[["NewSim"]]$name, "NewSim")
})

test_that("add_simulation vectorized appends multiple Simulations", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  sims <- list(
    create_simulation(
      name = "S1",
      individual = "Korean (Yu 2004 study)",
      compounds = list(create_compound_properties(name = "Rifampicin"))
    ),
    create_simulation(
      name = "S2",
      individual = "Korean (Yu 2004 study)",
      compounds = list(create_compound_properties(name = "Rifampicin"))
    )
  )
  suppressMessages(snap$add_simulation(sims))
  expect_length(snap$simulations, 4)
  expect_in(c("S1", "S2"), names(snap$simulations))
})

test_that("add_simulation warns about unresolved references", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  sim <- create_simulation(
    name = "MissingRefs",
    individual = "NoSuchIndividual",
    compounds = list(
      create_compound_properties(
        name = "NoSuchCompound",
        protocol = create_protocol_selection(
          name = "NoSuchProtocol",
          formulations = list(
            create_formulation_selection(
              name = "NoSuchFormulation",
              key = "K"
            )
          )
        )
      )
    ),
    events = list(create_event_selection(name = "NoSuchEvent", start_time = 1)),
    observer_sets = list(create_observer_set_selection(name = "NoSuchSet")),
    observed_data_names = c("NoSuchData")
  )

  expect_snapshot(snap$add_simulation(sim))
})

test_that("remove_simulation drops simulations by name", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  suppressMessages(snap$remove_simulation("simulation1"))
  expect_length(snap$simulations, 1)
  expect_equal(snap$simulations[[1]]$name, "simulation2")
})

test_that("remove_simulation warns on unknown name", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  expect_snapshot(snap$remove_simulation("NoSuchSim"))
})

test_that("Snapshot round-trip preserves Simulations after migration", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  temp_file <- withr::local_tempfile(fileext = ".json")
  suppressMessages(snap$export(temp_file))
  snap2 <- load_snapshot(temp_file)

  expect_length(snap2$data$Simulations, length(snap$data$Simulations))
  # Use expect_equal (not expect_identical) because jsonlite re-parses some
  # whole-number doubles as integers on the second load.
  expect_equal(
    snap$data$Simulations,
    snap2$data$Simulations
  )
})

test_that("Simulation$data round-trips fixture after Applications-to-Events migration", {
  snap <- jsonlite::fromJSON(
    test_path("data", "test_snapshot.json"),
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  raw <- snap$Simulations[[1]]
  sim <- Simulation$new(raw)
  out <- sim$data

  # Migrated parameter paths: Applications|... rewritten to Events|...
  migrated_paths <- vapply(
    raw$Parameters,
    function(p) {
      segs <- strsplit(p$Path, "|", fixed = TRUE)[[1]]
      segs[segs == "Applications"] <- "Events"
      paste(segs, collapse = "|")
    },
    character(1)
  )
  actual_paths <- vapply(out$Parameters, function(p) p$Path, character(1))
  expect_equal(actual_paths, migrated_paths)

  # Every other modelled section is byte-equivalent.
  for (key in setdiff(names(raw), "Parameters")) {
    expect_identical(out[[key]], raw[[key]])
  }
})
