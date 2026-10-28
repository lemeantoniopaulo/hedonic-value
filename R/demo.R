#' Run a reproducible hedonicValue demonstration
#'
#' The demonstration uses a larger synthetic urban-market fixture. It does not
#' write files and returns model comparison, selection, diagnostics and
#' fundamentação screening objects for inspection or notebooks.
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

  path <- system.file("extdata", "synthetic_urban_market_120.csv",
                      package = "hedonicValue")
  if (!nzchar(path)) stop("Synthetic demonstration dataset is unavailable.")

  data <- utils::read.csv(path, stringsAsFactors = FALSE,
                          check.names = FALSE)
  data <- data[data$observation_type == "rent", , drop = FALSE]
  data$observation_date <- as.Date(data$observation_date)
  split <- hv_temporal_split(data, "observation_date",
                             sort(unique(data$observation_date))[round(length(unique(data$observation_date)) * .75)])
  train <- split$train
  test <- split$test
  formulas <- list(
    estrutural = rent_brl_month ~ area_built_m2 + bedrooms + bathrooms + parking_spaces,
    hedonic = rent_brl_month ~ area_built_m2 + bedrooms + bathrooms + parking_spaces +
      age_years + condition_score + furnished + lake_view + pool_private +
      distance_center_km,
    hedonic_encargos = rent_brl_month ~ area_built_m2 + bedrooms + bathrooms +
      parking_spaces + age_years + condition_score + furnished + lake_view +
      pool_private + distance_center_km + condo_brl_month
  )
  fit_one <- function(formula) {
    hv_fit_model(formula, train, method = method,
                 weights = if (method == "wls") train$area_built_m2 else NULL)
  }
  models <- lapply(formulas, fit_one)
  selection <- hv_select_model(models, test, "rent_brl_month",
                               metric = "rmse", id = "observation_id")
  model <- selection$selected_model
  interval <- if (method %in% c("ols", "wls")) "confidence" else "none"
  predictions <- hv_predict_model(model, test, interval = "none")
  target <- data.frame(
    area_built_m2 = median(data$area_built_m2),
    bedrooms = round(median(data$bedrooms)),
    bathrooms = round(median(data$bathrooms)),
    parking_spaces = round(median(data$parking_spaces)),
    age_years = round(median(data$age_years)),
    condition_score = median(data$condition_score),
    furnished = 1L, lake_view = 1L, pool_private = 0L,
    distance_center_km = median(data$distance_center_km),
    condo_brl_month = median(data$condo_brl_month)
  )
  target_ci80 <- hv_predict_model(model, target, interval = interval, level = .80)
  fundamentacao <- hv_fundamentacao(model)
  plots <- if (isTRUE(include_plots)) {
    list(
      residuals = hv_plot(model, type = "residuals"),
      observed_vs_fitted = hv_plot(model, type = "observed_vs_fitted")
    )
  } else NULL

  list(data = data, train_data = train, test_data = test, models = models,
       model = model, selected_name = selection$selected_name,
       model_comparison = selection$comparison, selection = selection,
       predictions = predictions, target = target,
       confidence_interval_80 = target_ci80,
       fundamentacao = fundamentacao, plots = plots)
}

#' Render the complete normative demonstration report
#'
#' The report is built from the installed R Markdown template and uses only
#' synthetic data. Every normative item starts as `NÃO AVALIADO`; no conformity
#' statement is generated automatically.
#'
#' @param output_dir Directory for the rendered report. Defaults to a temporary
#'   directory.
#' @param output_format One of `html_document`, `pdf_document` or
#'   `word_document`.
#' @return Invisibly, the path returned by [hv_render_report()].
#' @export
hv_demo_report <- function(output_dir = tempdir(),
                           output_format = c("html_document", "pdf_document",
                                              "word_document")) {
  output_format <- match.arg(output_format)
  if (!requireNamespace("rmarkdown", quietly = TRUE))
    stop("Install the 'rmarkdown' package to render the demonstration report.")

  template <- system.file("rmarkdown", "templates", "relatorio_avaliacao",
                          "skeleton", "skeleton.Rmd", package = "hedonicValue")
  if (!nzchar(template)) stop("R Markdown demonstration template is unavailable.")
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  demo_result <- hv_demo(method = "ols", include_plots = FALSE)
  requirements <- data.frame(
    id = paste0("N-00", 1:8),
    reference = rep("ABNT NBR 14653-2:2011 / IBAPE/SP:2011", 8),
    requirement = c(
      "Finalidade, objeto, data-base e escopo",
      "Fontes e dados de mercado",
      "Caracterização, vistoria e documentação",
      "Seleção, comparabilidade e homogeneização",
      "Ofertas, duplicidades, outliers e ausências",
      "Método, variáveis e diagnósticos",
      "Extrapolação, fundamentação, precisão e limitações",
      "Responsabilidade técnica e conclusão"
    ),
    status = rep("NÃO AVALIADO", 8),
    evidence = rep("", 8),
    gap = rep("Requer análise e evidência do avaliador", 8),
    responsible = rep("", 8),
    stringsAsFactors = FALSE
  )
  evidence <- data.frame(
    id = "E-001",
    description = "Fixture sintético do pacote",
    source = "synthetic_urban_market_120.csv",
    version_date = as.character(Sys.Date()),
    location = "inst/extdata",
    status = "SINTÉTICO",
    stringsAsFactors = FALSE
  )
  params <- list(
    study = "Demonstração hedonicValue",
    purpose = "Exemplo reprodutível de modelagem e organização de evidências",
    status = "NÃO AVALIADO",
    normative_references = c("ABNT NBR 14653-2:2011", "IBAPE/SP:2011"),
    requirement_matrix = requirements,
    evidence_register = evidence,
    inspection = list(performed = FALSE, date = NA_character_,
                      responsible = NA_character_),
    professional_responsibility = list(name = NA_character_,
                                       registration = NA_character_,
                                       technical_record = NA_character_),
    evidence_gaps = c("Dados sintéticos; não representam transações de mercado.",
                      "Vistoria, fontes e responsabilidade profissional não foram informadas."),
    sample_data = demo_result$data,
    model_comparison = demo_result$model_comparison,
    selected_name = demo_result$selected_name,
    target = demo_result$target,
    confidence_interval_80 = demo_result$confidence_interval_80,
    fundamentacao = demo_result$fundamentacao,
    model = demo_result$model
  )
  input <- file.path(tempdir(), "hedonicValue-demo.Rmd")
  file.copy(template, input, overwrite = TRUE)
  hv_render_report(input, output_file = paste0("hedonicValue-demo.",
                                               sub("_document$", "", output_format)),
                   output_dir = output_dir, output_format = output_format,
                   params = params)
}
