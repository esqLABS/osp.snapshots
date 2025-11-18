# Compound collection is printed correctly

    Code
      print(snapshot$compounds)
    Output
      
      -- Compounds (6) ---------------------------------------------------------------
      * Rifampicin
      * 123456
      * Perpetrator_2
      * 100777- initial table parameters
      * 100777
      * test

# Compounds are printed correctly

    Code
      print(compound)
    Output
      
      -- Compound: Rifampicin --------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Small Molecule
      * Plasma Protein Binding Partner: Albumin
      * Molecular Weight: 822.94 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: PK-Sim Standard
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2.5 Log Units [Publication - Other - (R13-5357)]
      * Fraction Unbound:
        * 17 % [Publication - InVitro - (R13-5357)]
      * Solubility:
        * Aqueous: 2800 mg/l (pH 7.5) [Publication - (R20-1499)]
        * test: 345 mg/l (pH 7) [Unknown]
      * Intestinal Permeability:
        * 3.836e-07 cm/min [Publication - (PK-Sim default calculation)]
      * pKa Types:
        * Base: 7.9 [Database - (R24-3728)]
        * Acid: 1.7 [Database - (R24-3728)]
      
      -- Processes --
      
      Processes (21 total):
        * Metabolism:
          * MetabolizationSpecific_MM (AADAC): Enzyme concentration=1 µmol/l, Vmax=12
          µmol/l/min, Km=195.1 µmol/l, kcat=9.865 1/min [Nakajima 2011]
        * Transport:
          * ActiveTransportSpecific_MM (P-gp): Transporter concentration=1 nmol/l,
          Vmax=0 µmol/l/min, Km=55 µmol/l, kcat=0.6088 1/min [Collett 2004]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1.5 µmol/l, kcat=7.796 1/min [Tirona 2003]
        * Clearance:
          * BiliaryClearance [BCL]
          * LiverClearance: Specific clearance=666 1/h [test123]
          * TubularSecretion_FirstOrder: Tubular secretion=33 l/min, TSspec=55 1/min
          [RenCL_rif]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=18.5 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (P-gp): Ki=169 µmol/l [Reitman 2011]
          * CompetitiveInhibition (CYP2C8): Ki=30.2 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (OATP1B1): Ki=0.477 µmol/l [Hirano 2006]
          * CompetitiveInhibition (OATP1B3): Ki=0.9 µmol/l [Annaert 2010]
          * CompetitiveInhibition (CYP3A4): Ki=23 µmol/l [Comp]
          * MixedInhibition (CYP3A4): Ki_c=23 µmol/l, Ki_u=3 µmol/l [Mixed]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=22 µmol/l
          [Irreversible]
        * Induction:
          * Induction (CYP3A4): EC50=0.34 µmol/l, Emax=9 [Templeton 2011]
          * Induction (P-gp): EC50=0.34 µmol/l, Emax=2.5 [Greiner 1999]
          * Induction (OATP1B1): EC50=0.34 µmol/l, Emax=0.383 [Dixit 2007]
          * Induction (AADAC): EC50=0.34 µmol/l, Emax=0.985 [Assumed]
          * Induction (CYP2C8): EC50=0.34 µmol/l, Emax=3.2 [Buckley 2014]
          * Induction (CYP1A2): EC50=0.34 µmol/l, Emax=0.65 [Chen 2010]
          * Induction (CYP2E1): EC50=0.34 µmol/l, Emax=0.8 [Rae 2001]

