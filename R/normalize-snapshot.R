# Load-time normalization of a parsed snapshot to the current PK-Sim version.
#
# `osp.snapshots` reads a snapshot, lets the user edit it through R6 block
# objects, and writes it back out. The block classes only ever emit the
# current (v12 / `Version = 80`) structure, so a loaded v11 (`Version = 79`)
# file whose untouched sections were replayed verbatim would export a
# mixed-version file: v79-shaped for untouched sections, v80-shaped for edited
# ones. PK-Sim reads the whole file under one migration path keyed on the
# single declared `Version`, so a mixed file mis-migrates.
#
# `normalize_snapshot_to_current()` upconverts the parsed data to the current
# `Version = 80` structure in memory at load time (called from
# `Snapshot$initialize()` right after version validation), so the whole
# in-memory model and every export are one coherent v12-format snapshot. The
# v11-to-v12 delta this package can encounter has exactly two parts:
#
#   1. `Applications` path segments become `Events` (already implemented by
#      `migrate_applications_to_events()`; reused here so it also reaches
#      `ParameterIdentifications` linked-parameter paths, which never pass
#      through `LocalizedParameter`).
#   2. The renal-clearance process containers `GlomerularFiltration` and
#      `RenalClearance` are qualified with the owning compound name wherever
#      they appear as a whole segment of a parameter path.
#
# Everything operates on whole `|`-separated segments, never on substrings,
# mirroring `migrate_applications_to_events()`. The step is idempotent: an
# already-v80 file has no bare renal container segment left to rename and its
# `Applications` are already `Events`, so only `Version = 80` is (re)affirmed.
normalize_snapshot_to_current <- function(data) {
  compound_names <- extract_compound_names(data)

  data <- normalize_localized_parameter_paths(data, compound_names)
  data <- normalize_identification_parameter_paths(data, compound_names)

  # Always emit the current version so both the in-memory model and every
  # export report `Version = 80`, regardless of the loaded file's original
  # declared version. `.original_data$Version` is the source `$data` reads
  # (it is not one of the export adapters), so this is where the effective
  # export version is set. Integer literal to match `create_snapshot()`.
  data$Version <- 80L

  data
}

# Extract the non-NA compound names from the parsed snapshot's `Compounds`
# section. Returns `character(0)` when there are no compounds.
extract_compound_names <- function(data) {
  compounds <- data$Compounds %||% list()
  if (length(compounds) == 0) {
    return(character(0))
  }
  names_raw <- vapply(
    compounds,
    \(compound) compound$Name %||% NA_character_,
    character(1)
  )
  names_raw[!is.na(names_raw)]
}

# Normalize a single parameter path string end to end: first the legacy
# `Applications` -> `Events` migration (reusing the existing helper), then the
# renal-clearance container rename. This is the one canonical per-path
# normalizer, used for both localized-parameter paths and
# identification-parameter linked paths.
normalize_parameter_path <- function(path, compound_names) {
  path <- migrate_applications_to_events(path)
  rename_renal_containers_in_path(path, compound_names)
}

# Rewrite localized-parameter paths in every place the package wraps
# `Parameters` as localized parameters: `Simulations`, `Individuals`, and the
# population base individual under `Populations[[i]]$Settings$Individual`.
# Rewriting these in `.original_data` up front means the later
# `LocalizedParameter$new()` wrapping just re-runs `migrate_applications_to_events()`
# as a confirmed no-op (the `Applications` are already gone) and the renal
# rename is idempotent (a renamed segment no longer equals the bare container
# name), so there is no double-rewrite hazard.
normalize_localized_parameter_paths <- function(data, compound_names) {
  data$Simulations <- rewrite_block_parameter_paths(
    data$Simulations,
    compound_names
  )
  data$Individuals <- rewrite_block_parameter_paths(
    data$Individuals,
    compound_names
  )

  if (length(data$Populations) > 0) {
    data$Populations <- lapply(data$Populations, function(population) {
      base_individual <- population$Settings$Individual
      if (!is.null(base_individual)) {
        population$Settings$Individual <- rewrite_parameters_paths(
          base_individual,
          compound_names
        )
      }
      population
    })
  }

  data
}

