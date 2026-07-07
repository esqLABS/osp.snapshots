# create_snapshot rejects non-scalar or non-character arguments

    Code
      create_snapshot(name = 1)
    Condition
      Error in `create_snapshot()`:
      ! `name` must be a single string

---

    Code
      create_snapshot(name = c("a", "b"))
    Condition
      Error in `create_snapshot()`:
      ! `name` must be a single string

---

    Code
      create_snapshot(description = 1)
    Condition
      Error in `create_snapshot()`:
      ! `description` must be a single string

---

    Code
      create_snapshot(description = c("a", "b"))
    Condition
      Error in `create_snapshot()`:
      ! `description` must be a single string

