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
      "| normative status:", x$compliance, "\n")
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
  X <- stats::model.matrix(stats::delete.response(stats::terms(object$model)),
    data = newdata, contrasts.arg = object$model$contrasts,
    xlev = object$model$xlevels)
  B <- stats::coef(object$model)
  contributions <- sweep(X[, names(B), drop = FALSE], 2L, B, `*`)
  out <- as.data.frame(contributions)
  out$estimated_value <- rowSums(contributions)
  attr(out, "scale") <- if (identical(object$model$call[[1L]], as.name("lm"))) "linear_predictor" else "model_scale"
  attr(out, "back_transform_required") <- TRUE
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
  ci <- hv_predict(object, newdata, level=.80, interval="confidence")
  positive <- ci$fit > 0 & ci$lwr > 0
  width <- ifelse(positive, (ci$upr - ci$lwr) / ci$fit, NA_real_)
  precision <- ifelse(is.na(width), "NOT_CLASSIFIED",
    ifelse(width <= .30, "III", ifelse(width <= .40, "II",
      ifelse(width <= .50, "I", "NOT_CLASSIFIED"))))
  list(status = "PRELIMINARY_ONLY",
    standard = if (is.null(evidence$standard)) "NBR_14653-2:2011_VERIFY_EDITION" else evidence$standard,
    n=n, k=k, minimum_sample_size=c(III=6*(k+1),II=4*(k+1),I=3*(k+1)),
    sample_size_screen=c(III=n>=6*(k+1),II=n>=4*(k+1),I=n>=3*(k+1)),
    interval_width_ratio=width, precision_screen=precision,
    outstanding=c("market-data provenance", "model significance",
      "individual regressor tests", "categorical sample support", "extrapolation",
      "model assumptions", "physical/documentary survey", "technical responsibility",
      "required report content", "applicable CAIXA tender version"))
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
