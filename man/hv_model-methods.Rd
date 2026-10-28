\name{hv_model-methods}
\alias{print.hv_model}
\alias{tidy.hv_model}
\alias{glance.hv_model}
\alias{augment.hv_model}
\alias{autoplot.hv_model}
\title{Métodos S3 para modelos de avaliação hedônica}
\description{Métodos de impressão, organização, síntese, ampliação e gráfico para objetos hv_model.}
\usage{
\method{print}{hv_model}(x, ...)
\method{tidy}{hv_model}(x, ...)
\method{glance}{hv_model}(x, ...)
\method{augment}{hv_model}(x, data = NULL, ...)
\method{autoplot}{hv_model}(object,
    type = c("diagnostics", "observed_vs_fitted"), ...)
}
\arguments{
\item{x}{Objeto hv_model.}
\item{object}{Objeto hv_model.}
\item{data}{Data frame opcional.}
\item{type}{Tipo de gráfico.}
\item{...}{Argumentos adicionais.}
}
\value{Modelo invisível, tibble ou objeto ggplot, conforme o método.}
