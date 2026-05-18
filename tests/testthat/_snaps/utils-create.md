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

