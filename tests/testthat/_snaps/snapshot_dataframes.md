# as_tibbles() errors for non-Snapshot input

    Code
      as_tibbles(list(), "compounds")
    Condition
      Error in `validate_snapshot()`:
      ! Expected a Snapshot object, but got <list>

# as_tibbles() errors for unknown kind

    Code
      as_tibbles(test_snapshot, "nope")
    Condition
      Error in `as_tibbles()`:
      ! Unknown `kind` "nope".
      i Must be one of "compounds", "individuals", "formulations", "populations", "events", "expression_profiles", "protocols", "observer_sets", and "observed_data".

# as_tibbles() errors for malformed kind

    Code
      as_tibbles(test_snapshot, c("a", "b"))
    Condition
      Error in `as_tibbles()`:
      ! Unknown `kind` "a" and "b".
      i Must be one of "compounds", "individuals", "formulations", "populations", "events", "expression_profiles", "protocols", "observer_sets", and "observed_data".

---

    Code
      as_tibbles(test_snapshot, NA_character_)
    Condition
      Error in `as_tibbles()`:
      ! Unknown `kind` NA.
      i Must be one of "compounds", "individuals", "formulations", "populations", "events", "expression_profiles", "protocols", "observer_sets", and "observed_data".

---

    Code
      as_tibbles(test_snapshot, c("compounds", "nope"))
    Condition
      Error in `as_tibbles()`:
      ! Unknown `kind` "nope".
      i Must be one of "compounds", "individuals", "formulations", "populations", "events", "expression_profiles", "protocols", "observer_sets", and "observed_data".

---

    Code
      as_tibbles(test_snapshot, 1)
    Condition
      Error in `as_tibbles()`:
      ! `kind` must be `NULL` or a character vector, not a number.

---

    Code
      as_tibbles(test_snapshot, character(0))
    Condition
      Error in `as_tibbles()`:
      ! `kind` must name at least one collection.

