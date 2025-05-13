# Population print method returns formatted output

    Code
      print(complete_population)
    Message
      
      -- Population: Test Population (Seed: 12345) --
      
      Individual name: European Reference
      Source Population: European_ICRP_2002
      Number of individuals: 100
      Proportion of females: 50%
      Age range: 20 - 60 year(s)
      Weight range: 50 - 90 kg
      Height range: 150 - 190 cm
      BMI range: 18.5 - 30 kg/m²
      eGFR range: 60 - 120 ml/min/1.73m²
      
      -- Advanced Parameters 
      1 advanced parameters defined

---

    Code
      print(minimal_population)
    Message
      
      -- Population: Minimal Population --
      
      Number of individuals: 10
      Proportion of females: 0%
      Age range: 30 - 40 year(s)

# AdvancedParameter class works correctly

    Code
      print(advanced_param)
    Message
      Parameter: Modified Parameter
      Distribution type: LogNormal
      Seed: 98765
      Mean: 1.5 l
      Geometric SD: 1.2

# get_populations_dfs returns correct data frames

    Code
      dfs$populations
    Output
      # A tibble: 6 x 22
        population_id name         seed number_of_individuals proportion_of_females
        <chr>         <chr>       <int>                 <int>                 <dbl>
      1 pop_1         pop_1   202395203                   100                    50
      2 pop2          pop2  -1746093953                    10                    50
      3 pop3          pop3   2040342218                    10                     2
      4 pop4          pop4    235227359                    10                    50
      5 pop6          pop6    324184656                    15                    50
      6 pop7          pop7    486878578                    12                    50
      # i 17 more variables: source_population <chr>, individual_name <chr>,
      #   age_min <dbl>, age_max <dbl>, age_unit <chr>, weight_min <dbl>,
      #   weight_max <dbl>, weight_unit <chr>, height_min <dbl>, height_max <dbl>,
      #   height_unit <chr>, bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>,
      #   egfr_min <dbl>, egfr_max <dbl>, egfr_unit <chr>

---

    Code
      dfs$populations_parameters
    Output
      # A tibble: 28 x 9
         population_id parameter        seed distribution_type statistic   value unit 
         <chr>         <chr>           <int> <chr>             <chr>       <dbl> <chr>
       1 pop_1         CYP3A4|t1/2 ~  2.02e8 Normal            Mean      2.3 e+1 h    
       2 pop_1         CYP3A4|t1/2 ~  2.02e8 Normal            Deviation 1.2 e+1 h    
       3 pop_1         Organism|Bon~  2.03e8 Discrete          Mean      1.14e-4 l/min
       4 pop_1         Organism|Bon~  2.03e8 Uniform           Minimum   1.2 e+1 <NA> 
       5 pop_1         Organism|Bon~  2.03e8 Uniform           Maximum   1.4 e+1 <NA> 
       6 pop_1         Organism|Gal~  2.03e8 Discrete          Mean      1.97e+1 min  
       7 pop2          Organism|pH ~ -1.75e9 LogNormal         Mean      7   e+0 <NA> 
       8 pop2          Organism|pH ~ -1.75e9 LogNormal         Geometri~ 1   e+0 <NA> 
       9 pop2          Organism|Vf ~ -1.75e9 Uniform           Minimum   0       <NA> 
      10 pop2          Organism|Vf ~ -1.75e9 Uniform           Maximum   1   e+0 <NA> 
      # i 18 more rows
      # i 2 more variables: source <chr>, description <chr>

---

    Code
      dfs_empty$populations
    Output
      # A tibble: 0 x 22
      # i 22 variables: population_id <chr>, name <chr>, seed <int>,
      #   number_of_individuals <int>, proportion_of_females <dbl>,
      #   source_population <chr>, individual_name <chr>, age_min <dbl>,
      #   age_max <dbl>, age_unit <chr>, weight_min <dbl>, weight_max <dbl>,
      #   weight_unit <chr>, height_min <dbl>, height_max <dbl>, height_unit <chr>,
      #   bmi_min <dbl>, bmi_max <dbl>, bmi_unit <chr>, egfr_min <dbl>,
      #   egfr_max <dbl>, egfr_unit <chr>

---

    Code
      dfs_empty$populations_parameters
    Output
      # A tibble: 0 x 9
      # i 9 variables: population_id <chr>, parameter <chr>, seed <int>,
      #   distribution_type <chr>, statistic <chr>, value <dbl>, unit <chr>,
      #   source <chr>, description <chr>

