# Population to_df returns correct structure

    Code
      dfs
    Output
      $characteristics
      # A tibble: 1 x 19
        population_id name      seed number_of_individuals proportion_of_females
        <chr>         <chr>    <dbl>                 <dbl>                 <dbl>
      1 test_pop      test_pop 12345                   100                    50
      # i 14 more variables: source_population <chr>, individual_name <chr>,
      #   age_min <dbl>, age_max <dbl>, age_unit <chr>, weight_min <dbl>,
      #   weight_max <dbl>, weight_unit <chr>, height_min <dbl>, height_max <dbl>,
      #   height_unit <chr>, bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>
      
      $parameters
      # A tibble: 2 x 10
        population_id parameter_type parameter  seed distribution_type statistic value
        <chr>         <chr>          <chr>     <dbl> <chr>             <chr>     <dbl>
      1 test_pop      Advanced       Test Par~ 67890 Normal            Mean         10
      2 test_pop      DiseaseState   eGFR         NA <NA>              <NA>         45
      # i 3 more variables: unit <chr>, source <chr>, description <chr>
      

# get_populations_dfs returns correct structure

    Code
      dfs
    Output
      $characteristics
      # A tibble: 1 x 19
        population_id name      seed number_of_individuals proportion_of_females
        <chr>         <chr>    <dbl>                 <dbl>                 <dbl>
      1 test_pop      test_pop 12345                   100                    50
      # i 14 more variables: source_population <chr>, individual_name <chr>,
      #   age_min <dbl>, age_max <dbl>, age_unit <chr>, weight_min <dbl>,
      #   weight_max <dbl>, weight_unit <chr>, height_min <dbl>, height_max <dbl>,
      #   height_unit <chr>, bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>
      
      $parameters
      # A tibble: 2 x 10
        population_id parameter_type parameter  seed distribution_type statistic value
        <chr>         <chr>          <chr>     <dbl> <chr>             <chr>     <dbl>
      1 test_pop      Advanced       Test Par~ 67890 Normal            Mean         10
      2 test_pop      DiseaseState   eGFR         NA <NA>              <NA>         45
      # i 3 more variables: unit <chr>, source <chr>, description <chr>
      

# get_populations_dfs handles empty snapshot

    Code
      dfs
    Output
      $characteristics
      # A tibble: 0 x 19
      # i 19 variables: population_id <chr>, name <chr>, seed <int>,
      #   number_of_individuals <int>, proportion_of_females <dbl>,
      #   source_population <chr>, individual_name <chr>, age_min <dbl>,
      #   age_max <dbl>, age_unit <chr>, weight_min <dbl>, weight_max <dbl>,
      #   weight_unit <chr>, height_min <dbl>, height_max <dbl>, height_unit <chr>,
      #   bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>
      
      $parameters
      # A tibble: 0 x 10
      # i 10 variables: population_id <chr>, parameter_type <chr>, parameter <chr>,
      #   seed <int>, distribution_type <chr>, statistic <chr>, value <dbl>,
      #   unit <chr>, source <chr>, description <chr>
      