---

    Code
      print(compound)
    Output
      
      -- Compound: 123456 ------------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Large Molecule
      * Plasma Protein Binding Partner: Glycoprotein
      * Molecular Weight: 150000 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: Charge dependent Schmitt
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * Optimized: 2.8972038771 Log Units [ParameterIdentification - (Value updated
        from '3.3.2 - Base oral model (SD, solution, + DDI, + MD), with CatC, both
        pKa fitted' on 2024-03-11 17:39)]
        * LogP (Simcyp): 3.53 Log Units [Publication - (R13-5357)]
      * Fraction Unbound:
        * Gertz et al. 2010: 0.031 [ParameterIdentification - (Value updated from 'PI
        Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09
        16:10)]
        * test: 12 % [Publication - (R13-5357)]
      * Solubility:
        * FaSSiF: 0.049 mg/ml (pH 6.5) [ParameterIdentification - (Value updated from
        'PI Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on
        2019-04-09 16:10)]
        * Table: 5000 mg/l (Table: pH 3→5000 mg/l, pH 6→3000 mg/l, pH 6.8→90 mg/l)
        [Publication - (R20-1499)]
      * Intestinal Permeability:
        * 0.00015549970673 cm/min [ParameterIdentification - (Value updated from 'PI
        Hohmann iv+po, Hyland feUr MDZG, Thummel feUr unchanged - Pint' on 2019-04-09
        16:10)]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      Processes (30 total):
        * Metabolism:
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=0 pmol/min/mg mic. protein, Km=37.8 µmol/l,
          kcat=3.5911771641 1/min [Optimized]
          * MetabolizationSpecific_Hill (UGT1A4): Enzyme concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=2 1/min, Hill coefficient=1 [Kim et
          al, 2020]
          * MetabolizationIntrinsic_MM (CYP3A4): Fraction intracellular (liver)=0.45,
          Vmax (liver tissue)=12 µmol/min/kg tissue, Km=1 µmol/l, Vmax=14.93
          µmol/l/min [Int-MM]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Fraction intracellular
          (liver)=0.8, Intrinsic clearance=800 l/min, Specific clearance=234 1/min
          [Int_FO]
          * MetabolizationSpecific_FirstOrder (CYP3A4): Enzyme concentration=1
          µmol/l, Specific clearance=330 1/min, CLspec/[Enzyme]=12 l/µmol/min [In
          vitro_FO]
          * MetabolizationSpecific_MM (CYP3A4): Enzyme concentration=1 µmol/l, Vmax=0
          µmol/l/min, Km=1 µmol/l, kcat=56 1/min [In vitro_MM]
          * MetabolizationSpecific_Hill (CYP3A4): Enzyme concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=12 µmol/l, kcat=211 1/min, Hill coefficient=8 [In
          vitro_H]
          * rCYP450_FirstOrder (CYP3A4): In vitro CL/recombinant enzyme=0 µl/min/pmol
          rec. enzyme, CLspec/[Enzyme]=45 l/µmol/min [In vitro_recombinant_FO]
          * rCYP450_MM (CYP3A4): In vitro Vmax/recombinant enzyme=59 nmol/min/pmol
          rec. enzyme, Km=3 µmol/l, kcat=13 1/min [In vitro_recombinant_MM]
          * MetabolizationLiverMicrosomes_FirstOrder (CYP3A4): In vitro CL for liver
          microsomes=56 µl/min/mg mic. protein, Content of CYP proteins in liver
          microsomes=120 pmol/mg mic. protein, CLspec/[Enzyme]=0.467 l/µmol/min
          [liv_micros_FO]
          * MetabolizationLiverMicrosomes_MM (CYP3A4): In vitro Vmax for liver
          microsomes=0 pmol/min/mg mic. protein, Km=3 µmol/l, kcat=44 1/min
          [liv_micros_MM]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=78.6
          l/min [test]
        * Transport:
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [Buhr 1997]
          * ActiveTransportIntrinsic_MM (OATP1B1): Vmax (liver tissue)=23 µmol/min/kg
          tissue, Km=1 µmol/l, Vmax=26 µmol/l/min [Int _ MM]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=3 µmol/l,
          Vmax=100 µmol/l/min, Km=2 µmol/l, kcat=33.3333333333 1/min [Spec_MM]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=1
          µmol/l, Vmax=12 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
          * ActiveTransport_InVitro_VesicularAssay_MM (OATP1B1): In vitro
          Vmax/transporter=56 nmol/min/pmol transporter, Km=1 µmol/l, kcat=45 1/min
          [In vitro_MM]
          * SpecificBinding (NTCP): koff=3 1/min, Kd=4 µmol/l [wer]
        * Clearance:
          * BiliaryClearance: Specific clearance=34 1/min [n45678]
          * KidneyClearance: Specific clearance=66 1/min [Kidney_plasma_CL]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
          * UncompetitiveInhibition (CYP3A4): Ki=1.667 µmol/l [uncomp_inh]
          * NoncompetitiveInhibition (CYP3A4): Ki=3 µmol/l [non-comp_inh]
          * MixedInhibition (CYP3A4): Ki_c=1 µmol/l, Ki_u=1 µmol/l [mixed_inh]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=1 µmol/l,
          Ki=2 µmol/l [irr_ing_2]
          * CompetitiveInhibition (ABCB1): Ki=23 µmol/l [test]
          * IrreversibleInhibition (CYP3A4): kinact=1.67 1/min, K_kinact_half=6
          µmol/l [irr_3]
        * Induction:
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=67 [induction]
          * Induction (GABRG2): EC50=1 µmol/l, Emax=200 [GABRG2-ind]
        * Other:
          * LiverMicrosomeHalfTime: t1/2 (microsomal assay)=23 min, Specific
          clearance=19.49 1/min [In vitro_mic_t1/2]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c01835608)]
        * F: 1 [Publication - (c01835608)]

---

    Code
      print(compound)
    Output
      
      -- Compound: Perpetrator_2 -----------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Small Molecule
      * Plasma Protein Binding Partner: Albumin
      * Molecular Weight: 822.94 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: PK-Sim Standard
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2.5 Log Units [Publication - Other - (R13-5357)]
      * Fraction Unbound:
        * 17 % [Publication - InVitro - (R13-5357)]
      * Solubility:
        * Aqueous: 2800 mg/l (pH 7.5) [Publication - (R20-1499)]
        * test: 345 mg/l (pH 7) [Unknown]
      * pKa Types:
        * Base: 7.9 [Database - (R24-3728)]
        * Acid: 1.7 [Database - (R24-3728)]
      
      -- Processes --
      
      Processes (2 total):
        * Clearance:
          * GlomerularFiltration: GFR fraction=1 [GFR]
          * HepatocytesRes: Measuring time=12 min, Residual fraction=23 % [In vitro
          hep_res]

---

    Code
      print(compound)
    Output
      
      -- Compound: 100777- initial table parameters ----------------------------------
      
      -- Basic Properties --
      
      * Type: Large Molecule
      * Molecular Weight: 150000 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Rodgers and Rowland
      * Permeability: Charge dependent Schmitt
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2.8972038771 Log Units [Publication - InVitro - (R24-4081)]
      * Fraction Unbound:
        * 0.031 % [Publication - InVitro - (R24-4081)]
      * Solubility:
        * 0.049 mg/ml (pH 6.5) [Publication - InVivo - (n00261417)]
      * Intestinal Permeability:
        * 0.00015549970673 cm/min [Publication - InVitro - (123456_456444_4.0)]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      Processes (9 total):
        * Metabolism:
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=0 pmol/min/mg mic. protein, Km=37.8 µmol/l,
          kcat=3.5911771641 1/min [Optimized]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=342
          l/min, Specific clearance=234 1/min [Int_FO]
        * Transport:
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=1.8 nmol/l [in-vitro]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=1
          µmol/l, Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
        * Clearance:
          * BiliaryClearance: Specific clearance=34 1/min [n45678]
          * TubularSecretion_MM: TSmax=0 µmol/min, Km=33 µmol/l, TSmax_spec=23
          µmol/l/min [TuSec_MM]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
        * Induction:
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=67 [induction]
        * Other:
          * LiverMicrosomeRes: Measuring time=345 min, Residual fraction=34 % [In
          vitro_mic_res]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c26475781)]
        * F: 1 [Publication - (c26475781)]

