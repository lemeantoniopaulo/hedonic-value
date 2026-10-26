# hedonic-value — Unified roadmap
This roadmap supersedes earlier conflicting milestone definitions. See docs/ADVERSARIAL_REVIEW_V1.md and docs/IMPLEMENTATION_STATUS.md.

## M0 — Valid package foundation
Correct DESCRIPTION, NAMESPACE, Rcpp registration, maintainer identity, documentation, CI and R CMD check. **Gate:** automated package checks pass.
## M1 — Explainable regression engine
OLS, WLS, GLS, robust estimators, model-specific inference, tibble/broom/ggplot2 integration, diagnostic charts. **Gate:** numerical parity and plot-data tests.
## M2 — Model selection and validation
Regularization, nested and blocked temporal/spatial validation, out-of-sample metrics, uncertainty and support/extrapolation. **Gate:** no leakage; reproducible benchmark.
## M3 — Nonlinear and distributional models
GAM and quantile regression with estimator-specific inference and graphics. **Gate:** parity against mature R libraries.
## M4 — Spatial econometrics
sf, spdep, spatialreg, SAR/SEM/SDM, spatial impacts, maps and spatial diagnostics. **Gate:** spatial test fixtures and correct W semantics.
## M5 — Probabilistic and index modules
Bayesian inference with posterior diagnostics; hedonic price indices as a separate module. **Gate:** posterior checks and temporal evaluation.
## M6 — Normative audit
Versioned official ABNT NBR 14653 and applicable CAIXA requirements, separate precision/fundamentation/documentation evidence. **Gate:** independent normative review.
## M7 — Institutional readiness
Provenance, privacy, reproducibility, performance, external validation, audit reports and security. **Gate:** independently reviewed release.

**Current state:** first implementation increment of M1 committed; M0 not yet validated. No certification or production-readiness claim.
