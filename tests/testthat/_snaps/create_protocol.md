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
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `dose`, `start_time`, `end_time`, `parameters`) or Advanced (use `schemas`).
      x Conflicting argument: `application_type`.

---

    Code
      create_protocol(name = "P", dosing_interval = "Single", target_organ = "Liver",
        schemas = list())
    Condition
      Error in `create_protocol()`:
      ! `schemas` is mutually exclusive with Simple Protocol fields.
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `dose`, `start_time`, `end_time`, `parameters`) or Advanced (use `schemas`).
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

# create_protocol validates dosing_interval against the DosingIntervalId enum

    Code
      create_protocol(name = "P", application_type = "Oral", dosing_interval = "typo")
    Condition
      Error in `create_protocol()`:
      ! `dosing_interval` must be one of the fixed PK-Sim dosing intervals.
      x Got "typo".
      i Valid values: "Single", "DI_6_6_6_6", "DI_6_6_12", "DI_8_8_8", "DI_12_12", and "DI_24".

# create_protocol validates time_unit against the Time dimension

    Code
      create_protocol(name = "P", time_unit = "banana")
    Condition
      Error in `validate_unit()`:
      ! Invalid unit: banana
      i Valid units for Time are: s, min, h, day(s), week(s), month(s), year(s), ks

# create_protocol promotes dose, start_time, and end_time to parameters

    Code
      protocol$data$Parameters
    Output
      [[1]]
      [[1]]$Name
      [1] "InputDose"
      
      [[1]]$Value
      [1] 10
      
      [[1]]$Unit
      [1] "mg"
      
      
      [[2]]
      [[2]]$Name
      [1] "Start time"
      
      [[2]]$Value
      [1] 0
      
      [[2]]$Unit
      [1] "h"
      
      
      [[3]]
      [[3]]$Name
      [1] "End time"
      
      [[3]]$Value
      [1] 24
      
      [[3]]$Unit
      [1] "h"
      
      

# create_protocol rejects an invalid dose_unit

    Code
      create_protocol(name = "P", dose = 5, dose_unit = "banana")
    Condition
      Error in `create_protocol()`:
      ! Invalid dose unit: banana
      i Valid dose units are: kg, g, mg, µg, ng, pg, mol, mmol, µmol, nmol, pmol, ng/kg, µg/kg, mg/kg, g/kg, kg/kg, mg/m², kg/dm², µg/cm², mg/cm²

---

    Code
      create_protocol(name = "P", dose = 5, dose_unit = "h")
    Condition
      Error in `create_protocol()`:
      ! Invalid dose unit: h
      i Valid dose units are: kg, g, mg, µg, ng, pg, mol, mmol, µmol, nmol, pmol, ng/kg, µg/kg, mg/kg, g/kg, kg/kg, mg/m², kg/dm², µg/cm², mg/cm²

# create_protocol rejects a NULL or non-scalar dose_unit

    Code
      create_protocol(name = "P", application_type = "Oral", dosing_interval = "Single",
        dose = 5, dose_unit = NULL)
    Condition
      Error in `create_protocol()`:
      ! Invalid dose unit:
      i Valid dose units are: kg, g, mg, µg, ng, pg, mol, mmol, µmol, nmol, pmol, ng/kg, µg/kg, mg/kg, g/kg, kg/kg, mg/m², kg/dm², µg/cm², mg/cm²

---

    Code
      create_protocol(name = "P", application_type = "Oral", dosing_interval = "Single",
        dose = 5, dose_unit = c("mg", "mmol"))
    Condition
      Error in `create_protocol()`:
      ! Invalid dose unit: mg and mmol
      i Valid dose units are: kg, g, mg, µg, ng, pg, mol, mmol, µmol, nmol, pmol, ng/kg, µg/kg, mg/kg, g/kg, kg/kg, mg/m², kg/dm², µg/cm², mg/cm²

