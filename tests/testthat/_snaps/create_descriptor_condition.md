# create_descriptor_condition aborts on missing or empty tag

    Code
      create_descriptor_condition()
    Condition
      Error in `create_descriptor_condition()`:
      ! `tag` must be a non-empty string

---

    Code
      create_descriptor_condition("")
    Condition
      Error in `create_descriptor_condition()`:
      ! `tag` must be a non-empty string

