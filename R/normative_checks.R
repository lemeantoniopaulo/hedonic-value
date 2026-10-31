#' Build an evidence-based normative requirement result
hv_normative_requirement <- function(id, requirement, status, criterion = NA_character_,
                                     evidence = NA_character_, source = NA_character_,
                                     item = NA_character_, result = NA_character_,
                                     justification = NA_character_, intervention = NA_character_) {
  data.frame(id = id, requirement = requirement, source = source, item = item,
    criterion = criterion, data_used = evidence, result = result, status = status,
    justification = justification, professional_intervention = intervention,
    stringsAsFactors = FALSE)
}

#' Check computable safeguards without asserting conformity to ABNT
#' @export
hv_normative_checks <- function(model, data, y, newdata = NULL, predictors = NULL,
                                normative_source = NULL, rules = list()) {
  if (!inherits(model, "hv_model") && !inherits(model, "lm")) stop("model must be a fitted model.")
  fit <- if (inherits(model, "hv_model")) model$model else model
  if (!is.data.frame(data) || !is.character(y) || !y %in% names(data)) stop("Invalid data/y.")
  X <- stats::model.matrix(fit); n <- stats::nobs(fit); k <- ncol(X) - 1L
  source <- if (is.null(normative_source)) NA_character_ else as.character(normative_source)[1L]
  rows <- list(
    hv_normative_requirement("N-001", "Quantidade de dados efetivamente utilizados",
      "Pendente de analise tecnica", "Edicao normativa e item aplicavel nao informados",
      as.character(n), source, NA, n, "O calculo amostral e reportado, mas o limite normativo nao foi presumido."),
    hv_normative_requirement("N-002", "Quantidade de variaveis independentes",
      "Pendente de analise tecnica", "Edicao normativa e item aplicavel nao informados",
      as.character(k), source, NA, k, "A contagem computavel nao substitui o criterio normativo aplicavel."),
    hv_normative_requirement("N-003", "Singularidade e multicolinearidade da matriz de projeto",
      "Pendente de analise tecnica",
      "Diagnostico computavel; limiar normativo nao presumido", paste0("rank=", qr(X)$rank,
      "; colunas=", ncol(X)), source, NA, qr(X)$rank, if (qr(X)$rank < ncol(X))
        "Matriz de projeto singular; o status normativo requer regra identificada." else
        "Limiar normativo e interpretacao profissional ainda requeridos."),
    hv_normative_requirement("N-004", "Significancia global e dos regressores",
      "Pendente de analise tecnica", "Nao classificar automaticamente por p-valores",
      "summary(model)", source, NA, NA, "Inferencia convencional apos selecao automatica requer cautela."),
    hv_normative_requirement("N-005", "Exame dos residuos e pontos influentes",
      "Pendente de analise tecnica", "Exame estatistico e julgamento profissional",
      "residuos, alavancagem e Cook disponiveis", source, NA, NA, "Resultados exploratorios nao demonstram atendimento normativo."),
    hv_normative_requirement("N-006", "Fundamentacao, precisao e documentacao",
      "Nao verificavel", "Fonte normativa/edicao/item nao confirmados",
      NA, source, NA, NA, "Depende de dados de mercado, vistoria, documentacao e responsabilidade tecnica.",
      "Perito deve informar e fundamentar a edicao normativa aplicavel.")
  )
  if (!is.null(newdata)) {
    if (is.null(predictors)) predictors <- attr(stats::terms(fit), "term.labels")
    ext <- hv_check_extrapolation(data, newdata, intersect(predictors, names(data)))
    rows[[length(rows) + 1L]] <- hv_normative_requirement("N-007", "Dominio e extrapolacao do avaliando",
      "Pendente de analise tecnica",
      "Comparacao descritiva com os limites observados; extrapolacao multivariada nao presumida",
      paste(capture.output(print(ext, row.names = FALSE)), collapse = " | "), source, NA, NA,
      "A situacao requer avaliacao tecnica e nao e decidida apenas por limites univariados.")
  }
  result <- do.call(rbind, rows)
  structure(result, class = c("hv_normative_result", "data.frame"),
            hv_normative_source = source,
            hv_warning = "Statuses are evidence states, not certification of ABNT conformity.")
}

#' Export a normative result as a report-ready list
#' @export
hv_normative_summary <- function(result) {
  stopifnot(inherits(result, "hv_normative_result") || is.data.frame(result))
  list(table = result, status_counts = table(result$status),
       conformity_certified = FALSE,
       warning = "Normative conformity is not inferred from predictive metrics.")
}
