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
      # A tibble: 3 x 18
        protocol_id          protocol_name        is_advanced
        <chr>                <chr>                <lgl>      
      1 Test Simple Protocol Test Simple Protocol FALSE      
      2 Test Simple Protocol Test Simple Protocol FALSE      
      3 Test Simple Protocol Test Simple Protocol FALSE      
        protocol_application_type protocol_dosing_interval protocol_time_unit
        <chr>                     <chr>                    <chr>             
      1 Oral                      DI_12_12                 h                 
      2 Oral                      DI_12_12                 h                 
      3 Oral                      DI_12_12                 h                 
        schema_id schema_name schema_item_id schema_item_name
        <chr>     <chr>       <chr>          <chr>           
      1 <NA>      <NA>        <NA>           <NA>            
      2 <NA>      <NA>        <NA>           <NA>            
      3 <NA>      <NA>        <NA>           <NA>            
        schema_item_application_type schema_item_formulation_key parameter_name
        <chr>                        <chr>                       <chr>         
      1 <NA>                         <NA>                        Start time    
      2 <NA>                         <NA>                        InputDose     
      3 <NA>                         <NA>                        End time      
        parameter_value parameter_unit parameter_source parameter_description
                  <dbl> <chr>          <chr>            <chr>                
      1               0 h              <NA>             <NA>                 
      2              10 mg             <NA>             <NA>                 
      3              24 h              <NA>             <NA>                 
        parameter_source_id
                      <int>
      1                  NA
      2                  NA
      3                  NA

---

    Code
      print(advanced_df, width = Inf)
    Output
      # A tibble: 2 x 18
        protocol_id            protocol_name          is_advanced
        <chr>                  <chr>                  <lgl>      
      1 Test Advanced Protocol Test Advanced Protocol TRUE       
      2 Test Advanced Protocol Test Advanced Protocol TRUE       
        protocol_application_type protocol_dosing_interval protocol_time_unit
        <chr>                     <chr>                    <chr>             
      1 <NA>                      Single                   h                 
      2 <NA>                      Single                   h                 
        schema_id schema_name schema_item_id schema_item_name
        <chr>     <chr>       <chr>          <chr>           
      1 Schema 1  Schema 1    Schema Item 1  Schema Item 1   
      2 Schema 1  Schema 1    Schema Item 1  Schema Item 1   
        schema_item_application_type schema_item_formulation_key parameter_name
        <chr>                        <chr>                       <chr>         
      1 Oral                         Test Formulation            Start time    
      2 Oral                         Test Formulation            InputDose     
        parameter_value parameter_unit parameter_source parameter_description
                  <dbl> <chr>          <chr>            <chr>                
      1               0 h              <NA>             <NA>                 
      2              15 mg             <NA>             <NA>                 
        parameter_source_id
                      <int>
      1                  NA
      2                  NA

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
      print(protocols)
    Message
      
      -- Protocols (2) ---------------------------------------------------------------
      * Simple (Simple - Oral - 2 times a day)
      * Advanced (Advanced - 1 schema)

