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

test_that("Simulation load path still wraps a multi-alternative compound's Alternatives (AC-15)", {
  # The retired create_compound_group_selection()/create_compound_properties()
  # constructors are gone from the public API, but CompoundGroupSelection and
  # CompoundProperties remain as unexported internal machinery that the
  # Simulation load path still relies on to parse a loaded simulation's
  # Alternatives array.
  snap <- jsonlite::fromJSON(
    test_path("data", "test_snapshot.json"),
    simplifyVector = FALSE,
    simplifyDataFrame = FALSE
  )
  raw <- snap$Simulations[[1]]
  sim <- Simulation$new(raw)

  alternatives <- sim$compounds[[1]]$alternatives
  expect_true(length(alternatives) >= 2)
  for (alt in alternatives) {
    expect_s3_class(alt, "CompoundGroupSelection")
  }

  expect_equal(
    sim$data$Compounds[[1]]$Alternatives,
    raw$Compounds[[1]]$Alternatives
  )
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

test_that("add_simulation build mode appends one simulation", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "NewSim",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin"))
    )
  )

  expect_length(snap$simulations, 3)
  expect_equal(snap$simulations[["NewSim"]]$name, "NewSim")
})

test_that("add_simulation build mode works through the functional wrapper", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  out <- suppressMessages(
    add_simulation(
      snap,
      name = "WrapperSim",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin"))
    )
  )

  expect_s3_class(out, "Snapshot")
  expect_equal(out$simulations[["WrapperSim"]]$name, "WrapperSim")
})

test_that("add_simulation derives calculation_methods from the compound", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "CalcSim",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin"))
    )
  )

  built <- snap$simulations[["CalcSim"]]$compounds[[1]]
  expected <- as.list(snap$compounds[["Rifampicin"]]$calculation_methods$names)
  expect_equal(built$calculation_methods, expected)
})

test_that("add_simulation infers the formulation key from the protocol", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  # Simple protocol (no schema items): falls back to the "Formulation" key.
  suppressMessages(
    snap$add_simulation(
      name = "SimpleKey",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(
        name = "Rifampicin",
        protocol = "Shin 2016 - Midazolam - iv 1 mg (Control)",
        formulation = "Oral solution"
      ))
    )
  )
  simple <- snap$simulations[["SimpleKey"]]$compounds[[1]]$protocol
  expect_equal(simple$formulations[[1]]$data$Key, "Formulation")

  # Advanced protocol with a single slot: the slot's formulation_key wins.
  suppressMessages(
    snap$add_simulation(
      name = "AdvancedKey",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(
        name = "Rifampicin",
        protocol = "Backman 1996 - Midazolam - 15 mg (Control)",
        formulation = "Tablet (Dormicum)"
      ))
    )
  )
  advanced <- snap$simulations[["AdvancedKey"]]$compounds[[1]]$protocol
  expect_equal(advanced$formulations[[1]]$data$Key, "Tablet (Dormicum)")
})

test_that("add_simulation binds a multi-slot formulation map", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "MultiSlot",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(
        name = "Rifampicin",
        protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
        formulation = c(
          "form-Lint80" = "form_Lint80",
          "Oral solution" = "Oral solution",
          "form-ZO" = "form-ZO"
        )
      ))
    )
  )

  built <- snap$simulations[["MultiSlot"]]$compounds[[1]]$protocol

  expected <- create_protocol_selection(
    name = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
    formulations = list(
      create_formulation_selection(name = "form_Lint80", key = "form-Lint80"),
      create_formulation_selection(
        name = "Oral solution",
        key = "Oral solution"
      ),
      create_formulation_selection(name = "form-ZO", key = "form-ZO")
    )
  )

  expect_equal(built$data$Formulations, expected$data$Formulations)
})

test_that("add_simulation binds a single named-slot formulation", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "NamedSlot",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(
        name = "Rifampicin",
        protocol = "Yu 2004 - Rifampicin - 600 mg MD OD 10 days",
        formulation = c(Formulation = "Oral solution")
      ))
    )
  )

  built <- snap$simulations[["NamedSlot"]]$compounds[[1]]$protocol
  expect_equal(built$formulations[[1]]$data$Key, "Formulation")
  expect_equal(built$formulations[[1]]$data$Name, "Oral solution")
})

