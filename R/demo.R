#' Run a reproducible hedonicValue demonstration
#'
#' The demonstration uses only the synthetic package fixture. It does not
#' write files and returns all objects needed for inspection or notebooks.
#'
#' @param method One of `ols`, `wls`, `gls` or `robust`.
#' @param include_plots Logical; include diagnostic ggplot objects in the
#'   returned list.
#' @return A list with `data`, `model`, `predictions` and, optionally, `plots`.
#' @export
hv_demo <- function(method = c("ols", "wls", "gls", "robust"),
                    include_plots = TRUE) {
  method <- match.arg(method)
  stopifnot(length(include_plots) == 1L, !is.na(include_plots))

  path <- system.file("extdata", "synthetic_property_test.csv",
                      package = "hedonicValue")
  if (!nzchar(path)) stop("Synthetic demonstration dataset is unavailable.")

  data <- utils::read.csv(path, stringsAsFactors = FALSE,
                          check.names = FALSE)
  data <- data[data$observation_type == "rent", , drop = FALSE]

  weights <- if (method == "wls") data$area_built_m2 else NULL
  model <- hv_fit_model(
    rent_brl_month ~ area_built_m2 + bedrooms + lake_view + furnished,
    data = data,
    method = method,
    weights = weights
  )

  interval <- if (method %in% c("ols", "wls")) "confidence" else "none"
  predictions <- hv_predict_model(model, data, interval = interval)
  plots <- if (isTRUE(include_plots)) {
    list(
      residuals = hv_plot(model, type = "residuals"),
      observed_vs_fitted = hv_plot(model, type = "observed_vs_fitted")
    )
  } else NULL

  list(data = data, model = model, predictions = predictions, plots = plots)
}
