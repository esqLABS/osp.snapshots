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

---

    Code
      create_protocol(name = "P", application_type = "NotARealType")
    Condition
      Error in `create_protocol()`:
      ! `application_type` must be one of the canonical PK-Sim application types.
      x Got "NotARealType".
      i Valid values: "Oral", "IntravenousBolus", "IntravenousInfusion", "Intramuscular", "Subcutaneous", "Dermal", "Rectal", "Inhalation", and "Intraperitoneal".

# create_protocol validates time_unit against the Time dimension

    Code
      create_protocol(name = "P", time_unit = "banana")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: banana
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

