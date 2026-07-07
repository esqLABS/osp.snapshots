# create_observer aborts on a missing or empty name

    Code
      create_observer(type = "Amount")
    Condition
      Error in `create_observer()`:
      ! `name` must be a non-empty string

---

    Code
      create_observer(name = "", type = "Amount")
    Condition
      Error in `create_observer()`:
      ! `name` must be a non-empty string

# create_observer aborts on an invalid type

    Code
      create_observer(name = "x", type = "Bogus")
    Condition
      Error in `create_observer()`:
      ! `type` must be one of "Amount" and "Container"

