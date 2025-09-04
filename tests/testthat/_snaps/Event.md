# print.event_collection works

    Code
      print(events)
    Output
      
      -- Events (2) ------------------------------------------------------------------
      * meal (Meal: Standard (Human)) - 3 parameters
      * gb (Gallbladder emptying)

---

    Code
      print(empty_events)
    Output
      
      -- Events (0) ------------------------------------------------------------------
      i No events found

# Test get_events_dfs

    Code
      snapshot$events
    Output
      
      -- Events (10) -----------------------------------------------------------------
      * GB emptying (Gallbladder emptying)
      * urinary (Urinary bladder emptying)
      * urinary2 (Urinary bladder emptying) - 1 parameter
      * Standard Meal (Meal: Standard (Human))
      * High fat Breakfast (Meal: High-fat breakfast (Human))
      * Ensure plus (Meal: Ensure Plus (Human))
      * High fat soup (Meal: High-fat soup (Human))
      * mixed (Meal: Mixed solid/liquid meal (Human))
      * Dextrose_1984 (Meal: Dextrose solution (Human)) - 3 parameters
      * Egg sandwich (Meal: Egg sandwich (Human)) - 2 parameters

---

    Code
      dfs
    Output
      $events
      # A tibble: 10 x 3
         event_id           name               template                             
         <chr>              <chr>              <chr>                                
       1 GB emptying        GB emptying        Gallbladder emptying                 
       2 urinary            urinary            Urinary bladder emptying             
       3 urinary2           urinary2           Urinary bladder emptying             
       4 Standard  Meal     Standard  Meal     Meal: Standard (Human)               
       5 High fat Breakfast High fat Breakfast Meal: High-fat breakfast (Human)     
       6 Ensure plus        Ensure plus        Meal: Ensure Plus (Human)            
       7 High fat soup      High fat soup      Meal: High-fat soup (Human)          
       8 mixed              mixed              Meal: Mixed solid/liquid meal (Human)
       9 Dextrose_1984      Dextrose_1984      Meal: Dextrose solution (Human)      
      10 Egg sandwich       Egg sandwich       Meal: Egg sandwich (Human)           
      
      $events_parameters
      # A tibble: 6 x 4
        event_id      parameter                        value unit 
        <chr>         <chr>                            <dbl> <chr>
      1 urinary2      Urinary bladder emptying enabled   0.6 <NA> 
      2 Dextrose_1984 Meal energy content              567   kcal 
      3 Dextrose_1984 Meal volume                        0.5 l    
      4 Dextrose_1984 Meal fraction solid                0.5 <NA> 
      5 Egg sandwich  Gallbladder emptying enabled       0   <NA> 
      6 Egg sandwich  Gallbladder emptying lag time     20   min  
      

