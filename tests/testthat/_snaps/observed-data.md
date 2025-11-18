# DataSet to tibble conversion works correctly

    Code
      df
    Output
      # A tibble: 10 x 30
         name           xValues yValues yErrorValues xDimension xUnit yDimension yUnit
         <chr>            <dbl>   <dbl>        <dbl> <chr>      <chr> <chr>      <chr>
       1 Backman 1996 ~     0.5 0.00859           NA Time       h     Concentra~ mg/l 
       2 Backman 1996 ~     1   0.0466            NA Time       h     Concentra~ mg/l 
       3 Backman 1996 ~     1.5 0.0435            NA Time       h     Concentra~ mg/l 
       4 Backman 1996 ~     2   0.0374            NA Time       h     Concentra~ mg/l 
       5 Backman 1996 ~     3   0.0237            NA Time       h     Concentra~ mg/l 
       6 Backman 1996 ~     4   0.0171            NA Time       h     Concentra~ mg/l 
       7 Backman 1996 ~     5   0.0105            NA Time       h     Concentra~ mg/l 
       8 Backman 1996 ~     6   0.00749           NA Time       h     Concentra~ mg/l 
       9 Backman 1996 ~     8   0.00506           NA Time       h     Concentra~ mg/l 
      10 Backman 1996 ~    10   0.00330           NA Time       h     Concentra~ mg/l 
      # i 22 more variables: yErrorType <chr>, yErrorUnit <chr>, molWeight <dbl>,
      #   lloq <dbl>, `DB Version` <chr>, ID <chr>, `Study Id` <chr>,
      #   Reference <chr>, Source <chr>, Grouping <chr>, `Data type` <chr>, N <chr>,
      #   Molecule <chr>, Species <chr>, Organ <chr>, Compartment <chr>, Route <chr>,
      #   Dose <chr>, `Times of Administration [h]` <chr>, Formulation <chr>,
      #   `Food state` <chr>, Comment <chr>

# loadDataSetFromSnapshot handles empty data

    Code
      df
    Output
      # A tibble: 0 x 12
      # i 12 variables: name <chr>, xValues <dbl>, yValues <dbl>, yErrorValues <dbl>,
      #   xDimension <chr>, xUnit <chr>, yDimension <chr>, yUnit <chr>,
      #   yErrorType <chr>, yErrorUnit <chr>, molWeight <dbl>, lloq <dbl>

