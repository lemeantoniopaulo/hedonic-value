test_that("OLS fit and prediction are consistent", {
  d <- data.frame(price = 100 + 5 * seq_len(30) + rnorm(30),
                  area = seq_len(30))
  m <- hv_fit(price ~ area, d)
  p <- hv_predict(m, d[1:2, , drop=FALSE])
  expect_equal(nrow(p), 2L)
  expect_true(all(c("fit", "lwr", "upr") %in% names(p)))
  e <- hv_explain(m, d[1:2, , drop=FALSE])
  expect_equal(e$estimated_value, as.numeric(stats::predict(m$model, d[1:2, , drop=FALSE])))
})
