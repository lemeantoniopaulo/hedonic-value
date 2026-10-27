test_that("OLS fit and prediction are consistent", {
  d <- data.frame(price = 100 + 5 * seq_len(30) + rnorm(30),
                  area = seq_len(30))
  m <- hv_fit(price ~ area, d)
  p <- hv_predict(m, d[1:2, , drop=FALSE])
  expect_equal(nrow(p), 2L)
  expect_true(all(c("fit", "lwr", "upr") %in% names(p)))
  e <- hv_explain(m, d[1:2, , drop=FALSE])
  expect_equal(e$estimated_value, as.numeric(stats::predict(m$model, d[1:2, , drop=FALSE])))
  expect_identical(attr(e, "scale"), "model_scale")
  expect_identical(attr(e, "response_transformation"), "unknown")
  expect_false(attr(e, "back_transform_required"))
})
test_that("normative check never creates a classification from heuristics", {
  d <- data.frame(price=100 + 5 * seq_len(30), area=seq_len(30))
  result <- hv_normative_check(hv_fit(price~area, d), d[1:2, ])
  expect_identical(result$status, "CONFORMIDADE_NAO_DETERMINADA")
  expect_null(result$precision_screen)
  expect_null(result$minimum_sample_size)
  expect_true(length(result$reasons) >= 1L)
})
test_that("explanation includes any fitted offset", {
  d <- data.frame(y=10 + 2 * seq_len(12), x=seq_len(12), z=rep(1, 12))
  model <- hv_fit(y~x + offset(z), d)
  explained <- hv_explain(model, d[1:3, ])
  expect_equal(explained$.offset, rep(1, 3))
  expect_equal(explained$estimated_value,
    as.numeric(stats::predict(model$model, d[1:3, ])))
})
