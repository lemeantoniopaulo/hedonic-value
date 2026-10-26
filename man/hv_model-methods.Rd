\name{hv_model-methods}
\alias{print.hv_model}
\alias{tidy.hv_model}
\alias{glance.hv_model}
\alias{augment.hv_model}
\alias{autoplot.hv_model}
\title{S3 methods for hedonic valuation models}
\description{Print, tidy, glance, augment and plot methods for hv_model objects.}
\usage{
\method{print}{hv_model}(x, ...)
\method{tidy}{hv_model}(x, ...)
\method{glance}{hv_model}(x, ...)
\method{augment}{hv_model}(x, data = NULL, ...)
\method{autoplot}{hv_model}(object,
    type = c("diagnostics", "observed_vs_fitted"), ...)
}
\arguments{
\item{x}{An hv_model object.}
\item{object}{An hv_model object.}
\item{data}{Optional data frame.}
\item{type}{Plot type.}
\item{...}{Additional arguments.}
}
\value{An invisible model, tibble or ggplot object depending on method.}
