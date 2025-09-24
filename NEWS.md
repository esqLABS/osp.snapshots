# osp.snapshots 0.1.0

* New `load_snapshot()` function to import PKSIM project snapshots from JSON 
  files, URLs, or predefined templates.

* New `export_snapshot()` function to save modified snapshots back to JSON files
  for import into PKSIM.

* Complete R6 class implementations for all major PKSIM building blocks:
  `Individual`, `Compound`, `Formulation`, `Population`, `Protocol`, `Event`, 
  `ExpressionProfile`, and `Parameter`.

* New data frame conversion functions for all building block types:
  `get_individuals_dfs()`, `get_compounds_dfs()`, `get_formulations_dfs()`, 
  `get_populations_dfs()`, `get_protocols_dfs()`, `get_events_dfs()`, 
  `get_expression_profiles_dfs()`, and `get_observed_data_dfs()`.

* New creation functions: `create_individual()`, `create_formulation()`, and 
  `create_parameter()` for building new building blocks.

* New management functions: `add_individual()`, `add_formulation()`, 
  `add_expression_profile()`, `remove_individual()`, `remove_formulation()`, 
  `remove_population()`, and `remove_expression_profile()`.

* Full integration with `ospsuite::DataSet` objects for observed data.

* Comprehensive input validation for species, populations, genders, and units.

* Time conversion utilities between OSPSuite and R `lubridate` formats.

* Structured print methods for all building block classes.
