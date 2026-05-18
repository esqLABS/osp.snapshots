# create_protocol validates required arguments

    Code
      create_protocol()
    Condition
      Error in `create_protocol()`:
      ! `name` must be a non-empty string

---

    Code
      create_protocol(name = "")
    Condition
      Error in `create_protocol()`:
      ! `name` must be a non-empty string

---

    Code
      create_protocol(name = "P", application_type = "Oral", schemas = list())
    Condition
      Error in `create_protocol()`:
      ! `schemas` and `application_type` are mutually exclusive
      i A protocol is either Simple (use `application_type`) or Advanced (use `schemas`).

---

    Code
      create_protocol(name = "P", parameters = "not a list")
    Condition
      Error in `create_protocol()`:
      ! `parameters` must be a list