# Rewrite `IdentificationParameter.LinkedParameters` entries under the
# top-level `ParameterIdentifications` section. These are full parameter-path
# strings (`SimulationName|Container|...|ParameterName`) that flow through
# `.original_data` verbatim (the section is not modelled by any R6 block class
# and is not one of the export adapters), so they must be rewritten here to be
# covered at all. Every level is guarded for absence/emptiness.
normalize_identification_parameter_paths <- function(data, compound_names) {
  if (length(data$ParameterIdentifications) == 0) {
    return(data)
  }

  data$ParameterIdentifications <- lapply(
    data$ParameterIdentifications,
    function(identification) {
      id_params <- identification$IdentificationParameters
      if (length(id_params) == 0) {
        return(identification)
      }
      identification$IdentificationParameters <- lapply(
        id_params,
        function(id_param) {
          linked <- id_param$LinkedParameters
          if (length(linked) == 0) {
            return(id_param)
          }
          id_param$LinkedParameters <- lapply(linked, function(linked_path) {
            normalize_parameter_path(linked_path, compound_names)
          })
          id_param
        }
      )
      identification
    }
  )

  data
}

# Apply the per-path normalizer to every `Parameters` entry of every block in a
# collection (a list of block dicts, e.g. `data$Simulations`). A `NULL`/empty
# collection passes through unchanged.
rewrite_block_parameter_paths <- function(blocks, compound_names) {
  if (length(blocks) == 0) {
    return(blocks)
  }
  lapply(blocks, function(block) {
    rewrite_parameters_paths(block, compound_names)
  })
}

# Rewrite the `Path` of every entry in a single block's `Parameters` list. A
# block with no `Parameters` (or an empty one) passes through unchanged.
rewrite_parameters_paths <- function(block, compound_names) {
  params <- block$Parameters
  if (length(params) == 0) {
    return(block)
  }
  block$Parameters <- lapply(params, function(param) {
    if (!is.null(param$Path)) {
      param$Path <- normalize_parameter_path(param$Path, compound_names)
    }
    param
  })
  block
}

# Rename renal-clearance container segments in one path. Splits on `|` and
# examines each whole segment; a segment that is exactly `GlomerularFiltration`
# or `RenalClearance` is a renal-clearance process container to qualify. The
# owning compound is resolved (see `resolve_renal_compound()`); when resolved
# the segment is replaced via `rename_renal_container_segment()`, when it
# cannot be resolved the segment is left unchanged and one informational
# message is emitted for the path (FR-2d: never silently produce an
# unresolvable path). Whole-segment matching (never `grepl` on the whole path)
# keeps substrings such as `MyGlomerularFiltrationX` untouched.
rename_renal_containers_in_path <- function(path, compound_names) {
  segments <- strsplit(path, "|", fixed = TRUE)[[1]]
  is_container <- segments %in% c("GlomerularFiltration", "RenalClearance")
  if (!any(is_container)) {
    return(path)
  }

  for (i in which(is_container)) {
    preceding <- if (i > 1) segments[[i - 1]] else NA_character_
    compound <- resolve_renal_compound(preceding, compound_names)
    if (is.na(compound)) {
      cli::cli_alert_info(c(
        "Could not determine the owning compound for the \\
        renal-clearance container {.val {segments[[i]]}} in path \\
        {.val {path}}; leaving the segment unchanged."
      ))
      next
    }
    segments[[i]] <- rename_renal_container_segment(segments[[i]], compound)
  }

  paste(segments, collapse = "|")
}

# Resolve the compound that owns a renal-clearance container from the segment
# immediately preceding the container and the snapshot's compound names, in
# order:
#   1. Adjacent-segment match (primary): a renal-clearance process container is
#      a child of the compound (molecule) node in the PK-Sim model tree, so the
#      preceding segment is the compound name. Use it when it matches a known
#      compound name. This is path-local and correct for multi-compound
#      snapshots.
#   2. Single-compound fallback: when the preceding segment does not match but
#      the snapshot has exactly one compound, the container is unambiguous.
#   3. Otherwise return `NA_character_` (undeterminable); the caller leaves the
#      segment unchanged and informs.
resolve_renal_compound <- function(preceding_segment, compound_names) {
  if (!is.na(preceding_segment) && preceding_segment %in% compound_names) {
    return(preceding_segment)
  }
  if (length(compound_names) == 1) {
    return(compound_names[[1]])
  }
  NA_character_
}

# The single place the exact renal-clearance rename form lives, matching
# PK-Sim's v11-to-v12 import migration: the container segment is qualified with
# the owning compound name joined by a hyphen (e.g. `GlomerularFiltration` ->
# `GlomerularFiltration-Rifampicin`). PK-Sim resolves the path literally, so
# the exact glue must match its mapper; this form mirrors PK-Sim's own
# systemic-process display-name convention (`"<Process>-<Label>"`). Isolated in
# this one function so a correction to the glue touches a single call site and
# its one expected-string test.
rename_renal_container_segment <- function(segment, compound_name) {
  paste0(segment, "-", compound_name)
}
