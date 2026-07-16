# create_schema_item validates required arguments

    Code
      create_schema_item()
    Condition
      Error in `create_schema_item()`:
      ! `name` must be a non-empty string

---

    Code
      create_schema_item(name = "")
    Condition
      Error in `create_schema_item()`:
      ! `name` must be a non-empty string

---

    Code
      create_schema_item(name = "Item", application_type = NULL)
    Condition
      Error in `create_schema_item()`:
      ! `application_type` must be a non-empty string

---

    Code
      create_schema_item(name = "Item", application_type = "NotARealType")
    Condition
      Error in `create_schema_item()`:
      ! `application_type` must be one of the canonical PK-Sim application types.
      x Got "NotARealType".
      i Valid values: "Oral", "IntravenousBolus", "IntravenousInfusion", "Intramuscular", "Subcutaneous", "Dermal", "Rectal", "Inhalation", and "Intraperitoneal".

---

    Code
      create_schema_item(name = "Item", application_type = "Oral", parameters = "not a list")
    Condition
      Error in `create_schema_item()`:
      ! `parameters` must be a list

# invalid dose unit aborts, attributed to create_schema_item()

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = 10, dose_unit = "h")
    Condition
      Error in `create_schema_item()`:
      ! Invalid dose unit: h
      i Valid dose units are: kg, g, mg, µg, ng, pg, mol, mmol, µmol, nmol, pmol, ng/kg, µg/kg, mg/kg, g/kg, kg/kg, mg/m², kg/dm², µg/cm², mg/cm²

---

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = 10, dose_unit = "not-a-unit")
    Condition
      Error in `create_schema_item()`:
      ! Invalid dose unit: not-a-unit
      i Valid dose units are: kg, g, mg, µg, ng, pg, mol, mmol, µmol, nmol, pmol, ng/kg, µg/kg, mg/kg, g/kg, kg/kg, mg/m², kg/dm², µg/cm², mg/cm²

# invalid start_time_unit aborts

    Code
      create_schema_item(name = "I", application_type = "Oral", start_time = 0,
        start_time_unit = "mg")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: mg
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

# non-finite or non-scalar dose aborts

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = "10")
    Condition
      Error in `create_schema_item()`:
      ! `dose` must be a single finite numeric value

---

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = c(1, 2))
    Condition
      Error in `create_schema_item()`:
      ! `dose` must be a single finite numeric value

---

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = NA_real_)
    Condition
      Error in `create_schema_item()`:
      ! `dose` must be a single finite numeric value

---

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = Inf)
    Condition
      Error in `create_schema_item()`:
      ! `dose` must be a single finite numeric value

# non-finite or non-scalar start_time aborts

    Code
      create_schema_item(name = "I", application_type = "Oral", start_time = "10")
    Condition
      Error in `create_schema_item()`:
      ! `start_time` must be a single finite numeric value

---

    Code
      create_schema_item(name = "I", application_type = "Oral", start_time = c(1, 2))
    Condition
      Error in `create_schema_item()`:
      ! `start_time` must be a single finite numeric value

---

    Code
      create_schema_item(name = "I", application_type = "Oral", start_time = NA_real_)
    Condition
      Error in `create_schema_item()`:
      ! `start_time` must be a single finite numeric value

---

    Code
      create_schema_item(name = "I", application_type = "Oral", start_time = Inf)
    Condition
      Error in `create_schema_item()`:
      ! `start_time` must be a single finite numeric value

# dose conflicts with an InputDose entry in parameters

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = 10,
        parameters = list(create_parameter(name = "InputDose", value = 5, unit = "mg")))
    Condition
      Error in `create_schema_item()`:
      ! Promoted argument conflict with `parameters` entry.
      x `dose` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

---

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = 10,
        parameters = list(list(Name = "InputDose", Value = 5, Unit = "mg")))
    Condition
      Error in `create_schema_item()`:
      ! Promoted argument conflict with `parameters` entry.
      x `dose` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# a Path-form InputDose entry conflicts with promoted dose

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = 10,
        parameters = list(create_parameter(path = "InputDose", value = 5, unit = "mg")))
    Condition
      Error in `create_schema_item()`:
      ! Promoted argument conflict with `parameters` entry.
      x `dose` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# start_time conflicts with a Start time entry in parameters

    Code
      create_schema_item(name = "I", application_type = "Oral", start_time = 0,
        parameters = list(create_parameter(name = "Start time", value = 1, unit = "h")))
    Condition
      Error in `create_schema_item()`:
      ! Promoted argument conflict with `parameters` entry.
      x `start_time` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# all conflicting promoted arguments are reported in one error

    Code
      create_schema_item(name = "I", application_type = "Oral", dose = 10,
        start_time = 0, parameters = list(create_parameter(name = "InputDose", value = 5,
          unit = "mg"), create_parameter(name = "Start time", value = 1, unit = "h")))
    Condition
      Error in `create_schema_item()`:
      ! Promoted arguments conflict with `parameters` entries.
      x `dose` and `start_time` are also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