test_that("add_simulation rejects a formulation map with an unnamed element", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "BadFormulationMap",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = c("form-Lint80" = "Lint 80mg tablet", "ZO tablet")
        ))
      )
    )
  )
})

test_that("add_simulation notes a multi-slot protocol when the formulation key is inferred", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  # A plain (unnamed) formulation string against a protocol with several
  # distinct slot keys falls back to inference and points the user at the
  # friendly multi-slot `formulation` map instead.
  expect_snapshot(
    suppressWarnings(
      snap$add_simulation(
        name = "InferredMultiSlot",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          protocol = "Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)",
          formulation = "Oral solution"
        ))
      )
    )
  )
})

test_that("add_simulation defaults alternatives to each group default", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "AltSim",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin"))
    )
  )

  # AC-10 regression guard: omitting `alternatives` must resolve
  # byte-identically to derivation, with no behavioural change from the
  # friendly-selection feature. Do not touch this test's expectations.
  alternatives <- snap$simulations[["AltSim"]]$compounds[[1]]$data$Alternatives
  expect_snapshot_value(alternatives, style = "json2")
})

test_that("add_simulation selects an alternative by friendly name and label", {
  snap <- local_snapshot(list(
    Version = 80,
    Compounds = list(list(
      Name = "Drug X",
      Solubility = list(
        list(
          Name = "Aqueous",
          IsDefault = TRUE,
          Parameters = list(list(
            Name = "Solubility at reference pH",
            Value = 9999,
            Unit = "mg/l"
          ))
        ),
        list(
          Name = "FaSSIF",
          IsDefault = FALSE,
          Parameters = list(list(
            Name = "Solubility at reference pH",
            Value = 200,
            Unit = "mg/l"
          ))
        )
      ),
      Lipophilicity = list(list(
        Name = "User defined",
        IsDefault = TRUE,
        Parameters = list(list(
          Name = "Lipophilicity",
          Value = 2.5,
          Unit = "Log Units"
        ))
      ))
    )),
    Individuals = list(list(Name = "Ind1", OriginData = list()))
  ))

  suppressMessages(
    snap$add_simulation(
      name = "FriendlySim",
      individual = "Ind1",
      compounds = list(list(
        name = "Drug X",
        alternatives = c(solubility = "FaSSIF")
      ))
    )
  )

  alternatives <- snap$simulations[["FriendlySim"]]$compounds[[
    1
  ]]$data$Alternatives
  expect_snapshot_value(alternatives, style = "json2")
})

test_that("add_simulation alternatives selection accepts a named list of strings", {
  snap <- local_snapshot(list(
    Version = 80,
    Compounds = list(list(
      Name = "Drug X",
      Solubility = list(
        list(
          Name = "Aqueous",
          IsDefault = TRUE,
          Parameters = list(list(
            Name = "Solubility at reference pH",
            Value = 9999,
            Unit = "mg/l"
          ))
        ),
        list(
          Name = "FaSSIF",
          IsDefault = FALSE,
          Parameters = list(list(
            Name = "Solubility at reference pH",
            Value = 200,
            Unit = "mg/l"
          ))
        )
      )
    )),
    Individuals = list(list(Name = "Ind1", OriginData = list()))
  ))

  vector_form <- local_snapshot(snap$data)
  list_form <- local_snapshot(snap$data)

  suppressMessages(
    vector_form$add_simulation(
      name = "VectorSim",
      individual = "Ind1",
      compounds = list(list(
        name = "Drug X",
        alternatives = c(solubility = "FaSSIF")
      ))
    )
  )
  suppressMessages(
    list_form$add_simulation(
      name = "ListSim",
      individual = "Ind1",
      compounds = list(list(
        name = "Drug X",
        alternatives = list(solubility = "FaSSIF")
      ))
    )
  )

  expect_equal(
    vector_form$simulations[["VectorSim"]]$compounds[[1]]$data$Alternatives,
    list_form$simulations[["ListSim"]]$compounds[[1]]$data$Alternatives
  )
})

