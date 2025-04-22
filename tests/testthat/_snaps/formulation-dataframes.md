# get_formulations_dfs returns combined data frames from all formulations

    Code
      dfs
    Output
      $basic
      # A tibble: 4 x 4
        formulation_id       name              formulation_type formulation_type_human
        <chr>                <chr>             <chr>            <chr>                 
      1 Test Tablet          Test Tablet       Formulation_Tab~ Weibull               
      2 Oral Solution        Oral Solution     Formulation_Dis~ Dissolved             
      3 Custom Release       Custom Release    Formulation_Tab~ Table                 
      4 Particle Formulation Particle Formula~ Formulation_Par~ Particle              
      
      $parameters
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
      dfs
    Output
      $basic
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, formulation_type <chr>,
      #   formulation_type_human <chr>
      
      $parameters
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>
      

# to_df returns specific tables when requested

    Code
      params_df
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
      all_dfs
    Output
      $basic
      # A tibble: 1 x 4
        formulation_id name        formulation_type           formulation_type_human
        <chr>          <chr>       <chr>                      <chr>                 
      1 Test Tablet    Test Tablet Formulation_Tablet_Weibull Weibull               
      
      $parameters
      # A tibble: 4 x 4
        formulation_id name                             value unit 
        <chr>          <chr>                            <dbl> <chr>
      1 Test Tablet    Dissolution time (50% dissolved) 60    min  
      2 Test Tablet    Lag time                         10    min  
      3 Test Tablet    Dissolution shape                 0.92 <NA> 
      4 Test Tablet    Use as suspension                 1    <NA> 
      

# to_df handles formulations without parameters

    Code
      dfs
    Output
      $basic
      # A tibble: 1 x 4
        formulation_id name          formulation_type      formulation_type_human
        <chr>          <chr>         <chr>                 <chr>                 
      1 Oral Solution  Oral Solution Formulation_Dissolved Dissolved             
      
      $parameters
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>
      

