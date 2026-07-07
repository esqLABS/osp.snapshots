#' Compound class for OSP snapshot compounds
#'
#' @description
#' An R6 class that represents a compound in an OSP snapshot.
#' This class provides methods to access different properties of a compound
#' and display a summary of its information.
#'
#' Compound processes are exposed via `$processes`, a flat named list of
#' [Process] objects. The per-category tibble accessors
#' (`$protein_binding_partners`, `$metabolizing_enzymes`,
#' `$hepatic_clearance`, `$transporter_proteins`, `$renal_clearance`,
#' `$biliary_clearance`, `$inhibition`, `$induction`) are
#' [`lifecycle::deprecate_soft()`]-warned in favour of `$processes` and the
#' long-form `processes` tibble returned by [get_compounds_dfs()].
#'
#' @importFrom tibble tibble as_tibble
#' @importFrom glue glue
#' @importFrom R6 R6Class
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
      private$.calculation_methods <- CalculationMethods$new(
        data$CalculationMethods
      )
      private$.parameters <- build_parameters_from_raw(
        private$.data$Parameters,
        key_by = "name"
      )
      private$.processes <- build_processes_from_raw(
        private$.data$Processes
      )
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
        if (
          !is.null(self$is_small_molecule) && !is.na(self$is_small_molecule)
        ) {
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
        if (self$calculation_methods$length > 0) {
          cli::cli_h2("Calculation Methods")
          for (name in self$calculation_methods$names) {
            cli::cli_li("{name}")
          }
        }

        # Display physicochemical properties using custom print methods
        cli::cli_h2("Physicochemical Properties")
        properties <- list(
          lipophilicity = "Lipophilicity",
          fraction_unbound = "Fraction Unbound",
          solubility = "Solubility",
          intestinal_permeability = "Intestinal Permeability",
          permeability = "Permeability",
          pka_types = "pKa Types"
        )

        for (prop_name in names(properties)) {
          prop_data <- self[[prop_name]]
          if (!is.null(prop_data) && length(prop_data) > 0) {
            print.physicochemical_property(prop_data)
          }
        }

        # Display processes
        raw_processes <- private$.data$Processes
        if (!is.null(raw_processes) && length(raw_processes) > 0) {
          cli::cli_h2("Processes")
          class(raw_processes) <- c("compound_processes", "list")
          print.compound_processes(raw_processes)
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
    #' Convert this compound's physicochemical properties and process
    #' parameters to a single long-form tibble (legacy shape).
    #'
    #' Used by [get_compounds_dfs()] to assemble the compound-wide
    #' `properties` tibble. The process-derived rows produced here are
    #' [`lifecycle::deprecate_soft()`]-warned at the
    #' [get_compounds_dfs()] entry point; prefer the long-form
    #' `processes` tibble returned alongside.
    #'
    #' @return A tibble with columns `compound`, `category`, `type`,
    #'   `parameter`, `value`, `unit`, `data_source`, `source`.
    to_df = function() {
      compound_name <- self$name

      df <- empty_compound_property_tibble()

      for (p in c(
        "lipophilicity",
        "fraction_unbound",
        "molecular_weight",
        "halogens",
        "pKa",
        "solubility",
        "intestinal_permeability",
        "permeability"
      )) {
        prop_data <- private$.get_property_data(p)
        if (!is.null(prop_data) && length(prop_data) > 0) {
          df <- dplyr::bind_rows(
            df,
            private$.property_to_rows(compound_name, p, prop_data)
          )
        }
      }

      process_rows <- compound_processes_to_legacy_df(
        compound_name,
        private$.data$Processes
      )
      if (nrow(process_rows) > 0) {
        df <- dplyr::bind_rows(df, process_rows)
      }

      df
    }
  ),

  private = list(
    .data = NULL,
    .parameters = NULL,
    .processes = NULL,
    .calculation_methods = NULL,

    deep_clone = function(name, value) {
      if (name == ".calculation_methods" && inherits(value, "R6")) {
        return(value$clone(deep = TRUE))
      }
      if (name == ".processes" && is.list(value)) {
        return(lapply(value, function(p) {
          if (inherits(p, "R6")) p$clone(deep = TRUE) else p
        }))
      }
      value
    },

    # Shared setter for the single-parameter alternative-group fields. A
    # numeric scalar builds a single default alternative; a list is stored
    # verbatim as the raw alternative array; NULL clears the key; anything
    # else aborts naming the field. `unit = NULL` omits the parameter unit
    # (fraction unbound). Returns the value to assign into private$.data.
    set_alternative_group = function(value, param_name, unit, field) {
      if (is.null(value)) {
        return(NULL)
      }
      if (is.numeric(value)) {
        if (length(value) != 1) {
          cli::cli_abort("{.arg {field}} must be a numeric value")
        }
        return(build_single_param_alternative(
          "User defined",
          param_name,
          value,
          unit
        ))
      }
      if (is.list(value)) {
        return(unname(value))
      }
      cli::cli_abort(
        "{.arg {field}} must be a numeric value, a raw alternative list, or NULL"
      )
    },

    .format_value = function(x) {
      vapply(
        x,
        function(nr) {
          if (is.character(nr)) {
            nr
          } else if (is.null(nr)) {
            NA_character_
          } else {
            as.character(nr)
          }
        },
        character(1)
      )
    },

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
        "permeability" = private$.extract_permeability(),
        NULL
      )
    },

    .property_to_rows = function(compound_name, parameter, prop_data) {
      if (parameter == "molecular_weight" && !is.list(prop_data)) {
        return(tibble::tibble(
          compound = compound_name,
          category = "physicochemical_property",
          type = parameter,
          parameter = NA_character_,
          value = private$.format_value(prop_data$Value),
          unit = prop_data$Unit %||% NA_character_,
          data_source = NA_character_,
          source = prop_data$Source
        ))
      } else if (is.list(prop_data)) {
        return(tibble::tibble(
          compound = compound_name,
          category = "physicochemical_property",
          type = parameter,
          parameter = if (parameter == "solubility") {
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
          data_source = NA_character_,
          source = purrr::map_chr(prop_data, ~ .x$Source)
        ))
      }
      empty_compound_property_tibble()
    },

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
      data
    },

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
      data
    },

    .extract_molecular_weight = function() {
      list(private$.extract_parameters(
        private$.data$Parameters,
        "Molecular weight"
      ))
    },

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
        data[[j]]$Source <- compound_value_origin_source(pka_source$ValueOrigin)
      }
      names(data) <- tolower(names)
      data
    },

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
          data[[id]]$Source <- compound_value_origin_source(source$ValueOrigin)
          data[[id]]$ref_pH <- pH
          data[[id]]$gain_per_charge <- gain_per_charge
          data[[id]]$table_name <- name
        } else if ("Solubility table" %in% param_names) {
          id <- names[j]
          data[[id]] <- list()
          source <- purrr::keep(params, ~ .x$Name == "Solubility table")[[1]]
          data[[id]]$Value <- purrr::map_dbl(source$TableFormula$Points, ~ .$Y)
          data[[id]]$Unit <- source$Unit
          data[[id]]$Source <- compound_value_origin_source(source$ValueOrigin)
          data[[id]]$pH <- purrr::map_dbl(source$TableFormula$Points, ~ .$X)
          data[[id]]$table_name <- id
        }
      }
      data
    },

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
      data
    },

    .extract_permeability = function() {
      permeability_data <- private$.data$Permeability
      if (is.null(permeability_data)) {
        return(NULL)
      }

      names <- purrr::map_chr(permeability_data, "Name")
      data <- vector("list", length(names))
      names(data) <- names

      for (j in seq_along(names)) {
        data[[j]] <- private$.extract_parameters(
          permeability_data[[j]]$Parameters,
          "Permeability"
        )
      }
      data
    },

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
        data[[j]]$Source <- compound_value_origin_source(
          halogen_data[[j]]$ValueOrigin
        )
      }
      data
    },

    .extract_parameters = function(parameters_list, property_name) {
      source <- purrr::keep(parameters_list, ~ .x$Name == property_name) |>
        purrr::list_c()
      if (!is.null(source)) {
        list(
          Value = as.numeric(source$Value),
          Unit = source$Unit %||% NA_character_,
          Source = compound_value_origin_source(source$ValueOrigin)
        )
      } else {
        NULL
      }
    }
  ),

  active = list(
    #' @field data The raw data of the compound (read-only). Refreshed from
    #'   the embedded [CalculationMethods] and the cached [Process]
    #'   objects so that mutations flow back to the export payload.
    data = function() {
      result <- private$.data
      cm <- private$.calculation_methods$to_list()
      if (is.null(cm) && is.null(private$.data$CalculationMethods)) {
        result$CalculationMethods <- NULL
      } else {
        result$CalculationMethods <- cm
      }
      if (length(private$.processes) > 0) {
        result$Processes <- lapply(private$.processes, function(p) p$data)
        names(result$Processes) <- NULL
      }
      result
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
      NA
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
      ""
    },

    #' @field lipophilicity The lipophilicity data of the compound. Writable:
    #'   assign a numeric scalar to create a single default `Lipophilicity`
    #'   alternative (parameter `"Lipophilicity"`, unit `"Log Units"`), a raw
    #'   alternative list to set the array verbatim (the escape hatch for
    #'   multiple, named, or species-specific alternatives), or `NULL` to
    #'   clear the property.
    lipophilicity = function(value) {
      if (missing(value)) {
        result <- private$.data$Lipophilicity
        if (!is.null(result)) {
          class(result) <- c("physicochemical_property", "list")
          attr(result, "property_name") <- "Lipophilicity"
        }
        return(result)
      }
      private$.data$Lipophilicity <- private$set_alternative_group(
        value,
        "Lipophilicity",
        "Log Units",
        "lipophilicity"
      )
    },

    #' @field fraction_unbound The fraction unbound data of the compound.
    #'   Writable: assign a numeric scalar to create a single default
    #'   `FractionUnbound` alternative (parameter
    #'   `"Fraction unbound (plasma, reference value)"`, no unit), a raw
    #'   alternative list to set the array verbatim, or `NULL` to clear the
    #'   property.
    fraction_unbound = function(value) {
      if (missing(value)) {
        result <- private$.data$FractionUnbound
        if (!is.null(result)) {
          class(result) <- c("physicochemical_property", "list")
          attr(result, "property_name") <- "Fraction Unbound"
        }
        return(result)
      }
      private$.data$FractionUnbound <- private$set_alternative_group(
        value,
        "Fraction unbound (plasma, reference value)",
        NULL,
        "fraction_unbound"
      )
    },

    #' @field solubility The solubility data of the compound. Writable:
    #'   assign a numeric scalar to create a single default `Solubility`
    #'   alternative (parameter `"Solubility at reference pH"`, unit
    #'   `"mg/l"`), a raw alternative list to set the array verbatim, or
    #'   `NULL` to clear the property. The scalar form cannot express
    #'   reference pH, gain per charge, or table solubility; set those by
    #'   assigning a raw alternative list or by using `create_compound()`
    #'   with its `reference_pH`, `solubility_gain_per_charge`, or
    #'   `solubility_table` arguments.
    solubility = function(value) {
      if (missing(value)) {
        result <- private$.data$Solubility
        if (!is.null(result)) {
          class(result) <- c("physicochemical_property", "list")
          attr(result, "property_name") <- "Solubility"
        }
        return(result)
      }
      if (is.null(value)) {
        private$.data$Solubility <- NULL
      } else if (is.numeric(value)) {
        if (length(value) != 1) {
          cli::cli_abort("{.arg solubility} must be a numeric value")
        }
        private$.data$Solubility <- build_solubility_alternative(
          "User defined",
          value,
          "mg/l"
        )
      } else if (is.list(value)) {
        private$.data$Solubility <- unname(value)
      } else {
        cli::cli_abort(
          "{.arg solubility} must be a numeric value, a raw alternative list, or NULL"
        )
      }
    },

    #' @field intestinal_permeability The intestinal permeability data of the
    #'   compound. Writable: assign a numeric scalar to create a single
    #'   default `IntestinalPermeability` alternative (parameter
    #'   `"Specific intestinal permeability (transcellular)"`, unit
    #'   `"cm/min"`), a raw alternative list to set the array verbatim, or
    #'   `NULL` to clear the property.
    intestinal_permeability = function(value) {
      if (missing(value)) {
        result <- private$.data$IntestinalPermeability
        if (!is.null(result)) {
          class(result) <- c("physicochemical_property", "list")
          attr(result, "property_name") <- "Intestinal Permeability"
        }
        return(result)
      }
      private$.data$IntestinalPermeability <- private$set_alternative_group(
        value,
        "Specific intestinal permeability (transcellular)",
        "cm/min",
        "intestinal_permeability"
      )
    },

    #' @field permeability The permeability data of the compound. Writable:
    #'   assign a numeric scalar to create a single default `Permeability`
    #'   alternative (parameter `"Permeability"`, unit `"cm/min"`), a raw
    #'   alternative list to set the array verbatim, or `NULL` to clear the
    #'   property.
    permeability = function(value) {
      if (missing(value)) {
        result <- private$.data$Permeability
        if (!is.null(result)) {
          class(result) <- c("physicochemical_property", "list")
          attr(result, "property_name") <- "Permeability"
        }
        return(result)
      }
      private$.data$Permeability <- private$set_alternative_group(
        value,
        "Permeability",
        "cm/min",
        "permeability"
      )
    },

    #' @field pka_types The pKa types of the compound. Writable: assign a
    #'   list of `list(type =, value =)` entries (the `create_compound()`
    #'   `pKa` shape, converted to `list(Type =, Pka =)`), a raw `PkaType[]`
    #'   list (entries carrying `Type`/`Pka`, set verbatim), or `NULL` /
    #'   `list()` to clear the pKa types.
    pka_types = function(value) {
      if (missing(value)) {
        result <- private$.data$PkaTypes
        if (!is.null(result)) {
          class(result) <- c("physicochemical_property", "list")
          attr(result, "property_name") <- "pKa Types"
        }
        return(result)
      }
      if (is.null(value) || length(value) == 0) {
        private$.data$PkaTypes <- NULL
      } else if (!is.list(value) || is.object(value)) {
        cli::cli_abort("{.arg pka_types} must be a list")
      } else if ("type" %in% names(value[[1]])) {
        validate_pka(value)
        private$.data$PkaTypes <- build_pka_types(value)
      } else {
        private$.data$PkaTypes <- unname(value)
      }
    },

    #' @field processes A flat named list of [Process] objects, one per
    #'   entry in the compound's `Processes` array. Duplicate names are
    #'   disambiguated with a numeric suffix (`_1`, `_2`, ...). The list is
    #'   built once at construction so that state changes made on a
    #'   [Process] persist across accesses. Writable: assign a list of
    #'   [Process] objects and/or raw process lists to rebuild the processes
    #'   (duplicate names are disambiguated as at construction), or `NULL` /
    #'   `list()` to clear them.
    processes = function(value) {
      if (missing(value)) {
        return(private$.processes)
      }
      raw <- if (is.null(value) || length(value) == 0) {
        NULL
      } else {
        to_raw_r6_or_list(value, "Process", "processes")
      }
      private$.data$Processes <- raw
      private$.processes <- build_processes_from_raw(raw)
    },

    #' @field calculation_methods A [CalculationMethods] object holding the
    #'   compound's calculation methods.
    calculation_methods = function(value) {
      if (missing(value)) {
        return(private$.calculation_methods)
      }
      if (inherits(value, "CalculationMethods")) {
        private$.calculation_methods <- value
      } else {
        private$.calculation_methods <- CalculationMethods$new(value)
      }
    },

    #' @field parameters The additional parameters of the compound (excluding molecular weight)
    parameters = function(value) {
      if (missing(value)) {
        raw_params <- private$.data$Parameters
        if (is.null(raw_params) || length(raw_params) == 0) {
          result <- list()
        } else {
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
      self$parameters
    },

    #' @field protein_binding_partners Deprecated. Filter
    #'   [get_compounds_dfs()]`$processes` on `category ==
    #'   "protein_binding_partners"`, or iterate `self$processes` and check
    #'   `process$category`.
    protein_binding_partners = function() {
      deprecate_compound_category_accessor("protein_binding_partners")
      legacy_category_named_list(
        private$.data$Processes,
        "protein_binding_partners"
      )
    },

    #' @field metabolizing_enzymes Deprecated. See `$protein_binding_partners`.
    metabolizing_enzymes = function() {
      deprecate_compound_category_accessor("metabolizing_enzymes")
      legacy_category_named_list(
        private$.data$Processes,
        "metabolizing_enzymes"
      )
    },

    #' @field hepatic_clearance Deprecated. See `$protein_binding_partners`.
    hepatic_clearance = function() {
      deprecate_compound_category_accessor("hepatic_clearance")
      legacy_category_named_list(
        private$.data$Processes,
        "hepatic_clearance"
      )
    },

    #' @field transporter_proteins Deprecated. See `$protein_binding_partners`.
    transporter_proteins = function() {
      deprecate_compound_category_accessor("transporter_proteins")
      legacy_category_named_list(
        private$.data$Processes,
        "transporter_proteins"
      )
    },

    #' @field renal_clearance Deprecated. See `$protein_binding_partners`.
    renal_clearance = function() {
      deprecate_compound_category_accessor("renal_clearance")
      legacy_category_named_list(
        private$.data$Processes,
        "renal_clearance"
      )
    },

    #' @field biliary_clearance Deprecated. See `$protein_binding_partners`.
    biliary_clearance = function() {
      deprecate_compound_category_accessor("biliary_clearance")
      legacy_category_named_list(
        private$.data$Processes,
        "biliary_clearance"
      )
    },

    #' @field inhibition Deprecated. See `$protein_binding_partners`.
    inhibition = function() {
      deprecate_compound_category_accessor("inhibition")
      legacy_category_named_list(private$.data$Processes, "inhibition")
    },

    #' @field induction Deprecated. See `$protein_binding_partners`.
    induction = function() {
      deprecate_compound_category_accessor("induction")
      legacy_category_named_list(private$.data$Processes, "induction")
    }
  )
)

# Shared empty tibble used by Compound$to_df() and the snapshot exporter.
empty_compound_property_tibble <- function() {
  tibble::tibble(
    compound = character(),
    category = character(),
    type = character(),
    parameter = character(),
    value = character(),
    unit = character(),
    data_source = character(),
    source = character()
  )
}

# Internal: derive the human-readable source string from a raw
# `ValueOrigin` dict. Hoisted out of `Compound` so it can be shared by the
# process tibble helpers in `R/process_dataframes.R`.
compound_value_origin_source <- function(value_origin) {
  if (is.null(value_origin)) {
    return(NA_character_)
  }
  if (identical(value_origin$Source, "ParameterIdentification")) {
    return("Parameter optimization")
  }
  if (is.null(value_origin$Description) || value_origin$Description == "") {
    return(NA_character_)
  }
  value_origin$Description
}

deprecate_compound_category_accessor <- function(name) {
  lifecycle::deprecate_soft(
    when = "0.3.0",
    what = I(glue::glue("Compound${name}")),
    details = paste0(
      "Use `compound$processes` (a flat named list of `Process` objects, ",
      "filtered by `$category`) or the long-form `processes` tibble ",
      "returned by `get_compounds_dfs()` instead."
    )
  )
}