---

    Code
      print(compound)
    Output
      
      -- Compound: 100777 ------------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Large Molecule
      * Molecular Weight: 150000 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: Poulin and Theil
      * Permeability: Charge dependent Schmitt
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 3.233 Log Units [ParameterIdentification]
      * Fraction Unbound:
        * 0.031 % [Publication - InVitro - (n00261417)]
      * Solubility:
        * 0.5 mg/ml (pH 6.5) [ParameterIdentification]
      * Intestinal Permeability:
        * 2.04 cm/min [ParameterIdentification]
      * pKa Types:
        * Base: 6.2 [Publication - (c26475781)]
        * Acid: 10.95 [Publication - (c26475781)]
      
      -- Processes --
      
      Processes (9 total):
        * Metabolism:
          * MetabolizationLiverMicrosomes_MM (UGT1A4) → Midazolam-N-glucuronide: In
          vitro Vmax for liver microsomes=12 pmol/min/mg mic. protein, Content of CYP
          proteins in liver microsomes=109 pmol/mg mic. protein, Km=40.23 µmol/l,
          kcat=0.1111111111 1/min [Optimized]
          * MetabolizationIntrinsic_FirstOrder (CYP3A4): Intrinsic clearance=888
          l/min, Specific clearance=234 1/min [Int_FO]
        * Transport:
          * SpecificBinding (GABRG2): koff=1 1/min, Kd=2.81 nmol/l [in-vitro]
          * ActiveTransportSpecific_Hill (OATP1B1): Transporter concentration=12
          µmol/l, Vmax=0 µmol/l/min, Km=1 µmol/l, kcat=222 1/min, Hill coefficient=2
          [Spec_H]
        * Clearance:
          * BiliaryClearance: Specific clearance=32.88 1/min [n45678]
          * TubularSecretion_MM: TSmax=12 µmol/min, Km=33 µmol/l, TSmax_spec=22.65
          µmol/l/min [TuSec_MM]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=2 µmol/l [comp_inh]
        * Induction:
          * Induction (CYP2E1): EC50=1 µmol/l, Emax=65.134 [induction]
        * Other:
          * LiverMicrosomeRes: Measuring time=345 min, Residual fraction=34 % [In
          vitro_mic_res]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c26475781)]
        * F: 1 [Publication - (c26475781)]

---

    Code
      print(compound)
    Output
      
      -- Compound: test --------------------------------------------------------------
      
      -- Basic Properties --
      
      * Type: Small Molecule
      * Plasma Protein Binding Partner: Albumin
      * Molecular Weight: 123 g/mol
      
      -- Calculation Methods --
      
      * Partition Coefficient: PK-Sim Standard
      * Permeability: PK-Sim Standard
      
      -- Physicochemical Properties --
      
      * Lipophilicity:
        * 2 Log Units [ParameterIdentification]
      * Fraction Unbound:
        * 0.45 [ParameterIdentification]
      * Solubility:
        * Measurement: 3 mg/l (pH 7) [ParameterIdentification]
        * test: 5 mg/l (pH 7) [Unknown]
      * pKa Types:
        * Base: 2 [Unknown]
      
      -- Additional Parameters --
      
      • Additional Parameters (2 total):
        * Br: 1 [Unknown]
        * Cl: 1 [Unknown]

# Compounds sections can be accessed and are correctly printed

    Code
      snapshot$compounds[[1]]$lipophilicity
    Message
      * Lipophilicity:
        * 2.5 Log Units [Publication - Other - (R13-5357)]

---

    Code
      snapshot$compounds[[1]]$processes
    Message
      Processes (21 total):
        * Metabolism:
          * MetabolizationSpecific_MM (AADAC): Enzyme concentration=1 µmol/l, Vmax=12
          µmol/l/min, Km=195.1 µmol/l, kcat=9.865 1/min [Nakajima 2011]
        * Transport:
          * ActiveTransportSpecific_MM (P-gp): Transporter concentration=1 nmol/l,
          Vmax=0 µmol/l/min, Km=55 µmol/l, kcat=0.6088 1/min [Collett 2004]
          * ActiveTransportSpecific_MM (OATP1B1): Transporter concentration=1 µmol/l,
          Vmax=0 µmol/l/min, Km=1.5 µmol/l, kcat=7.796 1/min [Tirona 2003]
        * Clearance:
          * BiliaryClearance [BCL]
          * LiverClearance: Specific clearance=666 1/h [test123]
          * TubularSecretion_FirstOrder: Tubular secretion=33 l/min, TSspec=55 1/min
          [RenCL_rif]
        * Inhibition:
          * CompetitiveInhibition (CYP3A4): Ki=18.5 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (P-gp): Ki=169 µmol/l [Reitman 2011]
          * CompetitiveInhibition (CYP2C8): Ki=30.2 µmol/l [Kajosaari 2005]
          * CompetitiveInhibition (OATP1B1): Ki=0.477 µmol/l [Hirano 2006]
          * CompetitiveInhibition (OATP1B3): Ki=0.9 µmol/l [Annaert 2010]
          * CompetitiveInhibition (CYP3A4): Ki=23 µmol/l [Comp]
          * MixedInhibition (CYP3A4): Ki_c=23 µmol/l, Ki_u=3 µmol/l [Mixed]
          * IrreversibleInhibition (CYP3A4): kinact=2 1/min, K_kinact_half=22 µmol/l
          [Irreversible]
        * Induction:
          * Induction (CYP3A4): EC50=0.34 µmol/l, Emax=9 [Templeton 2011]
          * Induction (P-gp): EC50=0.34 µmol/l, Emax=2.5 [Greiner 1999]
          * Induction (OATP1B1): EC50=0.34 µmol/l, Emax=0.383 [Dixit 2007]
          * Induction (AADAC): EC50=0.34 µmol/l, Emax=0.985 [Assumed]
          * Induction (CYP2C8): EC50=0.34 µmol/l, Emax=3.2 [Buckley 2014]
          * Induction (CYP1A2): EC50=0.34 µmol/l, Emax=0.65 [Chen 2010]
          * Induction (CYP2E1): EC50=0.34 µmol/l, Emax=0.8 [Rae 2001]

