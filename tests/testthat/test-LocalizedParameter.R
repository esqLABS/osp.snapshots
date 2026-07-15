test_that("LocalizedParameter inherits from Parameter and exposes path", {
  param <- LocalizedParameter$new(list(
    Path = "Organism|Liver|Volume",
    Value = 1.5,
    Unit = "L"
  ))

  expect_s3_class(param, "LocalizedParameter")
  expect_s3_class(param, "Parameter")
  expect_equal(param$path, "Organism|Liver|Volume")
  expect_equal(param$value, 1.5)
  expect_equal(param$unit, "L")
})

test_that("LocalizedParameter$data is read-only", {
  raw <- list(Path = "Organism|Liver|Volume", Value = 1.5, Unit = "L")
  param <- LocalizedParameter$new(raw)
  expect_snapshot(error = TRUE, param$data <- list())
  expect_equal(param$data, raw)
})

test_that("LocalizedParameter accepts Name as a legacy path fallback", {
  expect_snapshot(
    param <- LocalizedParameter$new(list(
      Name = "Dose",
      Value = 100
    ))
  )

  expect_equal(param$path, "Dose")
  expect_null(param$data$Name)
})

test_that("LocalizedParameter errors when no path is supplied", {
  expect_snapshot(
    LocalizedParameter$new(list(Value = 1.5)),
    error = TRUE
  )
})

test_that("LocalizedParameter errors when path is empty", {
  expect_snapshot(
    LocalizedParameter$new(list(Path = "", Value = 1.5)),
    error = TRUE
  )
})

test_that("LocalizedParameter errors when path is NA", {
  expect_snapshot(
    LocalizedParameter$new(list(Path = NA_character_, Value = 1.5)),
    error = TRUE
  )
})

test_that("LocalizedParameter errors when path is zero-length", {
  expect_snapshot(
    LocalizedParameter$new(list(Path = character(0), Value = 1.5)),
    error = TRUE
  )
})

test_that("LocalizedParameter errors when path is a multi-element vector", {
  expect_snapshot(
    LocalizedParameter$new(list(
      Path = c("Organism|A", "Organism|B"),
      Value = 1.5
    )),
    error = TRUE
  )
})

test_that("LocalizedParameter migrates Applications path segments to Events", {
  param <- LocalizedParameter$new(list(
    Path = "Applications|Schedule|Application_1|Volume",
    Value = 3.5,
    Unit = "ml/kg"
  ))

  expect_equal(
    param$path,
    "Events|Schedule|Application_1|Volume"
  )
})

test_that("LocalizedParameter does not migrate Applications inside other segments", {
  # Only whole segments named "Applications" should be migrated; substrings
  # such as "MyApplicationsX" must be left untouched.
  param <- LocalizedParameter$new(list(
    Path = "MyApplicationsX|Sub|Item",
    Value = 1.0
  ))

  expect_equal(param$path, "MyApplicationsX|Sub|Item")
})

test_that("LocalizedParameter migrates Applications in any segment position", {
  middle <- LocalizedParameter$new(list(
    Path = "Organism|Applications|Foo",
    Value = 1
  ))
  expect_equal(middle$path, "Organism|Events|Foo")

  trailing <- LocalizedParameter$new(list(
    Path = "Organism|Foo|Applications",
    Value = 1
  ))
  expect_equal(trailing$path, "Organism|Foo|Events")
})

test_that("LocalizedParameter migrates multiple Applications segments", {
  param <- LocalizedParameter$new(list(
    Path = "Applications|Sub|Applications|Leaf",
    Value = 1
  ))
  expect_equal(param$path, "Events|Sub|Events|Leaf")
})

test_that("LocalizedParameter instances still satisfy inherits(x, 'Parameter')", {
  # Pins the backward-compatibility contract: any code that already dispatches
  # on `Parameter` must keep working when handed a LocalizedParameter.
  param <- LocalizedParameter$new(list(
    Path = "Organism|Liver|Volume",
    Value = 1
  ))
  expect_s3_class(param, "Parameter")
})

