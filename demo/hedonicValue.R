# Demonstration of the hedonicValue package using synthetic data.
# Run with: demo("hedonicValue", package = "hedonicValue")

cat("hedonicValue demonstration\n")
cat("Synthetic data only; this is not a market valuation or a normative certificate.\n\n")

demo_result <- hv_demo(method = "ols", include_plots = TRUE)

cat("Rows used:", nrow(demo_result$data), "\n")
cat("Model method:", demo_result$model$method, "\n\n")
print(demo_result$model)
cat("\nTidy coefficients:\n")
print(broom::tidy(demo_result$model))
cat("\nModel capabilities:\n")
print(hv_model_capabilities(demo_result$model))
cat("\nFirst predictions:\n")
print(utils::head(demo_result$predictions))

if (interactive()) {
  print(demo_result$plots$residuals)
  print(demo_result$plots$observed_vs_fitted)
}

if (requireNamespace("rmarkdown", quietly = TRUE) &&
    rmarkdown::pandoc_available()) {
  report_path <- hv_demo_report()
  cat("\nComplete demonstration report:", report_path, "\n")
} else {
  cat("\nComplete report not rendered: install rmarkdown and Pandoc.\n")
}
