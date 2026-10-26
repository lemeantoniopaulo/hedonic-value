# CI failure triage — 2026-10-26

## Evidence
The user supplied a GitHub Actions notification screenshot showing:
- Workflow: R-CMD-check
- Result: All jobs failed
- Job: check
- Runtime: 3 minutes 26 seconds
- Annotations: 7

The screenshot does **not** expose a workflow run ID, job ID, annotation text or step logs. GitHub's connector can fetch job logs only by numeric job ID; those identifiers were unavailable in this audit. Therefore **the exact seven causes are not established**.

## Static inspection findings and changes
| Finding | Code evidence | Repair |
|---|---|---|
| Rcpp export function lacked generated bindings | src/hedonic_core.cpp | Added R/RcppExports.R, src/RcppExports.cpp; CI now regenerates with Rcpp::compileAttributes() |
| S3 registrations incomplete | NAMESPACE | Added imports for broom generics and ggplot2::autoplot, registered S3 methods |
| Runtime dependencies undeclared | DESCRIPTION | Added tibble, dplyr, ggplot2, broom |
| MIT license metadata lacked LICENSE | DESCRIPTION | Added LICENSE and corrected declaration |
| Exported API lacked .Rd help | man/ | Added initial help pages |
| GLS diagnostic response used nonportable call | R/visualization.R | Derived observed from fitted plus response residuals |
| glance() assumed non-null F statistic | R/tidy.R | Handled intercept-only model |
| CI lacked retained diagnostics | workflow YAML | Added check artifacts upload on failure |

## Unresolved and release-blocking
1. **Fetch the actual failing run logs** and reconcile all seven annotations. Need GitHub Actions run URL or numeric run ID.
2. Observe fresh CI outcome after these commits; do not equate successful commits with passing tests.
3. Confirm Rcpp::compileAttributes() regenerates bindings without compilation errors.
4. Run R CMD check on Linux and at least one other target environment.
5. Replace placeholder maintainer email with verified maintainer identity before distribution.
6. Review all warnings and notes, documentation coverage and numerical parity.
7. The old and new model APIs coexist; deprecation/consolidation not completed.
8. Advanced statistical and spatial modules and ABNT/CAIXA validation are not implemented.
9. No official ABNT text or CAIXA tender requirements were independently verified in this static review.

## Closure criteria
Close this incident only after (a) fetching the run logs, (b) mapping every failure to root cause and corrective commit, (c) fresh R CMD check succeeds, and (d) retaining test artifacts and CI URL as evidence.

**Audit status: remediation committed; incident remains OPEN pending live CI evidence.**
