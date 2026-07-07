# to_raw_r6_or_list rejects non-R6 non-list entries

    Code
      to_raw_r6_or_list(list("not valid"), "SchemaItem", "items")
    Condition
      Error:
      ! Every entry of `items` must be a <SchemaItem> or a raw list

# to_raw_r6_or_list rejects a bare R6 as the outer collection

    Code
      to_raw_r6_or_list(item, "SchemaItem", "items")
    Condition
      Error:
      ! `items` must be a list

# to_raw_r6_or_list rejects a non-list outer collection

    Code
      to_raw_r6_or_list("not a list", "SchemaItem", "items")
    Condition
      Error:
      ! `items` must be a list

# to_raw_r6_or_list rejects a wrong-class R6 entry

    Code
      to_raw_r6_or_list(list(compound), "SchemaItem", "items")
    Condition
      Error:
      ! Every entry of `items` must be a <SchemaItem> or a raw list

# build_expression_containers validates its input

    Code
      build_expression_containers("Liver")
    Condition
      Error:
      ! `expression` must be a data frame or a list

---

    Code
      build_expression_containers(data.frame(value = 1))
    Condition
      Error:
      ! `expression` data frame must have a name column

---

    Code
      build_expression_containers(data.frame(name = c("Liver", NA), value = c(1, 2)))
    Condition
      Error:
      ! Every name in `expression` must be a non-empty string

# build_disease_state validates a non-empty name

    Code
      build_disease_state(list(parameters = list()))
    Condition
      Error:
      ! `disease` must be a named list with a non-empty name

