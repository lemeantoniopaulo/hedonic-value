#' Estimate a log-response retransformation correction from training residuals
#' @export
hv_retransformation <- function(fit, method = c("none", "smearing", "lognormal")) {
  method <- match.arg(method)
  if (!inherits(fit, "lm")) stop("Retransformation currently requires an lm fit.")
  residuals <- as.numeric(stats::residuals(fit))
  if (method == "none") correction <- 1 else if (method == "smearing")
    correction <- mean(exp(residuals)) else correction <- exp(stats::var(residuals) / 2)
  if (!is.finite(correction) || correction <= 0) stop("Invalid retransformation correction.")
  list(method = method, correction = correction, n = length(residuals),
       scale = "original_response_mean", estimated_from = "training_residuals")
}

#' Back-transform predictions from a log-response model
#' @export
hv_back_transform <- function(eta, retransformation = NULL,
                              target = c("median", "mean")) {
  target <- match.arg(target)
  if (!is.numeric(eta)) stop("eta must be numeric.")
  correction <- if (is.null(retransformation) || target == "median") 1 else
    retransformation$correction
  out <- exp(eta) * correction
  if (any(!is.finite(out))) stop("Back-transformed predictions are not finite.")
  out
}