---

    Code
      snapshot$compounds[[2]]$parameters
    Message
      • Additional Parameters (2 total):
        * Cl: 1 [Publication - (c01835608)]
        * F: 1 [Publication - (c01835608)]

---

    Code
      snapshot$compounds[[1]]$calculation_methods
    Message
      Calculation Methods:
        * Partition Coefficient: Rodgers and Rowland
        * Permeability: PK-Sim Standard

# Compounds can be converted to dataframes

    Code
      print(get_compounds_dfs(snapshot), n = Inf)
    Output
      # A tibble: 237 x 8
          compound             category type  parameter value unit  data_source source
          <chr>                <chr>    <chr> <chr>     <chr> <chr> <chr>       <chr> 
        1 100777               physico~ lipo~ "Optimiz~ "3.2~ Log ~ <NA>        "Para~
        2 100777               physico~ frac~ "Gertz e~ "0.0~ %     <NA>        "n002~
        3 100777               physico~ mole~  <NA>     "150~ g/mol <NA>        "c264~
        4 100777               physico~ halo~ "Cl"      "1"   <NA>  <NA>        "c264~
        5 100777               physico~ halo~ "F"       "1"   <NA>  <NA>        "c264~
        6 100777               physico~ pKa   "base"    "6.2" <NA>  <NA>        "c264~
        7 100777               physico~ pKa   "acid"    "10.~ <NA>  <NA>        "c264~
        8 100777               physico~ solu~ "pH 6.5"  "0.5" mg/ml <NA>        "Para~
        9 100777               physico~ inte~ "Optimiz~ "2.0~ cm/m~ <NA>        "Para~
       10 100777               protein~ Spec~ "koff, G~ "1"   1/min in-vitro    "Para~
       11 100777               protein~ Spec~ "Kd, GAB~ "2.8~ nmol~ in-vitro    "Para~
       12 100777               metabol~ Meta~ "In vitr~ "12"  pmol~ Optimized   "n002~
       13 100777               metabol~ Meta~ "Content~ "109" pmol~ Optimized   "n002~
       14 100777               metabol~ Meta~ "Km, UGT~ "40.~ µmol~ Optimized   "Para~
       15 100777               metabol~ Meta~ "kcat, U~ "0.1~ 1/min Optimized   "PK-S~
       16 100777               metabol~ Meta~ "Intrins~ "888" l/min Int_FO       <NA> 
       17 100777               metabol~ Meta~ "Specifi~ "234" 1/min Int_FO      "n002~
       18 100777               hepatic~ Live~ "Lipophi~ "3.2~ Log ~ In vitro_m~  <NA> 
       19 100777               hepatic~ Live~ "Measuri~ "345" min   In vitro_m~ "R24-~
       20 100777               hepatic~ Live~ "Residua~ "34"  %     In vitro_m~ "R24-~
       21 100777               transpo~ Acti~ "Transpo~ "12"  µmol~ Spec_H       <NA> 
       22 100777               transpo~ Acti~ "Vmax, O~ "0"   µmol~ Spec_H       <NA> 
       23 100777               transpo~ Acti~ "Km, OAT~ "1"   µmol~ Spec_H      "n002~
       24 100777               transpo~ Acti~ "kcat, O~ "222" 1/min Spec_H      "n002~
       25 100777               transpo~ Acti~ "Hill co~ "2"   <NA>  Spec_H       <NA> 
       26 100777               renal_c~ Tubu~ "TSmax"   "12"  µmol~ TuSec_MM     <NA> 
       27 100777               renal_c~ Tubu~ "Km"      "33"  µmol~ TuSec_MM    "n002~
       28 100777               renal_c~ Tubu~ "TSmax_s~ "22.~ µmol~ TuSec_MM    "Para~
       29 100777               biliary~ Bili~ "Fractio~ "0.0~ <NA>  n45678       <NA> 
       30 100777               biliary~ Bili~ "Lipophi~ "2.8~ Log ~ n45678       <NA> 
       31 100777               biliary~ Bili~ "Plasma ~ "34"  ml/m~ n45678      "Assu~
       32 100777               biliary~ Bili~ "Specifi~ "32.~ 1/min n45678      "Para~
       33 100777               inhibit~ Comp~ "Ki, CYP~ "2"   µmol~ comp_inh    "n002~
       34 100777               inducti~ Indu~ "EC50, C~ "1"   µmol~ induction   "n002~
       35 100777               inducti~ Indu~ "Emax, C~ "65.~ <NA>  induction   "Para~
       36 100777- initial tab~ physico~ lipo~ "Optimiz~ "2.8~ Log ~ <NA>        "R24-~
       37 100777- initial tab~ physico~ frac~ "Gertz e~ "0.0~ %     <NA>        "R24-~
       38 100777- initial tab~ physico~ mole~  <NA>     "150~ g/mol <NA>        "c264~
       39 100777- initial tab~ physico~ halo~ "Cl"      "1"   <NA>  <NA>        "c264~
       40 100777- initial tab~ physico~ halo~ "F"       "1"   <NA>  <NA>        "c264~
       41 100777- initial tab~ physico~ pKa   "base"    "6.2" <NA>  <NA>        "c264~
       42 100777- initial tab~ physico~ pKa   "acid"    "10.~ <NA>  <NA>        "c264~
       43 100777- initial tab~ physico~ solu~ "pH 6.5"  "0.0~ mg/ml <NA>        "n002~
       44 100777- initial tab~ physico~ inte~ "Optimiz~ "0.0~ cm/m~ <NA>        "1234~
       45 100777- initial tab~ protein~ Spec~ "koff, G~ "1"   1/min in-vitro    "Assu~
       46 100777- initial tab~ protein~ Spec~ "Kd, GAB~ "1.8" nmol~ in-vitro     <NA> 
       47 100777- initial tab~ metabol~ Meta~ "In vitr~ "0"   pmol~ Optimized    <NA> 
       48 100777- initial tab~ metabol~ Meta~ "Km, UGT~ "37.~ µmol~ Optimized   "Assu~
       49 100777- initial tab~ metabol~ Meta~ "kcat, U~ "3.5~ 1/min Optimized   "n002~
       50 100777- initial tab~ metabol~ Meta~ "Intrins~ "342" l/min Int_FO      "n002~
       51 100777- initial tab~ metabol~ Meta~ "Specifi~ "234" 1/min Int_FO      "Calc~
       52 100777- initial tab~ hepatic~ Live~ "Lipophi~ "2.8~ Log ~ In vitro_m~  <NA> 
       53 100777- initial tab~ hepatic~ Live~ "Measuri~ "345" min   In vitro_m~ "R24-~
       54 100777- initial tab~ hepatic~ Live~ "Residua~ "34"  %     In vitro_m~ "R24-~
       55 100777- initial tab~ transpo~ Acti~ "Transpo~ "1"   µmol~ Spec_H       <NA> 
       56 100777- initial tab~ transpo~ Acti~ "Vmax, O~ "0"   µmol~ Spec_H       <NA> 
       57 100777- initial tab~ transpo~ Acti~ "Km, OAT~ "1"   µmol~ Spec_H      "n002~
       58 100777- initial tab~ transpo~ Acti~ "kcat, O~ "222" 1/min Spec_H      "n002~
       59 100777- initial tab~ transpo~ Acti~ "Hill co~ "2"   <NA>  Spec_H       <NA> 
       60 100777- initial tab~ renal_c~ Tubu~ "TSmax"   "0"   µmol~ TuSec_MM     <NA> 
       61 100777- initial tab~ renal_c~ Tubu~ "Km"      "33"  µmol~ TuSec_MM    "n002~
       62 100777- initial tab~ renal_c~ Tubu~ "TSmax_s~ "23"  µmol~ TuSec_MM    "Assu~
       63 100777- initial tab~ biliary~ Bili~ "Fractio~ "0.0~ <NA>  n45678       <NA> 
       64 100777- initial tab~ biliary~ Bili~ "Lipophi~ "2.8~ Log ~ n45678       <NA> 
       65 100777- initial tab~ biliary~ Bili~ "Plasma ~ "0"   ml/m~ n45678       <NA> 
       66 100777- initial tab~ biliary~ Bili~ "Specifi~ "34"  1/min n45678      "Assu~
       67 100777- initial tab~ inhibit~ Comp~ "Ki, CYP~ "2"   µmol~ comp_inh    "n002~
       68 100777- initial tab~ inducti~ Indu~ "EC50, C~ "1"   µmol~ induction   "n002~
       69 100777- initial tab~ inducti~ Indu~ "Emax, C~ "67"  <NA>  induction   "n002~
       70 123456               physico~ lipo~ "Optimiz~ "2.8~ Log ~ <NA>        "Para~
       71 123456               physico~ lipo~ "LogP (S~ "3.5~ Log ~ <NA>        "R13-~
       72 123456               physico~ frac~ "Gertz e~ "0.0~ <NA>  <NA>        "Para~
       73 123456               physico~ frac~ "test"    "12"  %     <NA>        "R13-~
       74 123456               physico~ mole~  <NA>     "150~ g/mol <NA>        "c018~
       75 123456               physico~ halo~ "Cl"      "1"   <NA>  <NA>        "c018~
       76 123456               physico~ halo~ "F"       "1"   <NA>  <NA>        "c018~
       77 123456               physico~ pKa   "base"    "6.2" <NA>  <NA>        "c264~
       78 123456               physico~ pKa   "acid"    "10.~ <NA>  <NA>        "c264~
       79 123456               physico~ solu~ "FaSSiF,~ "0.0~ mg/ml <NA>        "Para~
       80 123456               physico~ solu~ "Table"   "pH ~ mg/l  <NA>        "R20-~
       81 123456               physico~ inte~ "Optimiz~ "0.0~ cm/m~ <NA>        "Para~
       82 123456               protein~ Spec~ "koff, G~ "1"   1/min Buhr 1997   "Para~
       83 123456               protein~ Spec~ "Kd, GAB~ "1.8" nmol~ Buhr 1997   "Para~
       84 123456               protein~ Spec~ "koff, N~ "3"   1/min wer         "c443~
       85 123456               protein~ Spec~ "Kd, NTC~ "4"   µmol~ wer         "c443~
       86 123456               metabol~ Meta~ "In vitr~ "0"   pmol~ Optimized    <NA> 
       87 123456               metabol~ Meta~ "Km, UGT~ "37.~ µmol~ Optimized   "Para~
       88 123456               metabol~ Meta~ "kcat, U~ "3.5~ 1/min Optimized   "Para~
       89 123456               metabol~ Meta~ "Enzyme ~ "1"   µmol~ Kim et al,~  <NA> 
       90 123456               metabol~ Meta~ "Vmax, U~ "0"   µmol~ Kim et al,~  <NA> 
       91 123456               metabol~ Meta~ "Km, UGT~ "1"   µmol~ Kim et al,~ "R07-~
       92 123456               metabol~ Meta~ "kcat, U~ "2"   1/min Kim et al,~ "R07-~
       93 123456               metabol~ Meta~ "Hill co~ "1"   <NA>  Kim et al,~ "Assu~
       94 123456               metabol~ Meta~ "Fractio~ "0.4~ <NA>  Int-MM      "Assu~
       95 123456               metabol~ Meta~ "Vmax (l~ "12"  µmol~ Int-MM      "c443~
       96 123456               metabol~ Meta~ "Km, CYP~ "1"   µmol~ Int-MM      "Assu~
       97 123456               metabol~ Meta~ "Vmax, C~ "14.~ µmol~ Int-MM      "PK-S~
       98 123456               metabol~ Meta~ "Fractio~ "0.8" <NA>  Int_FO      "Assu~
       99 123456               metabol~ Meta~ "Intrins~ "800" l/min Int_FO      "c123~
      100 123456               metabol~ Meta~ "Specifi~ "234" 1/min Int_FO      "PK-S~
      101 123456               metabol~ Meta~ "Enzyme ~ "1"   µmol~ In vitro_FO  <NA> 
      102 123456               metabol~ Meta~ "Specifi~ "330" 1/min In vitro_FO  <NA> 
      103 123456               metabol~ Meta~ "CLspec/~ "12"  l/µm~ In vitro_FO "Para~
      104 123456               metabol~ Meta~ "Enzyme ~ "1"   µmol~ In vitro_MM  <NA> 
      105 123456               metabol~ Meta~ "Vmax, C~ "0"   µmol~ In vitro_MM  <NA> 
      106 123456               metabol~ Meta~ "Km, CYP~ "1"   µmol~ In vitro_MM "Para~
      107 123456               metabol~ Meta~ "kcat, C~ "56"  1/min In vitro_MM "c264~
      108 123456               metabol~ Meta~ "Enzyme ~ "1"   µmol~ In vitro_H   <NA> 
      109 123456               metabol~ Meta~ "Vmax, C~ "0"   µmol~ In vitro_H   <NA> 
      110 123456               metabol~ Meta~ "Km, CYP~ "12"  µmol~ In vitro_H  "c443~
      111 123456               metabol~ Meta~ "kcat, C~ "211" 1/min In vitro_H  "c443~
      112 123456               metabol~ Meta~ "Hill co~ "8"   <NA>  In vitro_H  "Assu~
      113 123456               metabol~ rCYP~ "In vitr~ "0"   µl/m~ In vitro_r~  <NA> 
      114 123456               metabol~ rCYP~ "CLspec/~ "45"  l/µm~ In vitro_r~ "c264~
      115 123456               metabol~ rCYP~ "In vitr~ "59"  nmol~ In vitro_r~ "c443~
      116 123456               metabol~ rCYP~ "Km, CYP~ "3"   µmol~ In vitro_r~ "c443~
      117 123456               metabol~ rCYP~ "kcat, C~ "13"  1/min In vitro_r~ "Para~
      118 123456               metabol~ Meta~ "In vitr~ "56"  µl/m~ liv_micros~ "c443~
      119 123456               metabol~ Meta~ "Content~ "120" pmol~ liv_micros~ "c443~
      120 123456               metabol~ Meta~ "CLspec/~ "0.4~ l/µm~ liv_micros~ "PK-S~
      121 123456               metabol~ Meta~ "In vitr~ "0"   pmol~ liv_micros~  <NA> 
      122 123456               metabol~ Meta~ "Km, CYP~ "3"   µmol~ liv_micros~ "c319~
      123 123456               metabol~ Meta~ "kcat, C~ "44"  1/min liv_micros~ "Para~
      124 123456               metabol~ Meta~ "Intrins~ "78.~ l/min test        "c443~
      125 123456               hepatic~ Live~ "Lipophi~ "2.8~ Log ~ In vitro_m~ "PK-S~
      126 123456               hepatic~ Live~ "t1/2 (m~ "23"  min   In vitro_m~ "R24-~
      127 123456               hepatic~ Live~ "Specifi~ "19.~ 1/min In vitro_m~ "PK-S~
      128 123456               transpo~ Acti~ "Vmax (l~ "23"  µmol~ Int _ MM     <NA> 
      129 123456               transpo~ Acti~ "Km, OAT~ "1"   µmol~ Int _ MM    "c264~
      130 123456               transpo~ Acti~ "Vmax, O~ "26"  µmol~ Int _ MM    "c264~
      131 123456               transpo~ Acti~ "Transpo~ "3"   µmol~ Spec_MM     "c264~
      132 123456               transpo~ Acti~ "Vmax, O~ "100" µmol~ Spec_MM     "c264~
      133 123456               transpo~ Acti~ "Km, OAT~ "2"   µmol~ Spec_MM     "c443~
      134 123456               transpo~ Acti~ "kcat, O~ "33.~ 1/min Spec_MM     "PK-S~
      135 123456               transpo~ Acti~ "Transpo~ "1"   µmol~ Spec_H       <NA> 
      136 123456               transpo~ Acti~ "Vmax, O~ "12"  µmol~ Spec_H       <NA> 
      137 123456               transpo~ Acti~ "Km, OAT~ "1"   µmol~ Spec_H      "c443~
      138 123456               transpo~ Acti~ "kcat, O~ "222" 1/min Spec_H      "c443~
      139 123456               transpo~ Acti~ "Hill co~ "2"   <NA>  Spec_H      "Assu~
      140 123456               transpo~ Acti~ "In vitr~ "56"  nmol~ In vitro_MM  <NA> 
      141 123456               transpo~ Acti~ "Km, OAT~ "1"   µmol~ In vitro_MM "Para~
      142 123456               transpo~ Acti~ "kcat, O~ "45"  1/min In vitro_MM "Para~
      143 123456               renal_c~ Kidn~ "Fractio~ "0.0~ <NA>  Kidney_pla~  <NA> 
      144 123456               renal_c~ Kidn~ "Plasma ~ "24"  ml/m~ Kidney_pla~  <NA> 
      145 123456               renal_c~ Kidn~ "Specifi~ "66"  1/min Kidney_pla~ "Para~
      146 123456               biliary~ Bili~ "Fractio~ "0.0~ <NA>  n45678       <NA> 
      147 123456               biliary~ Bili~ "Lipophi~ "2.8~ Log ~ n45678       <NA> 
      148 123456               biliary~ Bili~ "Plasma ~ "12"  ml/m~ n45678       <NA> 
      149 123456               biliary~ Bili~ "Specifi~ "34"  1/min n45678      "Para~
      150 123456               inhibit~ Comp~ "Ki, CYP~ "2"   µmol~ comp_inh    "c264~
      151 123456               inhibit~ Unco~ "Ki, CYP~ "1.6~ µmol~ uncomp_inh  "Para~
      152 123456               inhibit~ Nonc~ "Ki, CYP~ "3"   µmol~ non-comp_i~ "c443~
      153 123456               inhibit~ Mixe~ "Ki_c, C~ "1"   µmol~ mixed_inh   "c443~
      154 123456               inhibit~ Mixe~ "Ki_u, C~ "1"   µmol~ mixed_inh   "Para~
      155 123456               inhibit~ Irre~ "kinact,~ "2"   1/min irr_ing_2   "Para~
      156 123456               inhibit~ Irre~ "K_kinac~ "1"   µmol~ irr_ing_2   "R24-~
      157 123456               inhibit~ Irre~ "Ki, CYP~ "2"   µmol~ irr_ing_2   "c264~
      158 123456               inhibit~ Comp~ "Ki, ABC~ "23"  µmol~ test        "Para~
      159 123456               inhibit~ Irre~ "kinact,~ "1.6~ 1/min irr_3       "c319~
      160 123456               inhibit~ Irre~ "K_kinac~ "6"   µmol~ irr_3       "c319~
      161 123456               inhibit~ Irre~ "Ki, CYP~ "6"   µmol~ irr_3       "Assu~
      162 123456               inducti~ Indu~ "EC50, C~ "1"   µmol~ induction   "Para~
      163 123456               inducti~ Indu~ "Emax, C~ "67"  <NA>  induction   "c443~
      164 123456               inducti~ Indu~ "EC50, G~ "1"   µmol~ GABRG2-ind  "Para~
      165 123456               inducti~ Indu~ "Emax, G~ "200" <NA>  GABRG2-ind  "Para~
      166 Perpetrator_2        physico~ lipo~ "Optimiz~ "2.5" Log ~ <NA>        "R13-~
      167 Perpetrator_2        physico~ frac~ "Templet~ "17"  %     <NA>        "R13-~
      168 Perpetrator_2        physico~ mole~  <NA>     "822~ g/mol <NA>         <NA> 
      169 Perpetrator_2        physico~ pKa   "base"    "7.9" <NA>  <NA>        "R24-~
      170 Perpetrator_2        physico~ pKa   "acid"    "1.7" <NA>  <NA>        "R24-~
      171 Perpetrator_2        physico~ solu~ "Aqueous~ "280~ mg/l  <NA>        "R20-~
      172 Perpetrator_2        physico~ solu~ "test, p~ "345" mg/l  <NA>         <NA> 
      173 Perpetrator_2        hepatic~ Hepa~ "Measuri~ "12"  min   In vitro h~ "c319~
      174 Perpetrator_2        hepatic~ Hepa~ "Residua~ "23"  %     In vitro h~ "c319~
      175 Perpetrator_2        renal_c~ Glom~ "GFR fra~ "1"   <NA>  GFR         "R20-~
      176 Rifampicin           physico~ lipo~ "Optimiz~ "2.5" Log ~ <NA>        "R13-~
      177 Rifampicin           physico~ frac~ "Templet~ "17"  %     <NA>        "R13-~
      178 Rifampicin           physico~ mole~  <NA>     "822~ g/mol <NA>        "R13-~
      179 Rifampicin           physico~ pKa   "base"    "7.9" <NA>  <NA>        "R24-~
      180 Rifampicin           physico~ pKa   "acid"    "1.7" <NA>  <NA>        "R24-~
      181 Rifampicin           physico~ solu~ "Aqueous~ "280~ mg/l  <NA>        "R20-~
      182 Rifampicin           physico~ solu~ "test, p~ "345" mg/l  <NA>         <NA> 
      183 Rifampicin           physico~ inte~ "PK-Sim ~ "3.8~ cm/m~ <NA>        "PK-S~
      184 Rifampicin           metabol~ Meta~ "Enzyme ~ "1"   µmol~ Nakajima 2~  <NA> 
      185 Rifampicin           metabol~ Meta~ "Vmax, A~ "12"  µmol~ Nakajima 2~  <NA> 
      186 Rifampicin           metabol~ Meta~ "Km, AAD~ "195~ µmol~ Nakajima 2~ "Para~
      187 Rifampicin           metabol~ Meta~ "kcat, A~ "9.8~ 1/min Nakajima 2~ "R24-~
      188 Rifampicin           hepatic~ Live~ "Fractio~ "0.1~ <NA>  test123      <NA> 
      189 Rifampicin           hepatic~ Live~ "Lipophi~ "2.5" Log ~ test123      <NA> 
      190 Rifampicin           hepatic~ Live~ "Plasma ~ "12"  ml/m~ test123      <NA> 
      191 Rifampicin           hepatic~ Live~ "Specifi~ "666" 1/h   test123     "c443~
      192 Rifampicin           transpo~ Acti~ "Transpo~ "1"   nmol~ Collett 20~  <NA> 
      193 Rifampicin           transpo~ Acti~ "Vmax, P~ "0"   µmol~ Collett 20~  <NA> 
      194 Rifampicin           transpo~ Acti~ "Km, P-g~ "55"  µmol~ Collett 20~ "Para~
      195 Rifampicin           transpo~ Acti~ "kcat, P~ "0.6~ 1/min Collett 20~ "R20-~
      196 Rifampicin           transpo~ Acti~ "Transpo~ "1"   µmol~ Tirona 2003  <NA> 
      197 Rifampicin           transpo~ Acti~ "Vmax, O~ "0"   µmol~ Tirona 2003  <NA> 
      198 Rifampicin           transpo~ Acti~ "Km, OAT~ "1.5" µmol~ Tirona 2003 "Para~
      199 Rifampicin           transpo~ Acti~ "kcat, O~ "7.7~ 1/min Tirona 2003 "R20-~
      200 Rifampicin           renal_c~ Tubu~ "Tubular~ "33"  l/min RenCL_rif    <NA> 
      201 Rifampicin           renal_c~ Tubu~ "TSspec"  "55"  1/min RenCL_rif   "Assu~
      202 Rifampicin           biliary~ Bili~ "Fractio~ "0.1~ <NA>  BCL         "PK-S~
      203 Rifampicin           biliary~ Bili~ "Lipophi~ "2.5" Log ~ BCL         "PK-S~
      204 Rifampicin           biliary~ Bili~ "Plasma ~ "12"  ml/m~ BCL         "Assu~
      205 Rifampicin           inhibit~ Comp~ "Ki, CYP~ "18.~ µmol~ Kajosaari ~ "R18-~
      206 Rifampicin           inhibit~ Comp~ "Ki, CYP~ "30.~ µmol~ Kajosaari ~ "R18-~
      207 Rifampicin           inhibit~ Comp~ "Ki, P-g~ "169" µmol~ Reitman 20~ "R24-~
      208 Rifampicin           inhibit~ Comp~ "Ki, OAT~ "0.4~ µmol~ Hirano 2006 "R24-~
      209 Rifampicin           inhibit~ Comp~ "Ki, OAT~ "0.9" µmol~ Annaert 20~ "R24-~
      210 Rifampicin           inhibit~ Comp~ "Ki, CYP~ "23"  µmol~ Comp        "Para~
      211 Rifampicin           inhibit~ Mixe~ "Ki_c, C~ "23"  µmol~ Mixed       "R18-~
      212 Rifampicin           inhibit~ Mixe~ "Ki_u, C~ "3"   µmol~ Mixed       "Para~
      213 Rifampicin           inhibit~ Irre~ "kinact,~ "2"   1/min Irreversib~ "R24-~
      214 Rifampicin           inhibit~ Irre~ "K_kinac~ "22"  µmol~ Irreversib~ "R24-~
      215 Rifampicin           inhibit~ Irre~ "Ki, CYP~ "22"  µmol~ Irreversib~ "Assu~
      216 Rifampicin           inducti~ Indu~ "EC50, C~ "0.3~ µmol~ Templeton ~ "R24-~
      217 Rifampicin           inducti~ Indu~ "Emax, C~ "9"   <NA>  Templeton ~ "R24-~
      218 Rifampicin           inducti~ Indu~ "EC50, P~ "0.3~ µmol~ Greiner 19~ "R20-~
      219 Rifampicin           inducti~ Indu~ "Emax, P~ "2.5" <NA>  Greiner 19~ "R20-~
      220 Rifampicin           inducti~ Indu~ "EC50, O~ "0.3~ µmol~ Dixit 2007  "Para~
      221 Rifampicin           inducti~ Indu~ "Emax, O~ "0.3~ <NA>  Dixit 2007  "Para~
      222 Rifampicin           inducti~ Indu~ "EC50, A~ "0.3~ µmol~ Assumed     "R20-~
      223 Rifampicin           inducti~ Indu~ "Emax, A~ "0.9~ <NA>  Assumed     "Para~
      224 Rifampicin           inducti~ Indu~ "EC50, C~ "0.3~ µmol~ Buckley 20~ "Para~
      225 Rifampicin           inducti~ Indu~ "Emax, C~ "3.2" <NA>  Buckley 20~ "R20-~
      226 Rifampicin           inducti~ Indu~ "EC50, C~ "0.3~ µmol~ Chen 2010   "P07-~
      227 Rifampicin           inducti~ Indu~ "Emax, C~ "0.6~ <NA>  Chen 2010   "Para~
      228 Rifampicin           inducti~ Indu~ "EC50, C~ "0.3~ µmol~ Rae 2001    "P07-~
      229 Rifampicin           inducti~ Indu~ "Emax, C~ "0.8" <NA>  Rae 2001    "R24-~
      230 test                 physico~ lipo~ "Measure~ "2"   Log ~ <NA>        "Para~
      231 test                 physico~ frac~ "Measure~ "0.4~ <NA>  <NA>        "Para~
      232 test                 physico~ mole~  <NA>     "123" g/mol <NA>         <NA> 
      233 test                 physico~ halo~ "Br"      "1"   <NA>  <NA>         <NA> 
      234 test                 physico~ halo~ "Cl"      "1"   <NA>  <NA>         <NA> 
      235 test                 physico~ pKa   "base"    "2"   <NA>  <NA>         <NA> 
      236 test                 physico~ solu~ "Measure~ "3"   mg/l  <NA>        "Para~
      237 test                 physico~ solu~ "test, p~ "5"   mg/l  <NA>         <NA> 

