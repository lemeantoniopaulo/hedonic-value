#' Launch the optional Shiny workflow
#'
#' The app is intentionally thin: statistical logic remains in package
#' functions so that the same pipeline can be tested and audited outside Shiny.
#' @export
hv_run_app <- function(...) {
  if (!requireNamespace("shiny", quietly = TRUE))
    stop("Install the 'shiny' package to launch the application.")
  shiny::runApp(system.file("shiny", "hedonicValue", package = "hedonicValue"), ...)
}
