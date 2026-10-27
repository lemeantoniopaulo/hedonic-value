# hedonic-value

**Auditable hedonic valuation of Brazilian urban real estate — base R + tidyverse tools**

> **Status: experimental (v0.0.4).** The package is not certified or homologated by ABNT or CAIXA and is not a substitute for inspection, technical responsibility or an appraisal report.

## Purpose

hedonicValue provides explainable wrappers around mature R statistical functions for exploratory and reproducible hedonic valuation:

- stats::lm() for OLS and WLS;
- nlme::gls() for GLS;
- MASS::rlm() for robust regression;
- broom, tibble, dplyr and ggplot2 for tidy outputs and diagnostics.

There is no native code. The package deliberately avoids a parallel numerical implementation when canonical R estimators already provide the required behavior, inference and diagnostics.

## Quick start

    remotes::install_github("lemeantoniopaulo/hedonic-value")
    library(hedonicValue)
    modelo <- hv_fit_model(preco ~ area + idade, imoveis, method = "ols")
    hv_predict_model(modelo, imoveis[1:5, ], interval = "confidence")
    hv_plot(modelo, type = "residuals")
    broom::tidy(modelo)
    broom::glance(modelo)

The legacy hv_fit() / hv_predict() API remains available for compatibility. The newer hv_fit_model() API supports ols, wls, gls and robust, with estimator-specific limitations documented in the function behavior.

## Example data

Small documented fixtures derived from the project memorandum are available in inst/extdata:

- compact apartments in Ipiranga;
- luxury houses around Represa Bortolan.

They are asking-price observations and project-level ranges, not verified transactions.

## Scope and cautions

Coefficients are conditional associations, not automatically causal effects. Out-of-sample performance, spatial dependence, transformations, uncertainty, representativeness and extrapolation require explicit assessment. Neither a high R² nor a successful package check establishes appraisal compliance.

Spatial econometrics, GAM, quantile, Bayesian and regularized models remain future extensions and should use established R packages when implemented.

See ROADMAP.md, docs/SPECIFICATION.md and docs/IMPLEMENTATION_STATUS.md.


## Conformidade normativa

A auditoria metodológica e o plano sequencial de adequação à ABNT NBR 14653-2 e aos materiais do IBAPE/SP estão em [docs/PLANO_ADEQUACAO_NBR14653_IBAPE.md](docs/PLANO_ADEQUACAO_NBR14653_IBAPE.md). O documento distingue capacidade estatística, diagnóstico, rastreabilidade, fundamentação e precisão normativa. O pacote não certifica conformidade nem substitui laudo ou responsabilidade técnica.
