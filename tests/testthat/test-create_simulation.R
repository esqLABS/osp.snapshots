test_that("create_simulation default Solver serialises as a JSON object", {
  # PK-Sim's snapshot mapper rejects `Solver: []` silently. The default
  # Solver (when no `solver` argument is supplied) must round-trip as
  # `{}`, not `[]`, so the simulation is loadable.
  sim <- create_simulation(name = "S", individual = "X")
  expect_equal(
    as.character(jsonlite::toJSON(sim$data$Solver, auto_unbox = TRUE)),
    "{}"
  )
})

test_that("create_simulation happy path with individual", {
  sim <- create_simulation(
    name = "Sim 1",
    individual = "Adult",
    compounds = list(create_compound_properties(name = "Drug X")),
    events = list(create_event_selection(name = "E", start_time = 1)),
    observer_sets = list(create_observer_set_selection(name = "O"))
  )

  expect_s3_class(sim, "Simulation")
  expect_equal(sim$name, "Sim 1")
  expect_equal(sim$model, "4Comp")
  expect_equal(sim$individual, "Adult")
  expect_length(sim$compounds, 1)
  expect_length(sim$events, 1)
  expect_length(sim$observer_sets, 1)
})

test_that("create_simulation happy path with population", {
  sim <- create_simulation(
    name = "PopSim",
    population = "Adults",
    output_schema = create_output_schema(
      intervals = list(
        create_output_interval(start_time = 0, end_time = 24, resolution = 20)
      )
    )
  )

  expect_equal(sim$population, "Adults")
  expect_null(sim$individual)
  expect_length(sim$output_schema$intervals, 1)
})

test_that("create_simulation accepts every optional argument", {
  sim <- create_simulation(
    name = "S",
    individual = "Adult",
    description = "demo",
    allow_aging = FALSE,
    solver = create_solver_settings(abs_tol = 1e-9),
    observed_data_names = c("Study A"),
    output_selections = c("Organism|Liver"),
    output_mappings = list(
      create_output_mapping(path = "p", observed_data = "Study A")
    ),
    parameters = list(create_parameter(path = "Organism|Liver", value = 1)),
    advanced_parameters = list(
      AdvancedParameter$new(list(Name = "ap", DistributionType = "Normal"))
    )
  )

  expect_equal(sim$description, "demo")
  expect_identical(sim$allow_aging, FALSE)
  expect_equal(sim$solver$abs_tol, 1e-9)
  expect_equal(sim$observed_data_names, list("Study A"))
  expect_equal(sim$output_selections, list("Organism|Liver"))
  expect_length(sim$output_mappings, 1)
  expect_length(sim$parameters, 1)
  expect_length(sim$advanced_parameters, 1)
})

test_that("create_simulation enforces XOR on individual/population", {
  expect_snapshot(error = TRUE, create_simulation(name = "S"))
  expect_snapshot(
    error = TRUE,
    create_simulation(name = "S", individual = "A", population = "P")
  )
})

test_that("create_simulation validates required arguments", {
  expect_snapshot(error = TRUE, create_simulation())
  expect_snapshot(error = TRUE, create_simulation(name = "", individual = "A"))
  expect_snapshot(
    error = TRUE,
    create_simulation(name = "S", individual = "A", allow_aging = "no")
  )
})
