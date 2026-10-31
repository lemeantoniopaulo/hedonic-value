#' Create a reproducible execution audit object
#' @export
hv_create_audit_trail <- function(data = NULL, configuration = list(), result = NULL,
                                  seed = NULL, run_id = NULL) {
  data_hash <- NA_character_
  if (!is.null(data)) {
    raw <- serialize(data, NULL, version = 3)
    data_hash <- paste0(length(raw), "-", sum(as.numeric(raw)) %% 1000000007)
  }
  commit <- tryCatch(system2("git", c("rev-parse", "HEAD"), stdout = TRUE,
                             stderr = FALSE)[1L], error = function(e) NA_character_)
  structure(list(run_id = if (is.null(run_id)) paste0("hv-", format(Sys.time(), "%Y%m%d%H%M%S")) else run_id,
    created_at = Sys.time(), package_version = tryCatch(as.character(utils::packageVersion("hedonicValue")),
      error = function(e) NA_character_),
    git_commit = commit, r_version = R.version.string, data_hash = data_hash,
    configuration = configuration, seed = seed, result = result), class = "hv_audit_trail")
}

#' Save or load an audit trail
#' @export
hv_save_audit <- function(audit, path) {
  stopifnot(inherits(audit, "hv_audit_trail"), is.character(path), length(path) == 1L)
  saveRDS(audit, path); invisible(path)
}

#' @export
hv_load_audit <- function(path) {
  if (!file.exists(path)) stop("Audit file does not exist.")
  x <- readRDS(path)
  if (!inherits(x, "hv_audit_trail")) stop("The file is not a hedonicValue audit trail.")
  x
}
