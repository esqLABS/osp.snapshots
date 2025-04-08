# Snapshot print method works

    Code
      snapshot
    Message
      
      -- PKSIM Snapshot --------------------------------------------------------------
      i Version: 80 (PKSIM 12.0)
      * Compounds: 2
      * ExpressionProfiles: 2
      * Formulations: 2
      * Individuals: 2
      * Protocols: 2
      * SimulationClassifications: 2
      * Simulations: 2

# Individual collection print method works

    Code
      print(individuals_named)
    Message
      
      -- Individuals (3) -------------------------------------------------------------
      * Individual 1
      * Individual 2
      * Individual 3

# Individuals can be modified from the snapshot object

    Code
      snapshot$data$Individuals[[1]]
    Output
      $Name
      [1] "Mouly2002_modified"
      
      $Seed
      [1] 1300547185
      
      $OriginData
      $OriginData$CalculationMethods
      [1] "SurfaceAreaPlsInt_VAR1"        "Body surface area - Mosteller"
      
      $OriginData$Species
      $OriginData$Species$Beagle
      [1] "Beagle"
      
      
      $OriginData$Population
      $OriginData$Population$Asian_Tanaka_1996
      [1] "Asian_Tanaka_1996"
      
      
      $OriginData$Gender
      $OriginData$Gender$Female
      [1] "FEMALE"
      
      
      $OriginData$Age
      $OriginData$Age$Value
      [1] 39.9
      
      $OriginData$Age$Unit
      [1] "year(s)"
      
      
      $OriginData$Weight
      $OriginData$Weight$Value
      numeric(0)
      
      $OriginData$Weight$Unit
      [1] "kg"
      
      
      $OriginData$Height
      $OriginData$Height$Value
      numeric(0)
      
      $OriginData$Height$Unit
      [1] "cm"
      
      
      
      $Parameters
      $Parameters$`Organism|Gallbladder|Gallbladder ejection fraction`
      $Parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$Path
      [1] "Organism|Gallbladder|Gallbladder ejection fraction"
      
      $Parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$Value
      [1] 0.96
      
      $Parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$ValueOrigin
      $Parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$ValueOrigin$Source
      [1] "Publication"
      
      $Parameters$`Organism|Gallbladder|Gallbladder ejection fraction`$ValueOrigin$Description
      [1] "R24-4081"
      
      
      
      $Parameters$`Organism|Liver|EHC continuous fraction`
      $Parameters$`Organism|Liver|EHC continuous fraction`$Path
      [1] "Organism|Liver|EHC continuous fraction"
      
      $Parameters$`Organism|Liver|EHC continuous fraction`$Value
      [1] 1
      
      $Parameters$`Organism|Liver|EHC continuous fraction`$ValueOrigin
      $Parameters$`Organism|Liver|EHC continuous fraction`$ValueOrigin$Source
      [1] "Publication"
      
      $Parameters$`Organism|Liver|EHC continuous fraction`$ValueOrigin$Description
      [1] "R24-4081"
      
      
      
      
      $ExpressionProfiles
      [1] "CYP1A2|Human|Healthy" "CYP2B6|Human|Healthy"
      

---

    Code
      snapshot$individuals[[1]]
    Output
      
      -- Individual: Mouly2002_modified | Seed: 1300547185 ---------------------------
      
      -- Origin Data --
      
      * Species: Beagle
      * Population: Asian_Tanaka_1996
      * Gender: FEMALE
      * Age: 39.9 year(s)
      * Height: cm
      * Weight: kg
      * Calculation Methods:
        * SurfaceAreaPlsInt_VAR1
        * Body surface area - Mosteller
      
      -- Parameters --
      
      * Organism|Gallbladder|Gallbladder ejection fraction: 0.96
      * Organism|Liver|EHC continuous fraction: 1
      
      -- Expression Profiles --
      
      * CYP1A2|Human|Healthy
      * CYP2B6|Human|Healthy

