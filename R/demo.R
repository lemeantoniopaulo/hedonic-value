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

#' Render the complete normative demonstration report
#'
#' The report is built from the installed R Markdown template and uses only
#' synthetic data. Every normative item starts as `NAO AVALIADO`; no conformity
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
      "Caracterizacao, vistoria e documentacao",
      "Selecao, comparabilidade e homogeneizacao",
      "Ofertas, duplicidades, outliers e ausencias",
      "Metodo, variaveis e diagnosticos",
      "Extrapolacao, fundamentacao, precisao e limitacoes",
      "Responsabilidade tecnica e conclusao"
    ),
    status = rep("NAO AVALIADO", 8),
    evidence = rep("", 8),
     gap = rep("Requer analise e evidencia do avaliador", 8),
    responsible = rep("", 8),
    stringsAsFactors = FALSE
  )
  evidence <- data.frame(
    id = "E-001",
    description = "Fixture sintetico do pacote",
    source = "synthetic_property_test.csv",
    version_date = as.character(Sys.Date()),
    location = "inst/extdata",
    status = "SINTETICO",
    stringsAsFactors = FALSE
  )
  params <- list(
    study = "Demonstracao hedonicValue",
    purpose = "Exemplo reprodutivel de modelagem e organizacao de evidencias",
    status = "NAO AVALIADO",
    normative_references = c("ABNT NBR 14653-2:2011", "IBAPE/SP:2011"),
    requirement_matrix = requirements,
    evidence_register = evidence,
    inspection = list(performed = FALSE, date = NA_character_,
                      responsible = NA_character_),
    professional_responsibility = list(name = NA_character_,
                                       registration = NA_character_,
                                       technical_record = NA_character_),
    evidence_gaps = c("Dados sinteticos; nao representam transacoes de mercado.",
                      "Vistoria, fontes e responsabilidade profissional nao foram informadas."),
    sample_data = demo_result$data,
    model = demo_result$model
  )
  input <- file.path(tempdir(), "hedonicValue-demo.Rmd")
  file.copy(template, input, overwrite = TRUE)
  hv_render_report(input, output_file = paste0("hedonicValue-demo.",
                                               sub("_document$", "", output_format)),
                   output_dir = output_dir, output_format = output_format,
                   params = params)
}
