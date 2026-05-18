# create_schema validates required arguments

    Code
      create_schema()
    Condition
      Error in `create_schema()`:
      ! `name` must be a non-empty string

---

    Code
      create_schema(name = "")
    Condition
      Error in `create_schema()`:
      ! `name` must be a non-empty string

---

    Code
      create_schema(name = "Schema 1", parameters = "not a list")
    Condition
      Error in `create_schema()`:
      ! `parameters` must be a list

---

    Code
      create_schema(name = "Schema 1", items = "not a list")
    Condition
      Error in `create_schema()`:
      ! `items` must be a list

---

    Code
      create_schema(name = "Schema 1", items = list("not a SchemaItem or list"))
    Condition
      Error in `create_schema()`:
      ! Every entry of `items` must be a <SchemaItem> or a raw list

