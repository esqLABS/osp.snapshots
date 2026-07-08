# Shared internal resolver used by `add_simulation()` to turn the
# `compounds` argument into raw `CompoundProperties`-shaped payloads,
# deriving defaults from the snapshot in hand for inline entries and
# passing escape-hatch objects through untouched. All functions here are
# internal (non-exported).

# Resolve a `compounds` argument (a list of inline compound-config lists
# and/or `CompoundProperties` objects) into an unnamed list of raw
# `CompoundProperties`-shaped payloads. Inline entries are resolved
# against `snapshot` (calculation methods, formulation key, alternatives
# derived from the referenced building blocks); `CompoundProperties`
# objects are passed through as their raw `$data` with no defaulting, so
# the resulting `Simulation$data$Compounds` array is identical in shape to
# a hand-built factory tree.
#
# @keywords internal
resolve_compounds <- function(compounds, snapshot, call = parent.frame()) {
  if (is.null(compounds)) {
    return(NULL)
  }
  if (!is.list(compounds) || is.object(compounds)) {
    cli::cli_abort("{.arg compounds} must be a list", call = call)
  }

  notes <- new_derivation_notes()
  resolved <- lapply(compounds, function(entry) {
    if (inherits(entry, "CompoundProperties")) {
      entry$data
    } else if (is.list(entry) && !is.object(entry)) {
      resolve_one_compound(entry, snapshot, notes, call = call)
    } else {
      cli::cli_abort(
        "Every entry of {.arg compounds} must be a {.cls CompoundProperties} \\
        object or an inline compound-config list",
        call = call
      )
    }
  })

  emit_derivation_notes(notes)
  unname(resolved)
}

# Resolve one inline compound-config list into a raw
# `CompoundProperties`-shaped payload. Defaults are derived from the
# referenced compound building block when it is present in the snapshot;
# a supplied value always wins over derivation.
resolve_one_compound <- function(
  config,
  snapshot,
  notes,
  call = parent.frame()
) {
  check_required_string(config$name, "name")

  compound <- snapshot$compounds[[config$name]]

  data <- list(Name = config$name)

  # calculation_methods (FR-5.1): supplied wins; else derive from the BB.
  if (!is.null(config$calculation_methods)) {
    if (!is.character(config$calculation_methods)) {
      cli::cli_abort(
        "{.arg calculation_methods} must be a character vector",
        call = call
      )
    }
    data$CalculationMethods <- as.list(config$calculation_methods)
  } else if (!is.null(compound)) {
    derived <- derive_calculation_methods(compound)
    if (!is.null(derived)) {
      data$CalculationMethods <- derived
      notes$add("calculation methods", config$name)
    }
  }

  # alternatives (FR-5.3): supplied wins; else default each group.
  if (!is.null(config$alternatives)) {
    data$Alternatives <- to_raw_r6_or_list(
      config$alternatives,
      "CompoundGroupSelection",
      "alternatives",
      call = call
    )
  } else if (!is.null(compound)) {
    derived <- derive_alternatives(compound)
    if (!is.null(derived)) {
      data$Alternatives <- derived
      notes$add("alternatives", config$name)
    }
  }

  # processes (FR-5.4): never defaulted; only set when supplied.
  if (!is.null(config$processes)) {
    data$Processes <- resolve_processes(config$processes, call = call)
  }

  # protocol / formulation (FR-5.2): infer the formulation key from the
  # referenced protocol's slot. A formulation without a protocol has
  # nowhere to attach and is ignored.
  if (!is.null(config$protocol)) {
    check_required_string(config$protocol, "protocol")
    data$Protocol <- build_protocol_selection(
      config$protocol,
      config$formulation,
      snapshot,
      notes
    )
  }

  data
}

# FR-5.1: default calculation methods from the compound building block.
# Returns the raw list-of-strings sink shape, or `NULL` when the compound
# carries no calculation methods.
derive_calculation_methods <- function(compound) {
  names <- compound$calculation_methods$names
  if (length(names) == 0) {
    return(NULL)
  }
  as.list(names)
}

# FR-5.2: build a `ProtocolSelection`-shaped payload, inferring the
# formulation key from the referenced protocol's application slot. When
# no formulation is supplied the protocol is bound without a formulation.
build_protocol_selection <- function(
  protocol_name,
  formulation_name,
  snapshot,
  notes
) {
  result <- list(Name = protocol_name)
  if (is.null(formulation_name)) {
    return(result)
  }
  check_required_string(formulation_name, "formulation")

  protocol <- snapshot$protocols[[protocol_name]]
  key <- infer_formulation_key(protocol, notes)
  result$Formulations <- list(list(Name = formulation_name, Key = key))
  result
}