# create_protocol rejects non-finite or non-scalar dose values

    Code
      create_protocol(name = "P", dose = NA)
    Condition
      Error in `create_protocol()`:
      ! `dose` must be a single finite numeric value

---

    Code
      create_protocol(name = "P", dose = c(1, 2))
    Condition
      Error in `create_protocol()`:
      ! `dose` must be a single finite numeric value

---

    Code
      create_protocol(name = "P", dose = Inf)
    Condition
      Error in `create_protocol()`:
      ! `dose` must be a single finite numeric value

---

    Code
      create_protocol(name = "P", start_time = "0")
    Condition
      Error in `create_protocol()`:
      ! `start_time` must be a single finite numeric value

# create_protocol errors when a promoted argument conflicts with parameters

    Code
      create_protocol(name = "P", dose = 10, parameters = list(create_parameter(name = "InputDose",
        value = 5, unit = "mg")))
    Condition
      Error in `create_protocol()`:
      ! Promoted argument conflict with `parameters` entry.
      x `dose` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

---

    Code
      create_protocol(name = "P", start_time = 0, parameters = list(create_parameter(
        name = "Start time", value = 1, unit = "h")))
    Condition
      Error in `create_protocol()`:
      ! Promoted argument conflict with `parameters` entry.
      x `start_time` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

---

    Code
      create_protocol(name = "P", end_time = 24, parameters = list(create_parameter(
        name = "End time", value = 12, unit = "h")))
    Condition
      Error in `create_protocol()`:
      ! Promoted argument conflict with `parameters` entry.
      x `end_time` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_protocol reports every conflicting promoted argument in one error

    Code
      create_protocol(name = "P", dose = 10, start_time = 0, end_time = 24,
        parameters = list(create_parameter(name = "InputDose", value = 5, unit = "mg"),
        create_parameter(name = "Start time", value = 1, unit = "h"),
        create_parameter(name = "End time", value = 12, unit = "h")))
    Condition
      Error in `create_protocol()`:
      ! Promoted arguments conflict with `parameters` entries.
      x `dose`, `start_time`, and `end_time` are also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_protocol detects a Path-keyed conflict after Name normalisation

    Code
      create_protocol(name = "P", dose = 10, parameters = list(create_parameter(path = "InputDose",
        value = 5, unit = "mg")))
    Condition
      Error in `create_protocol()`:
      ! Promoted argument conflict with `parameters` entry.
      x `dose` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

---

    Code
      create_protocol(name = "P", dose = 10, parameters = list(list(Path = "InputDose",
        Value = 5, Unit = "mg")))
    Condition
      Error in `create_protocol()`:
      ! Promoted argument conflict with `parameters` entry.
      x `dose` is also supplied in `parameters`.
      i Supply each setting either as its promoted argument or as an entry in `parameters`, not both.

# create_protocol rejects the promoted arguments combined with schemas

    Code
      create_protocol(name = "P", dose = 10, schemas = schemas)
    Condition
      Error in `create_protocol()`:
      ! `schemas` is mutually exclusive with Simple Protocol fields.
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `dose`, `start_time`, `end_time`, `parameters`) or Advanced (use `schemas`).
      x Conflicting argument: `dose`.

---

    Code
      create_protocol(name = "P", start_time = 0, schemas = schemas)
    Condition
      Error in `create_protocol()`:
      ! `schemas` is mutually exclusive with Simple Protocol fields.
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `dose`, `start_time`, `end_time`, `parameters`) or Advanced (use `schemas`).
      x Conflicting argument: `start_time`.

---

    Code
      create_protocol(name = "P", end_time = 24, schemas = schemas)
    Condition
      Error in `create_protocol()`:
      ! `schemas` is mutually exclusive with Simple Protocol fields.
      i A protocol is either Simple (use `application_type`, `dosing_interval`, `target_organ`, `target_compartment`, `dose`, `start_time`, `end_time`, `parameters`) or Advanced (use `schemas`).
      x Conflicting argument: `end_time`.

