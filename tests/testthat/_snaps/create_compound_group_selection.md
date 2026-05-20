# create_compound_group_selection validates arguments

    Code
      create_compound_group_selection()
    Condition
      Error in `create_compound_group_selection()`:
      ! `group_name` must be a non-empty string

---

    Code
      create_compound_group_selection(group_name = "G")
    Condition
      Error in `create_compound_group_selection()`:
      ! `alternative_name` must be a non-empty string

