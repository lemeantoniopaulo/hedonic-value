#' Fit an explainable hedonic model
#'
#' @param formula Model formula.
#' @param data A data.frame or tibble.
#' @param method One of ols, wls, gls or robust.
#' @param weights Optional positive numeric vector for wls.
#' @param correlation Optional nlme correlation structure for gls.
#' @param ... Additional arguments passed to the estimator.
#' @export
hv_fit_model <- function(formula, data, method=c("ols","wls","gls","robust"),
                         weights=NULL, correlation=NULL, ...) {
  method <- match.arg(method)
  stopifnot(inherits(formula,"formula"), is.data.frame(data))
  if (inherits(data,"sf")) stop("sf input requires a geometry-aware adapter; remove geometry explicitly.")
  if (anyNA(stats::model.frame(formula, data=data, na.action=stats::na.pass)))
    stop("Missing values in modeled variables; preprocess explicitly.")
  if (method=="wls") {
    if (is.null(weights) || length(weights)!=nrow(data) ||
        anyNA(weights) || any(!is.finite(weights)) || any(weights<=0))
      stop("WLS requires finite positive weights for every row.")
  } else if (!is.null(weights)) stop("weights are currently supported only for wls.")
  if (method=="ols") fit <- stats::lm(formula, data=data, na.action=stats::na.fail, ...)
  if (method=="wls") {
    # lm() captures the expression passed as `weights` and evaluates it in the
    # model-frame context. Passing the formal symbol directly can resolve to
    # stats::weights rather than this already validated numeric vector.
    fit <- do.call(stats::lm, c(list(formula=formula, data=data,
      weights=weights, na.action=stats::na.fail), list(...)))
  }
  if (method=="robust") {
    if (!requireNamespace("MASS",quietly=TRUE)) stop("Install MASS for robust regression.")
    fit <- MASS::rlm(formula, data=data, na.action=stats::na.fail, ...)
  }
  if (method=="gls") {
    if (!requireNamespace("nlme",quietly=TRUE)) stop("Install nlme for GLS.")
    if (is.null(correlation))
      fit <- nlme::gls(formula, data=data, method="REML", na.action=stats::na.fail, ...)
    else fit <- nlme::gls(formula, data=data, correlation=correlation,
                         method="REML", na.action=stats::na.fail, ...)
  }
  if (anyNA(stats::coef(fit))) stop("Non-estimable coefficients.")
  structure(list(model=fit, method=method, formula=formula, n=nrow(data),
    data_columns=names(data), fitted_at=Sys.time(), normative_status="NOT_ASSESSED",
    capabilities=list(classical_prediction_interval=method %in% c("ols","wls"),
                      coefficient_inference=TRUE)),
    class="hv_model")
}
#' @export
hv_predict_model <- function(model, newdata, interval=c("none","confidence","prediction"),
                             level=.80) {
  stopifnot(inherits(model,"hv_model"),is.data.frame(newdata),
            length(level)==1L,is.finite(level),level>0,level<1)
  interval <- match.arg(interval)
  method <- model$method
  if (method %in% c("ols","wls")) {
    if (interval=="none") {
      p <- as.numeric(stats::predict(model$model,newdata=newdata))
      return(tibble::tibble(.pred=p,.lower=NA_real_,.upper=NA_real_,
                            .interval="none",.level=NA_real_))
    }
    if (method=="wls" && interval=="prediction")
      stop("WLS prediction intervals require new-observation variance/weights; unsupported.")
    p <- stats::predict(model$model,newdata=newdata,interval=interval,level=level)
    return(tibble::tibble(.pred=as.numeric(p[,"fit"]),
      .lower=as.numeric(p[,"lwr"]),.upper=as.numeric(p[,"upr"]),
      .interval=interval,.level=level))
  }
  if (interval!="none") stop("Interval inference is not implemented for this model family.")
  p <- if (method=="gls") stats::predict(model$model,newdata=newdata) else
    stats::predict(model$model,newdata=newdata)
  tibble::tibble(.pred=as.numeric(p),.lower=NA_real_,.upper=NA_real_,
                 .interval="none",.level=NA_real_)
}
#' @export
hv_model_capabilities <- function(model) {
  stopifnot(inherits(model,"hv_model"))
  tibble::tibble(method=model$method,
    coefficient_inference=isTRUE(model$capabilities$coefficient_inference),
    classical_prediction_interval=isTRUE(model$capabilities$classical_prediction_interval),
    normative_status=model$normative_status)
}