# FR-5.2: infer the formulation key from a Protocol's application slots.
# Simple protocols (no schemas) and unresolved protocols fall back to the
# literal `"Formulation"` key. When a protocol has several slots with
# differing keys, the single inline formulation maps to the first slot's
# key and a multi-slot note is recorded (the escape hatch covers exact
# multi-slot mapping).
infer_formulation_key <- function(protocol, notes) {
  if (is.null(protocol)) {
    return("Formulation")
  }

  keys <- character()
  for (schema in protocol$schemas) {
    for (item in schema$items) {
      key <- item$formulation_key
      if (!is.null(key) && nzchar(key)) {
        keys <- c(keys, key)
      }
    }
  }

  if (length(keys) == 0) {
    return("Formulation")
  }
  if (length(unique(keys)) > 1) {
    notes$add_multi_slot(protocol$name %||% "<unnamed>")
  }
  keys[[1]]
}

# FR-5.3: default each alternative group to its default alternative. The
# alternative marked `IsDefault` wins (absent `IsDefault` defaults to
# `TRUE` per the snapshot schema); otherwise the `"User defined"`
# alternative is used, and a group with no resolvable default is skipped.
derive_alternatives <- function(compound) {
  field_to_group <- list(
    lipophilicity = "COMPOUND_LIPOPHILICITY",
    fraction_unbound = "COMPOUND_FRACTION_UNBOUND",
    solubility = "COMPOUND_SOLUBILITY",
    intestinal_permeability = "COMPOUND_INTESTINAL_PERMEABILITY",
    permeability = "COMPOUND_PERMEABILITY"
  )

  selections <- list()
  for (field in names(field_to_group)) {
    alternatives <- compound[[field]]
    if (is.null(alternatives) || length(alternatives) == 0) {
      next
    }
    alternative_name <- default_alternative_name(alternatives)
    if (is.null(alternative_name)) {
      next
    }
    selections[[length(selections) + 1L]] <- list(
      GroupName = field_to_group[[field]],
      AlternativeName = alternative_name
    )
  }

  if (length(selections) == 0) {
    return(NULL)
  }
  selections
}

# Pick the default alternative's name from a group's alternative array.
# `IsDefault` absent means default (TRUE); an explicit `FALSE` opts out.
# Falls back to the `"User defined"` alternative, else `NULL`.
default_alternative_name <- function(alternatives) {
  for (alt in alternatives) {
    if (isTRUE(alt$IsDefault %||% TRUE)) {
      return(alt$Name)
    }
  }
  for (alt in alternatives) {
    if (identical(alt$Name, "User defined")) {
      return(alt$Name)
    }
  }
  NULL
}

# FR-6: build `CompoundProcessSelection`-shaped payloads from either a
# character vector of names or a list of explicit objects / raw lists.
resolve_processes <- function(processes, call = parent.frame()) {
  if (is.character(processes)) {
    return(lapply(processes, function(name) {
      if (is_systemic_process(name)) {
        list(SystemicProcessType = name)
      } else {
        list(MoleculeName = name)
      }
    }))
  }
  if (is.list(processes) && !is.object(processes)) {
    return(to_raw_r6_or_list(
      processes,
      "CompoundProcessSelection",
      "processes",
      call = call
    ))
  }
  cli::cli_abort(
    "{.arg processes} must be a character vector or a list of \\
    {.cls CompoundProcessSelection} objects",
    call = call
  )
}

# FR-6 heuristic: classify a process name as a systemic-process type. The
# three canonical tokens are treated as systemic; every other name is a
# molecule name. Finer control (metabolite/compound qualifiers, other
# systemic types) uses `create_compound_process_selection()`.
is_systemic_process <- function(name) {
  name %in% c("Hepatic", "Renal", "Biliary")
}

# FR-11: a small accumulator for derivation notes so the resolver emits
# one concise informational summary per `resolve_compounds()` call rather
# than a per-value chatter storm. Kept at message/inform level so it does
# not pollute warning snapshots.
new_derivation_notes <- function() {
  derived <- list()
  multi_slot <- character()
  list(
    add = function(kind, compound_name) {
      derived[[compound_name]] <<- unique(c(derived[[compound_name]], kind))
    },
    add_multi_slot = function(protocol_name) {
      multi_slot <<- unique(c(multi_slot, protocol_name))
    },
    derived = function() derived,
    multi_slot = function() multi_slot
  )
}

emit_derivation_notes <- function(notes) {
  derived <- notes$derived()
  if (length(derived) > 0) {
    compound_names <- names(derived)
    lines <- vapply(
      compound_names,
      function(name) {
        paste0(name, ": ", paste(derived[[name]], collapse = ", "))
      },
      character(1)
    )
    cli::cli_inform(c(
      "i" = "Derived defaults for {length(compound_names)} compound{?s} from the snapshot:",
      stats::setNames(lines, rep("*", length(lines)))
    ))
  }

  multi_slot <- notes$multi_slot()
  if (length(multi_slot) > 0) {
    cli::cli_inform(c(
      "!" = "{cli::qty(multi_slot)}Protocol{?s} {.val {multi_slot}} {?has/have} \\
      multiple application slots; mapped the formulation to the first slot.",
      "i" = "Use {.fn create_compound_properties} for exact multi-slot mapping."
    ))
  }
}
