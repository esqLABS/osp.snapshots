# Formulation print method returns formatted output

    Code
      print(test_formulation)
    Output
      
      -- Formulation: Test Tablet ----------------------------------------------------
      * Type: Weibull
      
      -- Parameters --
      
      * Dissolution time (50% dissolved): 60 min
      * Lag time: 10 min
      * Dissolution shape: 0.92
      * Use as suspension: 1

---

    Code
      print(dissolved_formulation)
    Output
      
      -- Formulation: Oral Solution --------------------------------------------------
      * Type: Dissolved

# Formulation handles table-based formulations correctly

    Code
      print(table_formulation)
    Output
      
      -- Formulation: Custom Release -------------------------------------------------
      * Type: Table
      
      -- Parameters --
      
      * Use as suspension: 1
      * Fraction (dose): 0
      * Release profile:
      
          Time [h]     | Fraction (dose)
          -------------|----------------
          0.00         | 0.00
          0.50         | 0.20
          1.00         | 0.40
          2.00         | 0.60
          4.00         | 0.80
          8.00         | 1.00
      

# Formulation fields can be modified through active bindings

    Code
      print(test_formulation)
    Output
      
      -- Formulation: Modified Tablet ------------------------------------------------
      * Type: Dissolved
      
      -- Parameters --
      
      * New Parameter: 100 mg

# create_formulation function works correctly

    Code
      print(dissolved)
    Output
      
      -- Formulation: Oral Solution --------------------------------------------------
      * Type: Dissolved

---

    Code
      print(tablet)
    Output
      
      -- Formulation: Tablet ---------------------------------------------------------
      * Type: Weibull
      
      -- Parameters --
      
      * Dissolution time (50% dissolved): 60 min
      * Lag time: 10 min
      * Dissolution shape: 0.92
      * Use as suspension: 1

# formulation to_df method works correctly

    Code
      all_df
    Output
      $formulations
      # A tibble: 1 x 4
        formulation_id name        formulation                formulation_type
        <chr>          <chr>       <chr>                      <chr>           
      1 Test Tablet    Test Tablet Formulation_Tablet_Weibull Weibull         
      
      $formulations_parameters
      # A tibble: 4 x 4
        formulation_id name                             value unit 
        <chr>          <chr>                            <dbl> <chr>
      1 Test Tablet    Dissolution time (50% dissolved) 60    min  
      2 Test Tablet    Lag time                         10    min  
      3 Test Tablet    Dissolution shape                 0.92 <NA> 
      4 Test Tablet    Use as suspension                 1    <NA> 
      

---

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
      dissolved_df
    Output
      $formulations
      # A tibble: 1 x 4
        formulation_id name          formulation           formulation_type
        <chr>          <chr>         <chr>                 <chr>           
      1 Oral Solution  Oral Solution Formulation_Dissolved Dissolved       
      
      $formulations_parameters
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>
      

# get_formulations_dfs returns correct data frames

    Code
      dfs$formulations
    Output
      # A tibble: 9 x 4
        formulation_id    name              formulation               formulation_type
        <chr>             <chr>             <chr>                     <chr>           
      1 Tablet (Dormicum) Tablet (Dormicum) Formulation_Tablet_Weibu~ Weibull         
      2 Oral solution     Oral solution     Formulation_Dissolved     Dissolved       
      3 form_dissolved    form_dissolved    Formulation_Dissolved     Dissolved       
      4 form_Lint80       form_Lint80       Formulation_Tablet_Lint80 Lint80          
      5 form-partdiss     form-partdiss     Formulation_Particles     Particle        
      6 form-table        form-table        Formulation_Table         Table           
      7 form-ZO           form-ZO           Formulation_ZeroOrder     Zero Order      
      8 form-FO           form-FO           Formulation_FirstOrder    First Order     
      9 form-partdiss2    form-partdiss2    Formulation_Particles     Particle        

---

    Code
      dfs$formulations_parameters
    Output
      # A tibble: 22 x 4
         formulation_id    name                                  value unit 
         <chr>             <chr>                                 <dbl> <chr>
       1 Tablet (Dormicum) Dissolution time (50% dissolved)     0.0107 min  
       2 Tablet (Dormicum) Lag time                            12      min  
       3 Tablet (Dormicum) Dissolution shape                    4.38   <NA> 
       4 Tablet (Dormicum) Use as suspension                    1      <NA> 
       5 form_Lint80       Dissolution time (80% dissolved)   240      min  
       6 form_Lint80       Lag time                             0      min  
       7 form_Lint80       Use as suspension                    1      <NA> 
       8 form-partdiss     Thickness (unstirred water layer)   30      µm   
       9 form-partdiss     Type of particle size distribution   0      <NA> 
      10 form-partdiss     Particle radius (mean)              10      µm   
      # i 12 more rows

---

    Code
      dfs_empty$formulations
    Output
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, formulation <chr>,
      #   formulation_type <chr>

---

    Code
      dfs_empty$formulations_parameters
    Output
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>

