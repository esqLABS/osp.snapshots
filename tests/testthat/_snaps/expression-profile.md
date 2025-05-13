# ExpressionProfile print method works

    Code
      print(complete_expression_profile)
    Message
      
      -- Expression Profile: CYP3A4 (Enzyme) -----------------------------------------
      * Species: Human
      * Category: Healthy
      * Localization: Intracellular, BloodCellsIntracellular
      * Ontogeny: CYP3A4
      * Parameters: 3

---

    Code
      print(minimal_expression_profile)
    Message
      
      -- Expression Profile: P-gp (Transporter) --------------------------------------
      * Species: Human
      * Category: Healthy

---

    Code
      print(without_category_expression_profile)
    Message
      
      -- Expression Profile: OATP1B1 (Transporter) -----------------------------------
      * Species: Rat
      * Category:
      * Parameters: 1

# print.expression_profile_collection works

    Code
      print(profiles)
    Message
      
      -- Expression Profiles (3) -----------------------------------------------------
      * CYP3A4 (Enzyme, Human, Healthy)
      * P-gp (Transporter, Human, Healthy)
      * OATP1B1 (Transporter, Rat, N/A)

---

    Code
      print(empty_profiles)
    Message
      
      -- Expression Profiles (0) -----------------------------------------------------
      i No expression profiles found

# expression_profile_collection from cloned test snapshot works

    Code
      print(profiles)
    Message
      
      -- Expression Profiles (14) ----------------------------------------------------
      * CYP3A4 (Enzyme, Human, Healthy)
      * AADAC (Enzyme, Human, Healthy)
      * P-gp (Transporter, Human, Healthy)
      * OATP1B1 (Transporter, Human, Healthy)
      * ATP1A2 (OtherProtein, Human, Healthy)
      * UGT1A4 (Enzyme, Human, Healthy)
      * GABRG2 (OtherProtein, Human, Healthy)
      * CYP3A4 (Enzyme, Human, Korean (Yu 2004 study))
      * AADAC (Enzyme, Human, Korean (Yu 2004 study))
      * P-gp (Transporter, Human, Korean (Yu 2004 study))
      * OATP1B1 (Transporter, Human, Korean (Yu 2004 study))
      * ATP1A2 (OtherProtein, Human, Korean (Yu 2004 study))
      * UGT1A4 (Enzyme, Human, Korean (Yu 2004 study))
      * GABRG2 (OtherProtein, Human, Korean (Yu 2004 study))

# Snapshot with empty expression profiles is handled correctly

    Code
      knitr::kable(dfs$expression_profiles)
    Output
      
      
      |expression_id |molecule |type |species |category |localization |ontogeny |
      |:-------------|:--------|:----|:-------|:--------|:------------|:--------|

---

    Code
      knitr::kable(dfs$expression_profiles_parameters)
    Output
      
      
      |expression_id |parameter | value|unit |source |description |
      |:-------------|:---------|-----:|:----|:------|:-----------|

