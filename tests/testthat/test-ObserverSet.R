# ---- ObserverSet logic tests ----
test_that("ObserverSet class initialization works", {
  data <- list(
    Name = "BrainPlasmaConcentration",
    Observers = list(list(Name = "obs1"), list(Name = "obs2"))
  )

  os <- ObserverSet$new(data)

  expect_s3_class(os, "R6")
  expect_s3_class(os, "ObserverSet")
  expect_equal(os$name, "BrainPlasmaConcentration")
  expect_length(os$observers, 2)
  expect_equal(os$data, data)
})

test_that("ObserverSet handles missing Observers", {
  os <- ObserverSet$new(list(Name = "Empty"))

  expect_equal(os$name, "Empty")
  expect_length(os$observers, 0)
})

test_that("ObserverSet name setter round-trips through data", {
  os <- ObserverSet$new(list(Name = "Old", Observers = list()))

  os$name <- "New"

  expect_equal(os$name, "New")
  expect_equal(os$data$Name, "New")
})

test_that("ObserverSet observers setter round-trips through data", {
  os <- ObserverSet$new(list(Name = "X", Observers = list()))

  os$observers <- list(list(Name = "obs"))

  expect_length(os$observers, 1)
  expect_equal(os$data$Observers[[1]]$Name, "obs")
})

test_that("ObserverSet data is read-only", {
  os <- ObserverSet$new(list(Name = "X"))
  expect_snapshot(os$data <- list(), error = TRUE)
})

# ---- Snapshot wiring ----
test_that("snapshot$observer_sets loads from JSON", {
  snapshot <- test_snapshot$clone()

  expect_named(snapshot$observer_sets)
  expect_s3_class(snapshot$observer_sets, "observer_set_collection")
  expect_s3_class(snapshot$observer_sets, "snapshot_collection")
  expect_s3_class(
    snapshot$observer_sets[["BrainPlasmaConcentration_Double"]],
    "ObserverSet"
  )
})

test_that("snapshot$observer_sets is empty when none present", {
  snapshot <- empty_snapshot$clone()

  expect_length(snapshot$observer_sets, 0)
  expect_s3_class(snapshot$observer_sets, "observer_set_collection")
})

test_that("snapshot$observer_sets suffixes duplicate names", {
  data <- list(
    Version = 80,
    ObserverSets = list(
      list(Name = "dup", Observers = list()),
      list(Name = "dup", Observers = list())
    )
  )
  snapshot <- Snapshot$new(data)

  expect_named(snapshot$observer_sets, c("dup_1", "dup_2"))
})

test_that("ObserverSets round-trip byte-equivalently through export", {
  snapshot <- test_snapshot$clone()
  tmp <- withr::local_tempfile(fileext = ".json")

  snapshot$export(tmp)
  reloaded <- jsonlite::fromJSON(
    tmp,
    simplifyDataFrame = FALSE,
    simplifyVector = FALSE
  )

  expect_equal(reloaded$ObserverSets, snapshot$data$ObserverSets)
})

# ---- Mutators ----
test_that("add_observer_set() appends an observer set", {
  snapshot <- empty_snapshot$clone()
  os <- ObserverSet$new(list(Name = "new_os", Observers = list()))

  add_observer_set(snapshot, os)

  expect_length(snapshot$observer_sets, 1)
  expect_named(snapshot$observer_sets, "new_os")
})

test_that("remove_observer_set() drops by name", {
  data <- list(
    Version = 80,
    ObserverSets = list(
      list(Name = "keep", Observers = list()),
      list(Name = "drop", Observers = list())
    )
  )
  snapshot <- Snapshot$new(data)

  remove_observer_set(snapshot, "drop")

  expect_named(snapshot$observer_sets, "keep")
})

test_that("remove_observer_set() drops ObserverSets section when empty", {
  data <- list(
    Version = 80,
    ObserverSets = list(list(Name = "only", Observers = list()))
  )
  snapshot <- Snapshot$new(data)

  remove_observer_set(snapshot, "only")

  expect_length(snapshot$observer_sets, 0)
})

test_that("add_observer_set() rejects non-ObserverSet inputs", {
  snapshot <- empty_snapshot$clone()
  expect_snapshot(add_observer_set(snapshot, list()), error = TRUE)
})

test_that("add_observer_set() rejects non-Snapshot inputs", {
  os <- ObserverSet$new(list(Name = "x", Observers = list()))
  expect_snapshot(add_observer_set(list(), os), error = TRUE)
})

test_that("remove_observer_set() warns on missing name", {
  data <- list(
    Version = 80,
    ObserverSets = list(list(Name = "only", Observers = list()))
  )
  snapshot <- Snapshot$new(data)

  expect_snapshot(remove_observer_set(snapshot, "missing"))
})

test_that("remove_observer_set() warns on empty collection", {
  snapshot <- empty_snapshot$clone()
  expect_snapshot(remove_observer_set(snapshot, "missing"))
})

test_that("remove_observer_set() deduplicates warnings and reports actual count", {
  data <- list(
    Version = 80,
    ObserverSets = list(
      list(Name = "keep", Observers = list()),
      list(Name = "drop", Observers = list())
    )
  )
  snapshot <- Snapshot$new(data)

  expect_snapshot(
    remove_observer_set(snapshot, c("drop", "drop", "missing", "missing"))
  )
  expect_named(snapshot$observer_sets, "keep")
})

# ---- Tibble exporter ----
test_that("get_observer_sets_dfs() returns one row per set", {
  snapshot <- test_snapshot$clone()

  df <- get_observer_sets_dfs(snapshot)

  expect_s3_class(df, "tbl_df")
  expect_named(df, c("observer_set_id", "name", "n_observers"))
  expect_equal(nrow(df), length(snapshot$observer_sets))
})

test_that("get_observer_sets_dfs() returns empty tibble for empty snapshot", {
  snapshot <- empty_snapshot$clone()

  df <- get_observer_sets_dfs(snapshot)

  expect_s3_class(df, "tbl_df")
  expect_named(df, c("observer_set_id", "name", "n_observers"))
  expect_equal(nrow(df), 0)
})

# ---- Print methods ----
test_that("print.ObserverSet prints a summary", {
  os <- ObserverSet$new(list(
    Name = "BrainPlasmaConcentration",
    Observers = list(list(Name = "obs1"), list(Name = "obs2"))
  ))
  expect_snapshot(print(os))
})

test_that("print.observer_set_collection prints a summary", {
  sets <- list(
    ObserverSet$new(list(Name = "A", Observers = list(list(Name = "o")))),
    ObserverSet$new(list(Name = "B", Observers = list()))
  )
  names(sets) <- c("A", "B")
  class(sets) <- c("observer_set_collection", "snapshot_collection", "list")

  expect_snapshot(print(sets))

  empty <- list()
  class(empty) <- c(
    "observer_set_collection",
    "snapshot_collection",
    "list"
  )
  expect_snapshot(print(empty))
})
