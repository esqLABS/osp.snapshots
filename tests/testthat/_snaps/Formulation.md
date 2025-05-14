# Formulation print method returns formatted output

    Code
      print(formulation1)
    Output
      
      -- Formulation: Tablet (Dormicum) ----------------------------------------------
      * Type: Weibull
      
      -- Parameters --
      
      * Dissolution time (50% dissolved): 0.0107481462 min
      * Lag time: 12 min
      * Dissolution shape: 4.3802943225
      * Use as suspension: 1

---

    Code
      print(formulation2)
    Output
      
      -- Formulation: Oral solution --------------------------------------------------
      * Type: Dissolved

# Formulation handles table-based formulations correctly

    Code
      print(table_formulation)
    Output
      
      -- Formulation: form-table -----------------------------------------------------
      * Type: Table
      
      -- Parameters --
      
      * Fraction (dose): 0
      * Release profile:
      
          Time [h]     | Fraction (dose)
          -------------|----------------
          0.00         | 0.00
          0.10         | 0.10
          0.50         | 0.60
          1.00         | 0.70
          3.00         | 0.80
          7.00         | 0.90
      
      * Use as suspension: 1

---

    Code
      table_formulation$to_df()
    Output
      $formulations
      # A tibble: 1 x 4
        formulation_id name       formulation       formulation_type
        <chr>          <chr>      <chr>             <chr>           
      1 form-table     form-table Formulation_Table Table           
      
      $formulations_parameters
      # A tibble: 8 x 11
        formulation_id name      value unit  is_table_point x_value y_value table_name
        <chr>          <chr>     <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
      1 form-table     Fraction~     0 <NA>  FALSE             NA      NA   <NA>      
      2 form-table     Fraction~    NA <NA>  TRUE               0       0   Time      
      3 form-table     Fraction~    NA <NA>  TRUE               0.1     0.1 Time      
      4 form-table     Fraction~    NA <NA>  TRUE               0.5     0.6 Time      
      5 form-table     Fraction~    NA <NA>  TRUE               1       0.7 Time      
      6 form-table     Fraction~    NA <NA>  TRUE               3       0.8 Time      
      7 form-table     Fraction~    NA <NA>  TRUE               7       0.9 Time      
      8 form-table     Use as s~     1 <NA>  FALSE             NA      NA   <NA>      
      # i 3 more variables: source <chr>, description <chr>, source_id <int>
      

# Formulation fields can be modified through active bindings

    Code
      print(test_formulation)
    Output
      
      -- Formulation: Modified Formulation -------------------------------------------
      * Type: Dissolved
      
      -- Parameters --
      
      * New Parameter: 100 mg

