#!/usr/bin/env Rscript
# Parameter-promotion evidence crawl (issue #158).
#
# Self-contained, `.Rbuildignore`d regeneration script. It discovers and pins a
# manifest of PK-Sim full-project snapshot JSON files published in the
# Open-Systems-Pharmacology GitHub org, fetches each pinned file once, tallies
# per-factory parameter occurrences, cross-checks candidate units against the
# package's own `validate_unit()`, and writes the deliverable artifacts under
# `dev/parameter-promotion/`.
#
# This script NEVER modifies anything under `R/`, `man/`, `NAMESPACE`, or the
# package's exported surface. It only reads the package (via
# `osp.snapshots::validate_unit()`) and writes under `dev/parameter-promotion/`.
#
# Reproducibility contract (FR-013 / FR-014): given the committed
# `source-manifest.csv`, re-running with `mode = "replay"` re-reads the pinned
# raw URLs (by commit SHA, never a branch/latest) and rebuilds the tally. Any
# manifest tuple whose upstream file has since disappeared is reported as an
# explicit gap, not silently dropped.
#
# Usage:
#   Rscript dev/parameter-promotion/crawl.R           # replay committed manifest (default)
#   Rscript dev/parameter-promotion/crawl.R discover  # re-discover + re-pin manifest, then crawl
#
# `discover` needs an authenticated `gh` CLI against the OSP org; `replay` needs
# only network access to raw.githubusercontent.com. Neither needs secrets.

# Configuration --------------------------------------------------------------

DEV_DIR <- "dev/parameter-promotion"
MANIFEST_PATH <- file.path(DEV_DIR, "source-manifest.csv")
SLICES_DIR <- file.path(DEV_DIR, "slices")
TALLY_PATH <- file.path(DEV_DIR, "crawl-tally.csv")
ORG <- "Open-Systems-Pharmacology"

# In-scope sections: a file counts as a project snapshot (D1) only if at least
# one of these top-level keys is present.
IN_SCOPE_SECTIONS <- c(
  "Compounds",
  "Protocols",
  "Events",
  "ExpressionProfiles",
  "Populations"
)

# Sentinel recorded for a parameter entry that carries no `Unit` field
# (dimensionless / unitless). Never dropped.
UNIT_NONE <- "(none)"

`%||%` <- function(x, y) if (is.null(x)) y else x

# Discovery (D1) + pinning (D2) ----------------------------------------------
# Requires an authenticated `gh` CLI. Produces the pinned manifest data frame.
# Selection rule (recorded in the manifest header and the methodology section):
#   - ALL `-Model` repos (monotherapy models: richest per-block variety).
#   - ALL `Example_*` repos and `Pregnancy-Models` (structural variety:
#     populations, advanced protocols, expression profiles).
#   - A deterministic 1-in-4 sample of `-DDI` repos (sorted by name, every 4th),
#     to represent multi-compound interaction snapshots without crawling all 121.
# Reproducibility rests on the committed manifest, not on this heuristic
# (spec Non-goal 3, D1). Re-running `discover` against a changed org may resolve
# a different set / different SHAs; `replay` against the committed manifest is
# the reproducible path.

gh_json <- function(path, ...) {
  args <- c("api", path, ...)
  out <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status") %||% 0L
  if (!identical(status, 0L)) {
    return(NULL)
  }
  jsonlite::fromJSON(paste(out, collapse = "\n"), simplifyVector = FALSE)
}

