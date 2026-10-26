#' Extract auditable plot data
#' @export
hv_plot_data <- function(model, type=c("residuals","observed_vs_fitted","qq")) {
  stopifnot(inherits(model,"hv_model"))
  type <- match.arg(type)
  fit <- model$model
  if (inherits(fit,"gls")) {
    observed <- as.numeric(stats::getResponse(fit))
    fitted <- as.numeric(stats::fitted(fit))
    resid <- observed-fitted
  } else {
    observed <- as.numeric(stats::model.response(stats::model.frame(fit)))
    fitted <- as.numeric(stats::fitted(fit))
    resid <- as.numeric(stats::residuals(fit))
  }
  d <- tibble::tibble(.row_id=seq_along(fitted),.observed=observed,
                      .fitted=fitted,.resid=resid,.method=model$method,
                      .partition="training")
  if (type=="qq") {
    d <- d[order(d$.resid),,drop=FALSE]
    d$.theoretical <- stats::qnorm(stats::ppoints(nrow(d)))
  }
  d
}
#' Plot model diagnostics using ggplot2
#' @export
hv_plot <- function(model,type=c("residuals","observed_vs_fitted","qq")) {
  type <- match.arg(type)
  d <- hv_plot_data(model,type)
  if (type=="residuals")
    return(ggplot2::ggplot(d,ggplot2::aes(x=.fitted,y=.resid))+
      ggplot2::geom_point()+ggplot2::geom_hline(yintercept=0,linetype=2)+
      ggplot2::labs(title="Residuals versus fitted (training)",x="Fitted",y="Residual"))
  if (type=="observed_vs_fitted")
    return(ggplot2::ggplot(d,ggplot2::aes(x=.observed,y=.fitted))+
      ggplot2::geom_point()+ggplot2::geom_abline(intercept=0,slope=1,linetype=2)+
      ggplot2::labs(title="Observed versus fitted (training)",x="Observed",y="Fitted"))
  ggplot2::ggplot(d,ggplot2::aes(x=.theoretical,y=.resid))+
    ggplot2::geom_point()+ggplot2::labs(title="Normal Q-Q (training)",
                                      x="Theoretical quantile",y="Residual quantile")
}
