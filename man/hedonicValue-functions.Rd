\name{hedonicValue-functions}
\alias{hv_fit}
\alias{hv_predict}
\alias{hv_explain}
\alias{hv_diagnostics}
\alias{hv_normative_check}
\alias{hv_compare}
\alias{hv_predict_tbl}
\alias{hv_fit_model}
\alias{hv_predict_model}
\alias{hv_model_capabilities}
\alias{hv_plot_data}
\alias{hv_plot}
\alias{hv_benchmark}
\alias{hv_temporal_split}
\title{Hedonic valuation models, predictions and diagnostics}
\description{Functions for exploratory hedonic valuation, model fitting, prediction,
diagnostics, plotting, comparison, and report rendering. These tools do not certify normative compliance.}
\usage{
hv_fit(formula, data, method = "ols")
hv_predict(object, newdata, level = 0.8,
           interval = c("confidence", "prediction"))
hv_explain(object, newdata)
hv_diagnostics(object)
hv_normative_check(object, newdata, evidence = list())
hv_compare(models, newdata, truth)
hv_predict_tbl(data, model, interval = c("confidence", "prediction"), level = 0.8)
hv_fit_model(formula, data, method = c("ols", "wls", "gls", "robust"),
             weights = NULL, correlation = NULL, ...)
hv_predict_model(model, newdata, interval = c("none", "confidence", "prediction"),
                 level = 0.8)
hv_model_capabilities(model)
hv_plot_data(model, type = c("residuals", "observed_vs_fitted", "qq"))
hv_plot(model, type = c("residuals", "observed_vs_fitted", "qq"))
hv_benchmark(models, test_data, truth, id = NULL)
hv_temporal_split(data, date, cutoff)
hv_render_report(input, output_file = NULL, output_dir = NULL,
                 output_format = c("html_document", "pdf_document", "word_document"),
                 params = list(), ...)
}
\arguments{
\item{formula}{A model formula.}
\item{data}{A data frame or tibble.}
\item{method}{Regression engine.}
\item{object}{An hv_model object.}
\item{model}{An hv_model object.}
\item{newdata}{Data for prediction.}
\item{level}{Nominal interval confidence level.}
\item{interval}{Type of interval requested.}
\item{evidence}{List of normative evidence metadata.}
\item{models}{Named list of hv_model objects.}
\item{truth}{Name of observed outcome column.}
\item{weights}{Positive weights for WLS.}
\item{correlation}{Optional nlme correlation structure.}
\item{...}{Additional engine arguments.}
\item{type}{Type of diagnostic graphic.}
\item{test_data}{Held-out observations.}
\item{id}{Optional unique observation ID column.}
\item{date}{Date column name.}
\item{cutoff}{Date separating training and test.}
}
\value{A model, tibble, data frame, ggplot object, diagnostic list, or rendered report path, according to function.}
\details{This is initial reference documentation. Statistical assumptions and interval
semantics depend on the model family; unsupported intervals fail explicitly in the
new API. Normative checks are preliminary and require independent review.}
