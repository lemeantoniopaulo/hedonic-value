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
\alias{hv_render_report}
\title{Modelos hedônicos, previsões, diagnósticos e relatórios}
\description{Funções para modelagem hedônica exploratória, ajuste, previsão, diagnóstico, visualização, comparação e renderização de relatórios R Markdown. As funções não certificam conformidade normativa.}
\usage{
hv_fit(formula, data, method = "ols")
hv_predict(object, newdata, level = 0.8, interval = c("confidence", "prediction"))
hv_explain(object, newdata)
hv_diagnostics(object)
hv_normative_check(object, newdata, evidence = list())
hv_compare(models, newdata, truth)
hv_predict_tbl(data, model, interval = c("confidence", "prediction"), level = 0.8)
hv_fit_model(formula, data, method = c("ols", "wls", "gls", "robust"), weights = NULL, correlation = NULL, ...)
hv_predict_model(model, newdata, interval = c("none", "confidence", "prediction"), level = 0.8)
hv_model_capabilities(model)
hv_plot_data(model, type = c("residuals", "observed_vs_fitted", "qq"))
hv_plot(model, type = c("residuals", "observed_vs_fitted", "qq"))
hv_benchmark(models, test_data, truth, id = NULL)
hv_temporal_split(data, date, cutoff)
hv_render_report(input, output_file = NULL, output_dir = NULL, output_format = c("html_document", "pdf_document", "word_document"), params = list(), ...)
}
\arguments{
\item{formula}{Fórmula do modelo.}
\item{data}{Data frame ou tibble.}
\item{object}{Objeto hv_model.}
\item{model}{Objeto hv_model.}
\item{newdata}{Dados para previsão.}
\item{level}{Nível nominal do intervalo.}
\item{interval}{Tipo de intervalo.}
\item{method}{Estimador utilizado.}
\item{weights}{Pesos positivos para WLS.}
\item{correlation}{Estrutura de correlação opcional para GLS.}
\item{models}{Lista nomeada de modelos.}
\item{truth}{Nome da variável observada.}
\item{test_data}{Dados de teste.}
\item{id}{Identificador opcional.}
\item{date}{Nome da coluna de data.}
\item{cutoff}{Data de separação entre treino e teste.}
\item{input}{Arquivo R Markdown de entrada.}
\item{output_file}{Arquivo de saída opcional.}
\item{output_dir}{Diretório de saída opcional.}
\item{output_format}{Formato de saída do R Markdown.}
\item{params}{Lista nomeada de parâmetros do relatório.}
\item{evidence}{Metadados de evidência normativa.}
\item{type}{Tipo de gráfico.}
\item{...}{Argumentos adicionais do estimador ou da renderização.}
}
\value{Modelo, tibble, data frame, objeto ggplot, lista de diagnóstico ou caminho do relatório renderizado, conforme a função.}
\details{Os diagnósticos e intervalos dependem da família do modelo. A verificação normativa é preliminar e requer revisão independente.}
