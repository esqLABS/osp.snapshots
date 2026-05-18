# create_event validates required arguments

    Code
      create_event()
    Condition
      Error in `create_event()`:
      ! `name` must be a non-empty string

---

    Code
      create_event(name = "E")
    Condition
      Error in `create_event()`:
      ! `template` must be a non-empty string

---

    Code
      create_event(name = "", template = "T")
    Condition
      Error in `create_event()`:
      ! `name` must be a non-empty string

---

    Code
      create_event(name = "E", template = "T", parameters = "nope")
    Condition
      Error in `create_event()`:
      ! `parameters` must be a list

