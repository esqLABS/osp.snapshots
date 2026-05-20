# create_protocol_selection validates arguments

    Code
      create_protocol_selection()
    Condition
      Error in `create_protocol_selection()`:
      ! `name` must be a non-empty string

---

    Code
      create_protocol_selection(name = "")
    Condition
      Error in `create_protocol_selection()`:
      ! `name` must be a non-empty string

---

    Code
      create_protocol_selection(name = "P", formulations = "nope")
    Condition
      Error in `create_protocol_selection()`:
      ! `formulations` must be a list

