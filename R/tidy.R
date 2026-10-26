# Tidyverse interoperability for hedonicValue.
#' @export
tidy.hv_model <- function(x, ...) {
  s <- summary(x$model)$coefficients
  tibble::tibble(term = rownames(s), estimate = unname(s[,1]),
    std.error = unname(s[,2]), statistic = unname(s[,3]),
    p.value = unname(s[,4]))
}
#' @export
glance.hv_model <- function(x, ...) {
  s <- summary(x$model)
  tibble::tibble(r.squared=s$r.squared, adj.r.squared=s$adj.r.squared,
    sigma=s$sigma, statistic=unname(s$fstatistic[1]),
    df=unname(s$fstatistic[2]), df.residual=stats::df.residual(x$model),
    nobs=stats::nobs(x$model), AIC=stats::AIC(x$model),
    BIC=stats::BIC(x$model))
}
#' @export
augment.hv_model <- function(x, data = NULL, ...) {
  if (is.null(data)) {
    return(tibble::tibble(.fitted=as.numeric(stats::fitted(x$model)),
      .resid=as.numeric(stats::resid(x$model)),
      .std.resid=as.numeric(stats::rstandard(x$model)),
      .hat=as.numeric(stats::hatvalues(x$model)),
      .cooksd=as.numeric(stats::cooks.distance(x$model))))
  }
  stopifnot(is.data.frame(data))
  out <- tibble::as_tibble(data)
  out$.fitted <- as.numeric(stats::predict(x$model, newdata=data))
  out
}
#' @export
hv_predict_tbl <- function(data, model, interval=c("confidence","prediction"),
                           level=.80) {
  interval <- match.arg(interval)
  p <- hv_predict(model, as.data.frame(data), level=level, interval=interval)
  dplyr::bind_cols(tibble::as_tibble(data),
    tibble::tibble(.pred=p$fit, .lower=p$lwr, .upper=p$upr,
                   .level=rep(level,nrow(p)), .interval=rep(interval,nrow(p))))
}
