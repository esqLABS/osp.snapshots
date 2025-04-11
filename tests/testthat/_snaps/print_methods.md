# print.compound_collection works with compounds

    Code
      print(test_snapshot$compounds)
    Message
      
      -- Compounds (6) ---------------------------------------------------------------
      * Rifampicin
      * BI 123456
      * Perpetrator_2
      * BI 100777- initial table parameters
      * BI 100777
      * test

# print.compound_collection works with empty collection

    Code
      print(compounds_named)
    Message
      
      -- Compounds (0) ---------------------------------------------------------------
      i No compounds found

# print.individual_collection works with individuals

    Code
      print(test_snapshot$individuals)
    Message
      
      -- Individuals (4) -------------------------------------------------------------
      * European (P-gp modified, CYP3A4 36 h)
      * Korean (Yu 2004 study)
      * CKD
      * ind_modified

# print.individual_collection works with empty collection

    Code
      print(individuals_named)
    Message
      
      -- Individuals (0) -------------------------------------------------------------
      i No individuals found

# print.parameter_collection works with parameters

    Code
      print(params)
    Output
      Parameter Collection with 3 parameters:
      Path                                     | Value           | Unit
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
      Path                                     | Value           | Unit
      -----------------------------------------|-----------------|----------------
      Test|Integer                             | 123             | count
      Test|Decimal                             | 123.5           | mg
      Test|Scientific                          | 1.23e-05        | mol
      Test|Large                               | 12345678        | cells

