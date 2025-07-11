#' Compound class for OSP snapshot compounds
#'
#' @description
#' An R6 class that represents a compound in an OSP snapshot.
#' This class provides methods to access different properties of a compound
#' and display a summary of its information.
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom glue glue
#' @export
Compound <- R6::R6Class(
  classname = "Compound",
  public = list(
    #' @description
    #' Create a new Compound object
    #' @param data Raw compound data from a snapshot
    #' @return A new Compound object
    initialize = function(data) {
      private$.data <- data
      private$initialize_parameters()
    },

    #' @description
    #' Print a summary of the compound including its properties and parameters.
    #'
    #' @param ... Additional arguments passed to print methods
    #'
    #' @return Invisibly returns the Compound object for method chaining
    print = function(...) {
      output <- cli::cli_format_method({
        cli::cli_h1("Compound: {self$name}")

        # Display basic compound properties
        cli::cli_h2("Basic Properties")
        if (!is.null(self$is_small_molecule)) {
          molecule_type <- if (self$is_small_molecule) {
            "Small Molecule"
          } else {
            "Large Molecule"
          }
          cli::cli_li("Type: {molecule_type}")
        }

        if (!is.null(self$plasma_protein_binding_partner)) {
          cli::cli_li(
            "Plasma Protein Binding Partner: {self$plasma_protein_binding_partner}"
          )
        }

        # Display molecular weight
        if (!is.na(self$molecular_weight)) {
          cli::cli_li(
            "Molecular Weight: {self$molecular_weight} {self$molecular_weight_unit}"
          )
        }

        # Display calculation methods
        if (
          !is.null(self$calculation_methods) &&
            length(self$calculation_methods) > 0
        ) {
          cli::cli_h2("Calculation Methods")
          if (!is.null(self$calculation_methods$partition_coef)) {
            cli::cli_li(
              "Partition Coefficient: {self$calculation_methods$partition_coef}"
            )
          }
          if (!is.null(self$calculation_methods$permeability)) {
            cli::cli_li("Permeability: {self$calculation_methods$permeability}")
          }
        }

        # Display physicochemical properties using custom print methods
        cli::cli_h2("Physicochemical Properties")
        properties <- list(
          lipophilicity = "Lipophilicity",
          fraction_unbound = "Fraction Unbound",
          solubility = "Solubility",
          intestinal_permeability = "Intestinal Permeability",
          pka_types = "pKa Types"
        )

        for (prop_name in names(properties)) {
          prop_data <- self[[prop_name]]
          if (!is.null(prop_data) && length(prop_data) > 0) {
            # Use the custom print method for physicochemical properties directly
            print.physicochemical_property(prop_data)
          }
        }

        # Display processes using custom print method
        if (!is.null(self$processes) && length(self$processes) > 0) {
          cli::cli_h2("Processes")
          print.compound_processes(self$processes)
        }

        # Display additional parameters using custom print method
        if (!is.null(self$parameters) && length(self$parameters) > 0) {
          cli::cli_h2("Additional Parameters")
          print.compound_additional_parameters(self$parameters)
        }
      })

      cat(output, sep = "\n")
      invisible(self)
    },

    #' @description
    #' Convert compound data to tibbles for analysis
    #' @return A tibble containing compound parameter data in the same format as legacy code
    to_df = function() {
      compound_name <- self$name

      # Initialize the dataframe
      df <- tibble::tibble(
        name = character(),
        parameter = character(),
        type = character(),
        value = character(),
        unit = character(),
        source = character()
      )

      # Process basic physicochemical properties
      for (p in c(
        "lipophilicity",
        "fraction_unbound",
        "molecular_weight",
        "halogens",
        "pKa",
        "solubility",
        "intestinal_permeability"
      )) {
        prop_data <- private$.get_property_data(p)
        if (!is.null(prop_data) && length(prop_data) > 0) {
          rows <- private$.property_to_rows(
            compound_name,
            p,
            prop_data
          )
          df <- dplyr::bind_rows(df, rows)
        }
      }

      # Process protein binding partners
      if (!is.null(private$.protein_binding_partners)) {
        rows <- private$.protein_binding_partners_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process metabolizing enzymes
      if (!is.null(private$.metabolizing_enzymes)) {
        rows <- private$.metabolizing_enzymes_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process hepatic clearance
      if (!is.null(private$.hepatic_clearance)) {
        rows <- private$.hepatic_clearance_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process transporter proteins
      if (!is.null(private$.transporter_proteins)) {
        rows <- private$.transporter_proteins_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process renal clearance
      if (!is.null(private$.renal_clearance)) {
        rows <- private$.renal_clearance_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process biliary clearance
      if (!is.null(private$.biliary_clearance)) {
        rows <- private$.biliary_clearance_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process inhibition
      if (!is.null(private$.inhibition)) {
        rows <- private$.inhibition_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      # Process induction
      if (!is.null(private$.induction)) {
        rows <- private$.induction_to_table(
          compound_name
        )
        df <- dplyr::bind_rows(df, rows)
      }

      return(df)
    }
  ),

  private = list(
    .data = NULL,
    .parameters = NULL,
    .protein_binding_partners = NULL,
    .metabolizing_enzymes = NULL,
    .hepatic_clearance = NULL,
    .transporter_proteins = NULL,
    .renal_clearance = NULL,
    .biliary_clearance = NULL,
    .inhibition = NULL,
    .induction = NULL,

    initialize_parameters = function() {
      if (
        !is.null(private$.data$Parameters) &&
          length(private$.data$Parameters) > 0
      ) {
        # Create parameters list
        private$.parameters <- lapply(
          private$.data$Parameters,
          function(param_data) Parameter$new(param_data)
        )
        # Name the parameters by their paths for easier access
        if (length(private$.parameters) > 0) {
          names(private$.parameters) <- vapply(
            private$.parameters,
            function(p) p$path %||% "Unknown",
            character(1)
          )
        }
        # Add collection class for custom printing
        class(private$.parameters) <- c("parameter_collection", "list")
      } else {
        # Initialize empty parameter list
        private$.parameters <- list()
        class(private$.parameters) <- c("parameter_collection", "list")
      }

      # Initialize processed data
      if (!is.null(private$.data$Processes)) {
        private$.extract_process_data()
      }
    },

    .extract_process_data = function() {
      processes <- private$.data$Processes

      # Extract protein binding partners
      all_bindings <- purrr::keep(
        processes,
        ~ .x$InternalName == "SpecificBinding"
      )
      if (length(all_bindings) > 0) {
        private$.protein_binding_partners <- private$.extract_protein_binding_partners(
          all_bindings
        )
      }

      # Extract metabolizing enzymes
      all_metabolizations <- purrr::keep(
        processes,
        ~ grepl("Metabolization|rCYP", .x$InternalName)
      )
      if (length(all_metabolizations) > 0) {
        private$.metabolizing_enzymes <- private$.extract_metabolizing_enzymes(
          all_metabolizations
        )
      }

      # Extract hepatic clearance
      private$.hepatic_clearance <- private$.extract_hepatic_clearance()

      # Extract transporter proteins
      private$.transporter_proteins <- private$.extract_transporter_proteins()

      # Extract renal clearance
      private$.renal_clearance <- private$.extract_renal_clearance()

      # Extract biliary clearance
      private$.biliary_clearance <- private$.extract_biliary_clearance()

      # Extract inhibition
      private$.inhibition <- private$.extract_inhibition()

      # Extract induction
      private$.induction <- private$.extract_induction()
    },

    # Utility function to extract value and unit from property entry
    .extract_property_value = function(entry) {
      if (is.null(entry$Parameters) || length(entry$Parameters) == 0) {
        return("N/A")
      }

      # Find the main property parameter (usually the first one that's not a modifier)
      main_param <- NULL
      for (param in entry$Parameters) {
        param_name <- param$Name %||% ""
        # Skip modifier parameters like "Reference pH"
        if (!grepl("Reference|pH|Modifier", param_name, ignore.case = TRUE)) {
          main_param <- param
          break
        }
      }

      # If no main parameter found, use the first one
      if (is.null(main_param) && length(entry$Parameters) > 0) {
        main_param <- entry$Parameters[[1]]
      }

      if (is.null(main_param)) {
        return("N/A")
      }

      # Check if this parameter has a TableFormula (table data)
      if (
        !is.null(main_param$TableFormula) &&
          !is.null(main_param$TableFormula$Points)
      ) {
        points <- main_param$TableFormula$Points
        x_name <- main_param$TableFormula$XName %||% "X"
        y_unit <- main_param$TableFormula$YUnit %||% main_param$Unit %||% ""

        # Format table points as "X1: Y1, X2: Y2, ..."
        table_entries <- vapply(
          points,
          function(point) {
            x_val <- point$X
            y_val <- point$Y
            if (y_unit != "") {
              glue::glue("{x_name} {x_val}: {y_val} {y_unit}")
            } else {
              glue::glue("{x_name} {x_val}: {y_val}")
            }
          },
          character(1)
        )

        return(paste(table_entries, collapse = ", "))
      }

      # Regular parameter (non-table)
      value <- main_param$Value %||% "N/A"
      unit <- main_param$Unit %||% ""

      if (unit != "" && value != "N/A") {
        return(glue::glue("{value} {unit}"))
      } else {
        return(as.character(value))
      }
    },

    # Utility function to get source information
    .get_source = function(value_origin) {
      if (is.null(value_origin)) {
        return(NA_character_)
      }
      if (value_origin$Source == "ParameterIdentification") {
        return("Parameter optimization")
      } else {
        if (
          is.null(value_origin$Description) || value_origin$Description == ""
        ) {
          return(NA_character_)
        } else {
          return(value_origin$Description)
        }
      }
    },

    # Format values as strings
    .format_value = function(my_vector) {
      return(sapply(my_vector, function(nr) {
        if (is.character(nr)) {
          return(nr)
        } else if (is.null(nr)) {
          return(NULL)
        } else {
          return(as.character(nr))
        }
      }))
    },

    # Extract property data based on property name
    .get_property_data = function(property) {
      switch(
        property,
        "lipophilicity" = private$.extract_lipophilicity(),
        "fraction_unbound" = private$.extract_fraction_unbound(),
        "molecular_weight" = private$.extract_molecular_weight(),
        "halogens" = private$.extract_halogens(),
        "pKa" = private$.extract_pka(),
        "solubility" = private$.extract_solubility(),
        "intestinal_permeability" = private$.extract_intestinal_permeability(),
        NULL
      )
    },

    # Convert property data to table rows
    .property_to_rows = function(
      compound_name,
      parameter,
      prop_data
    ) {
      if (parameter == "molecular_weight" && !is.list(prop_data)) {
        return(tibble::tibble(
          name = compound_name,
          parameter = parameter,
          type = NA_character_,
          value = private$.format_value(prop_data$Value),
          unit = prop_data$Unit %||% NA_character_,
          source = prop_data$Source
        ))
      } else if (is.list(prop_data)) {
        rows <- tibble::tibble(
          name = compound_name,
          parameter = parameter,
          type = if (parameter == "solubility") {
            purrr::map_chr(prop_data, ~ .x$table_name %||% names(prop_data))
          } else {
            names(prop_data)
          },
          value = purrr::map_chr(
            prop_data,
            ~ {
              if (!is.null(.x$pH)) {
                paste0(
                  "pH ",
                  .x$pH,
                  ": ",
                  private$.format_value(.x$Value),
                  collapse = "\n"
                )
              } else {
                private$.format_value(.x$Value)
              }
            }
          ),
          unit = purrr::map_chr(prop_data, ~ .x$Unit %||% NA_character_),
          source = purrr::map_chr(prop_data, ~ .x$Source)
        )
        return(rows)
      }
      return(tibble::tibble())
    },

    # Extract lipophilicity data
    .extract_lipophilicity = function() {
      lipophilicity_data <- private$.data$Lipophilicity
      if (is.null(lipophilicity_data)) {
        return(NULL)
      }

      names <- purrr::map_chr(lipophilicity_data, "Name")
      data <- vector("list", length(names))
      names(data) <- names

      for (j in seq_along(names)) {
        data[[j]] <- private$.extract_parameters(
          lipophilicity_data[[j]]$Parameters,
          "Lipophilicity"
        )
      }
      return(data)
    },

    # Extract fraction unbound data
    .extract_fraction_unbound = function() {
      fraction_unbound_data <- private$.data$FractionUnbound
      if (is.null(fraction_unbound_data)) {
        return(NULL)
      }

      names <- purrr::map_chr(fraction_unbound_data, "Name")
      data <- vector("list", length(names))
      names(data) <- names

      for (j in seq_along(names)) {
        data[[j]] <- private$.extract_parameters(
          fraction_unbound_data[[j]]$Parameters,
          "Fraction unbound (plasma, reference value)"
        )
      }
      return(data)
    },

    # Extract molecular weight
    .extract_molecular_weight = function() {
      return(list(private$.extract_parameters(
        private$.data$Parameters,
        "Molecular weight"
      )))
    },

    # Extract pKa data
    .extract_pka = function() {
      pKa_data <- private$.data$PkaTypes
      if (is.null(pKa_data)) {
        return(NULL)
      }

      names <- purrr::map_chr(pKa_data, "Type")
      data <- vector("list", length(names))
      names(data) <- names

      for (j in seq_along(names)) {
        data[[j]] <- list()
        pka_source <- pKa_data[[j]]
        data[[j]]$Value <- pka_source$Pka
        data[[j]]$Source <- private$.get_source(pka_source$ValueOrigin)
      }
      names(data) <- tolower(names)
      return(data)
    },

    # Extract solubility data
    .extract_solubility = function() {
      solubility_data <- private$.data$Solubility
      if (is.null(solubility_data)) {
        return(NULL)
      }

      names <- purrr::map_chr(solubility_data, "Name")
      data <- list()

      for (j in seq_along(names)) {
        params <- solubility_data[[j]]$Parameters
        param_names <- purrr::map_chr(params, ~ .x$Name)

        if ("Solubility at reference pH" %in% param_names) {
          id <- names[j]
          pH <- purrr::keep(params, ~ .x$Name == "Reference pH")[[1]]$Value
          gain_per_charge <- purrr::list_c(purrr::keep(
            params,
            ~ .x$Name == "Solubility gain per charge"
          ))$Value %||%
            1000
          name <- if (length(names) > 1) {
            paste0(names[j], ", pH ", pH)
          } else {
            paste("pH", pH)
          }
          source <- purrr::list_c(purrr::keep(
            params,
            ~ .x$Name == "Solubility at reference pH"
          ))
          data[[id]] <- list()
          data[[id]]$Value <- source$Value
          data[[id]]$Unit <- source$Unit
          data[[id]]$Source <- private$.get_source(source$ValueOrigin)
          data[[id]]$ref_pH <- pH
          data[[id]]$gain_per_charge <- gain_per_charge
          data[[id]]$table_name <- name
        } else if ("Solubility table" %in% param_names) {
          id <- names[j]
          data[[id]] <- list()
          source <- purrr::keep(params, ~ .x$Name == "Solubility table")[[1]]
          data[[id]]$Value <- purrr::map_dbl(source$TableFormula$Points, ~ .$Y)
          data[[id]]$Unit <- source$Unit
          data[[id]]$Source <- private$.get_source(source$ValueOrigin)
          data[[id]]$pH <- purrr::map_dbl(source$TableFormula$Points, ~ .$X)
          data[[id]]$table_name <- id
        }
      }
      return(data)
    },

    # Extract intestinal permeability data
    .extract_intestinal_permeability = function() {
      intestinal_permeability_data <- private$.data$IntestinalPermeability
      if (is.null(intestinal_permeability_data)) {
        return(NULL)
      }

      names <- purrr::map_chr(intestinal_permeability_data, "Name")
      data <- vector("list", length(names))
      names(data) <- names

      for (j in seq_along(names)) {
        data[[j]] <- private$.extract_parameters(
          intestinal_permeability_data[[j]]$Parameters,
          "Specific intestinal permeability (transcellular)"
        )
      }
      return(data)
    },

    # Extract halogens data
    .extract_halogens = function() {
      halogen_data <- purrr::keep(
        private$.data$Parameters,
        ~ .x$Name %in% c("F", "Cl", "Br", "I")
      )
      if (length(halogen_data) == 0) {
        return(NULL)
      }

      names <- purrr::map_chr(halogen_data, "Name")
      data <- vector("list", length(names))
      names(data) <- names

      for (j in seq_along(names)) {
        data[[j]] <- list()
        data[[j]]$Value <- halogen_data[[j]]$Value
        data[[j]]$Source <- private$.get_source(halogen_data[[j]]$ValueOrigin)
      }
      return(data)
    },

    # Extract parameters utility function
    .extract_parameters = function(parameters_list, property_name) {
      source <- purrr::keep(parameters_list, ~ .x$Name == property_name) %>%
        purrr::list_c()
      if (!is.null(source)) {
        data <- list()
        data$Value <- as.numeric(source$Value)
        data$Unit <- source$Unit %||% NA_character_
        data$Source <- private$.get_source(source$ValueOrigin)
        return(data)
      } else {
        return(NULL)
      }
    },

    # Extract protein binding partners
    .extract_protein_binding_partners = function(all_bindings) {
      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_bindings,
        "DataSource"
      )))

      binding_data <- list()

      for (datasource in datasource_names) {
        # Filter bindings by datasource
        bindings <- purrr::keep(
          all_bindings,
          ~ .x$DataSource == datasource
        )

        # Store all binding data for this datasource
        binding_data[[datasource]] <- purrr::map(
          bindings,
          function(binding) {
            parameter_names <- purrr::list_c(purrr::map(
              binding$Parameters,
              "Name"
            ))

            binding_params <- purrr::map(
              purrr::set_names(binding$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata about the binding
            binding_params$Process <- binding$InternalName
            binding_params$Molecule <- binding$Molecule
            binding_params$DataSource <- binding$DataSource

            return(binding_params)
          }
        )
      }

      return(binding_data)
    },

    # Table conversion methods for protein binding partners
    .protein_binding_partners_to_table = function(
      compound_name
    ) {
      purrr::imap(
        private$.protein_binding_partners,
        function(datasource_bindings, datasource_name) {
          purrr::map(datasource_bindings, function(binding) {
            molecule_name <- binding$Molecule

            # Extract parameters, excluding metadata
            data <- binding |>
              purrr::discard_at(c("Process", "Molecule", "DataSource"))

            purrr::imap(data, function(param, param_name) {
              tibble::tibble(
                name = compound_name,
                parameter = "protein_binding_partners",
                type = paste(param_name, molecule_name, sep = ", "),
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract metabolizing enzymes
    .extract_metabolizing_enzymes = function(all_metabolizations) {
      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_metabolizations,
        "DataSource"
      )))

      metabolization_data <- list()

      for (datasource in datasource_names) {
        # Filter metabolizations by datasource
        metabolizations <- purrr::keep(
          all_metabolizations,
          ~ .x$DataSource == datasource
        )

        # Store all metabolization data for this datasource
        metabolization_data[[datasource]] <- purrr::map(
          metabolizations,
          function(metabolization) {
            parameter_names <- purrr::list_c(purrr::map(
              metabolization$Parameters,
              "Name"
            ))

            metabolization_params <- purrr::map(
              purrr::set_names(metabolization$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata about the metabolization
            metabolization_params$Process <- metabolization$InternalName
            metabolization_params$Molecule <- metabolization$Molecule
            metabolization_params$Metabolite <- metabolization$Metabolite
            metabolization_params$DataSource <- metabolization$DataSource

            return(metabolization_params)
          }
        )
      }

      return(metabolization_data)
    },

    # Metabolizing enzymes table conversion
    .metabolizing_enzymes_to_table = function(compound_name) {
      if (
        is.null(private$.metabolizing_enzymes) ||
          length(private$.metabolizing_enzymes) == 0
      ) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.metabolizing_enzymes,
        function(datasource_metabolizations, datasource_name) {
          purrr::map(datasource_metabolizations, function(metabolization) {
            molecule_name <- metabolization$Molecule
            metabolite <- metabolization$Metabolite

            # Extract parameters, excluding metadata
            data <- metabolization |>
              purrr::discard_at(c(
                "Process",
                "Molecule",
                "Metabolite",
                "DataSource"
              ))

            purrr::imap(data, function(param, param_name) {
              if (!is.null(metabolite)) {
                type_string <- paste(
                  paste(
                    param_name,
                    molecule_name,
                    sep = ", "
                  ),
                  metabolite,
                  sep = "\n-"
                )
              } else {
                type_string <- paste(
                  param_name,
                  molecule_name,
                  sep = ", "
                )
              }
              tibble::tibble(
                name = compound_name,
                parameter = "metabolizing_enzymes",
                type = type_string,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract hepatic clearance
    .extract_hepatic_clearance = function() {
      processes <- private$.data$Processes
      if (is.null(processes)) {
        return(NULL)
      }

      all_hepatic <- purrr::keep(
        processes,
        ~ grepl(
          "Hepatocytes|LiverClearance|LiverMicrosomeR|LiverMicrosomeH",
          .x$InternalName
        )
      )

      if (length(all_hepatic) == 0) {
        return(NULL)
      }

      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_hepatic,
        "DataSource"
      )))

      hepatic_data <- list()

      for (datasource in datasource_names) {
        # Filter hepatic processes by datasource
        hepatic_processes <- purrr::keep(
          all_hepatic,
          ~ .x$DataSource == datasource
        )

        # Store all hepatic data for this datasource
        hepatic_data[[datasource]] <- purrr::map(
          hepatic_processes,
          function(hepatic) {
            parameter_names <- purrr::list_c(purrr::map(
              hepatic$Parameters,
              "Name"
            ))

            hepatic_params <- purrr::map(
              purrr::set_names(hepatic$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata
            hepatic_params$Process <- hepatic$InternalName
            hepatic_params$DataSource <- hepatic$DataSource

            return(hepatic_params)
          }
        )
      }

      return(hepatic_data)
    },

    # Hepatic clearance table conversion
    .hepatic_clearance_to_table = function(compound_name) {
      if (
        is.null(private$.hepatic_clearance) ||
          length(private$.hepatic_clearance) == 0
      ) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.hepatic_clearance,
        function(datasource_hepatic, datasource_name) {
          purrr::map(datasource_hepatic, function(hepatic) {
            # Extract parameters, excluding metadata
            data <- hepatic |>
              purrr::discard_at(c("Process", "DataSource"))

            purrr::imap(data, function(param, param_name) {
              tibble::tibble(
                name = compound_name,
                parameter = "hepatic_clearance",
                type = param_name,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract transporter proteins
    .extract_transporter_proteins = function() {
      processes <- private$.data$Processes
      if (is.null(processes)) {
        return(NULL)
      }

      all_transports <- purrr::keep(
        processes,
        ~ grepl("ActiveTransport", .x$InternalName)
      )

      if (length(all_transports) == 0) {
        return(NULL)
      }

      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_transports,
        "DataSource"
      )))

      transporter_data <- list()

      for (datasource in datasource_names) {
        # Filter transports by datasource
        transports <- purrr::keep(
          all_transports,
          ~ .x$DataSource == datasource
        )

        # Store all transport data for this datasource
        transporter_data[[datasource]] <- purrr::map(
          transports,
          function(transport) {
            parameter_names <- purrr::list_c(purrr::map(
              transport$Parameters,
              "Name"
            ))

            transport_data <- purrr::map(
              purrr::set_names(transport$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Keep all parameters - no filtering based on source
            # This ensures all transporter data is accessible to the user

            # Include metadata about the transport
            transport_data$Process <- transport$InternalName
            transport_data$Molecule <- transport$Molecule
            transport_data$DataSource <- transport$DataSource

            return(transport_data)
          }
        )
      }

      return(transporter_data)
    },

    # Transporter proteins table conversion
    .transporter_proteins_to_table = function(compound_name) {
      if (
        is.null(private$.transporter_proteins) ||
          length(private$.transporter_proteins) == 0
      ) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.transporter_proteins,
        function(datasource_transports, datasource_name) {
          purrr::map(datasource_transports, function(transport) {
            molecule_name <- transport$Molecule
            process <- transport$Process

            # Extract parameters, excluding metadata
            data <- transport |>
              purrr::discard_at(
                c("Process", "Molecule", "DataSource")
              )

            purrr::imap(data, function(param, param_name) {
              type_string <- paste(param_name, molecule_name, sep = ", ")

              tibble::tibble(
                name = compound_name,
                parameter = "transporter_proteins",
                type = type_string,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract renal clearance
    .extract_renal_clearance = function() {
      processes <- private$.data$Processes
      if (is.null(processes)) {
        return(NULL)
      }

      all_renal <- purrr::keep(
        processes,
        ~ grepl("Tubular|Kidney|Glomerular", .x$InternalName)
      )

      if (length(all_renal) == 0) {
        return(NULL)
      }

      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_renal,
        "DataSource"
      )))

      renal_data <- list()

      for (datasource in datasource_names) {
        # Filter renal processes by datasource
        renal_processes <- purrr::keep(
          all_renal,
          ~ .x$DataSource == datasource
        )

        # Store all renal data for this datasource
        renal_data[[datasource]] <- purrr::map(
          renal_processes,
          function(renal) {
            parameter_names <- purrr::list_c(purrr::map(
              renal$Parameters,
              "Name"
            ))

            renal_params <- purrr::map(
              purrr::set_names(renal$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata
            renal_params$Process <- renal$InternalName
            renal_params$DataSource <- renal$DataSource

            return(renal_params)
          }
        )
      }

      return(renal_data)
    },

    # Renal clearance table conversion
    .renal_clearance_to_table = function(compound_name) {
      if (
        is.null(private$.renal_clearance) ||
          length(private$.renal_clearance) == 0
      ) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.renal_clearance,
        function(datasource_renal, datasource_name) {
          purrr::map(datasource_renal, function(renal) {
            # Extract parameters, excluding metadata
            data <- renal |>
              purrr::discard_at(c("Process", "DataSource"))

            purrr::imap(data, function(param, param_name) {
              tibble::tibble(
                name = compound_name,
                parameter = "renal_clearance",
                type = param_name,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract biliary clearance
    .extract_biliary_clearance = function() {
      processes <- private$.data$Processes
      if (is.null(processes)) {
        return(NULL)
      }

      all_biliary <- purrr::keep(
        processes,
        ~ .x$InternalName == "BiliaryClearance"
      )

      if (length(all_biliary) == 0) {
        return(NULL)
      }

      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_biliary,
        "DataSource"
      )))

      biliary_data <- list()

      for (datasource in datasource_names) {
        # Filter biliary processes by datasource
        biliary_processes <- purrr::keep(
          all_biliary,
          ~ .x$DataSource == datasource
        )

        # Store all biliary data for this datasource
        biliary_data[[datasource]] <- purrr::map(
          biliary_processes,
          function(biliary) {
            parameter_names <- purrr::list_c(purrr::map(
              biliary$Parameters,
              "Name"
            ))

            biliary_params <- purrr::map(
              purrr::set_names(biliary$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata
            biliary_params$Process <- biliary$InternalName
            biliary_params$DataSource <- biliary$DataSource

            return(biliary_params)
          }
        )
      }

      return(biliary_data)
    },

    # Biliary clearance table conversion
    .biliary_clearance_to_table = function(compound_name) {
      if (
        is.null(private$.biliary_clearance) ||
          length(private$.biliary_clearance) == 0
      ) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.biliary_clearance,
        function(datasource_biliary, datasource_name) {
          purrr::map(datasource_biliary, function(biliary) {
            # Extract parameters, excluding metadata
            data <- biliary |>
              purrr::discard_at(c("Process", "DataSource"))

            purrr::imap(data, function(param, param_name) {
              tibble::tibble(
                name = compound_name,
                parameter = "biliary_clearance",
                type = param_name,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract inhibition
    .extract_inhibition = function() {
      processes <- private$.data$Processes
      if (is.null(processes)) {
        return(NULL)
      }

      all_inhibitions <- purrr::keep(
        processes,
        ~ grepl("Inhibition", .x$InternalName)
      )

      if (length(all_inhibitions) == 0) {
        return(NULL)
      }

      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_inhibitions,
        "DataSource"
      )))

      inhibition_data <- list()

      for (datasource in datasource_names) {
        # Filter inhibition processes by datasource
        inhibition_processes <- purrr::keep(
          all_inhibitions,
          ~ .x$DataSource == datasource
        )

        # Store all inhibition data for this datasource
        inhibition_data[[datasource]] <- purrr::map(
          inhibition_processes,
          function(inhibition) {
            parameter_names <- purrr::list_c(purrr::map(
              inhibition$Parameters,
              "Name"
            ))

            inhibition_params <- purrr::map(
              purrr::set_names(inhibition$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata
            inhibition_params$Process <- inhibition$InternalName
            inhibition_params$Molecule <- inhibition$Molecule
            inhibition_params$DataSource <- inhibition$DataSource

            # Handle special case for IrreversibleInhibition
            if (
              inhibition_params$Process == "IrreversibleInhibition" &&
                !("Ki" %in% names(inhibition_params))
            ) {
              inhibition_params$Ki <- inhibition_params$K_kinact_half
              inhibition_params$Ki$Source <- "Assumed Ki=K-kinact-half"
            }

            return(inhibition_params)
          }
        )
      }

      return(inhibition_data)
    },

    # Inhibition table conversion
    .inhibition_to_table = function(compound_name) {
      if (is.null(private$.inhibition) || length(private$.inhibition) == 0) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.inhibition,
        function(datasource_inhibitions, datasource_name) {
          purrr::map(datasource_inhibitions, function(inhibition) {
            molecule_name <- inhibition$Molecule

            # Extract parameters, excluding metadata
            data <- inhibition |>
              purrr::discard_at(c("Process", "Molecule", "DataSource"))

            purrr::imap(data, function(param, param_name) {
              type_string <- paste(
                param_name,
                molecule_name,
                sep = ", "
              )

              tibble::tibble(
                name = compound_name,
                parameter = "inhibition",
                type = type_string,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    },

    # Extract induction
    .extract_induction = function() {
      processes <- private$.data$Processes
      if (is.null(processes)) {
        return(NULL)
      }

      all_inductions <- purrr::keep(processes, ~ .x$InternalName == "Induction")

      if (length(all_inductions) == 0) {
        return(NULL)
      }

      # Use DataSource as primary index to avoid overwrites
      datasource_names <- unique(purrr::list_c(purrr::map(
        all_inductions,
        "DataSource"
      )))

      induction_data <- list()

      for (datasource in datasource_names) {
        # Filter induction processes by datasource
        induction_processes <- purrr::keep(
          all_inductions,
          ~ .x$DataSource == datasource
        )

        # Store all induction data for this datasource
        induction_data[[datasource]] <- purrr::map(
          induction_processes,
          function(induction) {
            parameter_names <- purrr::list_c(purrr::map(
              induction$Parameters,
              "Name"
            ))

            induction_params <- purrr::map(
              purrr::set_names(induction$Parameters, parameter_names),
              function(parameter) {
                list(
                  Value = as.numeric(parameter$Value),
                  Unit = parameter$Unit,
                  Source = private$.get_source(parameter$ValueOrigin)
                )
              }
            )

            # Include metadata
            induction_params$Process <- induction$InternalName
            induction_params$Molecule <- induction$Molecule
            induction_params$DataSource <- induction$DataSource

            return(induction_params)
          }
        )
      }

      return(induction_data)
    },

    # Induction table conversion
    .induction_to_table = function(compound_name) {
      if (is.null(private$.induction) || length(private$.induction) == 0) {
        return(tibble::tibble())
      }

      purrr::imap(
        private$.induction,
        function(datasource_inductions, datasource_name) {
          purrr::map(datasource_inductions, function(induction) {
            molecule_name <- induction$Molecule

            # Extract parameters, excluding metadata
            data <- induction |>
              purrr::discard_at(c("Process", "Molecule", "DataSource"))

            purrr::imap(data, function(param, param_name) {
              type_string <- paste(param_name, molecule_name, sep = ", ")

              tibble::tibble(
                name = compound_name,
                parameter = "induction",
                type = type_string,
                value = private$.format_value(param$Value),
                unit = param$Unit,
                source = param$Source,
                dataSource = datasource_name
              )
            }) %>%
              dplyr::bind_rows()
          }) %>%
            dplyr::bind_rows()
        }
      ) %>%
        dplyr::bind_rows()
    }
  ),

  active = list(
    #' @field data The raw data of the compound (read-only)
    data = function() {
      private$.data
    },

    #' @field name The name of the compound
    name = function(value) {
      if (missing(value)) {
        return(private$.data$Name)
      }
      private$.data$Name <- value
    },

    #' @field is_small_molecule Whether the compound is a small molecule
    is_small_molecule = function(value) {
      if (missing(value)) {
        if (!is.null(private$.data$IsSmallMolecule)) {
          return(private$.data$IsSmallMolecule)
        }
        return(NA)
      }
      private$.data$IsSmallMolecule <- value
    },

    #' @field plasma_protein_binding_partner The plasma protein binding partner of the compound
    plasma_protein_binding_partner = function(value) {
      if (missing(value)) {
        return(private$.data$PlasmaProteinBindingPartner)
      }
      private$.data$PlasmaProteinBindingPartner <- value
    },

    #' @field molecular_weight The molecular weight of the compound
    molecular_weight = function() {
      if (length(private$.data$Parameters) > 0) {
        for (param in private$.data$Parameters) {
          if (param$Name == "Molecular weight") {
            return(param$Value)
          }
        }
      }
      return(NA)
    },

    #' @field molecular_weight_unit The unit of the molecular weight
    molecular_weight_unit = function() {
      if (length(private$.data$Parameters) > 0) {
        for (param in private$.data$Parameters) {
          if (param$Name == "Molecular weight" && !is.null(param$Unit)) {
            return(param$Unit)
          }
        }
      }
      return("")
    },

    #' @field lipophilicity The lipophilicity data of the compound
    lipophilicity = function() {
      result <- private$.data$Lipophilicity
      if (!is.null(result)) {
        class(result) <- c("physicochemical_property", "list")
        attr(result, "property_name") <- "Lipophilicity"
      }
      result
    },

    #' @field fraction_unbound The fraction unbound data of the compound
    fraction_unbound = function() {
      result <- private$.data$FractionUnbound
      if (!is.null(result)) {
        class(result) <- c("physicochemical_property", "list")
        attr(result, "property_name") <- "Fraction Unbound"
      }
      result
    },

    #' @field solubility The solubility data of the compound
    solubility = function() {
      result <- private$.data$Solubility
      if (!is.null(result)) {
        class(result) <- c("physicochemical_property", "list")
        attr(result, "property_name") <- "Solubility"
      }
      result
    },

    #' @field intestinal_permeability The intestinal permeability data of the compound
    intestinal_permeability = function() {
      result <- private$.data$IntestinalPermeability
      if (!is.null(result)) {
        class(result) <- c("physicochemical_property", "list")
        attr(result, "property_name") <- "Intestinal Permeability"
      }
      result
    },

    #' @field pka_types The pKa types of the compound
    pka_types = function() {
      result <- private$.data$PkaTypes
      if (!is.null(result)) {
        class(result) <- c("physicochemical_property", "list")
        attr(result, "property_name") <- "pKa Types"
      }
      result
    },

    #' @field processes The processes of the compound
    processes = function() {
      result <- private$.data$Processes
      if (!is.null(result)) {
        class(result) <- c("compound_processes", "list")
      }
      result
    },

    #' @field calculation_methods The calculation methods of the compound
    calculation_methods = function() {
      calc_methods <- private$.data$CalculationMethods
      if (is.null(calc_methods)) {
        return(NULL)
      }

      result <- list(
        partition_coef = purrr::keep(calc_methods, function(x) {
          grepl("partition coefficient", x)
        }) %>%
          sub(".*- ", "", .),
        permeability = purrr::keep(calc_methods, function(x) {
          grepl("permeability ", x)
        }) %>%
          sub(".*- ", "", .)
      )

      # Add class for custom printing
      class(result) <- c("compound_calculation_methods", "list")
      result
    },

    #' @field parameters The additional parameters of the compound (excluding molecular weight)
    parameters = function(value) {
      if (missing(value)) {
        # Get raw parameters directly from data
        raw_params <- private$.data$Parameters
        if (is.null(raw_params) || length(raw_params) == 0) {
          result <- list()
        } else {
          # Filter out molecular weight parameters
          result <- purrr::keep(raw_params, function(param) {
            param_name <- param$Name %||% ""
            !grepl(
              "molecular weight|Molecular weight",
              param_name,
              ignore.case = TRUE
            )
          })
        }

        if (!is.null(result)) {
          class(result) <- c("compound_additional_parameters", "list")
        }
        return(result)
      }

      # For setting values, we could implement parameter updating logic here if needed
      # For now, just return the current parameters
      self$parameters
    },

    #' @field protein_binding_partners The protein binding partners data of the compound
    protein_binding_partners = function() {
      result <- private$.protein_binding_partners
      if (!is.null(result)) {
        class(result) <- c("protein_binding_partners", "list")
      }
      result
    },

    #' @field metabolizing_enzymes The metabolizing enzymes data of the compound
    metabolizing_enzymes = function() {
      result <- private$.metabolizing_enzymes
      if (!is.null(result)) {
        class(result) <- c("metabolizing_enzymes", "list")
      }
      result
    },

    #' @field hepatic_clearance The hepatic clearance data of the compound
    hepatic_clearance = function() {
      result <- private$.hepatic_clearance
      if (!is.null(result)) {
        class(result) <- c("hepatic_clearance", "list")
      }
      result
    },

    #' @field transporter_proteins The transporter proteins data of the compound
    transporter_proteins = function() {
      result <- private$.transporter_proteins
      if (!is.null(result)) {
        class(result) <- c("transporter_proteins", "list")
      }
      result
    },

    #' @field renal_clearance The renal clearance data of the compound
    renal_clearance = function() {
      result <- private$.renal_clearance
      if (!is.null(result)) {
        class(result) <- c("renal_clearance", "list")
      }
      result
    },

    #' @field biliary_clearance The biliary clearance data of the compound
    biliary_clearance = function() {
      result <- private$.biliary_clearance
      if (!is.null(result)) {
        class(result) <- c("biliary_clearance", "list")
      }
      result
    },

    #' @field inhibition The inhibition data of the compound
    inhibition = function() {
      result <- private$.inhibition
      if (!is.null(result)) {
        class(result) <- c("inhibition", "list")
      }
      result
    },

    #' @field induction The induction data of the compound
    induction = function() {
      result <- private$.induction
      if (!is.null(result)) {
        class(result) <- c("induction", "list")
      }
      result
    }
  )
)
