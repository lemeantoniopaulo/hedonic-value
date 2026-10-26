# Implementation ledger (2026-10-26)

This document distinguishes *specified*, *committed*, *tested* and *validated*.

| Feature | Committed | Runtime-tested | Normatively validated |
|---|---|---|---|
| OLS reference fit | Yes | No | No |
| WLS wrapper | Yes | No | No |
| GLS wrapper via nlme | Yes | No | No |
| Robust regression via MASS::rlm | Yes | No | No |
| Model-specific interval capability guard | Partial | No | No |
| Tibble prediction output | Yes | No | No |
| ggplot2 residual, QQ, observed/fitted charts | Yes | No | No |
| Plot data in tibble | Yes | No | No |
| Temporal holdout and benchmark | Initial | No | No |
| S3 broom and autoplot integration | Existing code; registration pending | No | No |
| C++ core integration | No | No | No |
| SAR, SEM, SDM, GAM, quantile, Bayesian, penalized | No | No | No |
| ABNT/CAIXA compliance engine | No | No | No |

**Critical limits:** R executable unavailable in the current execution environment; code not compiled or checked. The older hv_fit/hv_predict and the new hv_fit_model/hv_predict_model coexist pending a versioned API consolidation. New wrappers are an implementation increment, not a production release.

**Prioritized next actions:** validate R CMD check in CI; repair DESCRIPTION/NAMESPACE; implement Rcpp registration; unify API; add spatially blocked nested validation; formalize normative requirements from authorized official editions; test on real transaction data with provenance.
