# to_df returns all tables by default

    Code
      print(dfs$origin, width = Inf)
    Output
      # A tibble: 1 x 15
        individual_id name            seed species population                gender
        <chr>         <chr>          <dbl> <chr>   <chr>                     <chr> 
      1 Mouly2002     Mouly2002 1300547185 Human   WhiteAmerican_NHANES_1997 MALE  
          age age_unit weight weight_unit height height_unit disease_state
        <dbl> <chr>     <dbl> <chr>        <dbl> <chr>       <chr>        
      1  29.9 year(s)      70 kg             175 cm          Healthy      
        calculation_methods                                   disease_state_parameters
        <chr>                                                 <chr>                   
      1 SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller <NA>                    
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 2 x 6
        individual_id path                                               value unit 
        <chr>         <chr>                                              <dbl> <chr>
      1 Mouly2002     Organism|Gallbladder|Gallbladder ejection fraction   0.8 <NA> 
      2 Mouly2002     Organism|Liver|EHC continuous fraction               1   <NA> 
        source      description
        <chr>       <chr>      
      1 Publication R24-4081   
      2 Publication R24-4081   
    Code
      print(dfs$expressions, width = Inf)
    Output
      # A tibble: 2 x 2
        individual_id profile             
        <chr>         <chr>               
      1 Mouly2002     CYP1A2|Human|Healthy
      2 Mouly2002     CYP2B6|Human|Healthy

# to_df returns specific tables when requested

    Code
      print(origin_df, width = Inf)
    Output
      # A tibble: 1 x 15
        individual_id name          seed species population         gender   age
        <chr>         <chr>        <dbl> <chr>   <chr>              <chr>  <dbl>
      1 European      European 186687441 Human   European_ICRP_2002 MALE      30
        age_unit weight weight_unit height height_unit disease_state
        <chr>     <dbl> <chr>        <dbl> <chr>       <chr>        
      1 year(s)      NA <NA>            NA <NA>        <NA>         
        calculation_methods                                   disease_state_parameters
        <chr>                                                 <chr>                   
      1 SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller <NA>                    

---

    Code
      print(params_df, width = Inf)
    Output
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, path <chr>, value <dbl>, unit <chr>, source <chr>, description <chr>, source_id <int>

---

    Code
      print(expr_df, width = Inf)
    Output
      # A tibble: 2 x 2
        individual_id profile             
        <chr>         <chr>               
      1 European      CYP1A2|Human|Healthy
      2 European      CYP2B6|Human|Healthy

# to_df handles missing values

    Code
      print(dfs$origin, width = Inf)
    Output
      # A tibble: 1 x 15
        individual_id name     seed species population gender   age age_unit weight
        <chr>         <chr>   <int> <chr>   <chr>      <chr>  <dbl> <chr>     <dbl>
      1 Minimal       Minimal    NA <NA>    <NA>       <NA>      NA <NA>         NA
        weight_unit height height_unit disease_state calculation_methods
        <chr>        <dbl> <chr>       <chr>         <chr>              
      1 <NA>            NA <NA>        <NA>          <NA>               
        disease_state_parameters
        <chr>                   
      1 <NA>                    
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 0 x 7
      # i 7 variables: individual_id <chr>, path <chr>, value <dbl>, unit <chr>, source <chr>, description <chr>, source_id <int>
    Code
      print(dfs$expressions, width = Inf)
    Output
      # A tibble: 0 x 2
      # i 2 variables: individual_id <chr>, profile <chr>

# get_individuals_dfs returns combined data frames from all individuals

    Code
      print(dfs$origin, width = Inf)
    Output
      # A tibble: 2 x 15
        individual_id name            seed species population                gender
        <chr>         <chr>          <dbl> <chr>   <chr>                     <chr> 
      1 Mouly2002     Mouly2002 1300547185 Human   WhiteAmerican_NHANES_1997 MALE  
      2 European      European   186687441 Human   European_ICRP_2002        MALE  
          age age_unit weight weight_unit height height_unit disease_state
        <dbl> <chr>     <dbl> <chr>        <dbl> <chr>       <chr>        
      1  29.9 year(s)      NA <NA>            NA <NA>        <NA>         
      2  30   year(s)      NA <NA>            NA <NA>        <NA>         
        calculation_methods                                   disease_state_parameters
        <chr>                                                 <chr>                   
      1 SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller <NA>                    
      2 SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller <NA>                    
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 2 x 7
        individual_id path                                               value unit 
        <chr>         <chr>                                              <dbl> <chr>
      1 Mouly2002     Organism|Gallbladder|Gallbladder ejection fraction   0.8 <NA> 
      2 Mouly2002     Organism|Liver|EHC continuous fraction               1   <NA> 
        source      description source_id
        <chr>       <chr>           <int>
      1 Publication R24-4081           NA
      2 Publication R24-4081           NA
    Code
      print(dfs$expressions, width = Inf)
    Output
      # A tibble: 4 x 2
        individual_id profile             
        <chr>         <chr>               
      1 Mouly2002     CYP1A2|Human|Healthy
      2 Mouly2002     CYP2B6|Human|Healthy
      3 European      CYP1A2|Human|Healthy
      4 European      CYP2B6|Human|Healthy

# get_individuals_dfs handles empty snapshot

    Code
      print(dfs$origin, width = Inf)
    Output
      # A tibble: 0 x 14
      # i 14 variables: individual_id <chr>, name <chr>, seed <int>, species <chr>, population <chr>, gender <chr>, age <dbl>, age_unit <chr>, weight <dbl>, weight_unit <chr>, height <dbl>, height_unit <chr>, disease_state <chr>, calculation_methods <chr>
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 0 x 4
      # i 4 variables: individual_id <chr>, path <chr>, value <dbl>, unit <chr>
    Code
      print(dfs$expressions, width = Inf)
    Output
      # A tibble: 0 x 2
      # i 2 variables: individual_id <chr>, profile <chr>

# get_origin_df returns only origin data

    Code
      print(origin_df, width = Inf)
    Output
      # A tibble: 1 x 15
        individual_id name            seed species population                gender
        <chr>         <chr>          <dbl> <chr>   <chr>                     <chr> 
      1 Mouly2002     Mouly2002 1300547185 Human   WhiteAmerican_NHANES_1997 MALE  
          age age_unit weight weight_unit height height_unit disease_state
        <dbl> <chr>     <dbl> <chr>        <dbl> <chr>       <chr>        
      1  29.9 year(s)      NA <NA>            NA <NA>        <NA>         
        calculation_methods                                   disease_state_parameters
        <chr>                                                 <chr>                   
      1 SurfaceAreaPlsInt_VAR1; Body surface area - Mosteller <NA>                    

# get_parameters_df returns only parameter data

    Code
      print(param_df, width = Inf)
    Output
      # A tibble: 1 x 6
        individual_id path                                               value unit 
        <chr>         <chr>                                              <dbl> <chr>
      1 Mouly2002     Organism|Gallbladder|Gallbladder ejection fraction   0.8 <NA> 
        source      description
        <chr>       <chr>      
      1 Publication R24-4081   

# get_expressions_df returns only expression data

    Code
      print(expr_df, width = Inf)
    Output
      # A tibble: 2 x 2
        individual_id profile             
        <chr>         <chr>               
      1 Mouly2002     CYP1A2|Human|Healthy
      2 Mouly2002     CYP2B6|Human|Healthy

