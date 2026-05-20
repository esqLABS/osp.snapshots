# create_formulation_selection validates arguments

    Code
      create_formulation_selection()
    Condition
      Error in `create_formulation_selection()`:
      ! `name` must be a non-empty string

---

    Code
      create_formulation_selection(name = "F")
    Condition
      Error in `create_formulation_selection()`:
      ! `key` must be a non-empty string

---

    Code
      create_formulation_selection(name = "", key = "K")
    Condition
      Error in `create_formulation_selection()`:
      ! `name` must be a non-empty string

