# Populations can be accessed from snapshot

    Code
      snapshot$populations
    Message
      
      -- Populations (6) -------------------------------------------------------------
      * pop_1 [Source: European_ICRP_2002] (100 individuals)
      * pop2 [Source: European_ICRP_2002] (10 individuals)
      * pop3 [Source: Asian_Tanaka_1996] (10 individuals)
      * pop4 [Source: European_ICRP_2002] (10 individuals)
      * pop6 [Source: European_ICRP_2002] (15 individuals)
      * pop7 [Source: Asian_Tanaka_1996] (12 individuals)

---

    Code
      print(pop)
    Message
      
      -- Population: pop_1 (Seed: 202395203) --
      
      Source Population: European_ICRP_2002
      Number of individuals: 100
      Proportion of females: 50%
      Age range: 0 - 100 year(s)
      
      -- Advanced Parameters 
      4 advanced parameters defined

# Populations can be modified from the snapshot object and snapshot data is updated

    Code
      snapshot$data$Populations[[1]]
    Output
      $Name
      pop_1_modified
      
      $Seed
      [1] 12345678
      
      $Settings
      $Settings$NumberOfIndividuals
      [1] 110
      
      $Settings$ProportionOfFemales
      [1] 75
      
      $Settings$Age
      $Settings$Age$Min
      [1] 0
      
      $Settings$Age$Max
      [1] 100
      
      $Settings$Age$Unit
      [1] "year(s)"
      
      
      $Settings$Individual
      $Settings$Individual$Name
      [1] "European (P-gp modified, CYP3A4 36 h)"
      
      $Settings$Individual$Seed
      [1] 17189110
      
      $Settings$Individual$OriginData
      $Settings$Individual$OriginData$CalculationMethods
      [1] "SurfaceAreaPlsInt_VAR1"        "Body surface area - Mosteller"
      
      $Settings$Individual$OriginData$Species
      [1] "Human"
      
      $Settings$Individual$OriginData$Population
      [1] "European_ICRP_2002"
      
      $Settings$Individual$OriginData$Gender
      [1] "MALE"
      
      $Settings$Individual$OriginData$Age
      $Settings$Individual$OriginData$Age$Value
      [1] 30
      
      $Settings$Individual$OriginData$Age$Unit
      [1] "year(s)"
      
      
      
      $Settings$Individual$Parameters
      $Settings$Individual$Parameters[[1]]
      $Settings$Individual$Parameters[[1]]$Path
      [1] "Organism|Liver|EHC continuous fraction"
      
      $Settings$Individual$Parameters[[1]]$Value
      [1] 1
      
      $Settings$Individual$Parameters[[1]]$ValueOrigin
      $Settings$Individual$Parameters[[1]]$ValueOrigin$Source
      [1] "Unknown"
      
      
      
      
      $Settings$Individual$ExpressionProfiles
      [1] "CYP3A4|Human|Healthy"  "AADAC|Human|Healthy"   "P-gp|Human|Healthy"   
      [4] "OATP1B1|Human|Healthy" "ATP1A2|Human|Healthy"  "UGT1A4|Human|Healthy" 
      [7] "GABRG2|Human|Healthy" 
      
      
      
      $AdvancedParameters
      $AdvancedParameters[[1]]
      $AdvancedParameters[[1]]$Name
      [1] "CYP3A4|t1/2 (intestine)"
      
      $AdvancedParameters[[1]]$Seed
      [1] 202400546
      
      $AdvancedParameters[[1]]$DistributionType
      [1] "Normal"
      
      $AdvancedParameters[[1]]$Parameters
      $AdvancedParameters[[1]]$Parameters[[1]]
      $AdvancedParameters[[1]]$Parameters[[1]]$Name
      [1] "Mean"
      
      $AdvancedParameters[[1]]$Parameters[[1]]$Value
      [1] 23
      
      $AdvancedParameters[[1]]$Parameters[[1]]$Unit
      [1] "h"
      
      $AdvancedParameters[[1]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[1]]$Parameters[[1]]$ValueOrigin$Source
      [1] "ParameterIdentification"
      
      
      
      $AdvancedParameters[[1]]$Parameters[[2]]
      $AdvancedParameters[[1]]$Parameters[[2]]$Name
      [1] "Deviation"
      
      $AdvancedParameters[[1]]$Parameters[[2]]$Value
      [1] 12
      
      $AdvancedParameters[[1]]$Parameters[[2]]$Unit
      [1] "h"
      
      $AdvancedParameters[[1]]$Parameters[[2]]$ValueOrigin
      $AdvancedParameters[[1]]$Parameters[[2]]$ValueOrigin$Source
      [1] "Publication"
      
      $AdvancedParameters[[1]]$Parameters[[2]]$ValueOrigin$Description
      [1] "c01835608"
      
      
      
      
      
      $AdvancedParameters[[2]]
      $AdvancedParameters[[2]]$Name
      [1] "Organism|Bone|Lymph flow rate"
      
      $AdvancedParameters[[2]]$Seed
      [1] 203191984
      
      $AdvancedParameters[[2]]$DistributionType
      [1] "Discrete"
      
      $AdvancedParameters[[2]]$Parameters
      $AdvancedParameters[[2]]$Parameters[[1]]
      $AdvancedParameters[[2]]$Parameters[[1]]$Name
      [1] "Mean"
      
      $AdvancedParameters[[2]]$Parameters[[1]]$Value
      [1] 0.0001140143
      
      $AdvancedParameters[[2]]$Parameters[[1]]$Unit
      [1] "l/min"
      
      $AdvancedParameters[[2]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[2]]$Parameters[[1]]$ValueOrigin$Source
      [1] "ParameterIdentification"
      
      
      
      
      
      $AdvancedParameters[[3]]
      $AdvancedParameters[[3]]$Name
      [1] "Organism|Bone|Interstitial|pH"
      
      $AdvancedParameters[[3]]$Seed
      [1] 203212109
      
      $AdvancedParameters[[3]]$DistributionType
      [1] "Uniform"
      
      $AdvancedParameters[[3]]$Parameters
      $AdvancedParameters[[3]]$Parameters[[1]]
      $AdvancedParameters[[3]]$Parameters[[1]]$Name
      [1] "Minimum"
      
      $AdvancedParameters[[3]]$Parameters[[1]]$Value
      [1] 12
      
      $AdvancedParameters[[3]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[3]]$Parameters[[1]]$ValueOrigin$Source
      [1] "Other"
      
      $AdvancedParameters[[3]]$Parameters[[1]]$ValueOrigin$Description
      [1] "Assumed"
      
      
      
      $AdvancedParameters[[3]]$Parameters[[2]]
      $AdvancedParameters[[3]]$Parameters[[2]]$Name
      [1] "Maximum"
      
      $AdvancedParameters[[3]]$Parameters[[2]]$Value
      [1] 14
      
      $AdvancedParameters[[3]]$Parameters[[2]]$ValueOrigin
      $AdvancedParameters[[3]]$Parameters[[2]]$ValueOrigin$Source
      [1] "Publication"
      
      $AdvancedParameters[[3]]$Parameters[[2]]$ValueOrigin$Description
      [1] "R24-4085"
      
      
      
      
      
      $AdvancedParameters[[4]]
      $AdvancedParameters[[4]]$Name
      [1] "Organism|Gallbladder|Gallbladder ejection half-time"
      
      $AdvancedParameters[[4]]$Seed
      [1] 203229343
      
      $AdvancedParameters[[4]]$DistributionType
      [1] "Discrete"
      
      $AdvancedParameters[[4]]$Parameters
      $AdvancedParameters[[4]]$Parameters[[1]]
      $AdvancedParameters[[4]]$Parameters[[1]]$Name
      [1] "Mean"
      
      $AdvancedParameters[[4]]$Parameters[[1]]$Value
      [1] 19.7
      
      $AdvancedParameters[[4]]$Parameters[[1]]$Unit
      [1] "min"
      
      $AdvancedParameters[[4]]$Parameters[[1]]$ValueOrigin
      $AdvancedParameters[[4]]$Parameters[[1]]$ValueOrigin$Source
      [1] "Publication"
      
      $AdvancedParameters[[4]]$Parameters[[1]]$ValueOrigin$Description
      [1] "R24-4085"
      
      
      
      
      
      

