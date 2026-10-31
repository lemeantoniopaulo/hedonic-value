hv_fit_selected <- function(data, y, response = c("original", "log"),
                            transformations = list(), retransformation = "smearing") {
  response <- match.arg(response)
  if (!is.character(y) || length(y) != 1L || !y %in% names(data)) stop("Unknown response column.")
  if (response == "log" && (!is.numeric(data[[y]]) ||
      any(!is.finite(data[[y]]) | data[[y]] <= 0, na.rm = TRUE)))
    stop("Log-response family requires a strictly positive response.")
  chosen <- names(transformations)[!vapply(transformations, function(x)
    identical(x, "exclude") || is.null(x), logical(1))]
  columns <- c(y, names(transformations)[!vapply(transformations, function(x)
    identical(x, "exclude") || is.null(x), logical(1))])
  complete <- hv_complete_cases(data, columns, "selected model fit")
  data <- complete$data
  transformed <- hv_transform_variables(data, transformations)
  transformed$.hv_response <- if (response == "log") log(data[[y]]) else data[[y]]
  fit <- stats::lm(stats::reformulate(chosen, ".hv_response"), data = transformed,
                   na.action = stats::na.fail)
  rt <- if (response == "log") hv_retransformation(fit, retransformation) else NULL
  structure(list(model = fit, response = response, y = y, predictors = chosen,
    transformations = transformations, retransformation = rt,
    training_rows = complete$rows, scale = "original_response_for_comparison"),
    class = "hv_selected_model")
}

#' Predict a selected hedonic model on the original response scale
#' @export
hv_predict_selected <- function(model, newdata, target = c("mean", "median")) {
  stopifnot(inherits(model, "hv_selected_model"), is.data.frame(newdata))
  target <- match.arg(target)
  transformed <- hv_transform_variables(newdata, model$transformations)
  eta <- as.numeric(stats::predict(model$model, newdata = transformed))
  if (model$response == "log") hv_back_transform(eta, model$retransformation, target) else eta
}

hv_candidate_fitness <- function(data, y, response, space, chromosome,
                                 folds, retransformation, complexity_penalty) {
  transformations <- hv_decode_chromosome(chromosome, space)
  selected <- names(transformations)[!vapply(transformations, function(x)
    identical(x, "exclude") || is.null(x), logical(1))]
  if (!length(selected)) return(list(loss = .Machine$double.xmax ^ 0.5, reason = "no_predictors"))
  cv <- tryCatch(hv_cross_validate(data, y, names(space), response = response,
    transformations = transformations, folds = folds,
    retransformation = retransformation), error = function(e) e)
  if (inherits(cv, "error"))
    return(list(loss = .Machine$double.xmax ^ 0.5, reason = conditionMessage(cv)))
  complexity <- length(selected)
  loss <- as.numeric(cv$metrics[["rmse"]]) + complexity_penalty * complexity
  list(loss = loss, cv = cv, complexity = complexity,
       chromosome = chromosome, transformations = transformations)
}

#' Search both response families with comparable budgets
#' @export
hv_optimize_hedonic <- function(data, y, predictors = NULL, categorical = character(),
                                lambdas = c(-1, -0.5, 0, 0.5, 1), fixed = character(),
                                excluded = character(), k = 5L, repeats = 1L,
                                population_size = 30L, generations = 50L,
                                crossover_probability = 0.8, mutation_probability = 0.1,
                                elitism = 2L, patience = 10L, runs = 1L, seed = NULL,
                                complexity_penalty = 0, exhaustive_limit = 10000L,
                                retransformation = c("smearing", "lognormal", "none")) {
  if (is.null(predictors)) predictors <- setdiff(names(data), y)
  if (!length(predictors)) stop("At least one predictor is required.")
  response_log_ok <- is.numeric(data[[y]]) && all(data[[y]] > 0, na.rm = TRUE)
  space <- hv_gene_space(data, predictors, categorical, lambdas, fixed, excluded)
  folds <- hv_make_folds(nrow(data), k, repeats, seed)
  run_family <- function(response, family_seed) {
    if (response == "log" && !response_log_ok)
      return(list(admissible = FALSE, reason = "response_not_strictly_positive", space = space))
    fit <- function(chromosome) hv_candidate_fitness(data, y, response, space,
      chromosome, folds, if (response == "log") match.arg(retransformation) else "none",
      complexity_penalty)
    result <- hv_genetic_optimize(space, fit, population_size, generations,
      crossover_probability, mutation_probability, elitism, patience, runs,
      seed = family_seed, exhaustive_limit = exhaustive_limit)
    result$admissible <- TRUE; result$response <- response; result$space <- space
    result
  }
  families <- list(original = run_family("original", seed),
                   log = run_family("log", if (is.null(seed)) NULL else seed + 1L))
  best <- lapply(families, function(x) if (isTRUE(x$admissible)) {
    b <- x$best$result
    hv_fit_selected(data, y, x$response, b$transformations,
                    if (x$response == "log") match.arg(retransformation) else "none")
  } else NULL)
  comparable <- data.frame(family = character(), rmse = numeric(), mae = numeric(),
                           complexity = numeric(), stringsAsFactors = FALSE)
  for (nm in names(families)) if (isTRUE(families[[nm]]$admissible)) {
    b <- families[[nm]]$best$result
    comparable <- rbind(comparable, data.frame(family = nm,
      rmse = b$cv$metrics[["rmse"]], mae = b$cv$metrics[["mae"]],
      complexity = b$complexity, stringsAsFactors = FALSE))
  }
  recommended <- if (nrow(comparable)) comparable$family[which.min(comparable$rmse)] else NA_character_
  out <- list(y = y, predictors = predictors, families = families, selected_models = best,
       comparison = comparable, recommended_family = recommended,
       recommendation_requires_professional_review = TRUE,
       warning = "The CV objective is not an unbiased estimate when used for selection; use nested or external validation for final claims.")
  out$audit <- hv_create_audit_trail(data = data, seed = seed, configuration = list(
    y = y, predictors = predictors, lambdas = lambdas, fixed = fixed,
    excluded = excluded, k = k, repeats = repeats, population_size = population_size,
    generations = generations, crossover_probability = crossover_probability,
    mutation_probability = mutation_probability, elitism = elitism, patience = patience,
    runs = runs, complexity_penalty = complexity_penalty,
    exhaustive_limit = exhaustive_limit, retransformation = match.arg(retransformation)))
  out
}
