# hedonic-value

**Auditable hedonic valuation of Brazilian urban real estate — R + tidyverse + ggplot2 + RcppArmadillo**

> **Status: experimental (v0.0.3).** The repository contains initial implementations and tests, but **a successful R CMD check has not yet been verified**. The package is **not certified or homologated by ABNT or CAIXA** and must not be treated as a substitute for professional inspection, technical responsibility or an appraisal report.

## Purpose

`hedonicValue` is an R package under development for explainable, reproducible valuation of urban real estate (residential, commercial, land and other property types where the data and valuation approach are appropriate). It prioritizes interpretable statistical methods, explicit uncertainty, spatial and temporal validation, and traceable evidence.

**Core design decisions**

- **Multimethod, not OLS-only:** OLS is the reference baseline, not the sole intended estimator.
- **Tidyverse-native:** data.frame/tibble inputs, tibble outputs for the new API, broom S3 methods, ggplot2 graphics, and planned tidymodels adapters.
- **Auditable:** distinguish estimates, assumptions, limitations, model validation and normative evidence.
- **Model-specific inference:** do not conflate confidence intervals, individual prediction intervals, conditional quantiles or Bayesian credible intervals.
- **No automatic compliance certification:** applicable ABNT NBR 14653 editions and CAIXA contractual requirements must be verified and reviewed independently.

## Implementation status

The following table distinguishes **code committed** from **runtime validation**.

| Capability | Repository status | Verification |
|---|---|---|
| OLS reference model (`hv_fit`, `hv_fit_model`) | Initial code | R CMD check pending |
| WLS (`hv_fit_model(..., method="wls")`) | Initial code | Numerical tests written; CI result unverified |
| GLS via `nlme::gls` | Initial wrapper | CI result unverified |
| Robust regression via `MASS::rlm` | Initial wrapper | CI result unverified |
| Confidence / prediction intervals | Initial OLS API; guarded new API | Statistical validation pending |
| `broom::tidy/glance/augment` | S3 methods and registration | Runtime dispatch check pending |
| `hv_predict_tbl()` | Initial pipe-first tibble interface | Runtime check pending |
| `ggplot2::autoplot()` | Basic model graphics | Runtime check pending |
| `hv_plot()`, `hv_plot_data()` | Residuals, observed vs fitted, Q-Q | Runtime check pending |
| `hv_benchmark()`, `hv_temporal_split()` | Initial evaluation utilities | Leakage and benchmark validation pending |
| RcppArmadillo numerical core | C++ function and Rcpp bindings | Compilation/parity pending |
| Ridge/LASSO/Elastic Net, GAM, quantile, SAR/SEM/SDM, Bayesian | Specified | Not implemented |
| Full plot catalogue, dashboards and maps | Specified | Not implemented |
| Normative ABNT/CAIXA evidence engine | Specified | Not implemented or validated |

**CI incident:** a GitHub Actions `R-CMD-check` failure was reported. Static defects were repaired in subsequent commits (S3 registration, dependency declarations, Rcpp binding files, help pages and workflow diagnostics), but the original seven annotations have not been mapped to logs and a clean follow-up run has **not** been confirmed. See [CI failure triage](docs/CI_FAILURE_TRIAGE_2026-10-26.md).

## Quick start (experimental)

Installation from GitHub **requires successful compilation** and a functioning R toolchain. The commands below are an intended workflow, **not evidence of a successful installation**:

```r
install.packages("remotes")
remotes::install_github("lemeantoniopaulo/hedonic-value")

library(hedonicValue)
library(tibble)
library(ggplot2)

set.seed(42)
imoveis <- tibble(
  preco = 200000 + 5000 * seq_len(50) + rnorm(50, sd = 20000),
  area = seq(45, 143, length.out = 50),
  idade = rep(0:9, length.out = 50)
)

# Existing OLS API
ols <- hv_fit(preco ~ area + idade, data = imoveis)
broom::tidy(ols)
broom::glance(ols)
ggplot2::autoplot(ols)

# New multimethod API (experimental)
modelo <- hv_fit_model(preco ~ area + idade, imoveis, method = "ols")
previsoes <- hv_predict_model(modelo, imoveis[1:5, ], interval = "confidence")
grafico <- hv_plot(modelo, type = "residuals")

# Optional weighted least squares
wls <- hv_fit_model(preco ~ area + idade, imoveis,
                    method = "wls", weights = rep(1, nrow(imoveis)))

# Pipe-first prediction on the original OLS API
resultado <- imoveis[1:5, ] |>
  hv_predict_tbl(ols, interval = "prediction")

print(previsoes)
print(grafico)
```

