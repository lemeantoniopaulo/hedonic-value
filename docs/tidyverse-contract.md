# Tidyverse-native interoperability contract

- Accept base data.frame and tibble. sf inputs require a dedicated geometry-aware adapter before normative use.
- broom::tidy(), broom::glance(), broom::augment() S3 methods for hv_model.
- hv_predict_tbl(data, model, interval, level) returns tibble with .pred, .lower, .upper, .level and .interval.
- ggplot2::autoplot(model, type) returns a ggplot object and supports additional layers.
- Formula interface remains hv_fit(formula, data); pipe-first input uses hv_fit(data, formula) only after an explicit API refactor.
- Model matrix creation must not silently convert geometry or change measurement units.
- All outputs must disclose whether intervals are confidence, prediction, or posterior credible intervals.
- S3 registration, package checks, numerical validation and spatial handling are release gates.
- tidymodels/parsnip integration is planned, not implemented.