test_that("create_parameter routes to LocalizedParameter when path is given", {
  localized <- create_parameter(
    path = "Organism|Liver|Volume",
    value = 1.5,
    unit = "L"
  )

  expect_s3_class(localized, "LocalizedParameter")
  expect_equal(localized$path, "Organism|Liver|Volume")
})

test_that("create_parameter returns plain Parameter when no path is given", {
  plain <- create_parameter(
    name = "Dose",
    value = 100
  )

  expect_s3_class(plain, "Parameter")
  expect_false(inherits(plain, "LocalizedParameter"))
})

test_that("create_parameter writes Name (not Path) for plain Parameter", {
  plain <- create_parameter(
    name = "Dose",
    value = 100
  )

  expect_equal(plain$data$Name, "Dose")
  expect_null(plain$data$Path)
})

test_that("create_parameter writes Path (not Name) for LocalizedParameter", {
  localized <- create_parameter(
    path = "Organism|Liver|Volume",
    value = 1.5
  )

  expect_equal(localized$data$Path, "Organism|Liver|Volume")
  expect_null(localized$data$Name)
})

test_that("create_parameter migrates Applications when path is given", {
  param <- create_parameter(
    path = "Applications|Schedule|Application_1|Volume",
    value = 3.5,
    unit = "ml/kg"
  )

  expect_s3_class(param, "LocalizedParameter")
  expect_equal(
    param$path,
    "Events|Schedule|Application_1|Volume"
  )
})

test_that("Individual parameters load as LocalizedParameter", {
  ind <- Individual$new(complete_individual_data)
  first_param <- ind$parameters[[1]]

  expect_s3_class(first_param, "LocalizedParameter")
  expect_s3_class(first_param, "Parameter")
})

# Renal-clearance container rename on localized-parameter paths ---------------
#
# The rename is a snapshot-level load step (not a `LocalizedParameter`
# behaviour), so these load a hand-rolled snapshot through `Snapshot$new()` and
# assert the normalized path.

test_that("Snapshot renames renal-clearance containers on localized paths", {
  data <- list(
    Version = 79,
    Compounds = list(list(Name = "Drug")),
    Simulations = list(list(
      Name = "Sim",
      Parameters = list(
        list(
          Path = "Sim|Organism|Kidney|Drug|GlomerularFiltration|Plasma clearance",
          Value = 1
        ),
        list(
          Path = "Sim|Organism|Kidney|Drug|RenalClearance|Fraction",
          Value = 2
        )
      )
    ))
  )
  snapshot <- Snapshot$new(data)

  paths <- vapply(
    snapshot$data$Simulations[[1]]$Parameters,
    \(p) p$Path,
    character(1)
  )
  expect_equal(
    paths,
    c(
      "Sim|Organism|Kidney|Drug|GlomerularFiltration-Drug|Plasma clearance",
      "Sim|Organism|Kidney|Drug|RenalClearance-Drug|Fraction"
    )
  )
})

test_that("Snapshot renames renal containers on individual parameter paths", {
  data <- list(
    Version = 79,
    Compounds = list(list(Name = "Drug")),
    Individuals = list(list(
      Name = "Ind",
      Parameters = list(
        list(
          Path = "Organism|Kidney|Drug|GlomerularFiltration|Plasma clearance",
          Value = 1
        )
      )
    ))
  )
  snapshot <- Snapshot$new(data)

  path <- snapshot$data$Individuals[[1]]$Parameters[[1]]$Path
  expect_equal(
    path,
    "Organism|Kidney|Drug|GlomerularFiltration-Drug|Plasma clearance"
  )
})

test_that("Snapshot renames renal containers on population base-individual paths", {
  data <- list(
    Version = 79,
    Compounds = list(list(Name = "Drug")),
    Populations = list(list(
      Name = "Pop",
      Settings = list(
        Individual = list(
          Name = "Base",
          Parameters = list(
            list(
              Path = "Organism|Kidney|Drug|RenalClearance|Fraction",
              Value = 1
            )
          )
        )
      )
    ))
  )
  snapshot <- Snapshot$new(data)

  path <- snapshot$data$Populations[[1]]$Settings$Individual$Parameters[[
    1
  ]]$Path
  expect_equal(path, "Organism|Kidney|Drug|RenalClearance-Drug|Fraction")
})

