test_that("create_observer builds a minimal amount observer", {
  observer <- create_observer(name = "x", type = "Amount")

  expect_s3_class(observer, "Observer")
  expect_equal(observer$name, "x")
  expect_equal(observer$type, "Amount")
  expect_named(observer$data, c("Name", "Type"))
})

test_that("create_observer aborts on a missing or empty name", {
  expect_snapshot(create_observer(type = "Amount"), error = TRUE)
  expect_snapshot(create_observer(name = "", type = "Amount"), error = TRUE)
})

test_that("create_observer aborts on an invalid type", {
  expect_snapshot(create_observer(name = "x", type = "Bogus"), error = TRUE)
})

test_that("create_observer sets Dimension and a bare formula expression", {
  observer <- create_observer(
    name = "x",
    type = "Container",
    dimension = "Concentration (molar)",
    formula = "Conc_Br"
  )

  expect_equal(observer$data$Formula$Formula, "Conc_Br")
  expect_equal(observer$data$Dimension, "Concentration (molar)")
})

test_that("create_observer uses a full list formula as the whole Formula", {
  formula <- list(
    Name = "f",
    Formula = "2*Conc",
    References = list(list(Alias = "Conc", Path = "p"))
  )

  observer <- create_observer(name = "x", type = "Amount", formula = formula)

  expect_equal(observer$data$Formula, formula)
})

test_that("create_observer writes formula references, even without a formula", {
  observer <- create_observer(
    name = "x",
    type = "Container",
    formula_references = list(
      create_formula_reference("Conc_Br", "Organism|Brain|Plasma")
    )
  )

  expect_equal(
    observer$data$Formula$References,
    list(list(Alias = "Conc_Br", Path = "Organism|Brain|Plasma"))
  )
  expect_named(observer$data$Formula, "References")
})

test_that("create_observer formula_references override a formula's References", {
  observer <- create_observer(
    name = "x",
    type = "Amount",
    formula = list(
      Name = "f",
      Formula = "2*Conc",
      References = list(list(Alias = "old", Path = "old_path"))
    ),
    formula_references = list(create_formula_reference("new", "new_path"))
  )

  expect_equal(
    observer$data$Formula$References,
    list(list(Alias = "new", Path = "new_path"))
  )
  expect_equal(observer$data$Formula$Name, "f")
  expect_equal(observer$data$Formula$Formula, "2*Conc")
})

test_that("create_observer writes container criteria", {
  observer <- create_observer(
    name = "x",
    type = "Container",
    container_criteria = list(
      create_descriptor_condition("Brain", "InContainer")
    )
  )

  expect_equal(
    observer$data$ContainerCriteria[[1]],
    list(Tag = "Brain", Type = "InContainer")
  )
})

test_that("create_observer writes a molecule list", {
  observer <- create_observer(
    name = "x",
    type = "Container",
    molecule_list = create_molecule_list(for_all = FALSE, include = "Drug")
  )

  expect_equal(observer$data$MoleculeList$ForAll, FALSE)
  expect_equal(observer$data$MoleculeList$MoleculeNamesToInclude, list("Drug"))
})

test_that("create_observer composes with create_observer_set", {
  observer <- create_observer(name = "o", type = "Amount")
  set <- create_observer_set(name = "S", observers = list(observer))

  expect_equal(set$data$Observers[[1]], observer$data)
})

test_that("an observer built via create_observer round-trips through export", {
  observer <- create_observer(
    name = "brain_plasma_conc",
    type = "Container",
    dimension = "Concentration (molar)",
    formula = "Conc_Br",
    formula_references = list(
      create_formula_reference(
        "Conc_Br",
        "Organism|Brain|Plasma|Drug|Concentration",
        "Concentration (molar)"
      )
    ),
    container_criteria = list(
      create_descriptor_condition("Brain", "InContainer")
    ),
    molecule_list = create_molecule_list(for_all = FALSE, include = "Drug")
  )
  set <- create_observer_set(
    name = "BrainPlasmaConcentration",
    observers = list(observer)
  )
  snapshot <- create_snapshot() |> add_observer_set(set)

  tmp <- withr::local_tempfile(fileext = ".json")
  snapshot$export(tmp)
  reloaded <- Snapshot$new(tmp)

  expect_equal(
    reloaded$observer_sets[[1]]$observers[[1]]$data,
    observer$data
  )
})