discover_manifest <- function() {
  message("Discovery: enumerating non-archived OSP repos matching D1 ...")
  repos <- character(0)
  page <- 1L
  repeat {
    batch <- gh_json(sprintf(
      "orgs/%s/repos?per_page=100&type=public&page=%d",
      ORG,
      page
    ))
    if (is.null(batch) || length(batch) == 0L) {
      break
    }
    for (r in batch) {
      if (isFALSE(r$archived)) {
        repos <- c(repos, r$name)
      }
    }
    page <- page + 1L
  }
  repos <- sort(unique(repos))

  d1 <- repos[
    grepl("-Model$", repos) |
      grepl("-DDI$", repos) |
      grepl("^Example_", repos) |
      repos == "Pregnancy-Models"
  ]

  model_repos <- sort(d1[grepl("-Model$", d1)])
  example_repos <- sort(d1[grepl("^Example_", d1) | d1 == "Pregnancy-Models"])
  ddi_repos <- sort(d1[grepl("-DDI$", d1)])
  ddi_sample <- ddi_repos[seq(1, length(ddi_repos), by = 4)]

  selected <- c(model_repos, example_repos, ddi_sample)
  message(sprintf(
    "  D1 matches: %d (%d Model, %d Example/Pregnancy, %d DDI). Selected %d (all Model/Example + 1-in-4 DDI).",
    length(d1),
    length(model_repos),
    length(example_repos),
    length(ddi_repos),
    length(selected)
  ))

  rows <- list()
  for (repo in selected) {
    default_branch <- tryCatch(
      gh_json(sprintf("repos/%s/%s", ORG, repo))$default_branch,
      error = function(e) NULL
    )
    if (is.null(default_branch)) {
      message(sprintf("  [skip] %s: repo metadata unavailable", repo))
      next
    }
    sha <- tryCatch(
      gh_json(sprintf("repos/%s/%s/commits/HEAD", ORG, repo))$sha,
      error = function(e) NULL
    )
    if (is.null(sha)) {
      message(sprintf("  [skip] %s: HEAD sha unavailable", repo))
      next
    }
    # Resolve the project snapshot file. Repos vary: many use the conventional
    # `<RepoName>.json`, but some publish it under the compound name (`7E3.json`,
    # `Compound.json`) or a lower-cased variant (`Atomoxetine-model.json`). Try
    # the conventional path first, then fall back to scanning root-level `*.json`
    # entries in the pinned tree and taking the first that parses as a project
    # snapshot (>= 1 in-scope section). A repo with no such file contributes
    # nothing (D1) and is skipped, not aborted (FR-006).
    candidate_paths <- paste0(repo, ".json")
    tree <- gh_json(sprintf(
      "repos/%s/%s/git/trees/%s?recursive=0",
      ORG,
      repo,
      sha
    ))
    if (!is.null(tree$tree)) {
      root_jsons <- vapply(tree$tree, function(e) e$path %||% "", character(1))
      root_jsons <- root_jsons[
        grepl("\\.json$", root_jsons) & !grepl("/", root_jsons)
      ]
      candidate_paths <- unique(c(candidate_paths, root_jsons))
    }

    resolved_path <- NULL
    resolved_url <- NULL
    present <- character(0)
    for (file_path in candidate_paths) {
      raw_url <- sprintf(
        "https://raw.githubusercontent.com/%s/%s/%s/%s",
        ORG,
        repo,
        sha,
        utils::URLencode(file_path, reserved = TRUE)
      )
      parsed <- tryCatch(
        jsonlite::fromJSON(raw_url, simplifyVector = FALSE),
        error = function(e) NULL
      )
      if (is.null(parsed)) {
        next
      }
      p <- IN_SCOPE_SECTIONS[
        vapply(
          IN_SCOPE_SECTIONS,
          function(s) !is.null(parsed[[s]]) && length(parsed[[s]]) > 0L,
          logical(1)
        )
      ]
      if (length(p) > 0L) {
        resolved_path <- file_path
        resolved_url <- raw_url
        present <- p
        break
      }
    }
    if (is.null(resolved_path)) {
      message(sprintf(
        "  [no snapshot] %s: no root-level project snapshot",
        repo
      ))
      next
    }
    rows[[length(rows) + 1L]] <- data.frame(
      repository = repo,
      git_ref = default_branch,
      commit_sha = sha,
      file_path = resolved_path,
      raw_url = resolved_url,
      contributed = paste(present, collapse = ";"),
      stringsAsFactors = FALSE
    )
    message(sprintf(
      "  [ok] %s -> %s (%s)",
      repo,
      resolved_path,
      paste(present, collapse = ";")
    ))
  }
  do.call(rbind, rows)
}

write_manifest <- function(manifest) {
  header <- c(
    "# Parameter-promotion crawl source manifest (issue #158).",
    "#",
    "# Each row pins one PK-Sim full-project snapshot JSON by exact commit SHA so",
    "# the frequency counts are reproducible against the identical files (D2, FR-004).",
    "# `raw_url` is a SHA-pinned raw.githubusercontent.com URL (never a branch/latest).",
    "# `contributed` = the in-scope sections present in that file (;-joined).",
    "#",
    "# Selection rule (D1 + recorded subset, Non-goal 3): all `-Model` repos, all",
    "# `Example_*` repos and `Pregnancy-Models`, plus a deterministic 1-in-4 sample",
    "# of `-DDI` repos (sorted by name). Reproducibility rests on this recorded",
    "# manifest, not on exhaustiveness; re-run `crawl.R` (replay) to reproduce.",
    "#"
  )
  writeLines(header, MANIFEST_PATH)
  suppressWarnings(
    utils::write.table(
      manifest,
      MANIFEST_PATH,
      sep = ",",
      row.names = FALSE,
      qmethod = "double",
      append = TRUE,
      col.names = TRUE
    )
  )
  message(sprintf(
    "Wrote manifest: %s (%d files)",
    MANIFEST_PATH,
    nrow(manifest)
  ))
}

