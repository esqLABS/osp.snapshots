# Shared internal resolver used by `add_simulation()` to turn the
# `compounds` argument into raw `CompoundProperties`-shaped payloads,
# deriving defaults from the snapshot in hand. All functions here are
# internal (non-exported).

# Resolve a `compounds` argument (a list of inline compound-config lists)
# into an unnamed list of raw `CompoundProperties`-shaped payloads. Each
# entry is resolved against `snapshot` (calculation methods, formulation
# key/map, alternatives derived from the referenced building block, merged
# with any friendly `alternatives` override).
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
      cli::cli_abort(
        c(
          "{.arg compounds} no longer accepts a {.cls CompoundProperties} \\
          object.",
          "i" = "Pass an inline compound-config list instead, e.g. \\
          {.code list(name = ..., alternatives = c(solubility = \"FaSSIF\"))}."
        ),
        call = call
      )
    } else if (is.list(entry) && !is.object(entry)) {
      resolve_one_compound(entry, snapshot, notes, call = call)
    } else {
      cli::cli_abort(
        "Every entry of {.arg compounds} must be an inline compound-config list",
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

  # alternatives (FR-9/FR-10): a friendly-name selection overrides that
  # group only; every group not named is defaulted as before, so the two
  # sources are merged rather than one replacing the other (D-3).
  selections <- list()
  if (!is.null(compound)) {
    derived <- derive_alternatives(compound)
    if (!is.null(derived)) {
      selections <- derived
      notes$add("alternatives", config$name)
    }
  }
  if (!is.null(config$alternatives)) {
    overrides <- resolve_alternative_selections(
      config$alternatives,
      compound,
      config$name,
      call = call
    )
    selections <- merge_alternative_selections(selections, overrides)
  }
  if (length(selections) > 0) {
    data$Alternatives <- selections
  }

  # processes (FR-5.4): never defaulted; only set when supplied.
  if (!is.null(config$processes)) {
    data$Processes <- resolve_processes(config$processes, call = call)
  }

  # protocol / formulation (FR-5.2): infer the formulation key from the
  # referenced protocol's slot. A formulation without a protocol has
  # nowhere to attach and is ignored.
  if (!is.null(config$protocol)) {
    check_required_string(config$protocol, "protocol", call = call)
    data$Protocol <- build_protocol_selection(
      config$protocol,
      config$formulation,
      snapshot,
      notes,
      call = call
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

# FR-5.2/D-4: build a `ProtocolSelection`-shaped payload. A plain,
# unnamed string keeps today's meaning: infer the slot key from the
# referenced protocol's application slot. A named character vector (or a
# named list of length-one strings) maps application-slot key to
# formulation name explicitly, binding one entry per named slot; this is
# the friendly replacement for the multi-slot protocol case the retired
# `create_compound_properties()` escape hatch served (FR-14). When no
# formulation is supplied the protocol is bound without a formulation.
build_protocol_selection <- function(
  protocol_name,
  formulation,
  snapshot,
  notes,
  call = parent.frame()
) {
  result <- list(Name = protocol_name)
  if (is.null(formulation)) {
    return(result)
  }

  if (is_formulation_map(formulation)) {
    check_formulation_map_names(formulation, call = call)
    result$Formulations <- Map(
      function(key, name) list(Name = name, Key = key),
      names(formulation),
      unlist(formulation, use.names = FALSE)
    ) |>
      unname()
    return(result)
  }

  check_required_string(formulation, "formulation", call = call)
  protocol <- snapshot$protocols[[protocol_name]]
  key <- infer_formulation_key(protocol, notes)
  result$Formulations <- list(list(Name = formulation, Key = key))
  result
}

# Internal: is `formulation` the slot-key-map shape (a named character
# vector, or a named list of length-one strings), as opposed to a plain
# unnamed string (D-4)? A named length-one vector is also a map (an
# explicit slot key), not the "infer the key" path.
is_formulation_map <- function(formulation) {
  is_named_chr <- is.character(formulation) && !is.null(names(formulation))
  is_named_list_of_strings <- is.list(formulation) &&
    !is.object(formulation) &&
    !is.null(names(formulation)) &&
    all(vapply(
      formulation,
      function(x) is.character(x) && length(x) == 1,
      logical(1)
    ))
  is_named_chr || is_named_list_of_strings
}

# Internal: abort if a named formulation map has an empty/missing slot key.
check_formulation_map_names <- function(formulation, call = parent.frame()) {
  if (any(!nzchar(names(formulation)))) {
    cli::cli_abort(
      "Every element of a named {.arg formulation} map must have a slot key name",
      call = call
    )
  }
  invisible(formulation)
}

# FR-5.2: infer the formulation key from a Protocol's application slots.
# Simple protocols (no schemas) and unresolved protocols fall back to the
# literal `"Formulation"` key. When a protocol has several slots with
# differing keys, the single inline formulation maps to the first slot's
# key and a multi-slot note is recorded (the named `formulation` map,
# D-4, covers exact multi-slot mapping).
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

# Internal: the friendly property name -> COMPOUND_* alternative-group
# constant map. The only place this mapping is defined; friendly names are
# the create_compound() / Compound field names. Kept internal so the
# COMPOUND_* constants never surface in user-facing code (FR-6, FR-7).
compound_field_to_group <- function() {
  list(
    lipophilicity = "COMPOUND_LIPOPHILICITY",
    fraction_unbound = "COMPOUND_FRACTION_UNBOUND",
    solubility = "COMPOUND_SOLUBILITY",
    intestinal_permeability = "COMPOUND_INTESTINAL_PERMEABILITY",
    permeability = "COMPOUND_PERMEABILITY"
  )
}

# FR-5.3: default each alternative group to its default alternative. The
# alternative marked `IsDefault` wins (absent `IsDefault` defaults to
# `TRUE` per the snapshot schema); otherwise the `"User defined"`
# alternative is used, and a group with no resolvable default is skipped.
derive_alternatives <- function(compound) {
  field_to_group <- compound_field_to_group()

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

# FR-6/FR-7: turn a friendly alternatives selection (named character vector
# or named list of length-one strings) into CompoundGroupSelection-shaped
# payloads. Validated against `compound` when it is present (FR-8); when
# `compound` is NULL (unresolved reference, D-6) the mapping is still
# emitted, unvalidated, so the missing-reference warning remains the
# single signal.
resolve_alternative_selections <- function(
  alternatives,
  compound,
  compound_name,
  call = parent.frame()
) {
  pairs <- normalize_alternative_selection(alternatives, call = call)
  field_to_group <- compound_field_to_group()

  dupes <- unique(pairs$property[duplicated(pairs$property)])
  if (length(dupes) > 0) {
    cli::cli_abort(
      "{.arg alternatives} names {.val {dupes}} more than once; a group \\
      can be selected at most once.",
      call = call
    )
  }

  unknown <- setdiff(pairs$property, names(field_to_group))
  if (length(unknown) > 0) {
    cli::cli_abort(
      c(
        "{.arg alternatives} names unknown propert{?y/ies} {.val {unknown}}.",
        "i" = "Valid properties are {.val {names(field_to_group)}}."
      ),
      call = call
    )
  }

  if (!is.null(compound)) {
    for (i in seq_along(pairs$property)) {
      validate_alternative_label(
        compound,
        pairs$property[[i]],
        pairs$label[[i]],
        compound_name,
        call = call
      )
    }
  }

  Map(
    function(property, label) {
      list(GroupName = field_to_group[[property]], AlternativeName = label)
    },
    pairs$property,
    pairs$label
  ) |>
    unname()
}

# Internal: coerce the `alternatives` argument (named character vector or
# named list of length-one strings) into a `list(property=, label=)`
# pair-of-vectors shape, aborting on anything else (FR-6, D-2).
normalize_alternative_selection <- function(
  alternatives,
  call = parent.frame()
) {
  is_named_chr <- is.character(alternatives) && !is.null(names(alternatives))
  is_named_list_of_strings <- is.list(alternatives) &&
    !is.object(alternatives) &&
    !is.null(names(alternatives)) &&
    all(vapply(
      alternatives,
      function(x) is.character(x) && length(x) == 1,
      logical(1)
    ))

  if (!is_named_chr && !is_named_list_of_strings) {
    cli::cli_abort(
      c(
        "{.arg alternatives} must be a named character vector or a named \\
        list of length-one strings.",
        "i" = "For example {.code alternatives = c(solubility = \"FaSSIF\")}."
      ),
      call = call
    )
  }
  if (any(!nzchar(names(alternatives)))) {
    cli::cli_abort(
      "Every element of {.arg alternatives} must be named",
      call = call
    )
  }
  list(
    property = names(alternatives),
    label = unlist(alternatives, use.names = FALSE)
  )
}

# FR-8: abort unless `label` is an available alternative name on
# `compound`'s `property`. Lists the available labels. `compound[[property]]`
# returns the property's raw alternative array (each element a
# `list(Name =, ...)`); the labels are each element's `Name`, not the
# array's own (absent) `names()`.
validate_alternative_label <- function(
  compound,
  property,
  label,
  compound_name,
  call = parent.frame()
) {
  available <- compound[[property]]
  labels <- if (length(available) > 0) {
    vapply(available, function(alt) alt$Name, character(1))
  } else {
    character(0)
  }
  if (length(labels) == 0) {
    cli::cli_abort(
      "Compound {.val {compound_name}} has no {.field {property}} \\
      alternatives available.",
      call = call
    )
  }
  if (!(label %in% labels)) {
    cli::cli_abort(
      c(
        "Compound {.val {compound_name}} has no {.field {property}} \\
        alternative named {.val {label}}.",
        "i" = "Available: {.val {labels}}."
      ),
      call = call
    )
  }
  invisible(TRUE)
}

# D-3/FR-9: layer `overrides` onto `derived`, replacing any entry whose
# GroupName matches; entries only in `derived` pass through untouched.
merge_alternative_selections <- function(derived, overrides) {
  if (length(overrides) == 0) {
    return(derived)
  }
  override_groups <- vapply(overrides, function(o) o$GroupName, character(1))
  kept <- Filter(function(d) !(d$GroupName %in% override_groups), derived)
  c(kept, overrides)
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
      "i" = "Pass a named {.arg formulation} map (slot key = formulation \\
      name) to bind every slot explicitly."
    ))
  }
}
