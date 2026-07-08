# Process$internal_name and $data_source require non-empty strings

    Code
      p$internal_name <- ""
    Condition
      Error:
      ! `internal_name` must be a non-empty string

---

    Code
      p$internal_name <- 5
    Condition
      Error:
      ! `internal_name` must be a non-empty string

---

    Code
      p$data_source <- ""
    Condition
      Error:
      ! `data_source` must be a non-empty string

---

    Code
      p$data_source <- 5
    Condition
      Error:
      ! `data_source` must be a non-empty string

# Process$molecule, $metabolite, $species accept NULL or a non-empty string

    Code
      p$molecule <- ""
    Condition
      Error:
      ! `molecule` must be a non-empty string

---

    Code
      p$molecule <- 5
    Condition
      Error:
      ! `molecule` must be a non-empty string

---

    Code
      p$metabolite <- ""
    Condition
      Error:
      ! `metabolite` must be a non-empty string

---

    Code
      p$species <- 5
    Condition
      Error:
      ! `species` must be a non-empty string

# Process print is stable

    Code
      print(p)
    Output
      
      -- Process: MetabolizationSpecific_MM 
      * Category: metabolizing_enzymes
      * Data source: Optimized
      * Molecule: CYP3A4
      * Metabolite: X-OH
      * Parameters: 1