test_that("Renal rename matches whole segments, not substrings", {
  # `GFR (specific)` (a parameter) and `MyGlomerularFiltrationX` (a substring
  # containing the container word) must be left unchanged.
  data <- list(
    Version = 79,
    Compounds = list(list(Name = "Drug")),
    Simulations = list(list(
      Name = "Sim",
      Parameters = list(
        list(Path = "Sim|Organism|Kidney|GFR (specific)", Value = 1),
        list(Path = "Sim|MyGlomerularFiltrationX|Sub|Item", Value = 2)
      )
    ))
  )
  snapshot <- Snapshot$new(data)

  paths <- vapply(
    snapshot$data$Simulations[[1]]$Parameters,
    \(p) p$Path,
    character(1)
  )
  expect_equal(
    paths,
    c(
      "Sim|Organism|Kidney|GFR (specific)",
      "Sim|MyGlomerularFiltrationX|Sub|Item"
    )
  )
})

test_that("Renal rename leaves the segment unchanged when the compound is ambiguous", {
  # Two compounds and no adjacent-segment compound match: the owning compound
  # cannot be determined, so the segment is left intact and one informational
  # message is emitted rather than producing an unresolvable path.
  data <- list(
    Version = 79,
    Compounds = list(list(Name = "DrugA"), list(Name = "DrugB")),
    Simulations = list(list(
      Name = "Sim",
      Parameters = list(
        list(
          Path = "Sim|Organism|Kidney|GlomerularFiltration|Plasma clearance",
          Value = 1
        )
      )
    ))
  )

  expect_snapshot(snapshot <- Snapshot$new(data))
  expect_equal(
    snapshot$data$Simulations[[1]]$Parameters[[1]]$Path,
    "Sim|Organism|Kidney|GlomerularFiltration|Plasma clearance"
  )
})

test_that("Snapshot round-trip preserves localized parameters in Individuals", {
  snapshot <- test_snapshot$clone()
  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)
  snapshot2 <- Snapshot$new(temp_file)

  individuals <- snapshot$data$Individuals
  individuals2 <- snapshot2$data$Individuals
  expect_equal(length(individuals), length(individuals2))

  for (i in seq_along(individuals)) {
    params <- individuals[[i]]$Parameters
    params2 <- individuals2[[i]]$Parameters
    expect_equal(length(params), length(params2))
    for (j in seq_along(params)) {
      expect_equal(params2[[j]]$Path, params[[j]]$Path)
      expect_equal(params2[[j]]$Value, params[[j]]$Value)
    }
  }
})

test_that("Snapshot round-trip preserves raw Simulation parameter data", {
  # Note: Simulations are currently passed through as raw list data; Snapshot
  # does not yet wrap them with a Simulation class, so this test exercises
  # JSON round-trip only, not LocalizedParameter behaviour. Once Simulations
  # are wrapped and their Parameters become LocalizedParameter instances,
  # extend this test to assert on class identity as well.
  snapshot <- test_snapshot$clone()
  temp_file <- withr::local_tempfile(fileext = ".json")
  snapshot$export(temp_file)
  snapshot2 <- Snapshot$new(temp_file)

  sims <- snapshot$data$Simulations
  sims2 <- snapshot2$data$Simulations

  skip_if(length(sims) == 0, "no simulations in fixture")
  for (i in seq_along(sims)) {
    params <- sims[[i]]$Parameters %||% list()
    params2 <- sims2[[i]]$Parameters %||% list()
    expect_equal(length(params), length(params2))
    for (j in seq_along(params)) {
      expect_equal(params2[[j]]$Path, params[[j]]$Path)
      expect_equal(params2[[j]]$Value, params[[j]]$Value)
    }
  }
})
