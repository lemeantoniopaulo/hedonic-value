hv_ci_check_clean <- function(result) {
  fields <- c("errors", "warnings", "notes")
  inherits(result, "rcmdcheck") &&
    is.numeric(result$status) && length(result$status) == 1L &&
    is.finite(result$status) && result$status == 0 &&
    identical(result$timeout, FALSE) &&
    all(fields %in% names(result)) &&
    all(vapply(result[fields], function(x) is.character(x) && length(x) == 0L,
               logical(1)))
}

hv_ci_run <- function(directory, checker = rcmdcheck::rcmdcheck) {
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  writeLines(capture.output(sessionInfo()), file.path(directory, "session-info.txt"))
  tryCatch({
    result <- checker(args = "--no-manual", error_on = "never",
                      check_dir = file.path(directory, "check"),
                      build_args = "--no-manual")
    saveRDS(result, file.path(directory, "check-result.rds"))
    if (!inherits(result, "rcmdcheck") ||
        !all(c("errors", "warnings", "notes") %in% names(result))) {
      stop("Missing or invalid structured R CMD check result")
    }
    counts <- vapply(result[c("errors", "warnings", "notes")], length, integer(1))
    writeLines(c(paste("process status:", paste(result$status, collapse = ",")),
                 paste("timeout:", paste(result$timeout, collapse = ",")),
                 paste(names(counts), counts, sep = ": ")),
               file.path(directory, "check-status.txt"))
    if (hv_ci_check_clean(result)) 0L else 1L
  }, error = function(e) {
    writeLines(conditionMessage(e), file.path(directory, "runner-error.txt"))
    message("Check runner failed: ", conditionMessage(e))
    1L
  })
}
