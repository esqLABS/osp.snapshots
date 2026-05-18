# to_raw_r6_or_list rejects non-R6 non-list entries

    Code
      to_raw_r6_or_list(list("not valid"), "SchemaItem", "items")
    Condition
      Error:
      ! Every entry of `items` must be a <SchemaItem> or a raw list