**API compatibility note:** `hv_fit(formula, data)` is the original OLS-only interface. `hv_fit_model(formula, data, method)` is the newer experimental multimethod interface. The two APIs coexist pending a documented consolidation. Do **not** use `imoveis |> hv_fit(formula)` — the current argument order is formula-first.

**Interval limitation:** the new API deliberately rejects unsupported interval requests (for example, a WLS individual prediction interval without an explicitly modeled variance for the new observation).

## Visualization design

The planned `hv.viz` subsystem uses **ggplot2** for editable plots, **tibble** for underlying plotting data, and optional **patchwork** for dashboards. It separates exploratory and forensic/report-ready modes.

| Priority | Visualization families |
|---|---|
| P0 | Price distributions, attributes, residuals, Q-Q, scale-location, influence, coefficients and intervals, holdout performance, error by segment and coverage |
| P1 | Regularization paths, GAM smooths, quantile curves, maps, Moran scatterplots, spatial autocorrelation and SAR/SDM impacts |
| P2 | Bayesian posterior distributions, credible intervals and temporal hedonic indices |

Plots must disclose scale, units, training/test partition, missingness and exclusions where applicable. Graphics are **not** evidence of normative compliance by themselves.

See the [visualization specification](docs/VISUALIZATION_SPECIFICATION.md) and [adversarial review](docs/ADVERSARIAL_REVIEW_V1.md).

## Development roadmap

| Milestone | Goal |
|---|---|
| **M0** | Loadable package, valid DESCRIPTION/NAMESPACE, Rcpp registration, help pages, license, CI passing |
| **M1** | Tested OLS/WLS/GLS/robust models, model-specific inference, tidyverse and ggplot2 diagnostics |
| **M2** | Model selection, regularization, blocked spatial/temporal validation, extrapolation and benchmarks |
| **M3** | GAM and quantile regression |
| **M4** | SAR, SEM, SDM, geospatial diagnostics and impact decomposition |
| **M5** | Bayesian inference and separate hedonic index module |
| **M6** | Versioned ABNT/CAIXA evidence checks and independent normative review |
| **M7** | Institutional-grade provenance, reproducibility, privacy, security and external validation |

The roadmap represents **planned work**, not completed capabilities. See [ROADMAP.md](ROADMAP.md) and the [implementation ledger](docs/IMPLEMENTATION_STATUS.md).

## Documentation

- [Full technical specification](docs/SPECIFICATION.md)
- [Adversarial audit and acceptance gates](docs/ADVERSARIAL_REVIEW_V1.md)
- [Visualization architecture](docs/VISUALIZATION_SPECIFICATION.md)
- [Tidyverse integration contract](docs/tidyverse-contract.md)
- [Proposed hv_model v1 contract](docs/HV_MODEL_CONTRACT_V1.md) — specification awaiting implementation
- [Implementation status](docs/IMPLEMENTATION_STATUS.md)
- [CI failure investigation](docs/CI_FAILURE_TRIAGE_2026-10-26.md)
- [Development roadmap](ROADMAP.md)

## Statistical and normative cautions

This package is intended to **support** qualified appraisal work. Coefficients are conditional associations, not automatically causal effects. Out-of-sample performance, representativeness, spatial dependence, transformations, uncertainty and extrapolation must be assessed explicitly. Preliminary numerical screens in the current code are **not normative classifications**.

ABNT NBR 14653 requirements and any CAIXA-specific tender or contract requirements must be verified against the **applicable official editions and documents** before being implemented as auditable rules. Neither a CI pass nor a high R² establishes appraisal compliance.

## Contributions and project maturity

Contributions should include tests, documentation, model-specific statistical justification, reproducible examples and explicit handling of failure cases. Please avoid claims of production readiness until package checks, benchmarks and independent reviews are complete.

**Current release gate:** fix all CI failures, run R CMD check successfully, validate numerical parity and document the results. The maintainer metadata currently contains a placeholder address and must be replaced with authorized details before publication.