test_that("add_simulation alternatives selection overrides one group and derives the rest", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "PartialOverride",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(
        name = "Rifampicin",
        alternatives = c(solubility = "test")
      ))
    )
  )
  suppressMessages(
    snap$add_simulation(
      name = "PlainDerivation",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin"))
    )
  )

  overridden <- snap$simulations[["PartialOverride"]]$compounds[[
    1
  ]]$data$Alternatives
  derived <- snap$simulations[["PlainDerivation"]]$compounds[[
    1
  ]]$data$Alternatives

  group_name <- function(alt) alt$GroupName
  alt_name <- function(alt) alt$AlternativeName

  # The overridden group carries the selected label.
  sol <- Filter(function(a) group_name(a) == "COMPOUND_SOLUBILITY", overridden)
  expect_equal(alt_name(sol[[1]]), "test")

  # Every other group matches plain derivation exactly.
  other_overridden <- Filter(
    function(a) group_name(a) != "COMPOUND_SOLUBILITY",
    overridden
  )
  other_derived <- Filter(
    function(a) group_name(a) != "COMPOUND_SOLUBILITY",
    derived
  )
  expect_equal(other_overridden, other_derived)
})

test_that("add_simulation errors selecting an unknown alternative label", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "BadLabel",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          alternatives = c(solubility = "Not a real label")
        ))
      )
    )
  )
})

test_that("add_simulation errors selecting an unknown friendly property name", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "BadProperty",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          alternatives = c(not_a_property = "Aqueous")
        ))
      )
    )
  )
})

test_that("add_simulation rejects a raw CompoundGroupSelection-shaped alternatives entry", {
  # The old escape-hatch shape (a raw `list(GroupName =, AlternativeName =)`
  # dict, or a `create_compound_group_selection()` result) is no longer an
  # accepted `alternatives` shape; only the friendly named vector/list is.
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "RawSelection",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          alternatives = list(list(
            GroupName = "COMPOUND_SOLUBILITY",
            AlternativeName = "Aqueous"
          ))
        ))
      )
    )
  )
})

test_that("add_simulation errors on a duplicate friendly property name in alternatives", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "DupProperty",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          alternatives = c(solubility = "Aqueous", solubility = "test")
        ))
      )
    )
  )
})

test_that("add_simulation alternatives selection against a property with no alternatives available errors", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "NoAlternatives",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          alternatives = c(permeability = "Anything")
        ))
      )
    )
  )
})

test_that("add_simulation alternatives selection against the wrong property is still an error", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  # "Optimized" exists on lipophilicity, not solubility.
  expect_snapshot(
    error = TRUE,
    suppressMessages(
      snap$add_simulation(
        name = "WrongProperty",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "Rifampicin",
          alternatives = c(solubility = "Optimized")
        ))
      )
    )
  )
})

test_that("add_simulation with alternatives against an unresolved compound is emitted verbatim", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    suppressMessages(
      snap$add_simulation(
        name = "UnresolvedCompound",
        individual = "Korean (Yu 2004 study)",
        compounds = list(list(
          name = "NoSuchCompound",
          alternatives = c(solubility = "FaSSIF")
        ))
      )
    )
  )

  alternatives <- snap$simulations[[
    "UnresolvedCompound"
  ]]$compounds[[1]]$data$Alternatives
  expect_equal(
    alternatives,
    list(list(GroupName = "COMPOUND_SOLUBILITY", AlternativeName = "FaSSIF"))
  )
})

test_that("add_simulation omits Processes when processes not supplied", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "NoProc",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin"))
    )
  )

  expect_null(snap$simulations[["NoProc"]]$compounds[[1]]$data$Processes)
})

test_that("add_simulation builds process selections from a name vector", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  suppressMessages(
    snap$add_simulation(
      name = "ProcSim",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(
        name = "Rifampicin",
        processes = c("P-gp", "Hepatic")
      ))
    )
  )

  processes <- snap$simulations[["ProcSim"]]$compounds[[1]]$processes
  expect_length(processes, 2)
  expect_equal(processes[[1]]$molecule_name, "P-gp")
  expect_null(processes[[1]]$systemic_process_type)
  expect_equal(processes[[2]]$systemic_process_type, "Hepatic")
  expect_null(processes[[2]]$molecule_name)
})

test_that("add_simulation passes explicit process objects through unchanged", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  proc <- create_compound_process_selection(
    molecule_name = "CYP3A4",
    metabolite_name = "1-OH-Midazolam"
  )
  suppressMessages(
    snap$add_simulation(
      name = "ExplicitProc",
      individual = "Korean (Yu 2004 study)",
      compounds = list(list(name = "Rifampicin", processes = list(proc)))
    )
  )

  built <- snap$simulations[["ExplicitProc"]]$compounds[[1]]$processes[[1]]
  expect_equal(built$data, proc$data)
})

