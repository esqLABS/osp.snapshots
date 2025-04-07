# print.parameter_collection produces correct output

    Code
      print(params)
    Output
      Parameter Collection with 2 parameters:
      Path                                     | Value           | Unit
      -----------------------------------------|-----------------|----------------
      Organism|Liver|Volume                    | 1.5             | L
      Organism|Kidney|GFR                      | 120             | ml/min

---

    Code
      print(empty_params)
    Output
      Empty Parameter Collection

---

    Code
      print(params_with_long)
    Output
      Parameter Collection with 3 parameters:
      Path                                     | Value           | Unit
      -----------------------------------------|-----------------|----------------
      Organism|Liver|Volume                    | 1.5             | L
      Organism|Kidney|GFR                      | 120             | ml/min
      ...g|Path|Very|Long|Path|Very|Long|Path| | 42              | units

