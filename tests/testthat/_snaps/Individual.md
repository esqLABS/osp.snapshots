# Individual print method returns formatted output

    Code
      print(complete_individual)
    Output
      
      -- Individual: Test Individual | Seed: 12345 -----------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 year(s)
      * Height: 175 cm
      * Weight: 70 kg
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction: 1
      * Organism|Kidney|GFR: 120.5 ml/min
      
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
      
      -- Individual: Test Individual | Seed: 12345 -----------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 year(s)
      * Height: 175 cm
      * Weight: 70 kg
      * Disease State: CKD
      * eGFR: 45 ml/min/1.73m²
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction: 1
      * Organism|Kidney|GFR: 120.5 ml/min
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual fields can be modified through active bindings

    Code
      print(test_individual)
    Output
      
      -- Individual: Modified Name | Seed: 54321 -------------------------------------
      
      -- Characteristics --
      
      * Species: Beagle
      * Population: Asian_Tanaka_1996
      * Gender: FEMALE
      * Age: 25 year(s)
      * Gestational Age: 28 week(s)
      * Height: 180 cm
      * Weight: 80 kg
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction: 1
      * Organism|Kidney|GFR: 120.5 ml/min
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual measurement units can be modified

    Code
      print(test_individual)
    Output
      
      -- Individual: Test Individual | Seed: 12345 -----------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 month(s)
      * Gestational Age: 30 day(s)
      * Height: 175 m
      * Weight: 70 g
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction: 1
      * Organism|Kidney|GFR: 120.5 ml/min
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual disease state can be modified

    Code
      print(test_individual)
    Output
      
      -- Individual: Test Individual | Seed: 12345 -----------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Population: European_ICRP_2002
      * Gender: MALE
      * Age: 30 year(s)
      * Height: 175 cm
      * Weight: 70 kg
      * Disease State: CKD
      * eGFR: 45 ml/min/1.73m²
      
      -- Parameters --
      
      * Organism|Liver|EHC continuous fraction: 1
      * Organism|Kidney|GFR: 120.5 ml/min
      
      -- Expression Profiles --
      
      * CYP3A4|Human|Healthy
      * P-gp|Human|Healthy

# Individual print method displays calculation methods

    Code
      print(test_individual)
    Output
      
      -- Individual: Test Individual with Methods ------------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Calculation Methods:
        * Method 1
        * Method 2
        * Method 3

# Individual can be created with calculation methods

    Code
      print(individual)
    Output
      
      -- Individual: Method Test Individual ------------------------------------------
      
      -- Characteristics --
      
      * Calculation Methods:
        * Test Method 1
        * Test Method 2

# create_individual supports gestational age

    Code
      print(individual)
    Output
      
      -- Individual: Preterm Baby ----------------------------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Population: Preterm
      * Gender: MALE
      * Age: 10 day(s)
      * Gestational Age: 30 week(s)
      * Height: 40 cm
      * Weight: 1.5 kg

# Individual handles gestational age correctly

    Code
      print(preterm_individual)
    Output
      
      -- Individual: Preterm Baby | Seed: 54321 --------------------------------------
      
      -- Characteristics --
      
      * Species: Human
      * Population: Preterm
      * Gender: MALE
      * Age: 10 day(s)
      * Gestational Age: 32 day(s)
      * Height: 40 cm
      * Weight: 1.5 kg

