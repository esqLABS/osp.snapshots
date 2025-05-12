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

# Snapshot with empty individuals is handled correctly

    Code
      print(snapshot$individuals)
    Message
      
      -- Individuals (0) -------------------------------------------------------------
      i No individuals found

# get_individuals_dfs returns correct data frames

    Code
      dfs$individuals
    Output
      # A tibble: 5 x 17
        individual_id            name    seed species population gender   age age_unit
        <chr>                    <chr>  <int> <chr>   <chr>      <chr>  <dbl> <chr>   
      1 European (P-gp modified~ Euro~ 1.72e7 Human   European_~ MALE    30   year(s) 
      2 Korean (Yu 2004 study)   Kore~ 5.30e7 Human   Asian_Tan~ MALE    23.3 year(s) 
      3 CKD                      CKD   3.91e8 Human   European_~ MALE    50   year(s) 
      4 ind_modified             ind_~ 4.88e8 Human   BlackAmer~ MALE    56   year(s) 
      5 baby                     baby  1.99e9 Human   Preterm    MALE    10   day(s)  
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <glue>,
      #   disease_state_parameters <glue>

---

    Code
      dfs$individuals_parameters
    Output
      # A tibble: 6 x 8
        individual_id             path  value unit  source description source_id name 
        <chr>                     <chr> <dbl> <chr> <chr>  <chr>           <int> <chr>
      1 European (P-gp modified,~ Orga~  0.8  <NA>  Publi~ R24-4081           NA <NA> 
      2 European (P-gp modified,~ Orga~  1    <NA>  Publi~ R24-4081           NA <NA> 
      3 Korean (Yu 2004 study)    Orga~  1    <NA>  Unkno~ <NA>               NA <NA> 
      4 Korean (Yu 2004 study)    Orga~  0.89 <NA>  Publi~ R24-4081           NA <NA> 
      5 CKD                       Orga~  7.25 <NA>  Datab~ Assumed            NA <NA> 
      6 ind_modified              Orga~ 33    ml/m~ Other  Assumed            15 <NA> 

---

    Code
      dfs$individuals_expressions
    Output
      # A tibble: 15 x 2
         individual_id                         profile                             
         <chr>                                 <chr>                               
       1 European (P-gp modified, CYP3A4 36 h) CYP3A4|Human|Healthy                
       2 European (P-gp modified, CYP3A4 36 h) AADAC|Human|Healthy                 
       3 European (P-gp modified, CYP3A4 36 h) P-gp|Human|Healthy                  
       4 European (P-gp modified, CYP3A4 36 h) OATP1B1|Human|Healthy               
       5 European (P-gp modified, CYP3A4 36 h) ATP1A2|Human|Healthy                
       6 European (P-gp modified, CYP3A4 36 h) UGT1A4|Human|Healthy                
       7 European (P-gp modified, CYP3A4 36 h) GABRG2|Human|Healthy                
       8 Korean (Yu 2004 study)                CYP3A4|Human|Korean (Yu 2004 study) 
       9 Korean (Yu 2004 study)                AADAC|Human|Korean (Yu 2004 study)  
      10 Korean (Yu 2004 study)                P-gp|Human|Korean (Yu 2004 study)   
      11 Korean (Yu 2004 study)                OATP1B1|Human|Korean (Yu 2004 study)
      12 Korean (Yu 2004 study)                ATP1A2|Human|Korean (Yu 2004 study) 
      13 Korean (Yu 2004 study)                UGT1A4|Human|Korean (Yu 2004 study) 
      14 Korean (Yu 2004 study)                GABRG2|Human|Korean (Yu 2004 study) 
      15 CKD                                   CYP3A4|Human|Korean (Yu 2004 study) 

---

    Code
      dfs_empty$individuals
    Output
      # A tibble: 0 x 17
      # i 17 variables: individual_id <chr>, name <chr>, seed <int>, species <chr>,
      #   population <chr>, gender <chr>, age <dbl>, age_unit <chr>,
      #   gestational_age <dbl>, gestational_age_unit <chr>, weight <dbl>,
      #   weight_unit <chr>, height <dbl>, height_unit <chr>, disease_state <chr>,
      #   calculation_methods <chr>, disease_state_parameters <chr>

---

    Code
      dfs_empty$individuals_parameters
    Output
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, path <chr>, value <dbl>, unit <chr>,
      #   source <chr>, description <chr>, source_id <int>

---

    Code
      dfs_empty$individuals_expressions
    Output
      # A tibble: 0 x 2
      # i 2 variables: individual_id <chr>, profile <chr>

# get_individuals_dfs handles individual with characteristics and expression profiles but no parameters

    Code
      dfs$individuals
    Output
      # A tibble: 1 x 17
        individual_id       name         seed species population gender   age age_unit
        <chr>               <chr>       <int> <chr>   <chr>      <chr>  <dbl> <chr>   
      1 CharExpr Individual CharExpr I~    NA Human   European_~ FEMALE    28 year(s) 
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <chr>,
      #   disease_state_parameters <chr>

---

    Code
      dfs$individuals_parameters
    Output
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, name <chr>, value <dbl>, unit <chr>,
      #   source <chr>, description <chr>, source_id <int>

---

    Code
      dfs$individuals_expressions
    Output
      # A tibble: 2 x 2
        individual_id       profile              
        <chr>               <chr>                
      1 CharExpr Individual CYP2D6|Human|Healthy 
      2 CharExpr Individual OATP1B1|Human|Healthy

