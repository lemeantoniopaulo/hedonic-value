#' Render a reproducible hedonic valuation report
#' @param input Path to an R Markdown file.
#' @param output_file Optional output file.
#' @param output_dir Optional output directory.
#' @param output_format Output format.
#' @param params Named report parameters.
#' @param ... Additional arguments passed to rmarkdown::render().
#' @return Invisibly, the rendered output path.
#' @export
hv_render_report <- function(input, output_file = NULL, output_dir = NULL,
                             output_format = c("html_document", "pdf_document", "word_document"),
                             params = list(), ...) {
  if (!requireNamespace("rmarkdown", quietly = TRUE))
    stop("Install the 'rmarkdown' package to render reports.")
  if (!is.character(input) || length(input) != 1L || !file.exists(input))
    stop("input must be an existing R Markdown file.")
  if (!is.list(params) || (length(params) > 0L && is.null(names(params))))
    stop("params must be a named list.")
  rmarkdown::render(input, output_format = match.arg(output_format),
    output_file = output_file, output_dir = output_dir, params = params,
    envir = new.env(parent = globalenv()), ...)
}
