hv_fit <- function(formula, data, method = "ols") {
  stopifnot(inherits(formula, "formula"), is.data.frame(data))
  if (!identical(method, "ols")) stop("Only 'ols' is currently implemented")
  fit <- stats::lm(formula, data = data, na.action = stats::na.fail)
  if (anyNA(stats::coef(fit))) stop("Non-estimable coefficients: check collinearity")
  structure(list(model = fit, method = method, formula = formula,
    n = stats::nobs(fit), created = Sys.time(),
    dataset_columns = names(data),
    normative_status = "CONFORMIDADE_NAO_DETERMINADA"), class = "hv_model")
}
print.hv_model <- function(x, ...) {
  cat("hedonicValue model |", x$method, "| n =", x$n,
      "| normative status:", if (is.null(x$normative_status)) "CONFORMIDADE_NAO_DETERMINADA" else x$normative_status, "\n")
  print(summary(x$model)$coefficients)
  invisible(x)
}
hv_predict <- function(object, newdata, level = .80,
                       interval = c("confidence", "prediction")) {
  stopifnot(inherits(object, "hv_model"), is.data.frame(newdata),
            is.finite(level), level > 0, level < 1)
  interval <- match.arg(interval)
  as.data.frame(stats::predict(object$model, newdata = newdata,
    interval = interval, level = level))
}
hv_explain <- function(object, newdata) {
  stopifnot(inherits(object, "hv_model"), is.data.frame(newdata))
  prediction_terms <- stats::delete.response(stats::terms(object$model))
  mf <- stats::model.frame(prediction_terms, data = newdata,
    na.action = stats::na.fail, xlev = object$model$xlevels)
  X <- stats::model.matrix(prediction_terms, data = mf,
    contrasts.arg = object$model$contrasts)
  B <- stats::coef(object$model)
  contributions <- sweep(X[, names(B), drop = FALSE], 2L, B, `*`)
  out <- as.data.frame(contributions)
  offset <- stats::model.offset(mf)
  if (is.null(offset)) offset <- rep(0, nrow(out))
  out$.offset <- as.numeric(offset)
  out$estimated_value <- rowSums(contributions) + out$.offset
  # The object does not record response transformations yet. Contributions are
  # therefore reported only on the fitted model scale; no back-transformation
  # is implied or requested.
  attr(out, "scale") <- "model_scale"
  attr(out, "response_transformation") <- "unknown"
  attr(out, "back_transform_required") <- FALSE
  out
}
hv_diagnostics <- function(object) {
  stopifnot(inherits(object, "hv_model"))
  m <- object$model
  list(summary = summary(m),
       residuals = data.frame(residual=stats::resid(m),
       studentized=stats::rstudent(m), leverage=stats::hatvalues(m),
       cooks_distance=stats::cooks.distance(m)))
}
hv_normative_check <- function(object, newdata, evidence = list()) {
  stopifnot(inherits(object, "hv_model"), is.data.frame(newdata))
  X <- stats::model.matrix(object$model)
  k <- ncol(X) - 1L
  n <- stats::nobs(object$model)
  list(status = "CONFORMIDADE_NAO_DETERMINADA",
    standard = if (is.null(evidence$standard)) NA_character_ else evidence$standard,
    n=n, k=k,
    reasons=c("No versioned normative rule set or professional review was supplied.",
      "Statistical results do not establish normative conformity."),
    outstanding=c("market-data provenance", "model significance",
      "individual regressor tests", "categorical sample support", "extrapolation",
      "model assumptions", "physical/documentary survey", "technical responsibility",
      "required report content", "applicable normative edition"))
}
hv_compare <- function(models, newdata, truth) {
  stopifnot(is.list(models), is.data.frame(newdata), truth %in% names(newdata))
  if (!is.numeric(newdata[[truth]])) stop("Truth must be numeric")
  if (is.null(names(models)) || any(!nzchar(names(models)))) stop("Models must be named")
  do.call(rbind,lapply(names(models), function(nm) {
    p <- hv_predict(models[[nm]], newdata)$fit
    e <- p - newdata[[truth]]
    data.frame(model=nm, rmse=sqrt(mean(e^2)), mae=mean(abs(e)),bias=mean(e))
  }))
}
