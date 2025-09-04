# Protocol print method returns formatted output

    Code
      print(simple_protocol)
    Output
      
      -- Protocol: Test Simple Protocol ----------------------------------------------
      * Type: Simple
      * Application Type: Oral
      * Dosing Interval: 2 times a day
      * Time Unit: h
      
      -- Parameters --
      
      * Start time: 0 h
      * InputDose: 10 mg
      * End time: 24 h

---

    Code
      print(advanced_protocol)
    Output
      
      -- Protocol: Test Advanced Protocol --------------------------------------------
      * Type: Advanced (Schema-based)
      * Dosing Interval: Once
      * Time Unit: h
      
      -- Schemas --
      
      * Schema: Schema 1
        * Schema Item 1: Oral - Test Formulation

# Protocol to_df method works correctly

    Code
      print(simple_df, width = Inf)
    Output
      # A tibble: 1 x 13
        protocol_name        schema_name schema_item_name type  formulation
        <chr>                <chr>       <chr>            <chr> <chr>      
      1 Test Simple Protocol <NA>        <NA>             Oral  <NA>       
        dosing_interval start_time start_time_unit  dose dose_unit rep_number rep_time
        <chr>                <dbl> <chr>           <dbl> <chr>          <dbl> <chr>   
      1 2 times a day            0 h                  10 mg                 2 12      
        rep_time_unit
        <chr>        
      1 h            

---

    Code
      print(advanced_df, width = Inf)
    Output
      # A tibble: 1 x 13
        protocol_name          schema_name    schema_item_name    type 
        <chr>                  <chr>          <chr>               <chr>
      1 Test Advanced Protocol Sub Protocol 1 Sub Protocol Step 1 Oral 
        formulation      dosing_interval start_time start_time_unit  dose dose_unit
        <chr>            <chr>                <dbl> <chr>           <dbl> <chr>    
      1 Test Formulation Once                     0 h                  15 mg       
        rep_number rep_time rep_time_unit
             <dbl> <chr>    <chr>        
      1          1 0        h            

# Protocol handles empty data gracefully

    Code
      print(minimal_protocol)
    Output
      
      -- Protocol: Minimal Protocol --------------------------------------------------
      * Type: Simple
      * Dosing Interval: Once

# Protocol with real test data works

    Code
      print(first_protocol)
    Output
      
      -- Protocol: Backman 1996 - Midazolam - 15 mg (Control) ------------------------
      * Type: Advanced (Schema-based)
      * Dosing Interval: Once
      * Time Unit: h
      
      -- Schemas --
      
      * Schema: Schema 1
        * Schema Item 1: Oral - Tablet (Dormicum)

# Protocol collection print method works

    Code
      print(snapshot$protocols)
    Output
      
      -- Protocols (9) ---------------------------------------------------------------
      * Backman 1996 - Midazolam - 15 mg (Control) (Advanced - 1 schema)
      * Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56) (Advanced - 4
      schemas)
      * Kharasch 2011 - Midazolam - iv 1 mg and po 3 mg (with Rifampicin) (Advanced -
      2 schemas)
      * Shin 2016 - Midazolam - iv 1 mg (Control) (Simple - Intravenous bolus - Once)
      * Yu 2004 - Rifampicin - 600 mg MD OD 10 days (Advanced - 1 schema)
      * Wiesinger - Rifampicin - low dose and high dose OD (Advanced - 2 schemas)
      * test 6-6-12 till 48 (Simple - Oral - 3 times a day)
      * test 12-12 till 24 (Simple - Intravenous bolus - 2 times a day)
      * test_single_34 (Advanced - 1 schema)

# get_protocols_dfs function works

    Code
      print(protocols_df, width = Inf)
    Output
      # A tibble: 15 x 13
         protocol_name                                                    
         <chr>                                                            
       1 Backman 1996 - Midazolam - 15 mg (Control)                       
       2 Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)       
       3 Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)       
       4 Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)       
       5 Reitman 2011 - Midazolam - po 2 mg (day 28, 35, 42 and 56)       
       6 Kharasch 2011 - Midazolam - iv 1 mg and po 3 mg (with Rifampicin)
       7 Kharasch 2011 - Midazolam - iv 1 mg and po 3 mg (with Rifampicin)
       8 Kharasch 2011 - Midazolam - iv 1 mg and po 3 mg (with Rifampicin)
       9 Shin 2016 - Midazolam - iv 1 mg (Control)                        
      10 Yu 2004 - Rifampicin - 600 mg MD OD 10 days                      
      11 Wiesinger - Rifampicin - low dose and high dose OD               
      12 Wiesinger - Rifampicin - low dose and high dose OD               
      13 test 6-6-12 till 48                                              
      14 test 12-12 till 24                                               
      15 test_single_34                                                   
         schema_name    schema_item_name    type              formulation      
         <chr>          <chr>               <chr>             <chr>            
       1 Sub Protocol 1 Sub Protocol Step 1 Oral              Tablet (Dormicum)
       2 Sub Protocol 1 Sub Protocol Step 1 Oral              form-Lint80      
       3 Sub Protocol 2 Sub Protocol Step 1 Oral              form-Lint80      
       4 Sub Protocol 3 Sub Protocol Step 1 Oral              Oral solution    
       5 Sub Protocol 4 Sub Protocol Step 1 Oral              form-ZO          
       6 Sub Protocol 1 Sub Protocol Step 1 Intravenous bolus <NA>             
       7 Sub Protocol 2 Sub Protocol Step 1 Oral              Oral solution    
       8 Sub Protocol 2 Sub Protocol Step 2 Oral              Oral solution    
       9 <NA>           <NA>                Intravenous bolus <NA>             
      10 Sub Protocol 1 Sub Protocol Step 1 Oral              Formulation      
      11 Sub Protocol 1 Sub Protocol Step 1 Oral              Formulation      
      12 Sub Protocol 2 Sub Protocol Step 1 Oral              form-ZO          
      13 <NA>           <NA>                Oral              <NA>             
      14 <NA>           <NA>                Intravenous bolus <NA>             
      15 Sub Protocol 1 Sub Protocol Step 1 Oral              Formulation      
         dosing_interval start_time start_time_unit  dose dose_unit rep_number
         <chr>                <dbl> <chr>           <dbl> <chr>          <dbl>
       1 Once                     0 h                  15 mg                 1
       2 Once                   648 h                   2 mg                 1
       3 Once                   816 h                   2 mg                 1
       4 Once                   984 h                   2 mg                 1
       5 Once                  1320 h                   2 mg                 1
       6 Once                   108 h                 100 mg                 1
       7 Once a day             132 h                  20 mg                 3
       8 Once a day             232 h                  10 mg                 3
       9 Once                     0 h                   1 mg                 1
      10 Once a day               0 h                 600 mg                10
      11 Once a day               0 h                  10 mg                11
      12 Once a day             264 h                 600 mg                11
      13 3 times a day            0 h                   1 mg/kg              6
      14 2 times a day            0 h                   1 mg/kg              1
      15 Once                     0 h                  24 mg/kg              1
         rep_time rep_time_unit
         <chr>    <chr>        
       1 0        h            
       2 0        h            
       3 0        h            
       4 0        h            
       5 0        h            
       6 0        h            
       7 24       h            
       8 24       h            
       9 0        h            
      10 24       h            
      11 24       h            
      12 24       h            
      13 6, 12    h            
      14 12       h            
      15 0        h            

