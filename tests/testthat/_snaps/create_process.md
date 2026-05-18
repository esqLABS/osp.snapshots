# create_process validates required arguments

    Code
      create_process()
    Condition
      Error in `create_process()`:
      ! `internal_name` must be a non-empty string

---

    Code
      create_process(internal_name = "SpecificBinding")
    Condition
      Error in `create_process()`:
      ! `data_source` must be a non-empty string

---

    Code
      create_process(internal_name = "", data_source = "A")
    Condition
      Error in `create_process()`:
      ! `internal_name` must be a non-empty string

---

    Code
      create_process(internal_name = "SpecificBinding", data_source = "A",
        parameters = "not a list")
    Condition
      Error in `create_process()`:
      ! `parameters` must be a list

