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
      ! `schemas` is mutually exclusive with Simple Protocol fields.
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `parameters`) or Advanced (use `schemas`).
      x Conflicting argument: `application_type`.

---

    Code
      create_protocol(name = "P", dosing_interval = "Single", target_organ = "Liver",
        schemas = list())
    Condition
      Error in `create_protocol()`:
      ! `schemas` is mutually exclusive with Simple Protocol fields.
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `parameters`) or Advanced (use `schemas`).
      x Conflicting arguments: `dosing_interval` and `target_organ`.

---

    Code
      create_protocol(name = "P", parameters = "not a list")
    Condition
      Error in `create_protocol()`:
      ! `parameters` must be a list

