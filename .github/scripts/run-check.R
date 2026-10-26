source(".github/scripts/check-support.R")
diagnostics <- file.path(Sys.getenv("RUNNER_TEMP", unset = tempdir()), "hedonic-ci")
quit(status = hv_ci_run(diagnostics))
