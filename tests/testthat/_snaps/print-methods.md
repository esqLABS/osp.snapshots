# print.compound_collection works with compounds

    Code
      print(test_snapshot$compounds)
    Output
      
      -- Compounds (6) ---------------------------------------------------------------
      * Rifampicin
      * 123456
      * Perpetrator_2
      * 100777- initial table parameters
      * 100777
      * test

# print.compound_collection works with empty collection

    Code
      print(compounds_named)
    Output
      
      -- Compounds (0) ---------------------------------------------------------------
      i No compounds found

# print.individual_collection works with individuals

    Code
      print(test_snapshot$individuals)
    Output
      
      -- Individuals (5) -------------------------------------------------------------
      * European (P-gp modified, CYP3A4 36 h)
      * Korean (Yu 2004 study)
      * ind_modified
      * Asian
      * CKD

# print.individual_collection works with empty collection

    Code
      print(individuals_named)
    Output
      
      -- Individuals (0) -------------------------------------------------------------
      i No individuals found

# print.formulation_collection works with formulations

    Code
      print(test_snapshot$formulations)
    Output
      
      -- Formulations (9) ------------------------------------------------------------
      * Tablet (Dormicum) (Weibull)
      * Oral solution (Dissolved)
      * form_dissolved (Dissolved)
      * form_Lint80 (Lint80)
      * form-particle-dissolution (Particle)
      * form-table (Table)
      * form-ZO (Zero Order)
      * form-FO (First Order)
      * form-particle-dissolution-2 (Particle)

# print.formulation_collection works with empty collection

    Code
      print(formulations_named)
    Output
      
      -- Formulations (0) ------------------------------------------------------------
      i No formulations found

# print.parameter_collection works with parameters

    Code
      print(params)
    Output
      Parameter Collection with 3 parameters:
      Name                                     | Value           | Unit
      -----------------------------------------|-----------------|----------------
      Test|Path1                               | 123.5           | mg
      ...ry|Long|Name|That|Should|Be|Truncated | 0.1235          | mg/ml
      Test|Path3                               | 987.7           | 

# print.parameter_collection works with empty collection

    Code
      print(params)
    Output
      Empty Parameter Collection

# print.parameter_collection formats values correctly

    Code
      print(params)
    Output
      Parameter Collection with 4 parameters:
      Name                                     | Value           | Unit
      -----------------------------------------|-----------------|----------------
      Test|Integer                             | 123             | count
      Test|Decimal                             | 123.5           | mg
      Test|Scientific                          | 1.23e-05        | mol
      Test|Large                               | 12345678        | cells

# print.expression_profile_collection works with profiles

    Code
      print(profiles)
    Output
      
      -- Expression Profiles (3) -----------------------------------------------------
      * CYP3A4 (Enzyme, Human, Healthy)
      * P-gp (Transporter, Human, Healthy)
      * OATP1B1 (Transporter, Rat, N/A)

# print.expression_profile_collection works with empty collection

    Code
      print(profiles_named)
    Output
      
      -- Expression Profiles (0) -----------------------------------------------------
      i No expression profiles found

