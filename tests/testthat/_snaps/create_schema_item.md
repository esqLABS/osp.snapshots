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

