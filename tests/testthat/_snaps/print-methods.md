# print.snapshot_collection dispatches on compound_collection

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

# print.snapshot_collection dispatches on empty compound_collection

    Code
      print(compounds_named)
    Output
      
      -- Compounds (0) ---------------------------------------------------------------
      i No compounds found

# print.snapshot_collection dispatches on individual_collection

    Code
      print(test_snapshot$individuals)
    Output
      
      -- Individuals (5) -------------------------------------------------------------
      * European (P-gp modified, CYP3A4 36 h)
      * Korean (Yu 2004 study)
      * ind_modified
      * Asian
      * CKD

# print.snapshot_collection dispatches on empty individual_collection

    Code
      print(individuals_named)
    Output
      
      -- Individuals (0) -------------------------------------------------------------
      i No individuals found

# print.snapshot_collection dispatches on formulation_collection

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

# print.snapshot_collection dispatches on empty formulation_collection

    Code
      print(formulations_named)
    Output
      
      -- Formulations (0) ------------------------------------------------------------
      i No formulations found

# print.snapshot_collection dispatches on simulation_collection

    Code
      print(snapshot$simulations)
    Output
      
      -- Simulations (2) -------------------------------------------------------------
      * simulation1 (Korean (Yu 2004 study))
      * simulation2 (European (P-gp modified, CYP3A4 36 h))

# print.snapshot_collection dispatches on empty simulation_collection

    Code
      print(simulations_named)
    Output
      
      -- Simulations (0) -------------------------------------------------------------
      i No simulations found

# print.snapshot_collection errors when no collection_kind_info method exists

    Code
      print(unknown)
    Condition
      Error in `UseMethod()`:
      ! no applicable method for 'collection_kind_info' applied to an object of class "c('future_collection', 'snapshot_collection', 'list')"

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

# print.snapshot_collection dispatches on expression_profile_collection

    Code
      print(profiles)
    Output
      
      -- Expression Profiles (3) -----------------------------------------------------
      * CYP3A4 (Enzyme, Human, Healthy)
      * P-gp (Transporter, Human, Healthy)
      * OATP1B1 (Transporter, Rat, N/A)

# print.snapshot_collection dispatches on empty expression_profile_collection

    Code
      print(profiles_named)
    Output
      
      -- Expression Profiles (0) -----------------------------------------------------
      i No expression profiles found

# print.physicochemical_property flags the default alternative

    Code
      print(compound$lipophilicity)
    Message
      * Lipophilicity:
        * Measured: 2.5 Log Units [Unknown]
        * Predicted (Default): 3.1 Log Units [Unknown]

# print.physicochemical_property omits the flag for a single alternative

    Code
      print(compound$lipophilicity)
    Message
      * Lipophilicity:
        * 2.5 Log Units [Unknown]

