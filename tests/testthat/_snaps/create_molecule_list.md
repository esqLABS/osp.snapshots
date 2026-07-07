# create_molecule_list aborts on a non-logical for_all

    Code
      create_molecule_list(for_all = "yes")
    Condition
      Error in `create_molecule_list()`:
      ! `for_all` must be a single <logical> value

# create_molecule_list rejects NA and empty molecule names

    Code
      create_molecule_list(include = NA_character_)
    Condition
      Error in `create_molecule_list()`:
      ! `include` must contain only non-empty strings

---

    Code
      create_molecule_list(include = "")
    Condition
      Error in `create_molecule_list()`:
      ! `include` must contain only non-empty strings

---

    Code
      create_molecule_list(exclude = c("A", ""))
    Condition
      Error in `create_molecule_list()`:
      ! `exclude` must contain only non-empty strings