test_that("add_simulation errors when compounds contains a CompoundProperties object", {
  # `create_compound_properties()` / `create_compound_group_selection()`
  # are retired as the compound-configuration path: an inline
  # compound-config list is the only accepted `compounds` entry shape, and
  # a `CompoundProperties` object (the old escape hatch) now errors,
  # pointing at the inline shape (FR-13, AC-14).
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  cp <- create_compound_properties(
    name = "Rifampicin",
    calculation_methods = c("Only this one")
  )
  expect_snapshot(
    error = TRUE,
    snap$add_simulation(
      name = "EscapeSim",
      individual = "Korean (Yu 2004 study)",
      compounds = list(cp)
    )
  )
})

test_that("add_simulation build mode enforces XOR on individual/population", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  expect_snapshot(error = TRUE, snap$add_simulation(name = "S"))
  expect_snapshot(
    error = TRUE,
    snap$add_simulation(name = "S", individual = "A", population = "P")
  )
})

test_that("add_simulation build mode validates required arguments", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  expect_snapshot(error = TRUE, snap$add_simulation())
  expect_snapshot(
    error = TRUE,
    snap$add_simulation(name = "", individual = "A")
  )
  expect_snapshot(
    error = TRUE,
    snap$add_simulation(name = "S", individual = "A", allow_aging = "no")
  )
})

test_that("add_simulation default Solver serialises as a JSON object", {
  # PK-Sim's snapshot mapper rejects `Solver: []` silently. The default
  # Solver (when no `solver` argument is supplied) must round-trip as
  # `{}`, not `[]`, so the simulation is loadable.
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  suppressMessages(
    snap$add_simulation(
      name = "SolverSim",
      individual = "Korean (Yu 2004 study)"
    )
  )
  expect_equal(
    as.character(
      jsonlite::toJSON(
        snap$simulations[["SolverSim"]]$data$Solver,
        auto_unbox = TRUE
      )
    ),
    "{}"
  )
})

test_that("add_simulation accepts every optional argument", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))
  # "Study A" is not in the fixture, so the add warns and proceeds; this
  # test only asserts that every optional argument is carried through.
  suppressWarnings(suppressMessages(
    snap$add_simulation(
      name = "FullSim",
      individual = "Korean (Yu 2004 study)",
      description = "demo",
      allow_aging = FALSE,
      solver = create_solver_settings(abs_tol = 1e-9),
      observed_data_names = c("Study A"),
      output_selections = c("Organism|Liver"),
      output_mappings = list(
        create_output_mapping(path = "p", observed_data = "Study A")
      ),
      parameters = list(create_parameter(path = "Organism|Liver", value = 1))
    )
  ))

  built <- snap$simulations[["FullSim"]]
  expect_equal(built$description, "demo")
  expect_identical(built$allow_aging, FALSE)
  expect_equal(built$solver$abs_tol, 1e-9)
  expect_equal(built$observed_data_names, list("Study A"))
  expect_equal(built$output_selections, list("Organism|Liver"))
  expect_length(built$output_mappings, 1)
  expect_length(built$parameters, 1)
})

test_that("add_simulation attaches a pre-built Simulation object", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  # Round-trip a loaded simulation back through the pre-built path.
  prebuilt <- snap$simulations[[1]]$clone(deep = TRUE)
  prebuilt$name <- "Prebuilt"
  suppressMessages(snap$add_simulation(prebuilt))

  expect_length(snap$simulations, 3)
  expect_equal(snap$simulations[["Prebuilt"]]$name, "Prebuilt")
})

test_that("add_simulation warns about unresolved references", {
  snap <- load_snapshot(test_path("data", "test_snapshot.json"))

  expect_snapshot(
    snap$add_simulation(
      name = "MissingRefs",
      individual = "NoSuchIndividual",
      compounds = list(list(
        name = "NoSuchCompound",
        protocol = "NoSuchProtocol",
        formulation = "NoSuchFormulation"
      )),
      events = list(create_event_selection(
        name = "NoSuchEvent",
        start_time = 1
      )),
      observer_sets = list(create_observer_set_selection(name = "NoSuchSet")),
      observed_data_names = c("NoSuchData")
    )
  )
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
