\name{hedonicValue-automation}
\alias{hv_import_data}
\alias{hv_classify_variables}
\alias{hv_validate_data}
\alias{hv_complete_cases}
\alias{hv_boxcox}
\alias{hv_boxcox_inverse}
\alias{hv_boxcox_lambdas}
\alias{hv_transform_variables}
\alias{hv_retransformation}
\alias{hv_back_transform}
\alias{hv_make_folds}
\alias{hv_prediction_metrics}
\alias{hv_cross_validate}
\alias{hv_gene_space}
\alias{hv_validate_chromosome}
\alias{hv_decode_chromosome}
\alias{hv_exhaustive_search}
\alias{hv_genetic_optimize}
\alias{hv_diagnose_model}
\alias{hv_check_extrapolation}
\alias{hv_normative_checks}
\alias{hv_normative_summary}
\alias{hv_create_audit_trail}
\alias{hv_save_audit}
\alias{hv_load_audit}
\alias{hv_predict_selected}
\alias{hv_optimize_hedonic}
\alias{hv_run_app}
\title{Auditable hedonic automation primitives}
\description{
Functions for explicit data import, Box--Cox transformations, original-scale
cross-validation, discrete genetic search, diagnostics, evidence-oriented
normative checks, prediction and audit trails. Normative statuses are not a
certification of ABNT, IBAPE or CAIXA conformity.
}
\usage{
hv_import_data(path, sheet = 1, na = c("", "NA", "N/A", "NULL"))
hv_classify_variables(data, y = NULL, overrides = list(), identifier_patterns = c("id", "identifier", "cadastral", "inscricao", "registro", "codigo", "code"))
hv_validate_data(data, y, predictors = NULL, missing = c("fail", "complete_cases"), allow_duplicates = FALSE)
hv_complete_cases(data, columns, context = "modeling")
hv_boxcox(x, lambda, shift = 0)
hv_boxcox_inverse(z, lambda, shift = 0)
hv_boxcox_lambdas(lambdas = c(-1, -0.5, 0, 0.5, 1))
hv_transform_variables(data, transformations, shifts = list())
hv_retransformation(fit, method = c("none", "smearing", "lognormal"))
hv_back_transform(eta, retransformation = NULL, target = c("median", "mean"))
hv_make_folds(n, k = 5L, repeats = 1L, seed = NULL)
hv_prediction_metrics(observed, predicted)
hv_cross_validate(data, y, predictors, response = c("original", "log"), transformations = list(), folds = NULL, k = 5L, repeats = 1L, seed = NULL, retransformation = c("none", "smearing", "lognormal"))
hv_gene_space(data, predictors, categorical = character(), lambdas = c(-1, -0.5, 0, 0.5, 1), fixed = character(), excluded = character())
hv_validate_chromosome(chromosome, space)
hv_decode_chromosome(chromosome, space)
hv_exhaustive_search(space, fitness, limit = 10000L)
hv_genetic_optimize(space, fitness, population_size = 30L, generations = 50L, crossover_probability = 0.8, mutation_probability = 0.1, elitism = 2L, patience = 10L, runs = 1L, seed = NULL, max_evaluations = Inf, exhaustive_limit = 10000L)
hv_diagnose_model(model, vif_threshold = NULL)
hv_check_extrapolation(data, newdata, predictors)
hv_normative_checks(model, data, y, newdata = NULL, predictors = NULL, normative_source = NULL, rules = list())
hv_normative_summary(result)
hv_create_audit_trail(data = NULL, configuration = list(), result = NULL, seed = NULL, run_id = NULL)
hv_save_audit(audit, path)
hv_load_audit(path)
hv_predict_selected(model, newdata, target = c("mean", "median"))
hv_optimize_hedonic(data, y, predictors = NULL, categorical = character(), lambdas = c(-1, -0.5, 0, 0.5, 1), fixed = character(), excluded = character(), k = 5L, repeats = 1L, population_size = 30L, generations = 50L, crossover_probability = 0.8, mutation_probability = 0.1, elitism = 2L, patience = 10L, runs = 1L, seed = NULL, complexity_penalty = 0, exhaustive_limit = 10000L, retransformation = c("smearing", "lognormal", "none"))
hv_run_app(...)
}
\arguments{
  \item{path}{Path to a CSV, XLS or XLSX file; for audit saving, an RDS path.}
  \item{sheet}{Excel sheet name or number.}
  \item{na}{Strings interpreted as missing on import.}
  \item{data}{A data frame.}
  \item{y}{Response column name.}
  \item{predictors}{Predictor column names.}
  \item{transformations}{Named list with "exclude", "linear" or numeric Box--Cox lambdas.}
  \item{lambda}{A finite Box--Cox lambda.}
  \item{shift}{An explicitly configured additive shift; defaults to zero.}
  \item{response}{Response family.}
  \item{model}{A fitted model object.}
  \item{newdata}{A data frame for prediction or extrapolation.}
  \item{space}{A chromosome gene space.}
  \item{fitness}{Function returning a finite scalar loss or a list with "loss".}
  \item{result}{A normative result data frame.}
  \item{audit}{An audit trail object.}
  \item{...}{Arguments passed to shiny::runApp.}
}
\value{A data frame, list, model, numeric vector, or invisible file path depending on the function.}
\seealso{\code{\link{hv_fit_model}}, \code{\link{hv_render_report}}}
