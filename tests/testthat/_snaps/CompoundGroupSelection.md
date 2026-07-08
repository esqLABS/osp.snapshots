# CompoundGroupSelection setters require non-empty scalar strings

    Code
      sel$group_name <- ""
    Condition
      Error:
      ! `group_name` must be a non-empty string

---

    Code
      sel$group_name <- 5
    Condition
      Error:
      ! `group_name` must be a non-empty string

---

    Code
      sel$alternative_name <- ""
    Condition
      Error:
      ! `alternative_name` must be a non-empty string

---

    Code
      sel$alternative_name <- 5
    Condition
      Error:
      ! `alternative_name` must be a non-empty string

