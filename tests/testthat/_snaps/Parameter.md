# Parameter print method returns formatted output

    Code
      print(param)
    Output
      
      -- Parameter: Organism|Liver|Volume 
      * Value: 1.5
      * Unit: L
      * Source: Publication
      * Description: Test reference

# Parameter handles table-based parameters correctly

    Code
      str(table_param$table_formula)
    Output
      List of 8
       $ Name            : chr "Fraction (dose)"
       $ XName           : chr "Time"
       $ XDimension      : chr "Time"
       $ XUnit           : chr "h"
       $ YName           : chr "Fraction (dose)"
       $ YDimension      : chr "Dimensionless"
       $ UseDerivedValues: logi TRUE
       $ Points          :List of 6
        ..$ :List of 3
        .. ..$ X            : num 0
        .. ..$ Y            : num 0
        .. ..$ RestartSolver: logi FALSE
        ..$ :List of 3
        .. ..$ X            : num 0.5
        .. ..$ Y            : num 0.2
        .. ..$ RestartSolver: logi FALSE
        ..$ :List of 3
        .. ..$ X            : num 1
        .. ..$ Y            : num 0.4
        .. ..$ RestartSolver: logi FALSE
        ..$ :List of 3
        .. ..$ X            : num 2
        .. ..$ Y            : num 0.6
        .. ..$ RestartSolver: logi FALSE
        ..$ :List of 3
        .. ..$ X            : num 4
        .. ..$ Y            : num 0.8
        .. ..$ RestartSolver: logi FALSE
        ..$ :List of 3
        .. ..$ X            : num 8
        .. ..$ Y            : num 1
        .. ..$ RestartSolver: logi FALSE

---

    Code
      cat("First point:\n")
    Output
      First point:
    Code
      str(table_param$table_formula$Points[[1]])
    Output
      List of 3
       $ X            : num 0
       $ Y            : num 0
       $ RestartSolver: logi FALSE
    Code
      cat("\nLast point:\n")
    Output
      
      Last point:
    Code
      str(table_param$table_formula$Points[[6]])
    Output
      List of 3
       $ X            : num 8
       $ Y            : num 1
       $ RestartSolver: logi FALSE

---

    Code
      cat("X values: ", glue::glue_collapse(x_values, sep = ", "), "\n")
    Output
      X values:  0, 0.5, 1, 2, 4, 8 
    Code
      cat("Y values: ", glue::glue_collapse(y_values, sep = ", "), "\n")
    Output
      Y values:  0, 0.2, 0.4, 0.6, 0.8, 1 

---

    Code
      print(table_param)
    Output
      
      -- Parameter: Fraction (dose) 
      Time (h)                  | Fraction (dose)          
      --------------------------|--------------------------
      0                         | 0                        
      0.5                       | 0.2                      
      1                         | 0.4                      
      2                         | 0.6                      
      4                         | 0.8                      
      8                         | 1                        

---

    Code
      str(df_result$parameter)
    Output
      tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
       $ path       : chr "Fraction (dose)"
       $ value      : chr "Table"
       $ unit       : chr NA
       $ source     : chr NA
       $ description: chr NA
       $ source_id  : int NA

---

    Code
      str(df_result$points)
    Output
      'data.frame':	6 obs. of  6 variables:
       $ parameter_path: chr  "Fraction (dose)" "Fraction (dose)" "Fraction (dose)" "Fraction (dose)" ...
       $ x             : num  0 0.5 1 2 4 8
       $ y             : num  0 0.2 0.4 0.6 0.8 1
       $ x_name        : chr  "Time" "Time" "Time" "Time" ...
       $ y_name        : chr  "Fraction (dose)" "Fraction (dose)" "Fraction (dose)" "Fraction (dose)" ...
       $ x_unit        : chr  "h" "h" "h" "h" ...

# create_parameter creates table parameters correctly

    Code
      str(table_param$data)
    Output
      List of 3
       $ Path        : chr "Fraction (dose)"
       $ Value       : num 0
       $ TableFormula:List of 8
        ..$ Name            : chr "Fraction (dose)"
        ..$ XName           : chr "Time"
        ..$ YName           : chr "Fraction (dose)"
        ..$ XDimension      : chr "Time"
        ..$ YDimension      : chr "Dimensionless"
        ..$ UseDerivedValues: logi TRUE
        ..$ Points          :List of 4
        .. ..$ :List of 3
        .. .. ..$ X            : num 0
        .. .. ..$ Y            : num 0
        .. .. ..$ RestartSolver: logi FALSE
        .. ..$ :List of 3
        .. .. ..$ X            : num 1
        .. .. ..$ Y            : num 0.5
        .. .. ..$ RestartSolver: logi FALSE
        .. ..$ :List of 3
        .. .. ..$ X            : num 2
        .. .. ..$ Y            : num 0.8
        .. .. ..$ RestartSolver: logi FALSE
        .. ..$ :List of 3
        .. .. ..$ X            : num 4
        .. .. ..$ Y            : num 1
        .. .. ..$ RestartSolver: logi FALSE
        ..$ XUnit           : chr "h"

---

    Code
      print(table_param)
    Output
      
      -- Parameter: Fraction (dose) 
      Time (h)                  | Fraction (dose)          
      --------------------------|--------------------------
      0                         | 0                        
      1                         | 0.5                      
      2                         | 0.8                      
      4                         | 1                        

# to_df method correctly handles table parameters

    Code
      print(result$parameter)
    Output
      # A tibble: 1 x 6
        path                value unit  source description source_id
        <chr>               <chr> <chr> <chr>  <chr>           <int>
      1 Dissolution Profile Table <NA>  <NA>   <NA>               NA

---

    Code
      print(result$points)
    Output
             parameter_path    x   y x_name            y_name x_unit
      1 Dissolution Profile 0.00 0.0   Time Fraction Released      h
      2 Dissolution Profile 0.25 0.1   Time Fraction Released      h
      3 Dissolution Profile 0.50 0.3   Time Fraction Released      h
      4 Dissolution Profile 1.00 0.6   Time Fraction Released      h
      5 Dissolution Profile 2.00 0.9   Time Fraction Released      h
      6 Dissolution Profile 3.00 1.0   Time Fraction Released      h

---

    Code
      str(plot_data)
    Output
      'data.frame':	6 obs. of  6 variables:
       $ parameter_path: chr  "Dissolution Profile" "Dissolution Profile" "Dissolution Profile" "Dissolution Profile" ...
       $ x             : num  0 0.25 0.5 1 2 3
       $ y             : num  0 0.1 0.3 0.6 0.9 1
       $ x_name        : chr  "Time" "Time" "Time" "Time" ...
       $ y_name        : chr  "Fraction Released" "Fraction Released" "Fraction Released" "Fraction Released" ...
       $ x_unit        : chr  "h" "h" "h" "h" ...

---

    Code
      cat("X range:", min(plot_data$x), "to", max(plot_data$x), "\n")
    Output
      X range: 0 to 3 
    Code
      cat("Y range:", min(plot_data$y), "to", max(plot_data$y), "\n")
    Output
      Y range: 0 to 1 

# Regular parameters handle to_df correctly after table support added

    Code
      print(df_result)
    Output
      # A tibble: 1 x 4
        path          value unit  source
        <chr>         <dbl> <chr> <chr> 
      1 Regular Param    42 mg    Test  

