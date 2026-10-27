# Symbols evaluated by ggplot2's data mask, declared for R CMD check.
utils::globalVariables(c(".fitted", ".observed", ".resid", ".theoretical"))

#' @export
autoplot.hv_model <- function(object, type=c("diagnostics","observed_vs_fitted"), ...) {
  type <- match.arg(type)
  d <- tibble::tibble(.fitted=as.numeric(stats::fitted(object$model)),
    .resid=as.numeric(stats::resid(object$model)),
    .observed=as.numeric(stats::model.response(stats::model.frame(object$model))))
  if (type == "diagnostics") {
    ggplot2::ggplot(d, ggplot2::aes(x=.fitted,y=.resid)) +
      ggplot2::geom_point() + ggplot2::geom_hline(yintercept=0, linetype=2) +
      ggplot2::labs(x="Fitted price", y="Residual", title="Residual diagnostics")
  } else {
    ggplot2::ggplot(d, ggplot2::aes(x=.observed,y=.fitted)) +
      ggplot2::geom_point() + ggplot2::geom_abline(slope=1,intercept=0,linetype=2) +
      ggplot2::labs(x="Observed price", y="Fitted price", title="Observed vs fitted")
  }
}

