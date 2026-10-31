#' Create reproducible cross-validation folds
#' @export
hv_make_folds <- function(n, k = 5L, repeats = 1L, seed = NULL) {
  if (length(n) != 1L || n < 2L || k < 2L || repeats < 1L) stop("Invalid fold dimensions.")
  if (!is.null(seed)) set.seed(seed)
  lapply(seq_len(repeats), function(r) {
    ids <- sample(rep(seq_len(min(k, n)), length.out = n))
    lapply(seq_len(min(k, n)), function(f) which(ids == f))
  })
}

#' Compute prediction metrics on the original response scale
#' @export
hv_prediction_metrics <- function(observed, predicted) {
  ok <- is.finite(observed) & is.finite(predicted)
  if (!any(ok)) stop("No finite observed/predicted pairs for metrics.")
  e <- predicted[ok] - observed[ok]
  pct <- if (all(observed[ok] != 0)) mean(abs(e / observed[ok])) * 100 else NA_real_
  c(rmse = sqrt(mean(e ^ 2)), mae = mean(abs(e)), medae = stats::median(abs(e)),
    mape = pct, bias = mean(e), n = sum(ok))
}

#' Cross-validate one response-family/specification without preprocessing leakage
#' @export
hv_cross_validate <- function(data, y, predictors, response = c("original", "log"),
                              transformations = list(), folds = NULL, k = 5L,
                              repeats = 1L, seed = NULL,
                              retransformation = c("none", "smearing", "lognormal")) {
  stopifnot(is.data.frame(data), is.character(y), length(y) == 1L)
  response <- match.arg(response); retransformation <- match.arg(retransformation)
  if (response == "log" && any(data[[y]] <= 0, na.rm = TRUE))
    stop("Log-response family requires a strictly positive response.")
  if (is.null(folds)) folds <- hv_make_folds(nrow(data), k, repeats, seed)
  fold_results <- list(); index <- 0L
  for (r in seq_along(folds)) for (f in seq_along(folds[[r]])) {
    index <- index + 1L; test_rows <- folds[[r]][[f]]; train_rows <- setdiff(seq_len(nrow(data)), test_rows)
    cols <- c(y, predictors)
    train_complete <- hv_complete_cases(data[train_rows, , drop = FALSE], cols,
                                        "cross-validation training")
    test_complete <- hv_complete_cases(data[test_rows, , drop = FALSE], cols,
                                       "cross-validation assessment")
    train <- train_complete$data; test <- test_complete$data
    transformed_train <- hv_transform_variables(train, transformations)
    transformed_test <- hv_transform_variables(test, transformations)
    response_name <- ".hv_response"
    transformed_train[[response_name]] <- if (response == "log") log(train[[y]]) else train[[y]]
    transformed_test[[response_name]] <- if (response == "log") log(test[[y]]) else test[[y]]
    chosen <- names(transformations)[!vapply(transformations, function(x)
      identical(x, "exclude") || is.null(x), logical(1))]
    chosen <- intersect(chosen, predictors)
    if (!length(chosen)) chosen <- character()
    form <- stats::reformulate(chosen, response_name)
    fit <- stats::lm(form, data = transformed_train, na.action = stats::na.fail)
    eta <- as.numeric(stats::predict(fit, newdata = transformed_test))
    rt <- if (response == "log") hv_retransformation(fit, retransformation) else NULL
    pred <- if (response == "log") hv_back_transform(eta, rt, "mean") else eta
    met <- hv_prediction_metrics(test[[y]], pred)
    fold_results[[index]] <- data.frame(repeat_id = r, fold = f, t(met),
      train_n = nrow(train), test_n = nrow(test), stringsAsFactors = FALSE)
  }
  fold_table <- do.call(rbind, fold_results)
  aggregate <- colMeans(fold_table[, c("rmse", "mae", "medae", "mape", "bias", "n")], na.rm = TRUE)
  list(response = response, y = y, predictors = predictors, transformations = transformations,
       fold_results = fold_table, metrics = aggregate, folds = folds,
       retransformation = retransformation, objective = "mean_RMSE_original_scale")
}
