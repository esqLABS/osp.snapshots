# create_compound_properties validates arguments

    Code
      create_compound_properties()
    Condition
      Error in `create_compound_properties()`:
      ! `name` must be a non-empty string

---

    Code
      create_compound_properties(name = "")
    Condition
      Error in `create_compound_properties()`:
      ! `name` must be a non-empty string

---

    Code
      create_compound_properties(name = "X", alternatives = "nope")
    Condition
      Error in `create_compound_properties()`:
      ! `alternatives` must be a list

---

    Code
      create_compound_properties(name = "X", protocol = "nope")
    Condition
      Error in `create_compound_properties()`:
      ! `protocol` must be a <ProtocolSelection> or a raw list

