# Individual print method returns formatted output

    Code
      print(complete_individual)
    Output
      
      -- Individual: Test Individual -------------------------------------------------
      
      -- Origin Data --
      
      * Seed: 12345
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 year(s)
      * Height: 175 cm
      * Weight: 70 kg
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual handles missing data gracefully

    Code
      print(minimal_individual)
    Output
      
      -- Individual: Minimal Individual ----------------------------------------------

# Individual creation with modified data works

    Code
      print(modified_individual)
    Output
      
      -- Individual: Test Individual -------------------------------------------------
      
      -- Origin Data --
      
      * Seed: 12345
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 year(s)
      * Height: 175 cm
      * Weight: 70 kg
      * Disease State: CKD
      * eGFR: 45 ml/min/1.73m<U+00B2>
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual fields can be modified through active bindings

    Code
      print(test_individual)
    Output
      
      -- Individual: Modified Name ---------------------------------------------------
      
      -- Origin Data --
      
      * Seed: 54321
      * Species: Beagle
      * Population: Asian_Tanaka_1996
      * Gender: FEMALE
      * Age: 25 year(s)
      * Height: 180 cm
      * Weight: 80 kg
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual measurement units can be modified

    Code
      print(test_individual)
    Output
      
      -- Individual: Test Individual -------------------------------------------------
      
      -- Origin Data --
      
      * Seed: 12345
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 month(s)
      * Height: 175 m
      * Weight: 70 g
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual disease state can be modified

    Code
      print(test_individual)
    Output
      
      -- Individual: Test Individual -------------------------------------------------
      
      -- Origin Data --
      
      * Seed: 12345
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 year(s)
      * Height: 175 cm
      * Weight: 70 kg
      * Disease State: CKD
      * eGFR: 45 ml/min/1.73m<U+00B2>
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

