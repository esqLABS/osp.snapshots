# get_formulations_dfs returns combined data frames from all formulations

    Code
      print(dfs$basic, width = Inf)
    Output
      # A tibble: 4 x 4
        formulation_id       name                 formulation_type          
        <chr>                <chr>                <chr>                     
      1 Test Tablet          Test Tablet          Formulation_Tablet_Weibull
      2 Oral Solution        Oral Solution        Formulation_Dissolved     
      3 Custom Release       Custom Release       Formulation_Table         
      4 Particle Formulation Particle Formulation Formulation_Particles     
        formulation_type_human
        <chr>                 
      1 Weibull               
      2 Dissolved             
      3 Table                 
      4 Particle              
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 9 x 4
        formulation_id       name                               value unit 
        <chr>                <chr>                              <dbl> <chr>
      1 Test Tablet          Dissolution time (50% dissolved)   60    min  
      2 Test Tablet          Lag time                           10    min  
      3 Test Tablet          Dissolution shape                   0.92 <NA> 
      4 Test Tablet          Use as suspension                   1    <NA> 
      5 Custom Release       Use as suspension                   1    <NA> 
      6 Custom Release       Fraction (dose)                     0    <NA> 
      7 Particle Formulation Thickness (unstirred water layer)  30    µm   
      8 Particle Formulation Type of particle size distribution  0    <NA> 
      9 Particle Formulation Particle radius (mean)             10    µm   

# get_formulations_dfs handles snapshots with no formulations

    Code
      print(dfs$basic, width = Inf)
    Output
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, formulation_type <chr>, formulation_type_human <chr>
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>

# to_df returns specific tables when requested

    Code
      print(params_df, width = Inf)
    Output
      # A tibble: 4 x 4
        formulation_id name                             value unit 
        <chr>          <chr>                            <dbl> <chr>
      1 Test Tablet    Dissolution time (50% dissolved) 60    min  
      2 Test Tablet    Lag time                         10    min  
      3 Test Tablet    Dissolution shape                 0.92 <NA> 
      4 Test Tablet    Use as suspension                 1    <NA> 

---

    Code
      print(all_dfs$basic, width = Inf)
    Output
      # A tibble: 1 x 4
        formulation_id name        formulation_type           formulation_type_human
        <chr>          <chr>       <chr>                      <chr>                 
      1 Test Tablet    Test Tablet Formulation_Tablet_Weibull Weibull               

# to_df handles formulations without parameters

    Code
      print(dfs$basic, width = Inf)
    Output
      # A tibble: 1 x 4
        formulation_id name          formulation_type      formulation_type_human
        <chr>          <chr>         <chr>                 <chr>                 
      1 Oral Solution  Oral Solution Formulation_Dissolved Dissolved             
    Code
      print(dfs$parameters, width = Inf)
    Output
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>