read_manifest <- function() {
  lines <- readLines(MANIFEST_PATH)
  data_lines <- lines[!grepl("^#", lines)]
  utils::read.csv(
    text = paste(data_lines, collapse = "\n"),
    stringsAsFactors = FALSE
  )
}

# Fetch & cache --------------------------------------------------------------
# Fetch each pinned snapshot once. A fetch/parse failure (repo deleted/renamed
# since pinning) is recorded as a gap (FR-006 resilience, FR-014 gap reporting),
# never fatal. Returns list(snapshots = named list keyed by repository, gaps).

fetch_snapshots <- function(manifest) {
  snapshots <- list()
  gaps <- list()
  for (i in seq_len(nrow(manifest))) {
    repo <- manifest$repository[i]
    url <- manifest$raw_url[i]
    parsed <- tryCatch(
      jsonlite::fromJSON(url, simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (is.null(parsed)) {
      gaps[[length(gaps) + 1L]] <- manifest[i, , drop = FALSE]
      message(sprintf("  [GAP] %s: could not read %s", repo, url))
      next
    }
    snapshots[[repo]] <- parsed
  }
  message(sprintf(
    "Fetched %d/%d snapshots (%d gaps).",
    length(snapshots),
    nrow(manifest),
    length(gaps)
  ))
  list(
    snapshots = snapshots,
    gaps = if (length(gaps)) do.call(rbind, gaps) else NULL
  )
}

# Tally helpers --------------------------------------------------------------
# The shared CSV column contract (Stage 1.5):
#   factory,parameter_id,id_field,occurrences,n_models,distinct_units,source_models
# `distinct_units` is `;`-joined (UNIT_NONE sentinel for unitless);
# `source_models` is `;`-joined repository names; n_models = distinct repos.

# A tally accumulator keyed by parameter_id. Each record holds occurrences and
# the sets of units and source models seen.
new_tally <- function() new.env(parent = emptyenv())

param_unit <- function(param) {
  u <- param$Unit
  if (is.null(u) || !nzchar(as.character(u))) UNIT_NONE else as.character(u)
}

# Add one observed parameter occurrence to the tally.
tally_add <- function(acc, id, unit, model) {
  key <- id
  rec <- if (exists(key, envir = acc, inherits = FALSE)) {
    get(key, envir = acc, inherits = FALSE)
  } else {
    list(occurrences = 0L, units = character(0), models = character(0))
  }
  rec$occurrences <- rec$occurrences + 1L
  rec$units <- union(rec$units, unit)
  rec$models <- union(rec$models, model)
  assign(key, rec, envir = acc)
  invisible(NULL)
}

# Convert an accumulator to a data frame with the shared column contract.
tally_to_df <- function(acc, factory, id_field) {
  keys <- ls(acc, sorted = TRUE)
  if (length(keys) == 0L) {
    return(data.frame(
      factory = character(0),
      parameter_id = character(0),
      id_field = character(0),
      occurrences = integer(0),
      n_models = integer(0),
      distinct_units = character(0),
      source_models = character(0),
      stringsAsFactors = FALSE
    ))
  }
  rows <- lapply(keys, function(k) {
    rec <- get(k, envir = acc, inherits = FALSE)
    data.frame(
      factory = factory,
      parameter_id = k,
      id_field = id_field,
      occurrences = rec$occurrences,
      n_models = length(rec$models),
      distinct_units = paste(sort(rec$units), collapse = ";"),
      source_models = paste(sort(rec$models), collapse = ";"),
      stringsAsFactors = FALSE
    )
  })
  df <- do.call(rbind, rows)
  df[order(-df$occurrences, df$parameter_id), , drop = FALSE]
}

# Walk a list of blocks, tallying each block's `.Parameters[]` by the given
# identifier field ("Name" or "Path").
tally_blocks <- function(acc, blocks, id_field, model) {
  if (is.null(blocks)) {
    return(invisible(NULL))
  }
  for (block in blocks) {
    params <- block$Parameters
    if (is.null(params)) {
      next
    }
    for (p in params) {
      id <- p[[id_field]]
      if (is.null(id) || !nzchar(as.character(id))) {
        next
      }
      tally_add(acc, as.character(id), param_unit(p), model)
    }
  }
  invisible(NULL)
}

# Per-factory tallies (FR-002/003/005; FR-007/008 boundaries) ----------------
# Each returns a data frame with the shared column contract, plus attribute
# `contributing_models` (number of snapshots that had >=1 block of this kind).

tally_factory <- function(snapshots, factory) {
  acc <- new_tally()
  contributing <- 0L
  # Extra context accumulators for the compound split (FR-008).
  excluded <- new_tally()

  for (model in names(snapshots)) {
    snap <- snapshots[[model]]
    contributed_here <- FALSE

    if (factory == "compound") {
      compounds <- snap$Compounds
      if (length(compounds)) {
        for (cmp in compounds) {
          if (!is.null(cmp$Parameters) && length(cmp$Parameters)) {
            contributed_here <- TRUE
          }
          tally_blocks(acc, list(cmp), "Name", model)
          # FR-008: record excluded-location params as context, not candidates.
          # Each physicochemical-property field (`Lipophilicity`, ...) is a LIST
          # of alternatives, each `{Name, IsDefault, Parameters}`. `PkaTypes` is
          # a list of pKa entries each carrying its own parameters. These are set
          # via dedicated fields, not via `create_compound(parameters=)`, so they
          # are counted only as context, never as loose-Parameters candidates.
          for (alt_field in c(
            "Lipophilicity",
            "FractionUnbound",
            "Solubility",
            "IntestinalPermeability",
            "Permeability"
          )) {
            alts <- cmp[[alt_field]]
            if (!is.null(alts) && length(alts)) {
              for (a in alts) {
                if (!is.null(a$Parameters)) {
                  for (p in a$Parameters) {
                    id <- p$Name
                    if (!is.null(id) && nzchar(as.character(id))) {
                      tally_add(
                        excluded,
                        paste0(alt_field, ":", id),
                        param_unit(p),
                        model
                      )
                    }
                  }
                }
              }
            }
          }
          # PkaTypes entries carry a `Value`/`Unit` directly (no nested list).
          if (!is.null(cmp$PkaTypes) && length(cmp$PkaTypes)) {
            for (pk in cmp$PkaTypes) {
              tally_add(excluded, "PkaTypes:Pka", param_unit(pk), model)
            }
          }
        }
      }
    } else if (factory == "process") {
      compounds <- snap$Compounds
      if (length(compounds)) {
        for (cmp in compounds) {
          procs <- cmp$Processes
          if (length(procs)) {
            contributed_here <- TRUE
            tally_blocks(acc, procs, "Name", model)
          }
        }
      }
    } else if (factory == "event") {
      if (length(snap$Events)) {
        contributed_here <- TRUE
        tally_blocks(acc, snap$Events, "Name", model)
      }
    } else if (factory == "expression_profile") {
      if (length(snap$ExpressionProfiles)) {
        contributed_here <- TRUE
        tally_blocks(acc, snap$ExpressionProfiles, "Path", model)
      }
    } else if (factory == "population") {
      pops <- snap$Populations
      if (length(pops)) {
        contributed_here <- TRUE
        for (pop in pops) {
          settings <- pop$Settings
          # Scalar ParameterRanges keyed by fixed name (Min/Max/Unit shape).
          for (rng_name in c(
            "Age",
            "Weight",
            "Height",
            "GestationalAge",
            "BMI"
          )) {
            rng <- settings[[rng_name]]
            if (!is.null(rng)) {
              unit <- rng$Unit
              unit <- if (is.null(unit) || !nzchar(as.character(unit))) {
                UNIT_NONE
              } else {
                as.character(unit)
              }
              tally_add(acc, rng_name, unit, model)
            }
          }
          # DiseaseStateParameters (range Name).
          if (!is.null(settings$DiseaseStateParameters)) {
            for (dsp in settings$DiseaseStateParameters) {
              id <- dsp$Name
              if (!is.null(id) && nzchar(as.character(id))) {
                tally_add(acc, as.character(id), param_unit(dsp), model)
              }
            }
          }
          # AdvancedParameters (Name).
          if (!is.null(pop$AdvancedParameters)) {
            for (ap in pop$AdvancedParameters) {
              id <- ap$Name
              if (!is.null(id) && nzchar(as.character(id))) {
                tally_add(acc, as.character(id), param_unit(ap), model)
              }
            }
          }
        }
      }
    } else if (factory == "protocol") {
      # FR-007: Simple protocols only (ApplicationType present).
      protocols <- snap$Protocols
      if (length(protocols)) {
        simple <- Filter(function(pr) !is.null(pr$ApplicationType), protocols)
        if (length(simple)) {
          contributed_here <- TRUE
          tally_blocks(acc, simple, "Name", model)
        }
      }
    } else if (factory == "schema") {
      # FR-007: Advanced protocols' Schemas[].Parameters only.
      protocols <- snap$Protocols
      if (length(protocols)) {
        for (pr in protocols) {
          if (is.null(pr$ApplicationType) && length(pr$Schemas)) {
            contributed_here <- TRUE
            tally_blocks(acc, pr$Schemas, "Name", model)
          }
        }
      }
    } else if (factory == "schema_item") {
      # FR-007: deepest level, Schemas[].SchemaItems[].Parameters.
      protocols <- snap$Protocols
      if (length(protocols)) {
        for (pr in protocols) {
          if (is.null(pr$ApplicationType) && length(pr$Schemas)) {
            for (sch in pr$Schemas) {
              if (length(sch$SchemaItems)) {
                contributing_items <- Filter(
                  function(si) !is.null(si$Parameters),
                  sch$SchemaItems
                )
                if (length(contributing_items)) {
                  contributed_here <- TRUE
                }
                tally_blocks(acc, sch$SchemaItems, "Name", model)
              }
            }
          }
        }
      }
    } else {
      stop("Unknown factory: ", factory)
    }

    if (contributed_here) contributing <- contributing + 1L
  }

  df <- tally_to_df(
    acc,
    factory,
    if (factory == "expression_profile") "Path" else "Name"
  )
  attr(df, "contributing_models") <- contributing
  if (factory == "compound") {
    attr(df, "excluded") <- tally_to_df(excluded, "compound_excluded", "Name")
  }
  df
}

# Main -----------------------------------------------------------------------

main <- function(mode = "replay") {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is required.")
  }

  dir.create(SLICES_DIR, recursive = TRUE, showWarnings = FALSE)

  if (mode == "discover") {
    manifest <- discover_manifest()
    if (is.null(manifest) || nrow(manifest) == 0L) {
      stop("Discovery produced an empty manifest (is `gh` authenticated?).")
    }
    write_manifest(manifest)
  } else {
    if (!file.exists(MANIFEST_PATH)) {
      stop("No committed manifest to replay; run with `discover` first.")
    }
    manifest <- read_manifest()
    message(sprintf(
      "Replay: %d pinned files from %s",
      nrow(manifest),
      MANIFEST_PATH
    ))
  }

  fetched <- fetch_snapshots(manifest)
  snapshots <- fetched$snapshots
  if (!is.null(fetched$gaps)) {
    message("Gaps (upstream files unreadable at their pinned SHA):")
    print(fetched$gaps[, c("repository", "commit_sha", "file_path")])
  }
  if (length(snapshots) == 0L) {
    stop("No snapshots could be read; cannot build a tally.")
  }

  factories <- c(
    "compound",
    "event",
    "expression_profile",
    "population",
    "process",
    "protocol",
    "schema",
    "schema_item"
  )

  all_slices <- list()
  for (factory in factories) {
    df <- tally_factory(snapshots, factory)
    slice_path <- file.path(SLICES_DIR, sprintf("tally-%s.csv", factory))
    utils::write.csv(df, slice_path, row.names = FALSE)
    message(sprintf(
      "  %s: %d distinct params, %d contributing snapshots -> %s",
      factory,
      nrow(df),
      attr(df, "contributing_models"),
      slice_path
    ))
    all_slices[[factory]] <- df
    # FR-008 context: the compound tally also emits the excluded-location
    # (physicochemical alternatives / pKa) counts as a separate slice.
    if (factory == "compound") {
      utils::write.csv(
        attr(df, "excluded"),
        file.path(SLICES_DIR, "tally-compound-excluded.csv"),
        row.names = FALSE
      )
    }
  }

  combined <- do.call(rbind, all_slices)
  combined <- combined[
    order(combined$factory, -combined$occurrences, combined$parameter_id),
    ,
    drop = FALSE
  ]
  utils::write.csv(combined, TALLY_PATH, row.names = FALSE)
  message(sprintf(
    "Wrote combined tally: %s (%d rows)",
    TALLY_PATH,
    nrow(combined)
  ))

  invisible(combined)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  mode <- if (length(args) >= 1L && args[1] %in% c("discover", "replay")) {
    args[1]
  } else {
    "replay"
  }
  main(mode)
}
