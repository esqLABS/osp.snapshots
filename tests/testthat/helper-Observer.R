# Test helpers for Observer round-trip checks --------------------------------

#' Mutate one Observer field, export and reload the snapshot, then check
#' that the new value survived the round-trip.
#'
#' Loads `test_snapshot.json` fresh so each call has independent state,
#' mutates the first observer of the first observer set, exports to a
#' temporary file (registered with `withr` against the caller's frame),
#' reloads, and asserts that the field equals `new_value`.
#'
#' @param field Name of the active binding on `Observer` to mutate
#'   (e.g. `"name"`, `"type"`, `"dimension"`, `"formula"`).
#' @param new_value Replacement value to write into the field.
#' @param env Environment used by `withr::local_tempfile()` for cleanup.
expect_observer_field_roundtrip <- function(
  field,
  new_value,
  env = parent.frame()
) {
  snapshot <- Snapshot$new(testthat::test_path("data", "test_snapshot.json"))
  observer <- snapshot$observer_sets[[1]]$observers[[1]]

  observer[[field]] <- new_value

  tmp <- withr::local_tempfile(fileext = ".json", .local_envir = env)
  snapshot$export(tmp)
  reloaded <- Snapshot$new(tmp)

  testthat::expect_equal(
    reloaded$observer_sets[[1]]$observers[[1]][[field]],
    new_value
  )
}
