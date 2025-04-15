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

# load_formulations function works correctly

    Code
      print(formulations)
    Message
      
      -- Formulations (2) ------------------------------------------------------------
      * Test Tablet (Weibull)
      * Oral Solution (Dissolved)

---

    Code
      print(empty_formulations)
    Message
      
      -- Formulations (0) ------------------------------------------------------------
      i No formulations found

---

    Code
      print(null_formulations)
    Message
      
      -- Formulations (0) ------------------------------------------------------------
      i No formulations found

# formulation to_df method works correctly

    Code
      print(all_df$basic)
    Output
      # A tibble: 1 x 4
        formulation_id name        formulation_type           formulation_type_human
        <chr>          <chr>       <chr>                      <chr>                 
      1 Test Tablet    Test Tablet Formulation_Tablet_Weibull Weibull               

---

    Code
      print(all_df$parameters)
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
      print(dissolved_df$basic)
    Output
      # A tibble: 1 x 4
        formulation_id name          formulation_type      formulation_type_human
        <chr>          <chr>         <chr>                 <chr>                 
      1 Oral Solution  Oral Solution Formulation_Dissolved Dissolved             

---

    Code
      print(dissolved_df$parameters)
    Output
      # A tibble: 0 x 4
      # i 4 variables: formulation_id <chr>, name <chr>, value <dbl>, unit <chr>

