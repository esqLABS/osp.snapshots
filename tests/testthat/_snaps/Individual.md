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

# assigning a non-character to expression_profiles aborts

    Code
      ind$expression_profiles <- list(1)
    Condition
      Error:
      ! expression_profiles must be a character vector of expression-profile names, not a list.

---

    Code
      ind$expression_profiles <- 42
    Condition
      Error:
      ! expression_profiles must be a character vector of expression-profile names, not a number.

# assigning an invalid description aborts

    Code
      ind$description <- 42
    Condition
      Error:
      ! description must be a single character string, not a number.

---

    Code
      ind$description <- c("a", "b")
    Condition
      Error:
      ! description must be a single character string, not a character vector.

# create_individual rejects a name-only parameter

    Code
      create_individual(name = "X", parameters = list(create_parameter(name = "SomeName",
        value = 1)))
    Condition
      Error in `FUN()`:
      ! Each `parameters` entry must be a localized parameter with a path.
      i Create it with `create_parameter(path = ...)`.

# create_individual rejects a mixed valid/invalid parameter list

    Code
      create_individual(name = "X", parameters = list(create_parameter(path = "Organism|Liver|Volume",
        value = 1), create_parameter(name = "SomeName", value = 2)))
    Condition
      Error in `FUN()`:
      ! Each `parameters` entry must be a localized parameter with a path.
      i Create it with `create_parameter(path = ...)`.

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
    Output
      
      -- Individuals (0) -------------------------------------------------------------
      i No individuals found

# get_individuals_dfs returns correct data frames

    Code
      dfs$individuals
    Output
      # A tibble: 5 x 18
        individual_id         name  description   seed species population gender   age
        <chr>                 <chr> <chr>        <int> <chr>   <chr>      <chr>  <dbl>
      1 European (P-gp modif~ Euro~ <NA>        1.72e7 Human   European_~ MALE    30  
      2 Korean (Yu 2004 stud~ Kore~ <NA>        5.30e7 Human   Asian_Tan~ MALE    23.3
      3 ind_modified          ind_~ <NA>        4.88e8 Human   BlackAmer~ MALE    56  
      4 Asian                 Asian <NA>        9.18e8 Human   Asian_Tan~ MALE    26  
      5 CKD                   CKD   <NA>        1.52e9 Human   European_~ MALE    50  
      # i 10 more variables: age_unit <chr>, gestational_age <dbl>,
      #   gestational_age_unit <chr>, weight <dbl>, weight_unit <chr>, height <dbl>,
      #   height_unit <chr>, disease_state <chr>, calculation_methods <glue>,
      #   disease_state_parameters <glue>

---

    Code
      dfs$individuals_parameters
    Output
      # A tibble: 5 x 7
        individual_id                   path  value unit  source description source_id
        <chr>                           <chr> <dbl> <chr> <chr>  <chr>           <int>
      1 European (P-gp modified, CYP3A~ Orga~  0.8  <NA>  Publi~ R24-4081           NA
      2 European (P-gp modified, CYP3A~ Orga~  1    <NA>  Publi~ R24-4081           NA
      3 Korean (Yu 2004 study)          Orga~  1    <NA>  Unkno~ <NA>               NA
      4 Korean (Yu 2004 study)          Orga~  0.89 <NA>  Publi~ R24-4081           NA
      5 ind_modified                    Orga~ 33    ml/m~ Other  Assumed            15

---

    Code
      dfs$individuals_expressions
    Output
      # A tibble: 16 x 2
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
      15 Asian                                 CYP3A4|Human|Healthy                
      16 CKD                                   CYP3A4|Human|Korean (Yu 2004 study) 

---

    Code
      dfs_empty$individuals
    Output
      # A tibble: 0 x 18
      # i 18 variables: individual_id <chr>, name <chr>, description <chr>,
      #   seed <int>, species <chr>, population <chr>, gender <chr>, age <dbl>,
      #   age_unit <chr>, gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <chr>,
      #   disease_state_parameters <chr>

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
      # A tibble: 1 x 18
        individual_id name  description  seed species population gender   age age_unit
        <chr>         <chr> <chr>       <int> <chr>   <chr>      <chr>  <dbl> <chr>   
      1 CharExpr Ind~ Char~ <NA>           NA Human   European_~ FEMALE    28 year(s) 
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <chr>,
      #   disease_state_parameters <chr>

---

    Code
      dfs$individuals_parameters
    Output
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, path <chr>, value <dbl>, unit <chr>,
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

# add_individual warns on unresolved expression profiles

    Code
      snapshot$add_individual(ind)
    Condition
      Warning:
      Individual "Subject 1" references expression profiles that are not in the snapshot:
      * ExpressionProfiles: NoSuch|Human|Healthy
      i PK-Sim will fail to resolve these at load time.
    Message
      v Added 1 individual(s)

