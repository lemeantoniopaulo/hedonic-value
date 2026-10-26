source(".github/scripts/check-support.R")
clean <- structure(list(errors = character(), warnings = character(),
                        notes = character(), status = 0L, timeout = FALSE), class = "rcmdcheck")
stopifnot(hv_ci_check_clean(clean))
for (field in c("errors", "warnings", "notes")) {
  bad <- clean
  bad[[field]] <- "Injected diagnostic"
  stopifnot(!hv_ci_check_clean(bad))
  bad[[field]] <- NULL
  stopifnot(!hv_ci_check_clean(bad))
}
stopifnot(!hv_ci_check_clean(NULL), !hv_ci_check_clean(list()),
          !hv_ci_check_clean(unclass(clean)))
bad <- clean
bad$errors <- NA_character_
stopifnot(!hv_ci_check_clean(bad))
for (status in list(1L, -1L, NA_integer_, Inf, "0", integer(), c(0L, 1L), NULL)) {
  bad <- clean; bad$status <- status
  stopifnot(!hv_ci_check_clean(bad))
}
for (timeout in list(TRUE, NA, NULL, 0, c(FALSE, FALSE))) {
  bad <- clean; bad$timeout <- timeout
  stopifnot(!hv_ci_check_clean(bad))
}
# Regression using rcmdcheck's real result constructor, not just a mock class.
failed_process <- rcmdcheck:::new_rcmdcheck(
  stdout = "", stderr = "Fatal error: cannot open file",
  description = desc::description$new("DESCRIPTION"), status = 1L)
stopifnot(!hv_ci_check_clean(failed_process))
diagnostic <- function(field) { result <- clean; result[[field]] <- "Injected diagnostic"; result }
cases <- list(clean = clean, error = diagnostic("errors"),
              warning = diagnostic("warnings"),
              note = diagnostic("notes"), invalid = list(), process_failure = failed_process)
for (name in names(cases)) {
  directory <- tempfile(paste0("ci-gate-", name, "-"))
  result <- cases[[name]]
  code <- hv_ci_run(directory, checker = function(...) result)
  stopifnot(identical(code, if (name == "clean") 0L else 1L),
            file.exists(file.path(directory, "check-result.rds")))
}
directory <- tempfile("ci-runner-exception-")
code <- hv_ci_run(directory, checker = function(...) stop("Injected runner failure"))
stopifnot(identical(code, 1L),
          identical(readLines(file.path(directory, "runner-error.txt")),
                    "Injected runner failure"))
cat("CI gate: clean accepted; errors/warnings/notes/invalid/exception rejected.\n")