# formulation to_df method works correctly

    Code
      all_df
    Output
      $formulations
      # A tibble: 1 x 4
        formulation_id    name              formulation               formulation_type
        <chr>             <chr>             <chr>                     <chr>           
      1 Tablet (Dormicum) Tablet (Dormicum) Formulation_Tablet_Weibu~ Weibull         
      
      $formulations_parameters
      # A tibble: 4 x 11
        formulation_id   name    value unit  is_table_point x_value y_value table_name
        <chr>            <chr>   <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
      1 Tablet (Dormicu~ Diss~  0.0107 min   FALSE               NA      NA <NA>      
      2 Tablet (Dormicu~ Lag ~ 12      min   FALSE               NA      NA <NA>      
      3 Tablet (Dormicu~ Diss~  4.38   <NA>  FALSE               NA      NA <NA>      
      4 Tablet (Dormicu~ Use ~  1      <NA>  FALSE               NA      NA <NA>      
      # i 3 more variables: source <chr>, description <chr>, source_id <int>
      

---

    Code
      params_df
    Output
      # A tibble: 4 x 11
        formulation_id   name    value unit  is_table_point x_value y_value table_name
        <chr>            <chr>   <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
      1 Tablet (Dormicu~ Diss~  0.0107 min   FALSE               NA      NA <NA>      
      2 Tablet (Dormicu~ Lag ~ 12      min   FALSE               NA      NA <NA>      
      3 Tablet (Dormicu~ Diss~  4.38   <NA>  FALSE               NA      NA <NA>      
      4 Tablet (Dormicu~ Use ~  1      <NA>  FALSE               NA      NA <NA>      
      # i 3 more variables: source <chr>, description <chr>, source_id <int>

---

    Code
      second_df
    Output
      $formulations
      # A tibble: 1 x 4
        formulation_id name          formulation           formulation_type
        <chr>          <chr>         <chr>                 <chr>           
      1 Oral solution  Oral solution Formulation_Dissolved Dissolved       
      
      $formulations_parameters
      # A tibble: 0 x 11
      # i 11 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>,
      #   is_table_point <lgl>, x_value <dbl>, y_value <dbl>, table_name <chr>,
      #   source <chr>, description <chr>, source_id <int>
      

# to_df correctly extracts table parameter points

    Code
      dfs
    Output
      $formulations
      # A tibble: 1 x 4
        formulation_id name       formulation       formulation_type
        <chr>          <chr>      <chr>             <chr>           
      1 form-table     form-table Formulation_Table Table           
      
      $formulations_parameters
      # A tibble: 8 x 11
        formulation_id name      value unit  is_table_point x_value y_value table_name
        <chr>          <chr>     <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
      1 form-table     Fraction~     0 <NA>  FALSE             NA      NA   <NA>      
      2 form-table     Fraction~    NA <NA>  TRUE               0       0   Time      
      3 form-table     Fraction~    NA <NA>  TRUE               0.1     0.1 Time      
      4 form-table     Fraction~    NA <NA>  TRUE               0.5     0.6 Time      
      5 form-table     Fraction~    NA <NA>  TRUE               1       0.7 Time      
      6 form-table     Fraction~    NA <NA>  TRUE               3       0.8 Time      
      7 form-table     Fraction~    NA <NA>  TRUE               7       0.9 Time      
      8 form-table     Use as s~     1 <NA>  FALSE             NA      NA   <NA>      
      # i 3 more variables: source <chr>, description <chr>, source_id <int>
      

# Table formulation correctly extracts parameter table points from test_snapshot

    Code
      print(dfs$formulations, n = Inf)
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
      print(dfs$formulations_parameters, n = Inf)
    Output
      # A tibble: 28 x 11
         formulation_id name     value unit  is_table_point x_value y_value table_name
         <chr>          <chr>    <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
       1 Tablet (Dormi~ Diss~   0.0107 min   FALSE             NA      NA   <NA>      
       2 Tablet (Dormi~ Lag ~  12      min   FALSE             NA      NA   <NA>      
       3 Tablet (Dormi~ Diss~   4.38   <NA>  FALSE             NA      NA   <NA>      
       4 Tablet (Dormi~ Use ~   1      <NA>  FALSE             NA      NA   <NA>      
       5 form_Lint80    Diss~ 240      min   FALSE             NA      NA   <NA>      
       6 form_Lint80    Lag ~   0      min   FALSE             NA      NA   <NA>      
       7 form_Lint80    Use ~   1      <NA>  FALSE             NA      NA   <NA>      
       8 form-partdiss  Thic~  30      µm    FALSE             NA      NA   <NA>      
       9 form-partdiss  Type~   0      <NA>  FALSE             NA      NA   <NA>      
      10 form-partdiss  Part~  10      µm    FALSE             NA      NA   <NA>      
      11 form-table     Frac~   0      <NA>  FALSE             NA      NA   <NA>      
      12 form-table     Frac~  NA      <NA>  TRUE               0       0   Time      
      13 form-table     Frac~  NA      <NA>  TRUE               0.1     0.1 Time      
      14 form-table     Frac~  NA      <NA>  TRUE               0.5     0.6 Time      
      15 form-table     Frac~  NA      <NA>  TRUE               1       0.7 Time      
      16 form-table     Frac~  NA      <NA>  TRUE               3       0.8 Time      
      17 form-table     Frac~  NA      <NA>  TRUE               7       0.9 Time      
      18 form-table     Use ~   1      <NA>  FALSE             NA      NA   <NA>      
      19 form-ZO        End ~  60      min   FALSE             NA      NA   <NA>      
      20 form-FO        t1/2    0.01   min   FALSE             NA      NA   <NA>      
      21 form-partdiss2 Thic~  23      µm    FALSE             NA      NA   <NA>      
      22 form-partdiss2 Part~   0      <NA>  FALSE             NA      NA   <NA>      
      23 form-partdiss2 Type~   1      <NA>  FALSE             NA      NA   <NA>      
      24 form-partdiss2 Part~  10      µm    FALSE             NA      NA   <NA>      
      25 form-partdiss2 Part~   3      µm    FALSE             NA      NA   <NA>      
      26 form-partdiss2 Numb~   3      <NA>  FALSE             NA      NA   <NA>      
      27 form-partdiss2 Part~   1      µm    FALSE             NA      NA   <NA>      
      28 form-partdiss2 Part~  19      µm    FALSE             NA      NA   <NA>      
      # i 3 more variables: source <chr>, description <chr>, source_id <int>

# get_formulations_dfs returns correct data frames

    Code
      dfs
    Output
      $formulations
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
      
      $formulations_parameters
      # A tibble: 28 x 11
         formulation_id  name    value unit  is_table_point x_value y_value table_name
         <chr>           <chr>   <dbl> <chr> <lgl>            <dbl>   <dbl> <chr>     
       1 Tablet (Dormic~ Diss~ 1.07e-2 min   FALSE               NA      NA <NA>      
       2 Tablet (Dormic~ Lag ~ 1.2 e+1 min   FALSE               NA      NA <NA>      
       3 Tablet (Dormic~ Diss~ 4.38e+0 <NA>  FALSE               NA      NA <NA>      
       4 Tablet (Dormic~ Use ~ 1   e+0 <NA>  FALSE               NA      NA <NA>      
       5 form_Lint80     Diss~ 2.4 e+2 min   FALSE               NA      NA <NA>      
       6 form_Lint80     Lag ~ 0       min   FALSE               NA      NA <NA>      
       7 form_Lint80     Use ~ 1   e+0 <NA>  FALSE               NA      NA <NA>      
       8 form-partdiss   Thic~ 3   e+1 µm    FALSE               NA      NA <NA>      
       9 form-partdiss   Type~ 0       <NA>  FALSE               NA      NA <NA>      
      10 form-partdiss   Part~ 1   e+1 µm    FALSE               NA      NA <NA>      
      # i 18 more rows
      # i 3 more variables: source <chr>, description <chr>, source_id <int>
      

---

    Code
      dfs_empty
    Output
      $formulations
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, formulation <chr>,
      #   formulation_type <chr>
      
      $formulations_parameters
      # A tibble: 0 x 8
      # i 8 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>,
      #   is_table_point <lgl>, x_value <dbl>, y_value <dbl>, table_name <chr>
      

