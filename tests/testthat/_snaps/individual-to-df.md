# to_df returns all tables by default

    Code
      dfs
    Output
      $origin
      # A tibble: 1 x 17
        individual_id name            seed species population    gender   age age_unit
        <chr>         <chr>          <dbl> <chr>   <chr>         <chr>  <dbl> <chr>   
      1 Mouly2002     Mouly2002 1300547185 Human   WhiteAmerica~ MALE    29.9 year(s) 
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <glue>,
      #   disease_state_parameters <chr>
      
      $parameters
      # A tibble: 2 x 6
        individual_id path                              value unit  source description
        <chr>         <chr>                             <dbl> <chr> <chr>  <chr>      
      1 Mouly2002     Organism|Gallbladder|Gallbladder~   0.8 <NA>  Publi~ R24-4081   
      2 Mouly2002     Organism|Liver|EHC continuous fr~   1   <NA>  Publi~ R24-4081   
      
      $expressions
      # A tibble: 2 x 2
        individual_id profile             
        <chr>         <chr>               
      1 Mouly2002     CYP1A2|Human|Healthy
      2 Mouly2002     CYP2B6|Human|Healthy
      

# to_df returns specific tables when requested

    Code
      origin_df
    Output
      # A tibble: 1 x 17
        individual_id name          seed species population      gender   age age_unit
        <chr>         <chr>        <dbl> <chr>   <chr>           <chr>  <dbl> <chr>   
      1 European      European 186687441 Human   European_ICRP_~ MALE      30 year(s) 
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <glue>,
      #   disease_state_parameters <chr>

---

    Code
      params_df
    Output
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, name <chr>, value <dbl>, unit <chr>,
      #   source <chr>, description <chr>, source_id <int>

---

    Code
      expr_df
    Output
      # A tibble: 2 x 2
        individual_id profile             
        <chr>         <chr>               
      1 European      CYP1A2|Human|Healthy
      2 European      CYP2B6|Human|Healthy

# to_df handles missing values

    Code
      dfs
    Output
      $origin
      # A tibble: 1 x 17
        individual_id name     seed species population gender   age age_unit
        <chr>         <chr>   <int> <chr>   <chr>      <chr>  <dbl> <chr>   
      1 Minimal       Minimal    NA <NA>    <NA>       <NA>      NA <NA>    
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <chr>,
      #   disease_state_parameters <chr>
      
      $parameters
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, name <chr>, value <dbl>, unit <chr>,
      #   source <chr>, description <chr>, source_id <int>
      
      $expressions
      # A tibble: 0 x 2
      # i 2 variables: individual_id <chr>, profile <chr>
      

# to_df includes gestational age

    Code
      origin_df
    Output
      # A tibble: 1 x 17
        individual_id name          seed species population gender   age age_unit
        <chr>         <chr>        <int> <chr>   <chr>      <chr>  <dbl> <chr>   
      1 Preterm Baby  Preterm Baby    NA Human   Preterm    MALE      10 day(s)  
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <chr>,
      #   disease_state_parameters <chr>

# get_individuals_dfs returns combined data frames from all individuals

    Code
      dfs
    Output
      $origin
      # A tibble: 2 x 17
        individual_id name            seed species population    gender   age age_unit
        <chr>         <chr>          <dbl> <chr>   <chr>         <chr>  <dbl> <chr>   
      1 Mouly2002     Mouly2002 1300547185 Human   WhiteAmerica~ MALE    29.9 year(s) 
      2 European      European   186687441 Human   European_ICR~ MALE    30   year(s) 
      # i 9 more variables: gestational_age <dbl>, gestational_age_unit <chr>,
      #   weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>,
      #   disease_state <chr>, calculation_methods <glue>,
      #   disease_state_parameters <chr>
      
      $parameters
      # A tibble: 2 x 8
        individual_id path              value unit  source description name  source_id
        <chr>         <chr>             <dbl> <chr> <chr>  <chr>       <chr>     <int>
      1 Mouly2002     Organism|Gallbla~   0.8 <NA>  Publi~ R24-4081    <NA>         NA
      2 Mouly2002     Organism|Liver|E~   1   <NA>  Publi~ R24-4081    <NA>         NA
      
      $expressions
      # A tibble: 4 x 2
        individual_id profile             
        <chr>         <chr>               
      1 Mouly2002     CYP1A2|Human|Healthy
      2 Mouly2002     CYP2B6|Human|Healthy
      3 European      CYP1A2|Human|Healthy
      4 European      CYP2B6|Human|Healthy
      

# get_individuals_dfs handles empty snapshot

    Code
      dfs
    Output
      $origin
      # A tibble: 0 x 14
      # i 14 variables: individual_id <chr>, name <chr>, seed <int>, species <chr>,
      #   population <chr>, gender <chr>, age <dbl>, age_unit <chr>, weight <dbl>,
      #   weight_unit <chr>, height <dbl>, height_unit <chr>, disease_state <chr>,
      #   calculation_methods <chr>
      
      $parameters
      # A tibble: 0 x 4
      # i 4 variables: individual_id <chr>, name <chr>, value <dbl>, unit <chr>
      
      $expressions
      # A tibble: 0 x 2
      # i 2 variables: individual_id <chr>, profile <chr>
      

