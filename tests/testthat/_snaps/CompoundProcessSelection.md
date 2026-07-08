# CompoundProcessSelection optional string fields accept NULL or a non-empty string

    Code
      sel[[field]] <- ""
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      sel[[field]] <- 5
    Condition
      Error:
      ! `name` must be a non-empty string

---

    Code
      sel[[field]] <- ""
    Condition
      Error:
      ! `molecule_name` must be a non-empty string

---

    Code
      sel[[field]] <- 5
    Condition
      Error:
      ! `molecule_name` must be a non-empty string

---

    Code
      sel[[field]] <- ""
    Condition
      Error:
      ! `metabolite_name` must be a non-empty string

---

    Code
      sel[[field]] <- 5
    Condition
      Error:
      ! `metabolite_name` must be a non-empty string

---

    Code
      sel[[field]] <- ""
    Condition
      Error:
      ! `compound_name` must be a non-empty string

---

    Code
      sel[[field]] <- 5
    Condition
      Error:
      ! `compound_name` must be a non-empty string

---

    Code
      sel[[field]] <- ""
    Condition
      Error:
      ! `systemic_process_type` must be a non-empty string

---

    Code
      sel[[field]] <- 5
    Condition
      Error:
      ! `systemic_process_type` must be a non-empty string

