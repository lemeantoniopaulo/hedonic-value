test_that("OLS and WLS match stats::lm", {
  set.seed(11)
  d <- data.frame(y=1+2*seq_len(50)+stats::rnorm(50),x=seq_len(50))
  a <- hv_fit_model(y~x,d,"ols")
  expect_equal(as.numeric(stats::coef(a$model)),
               as.numeric(stats::coef(stats::lm(y~x,d))))
  b <- hv_fit_model(y~x,d,"wls",weights=seq_len(50))
  expect_equal(as.numeric(stats::coef(b$model)),
               as.numeric(stats::coef(stats::lm(y~x,d,weights=seq_len(50)))))
  expect_s3_class(hv_predict_model(a,d[1:2,],"prediction"),"tbl_df")
  expect_error(hv_predict_model(b,d[1:2,],"prediction"),"WLS prediction")
})
test_that("WLS keeps the supplied vector when weights resolves to a function", {
  d <- data.frame(y=1 + 2 * seq_len(12) + sin(seq_len(12)), x=seq_len(12))
  weights <- stats::weights
  supplied <- seq_len(nrow(d))
  d$weights <- rev(supplied) + 10
  fit <- hv_fit_model(y~x, d, "wls", weights=supplied)
  reference <- do.call(stats::lm, list(formula=y~x, data=d, weights=supplied,
                                       na.action=stats::na.fail))
  expect_equal(as.numeric(stats::coef(fit$model)),
               as.numeric(stats::coef(reference)))
  expect_equal(as.numeric(stats::weights(fit$model)), supplied)
  expect_true(is.function(weights))
})
test_that("WLS rejects missing, misaligned, and non-positive weights", {
  d <- data.frame(y=1 + 2 * seq_len(5), x=seq_len(5))
  expect_error(hv_fit_model(y~x, d, "wls"), "requires finite positive weights")
  expect_error(hv_fit_model(y~x, d, "wls", weights=seq_len(4)),
               "requires finite positive weights")
  expect_error(hv_fit_model(y~x, d, "wls", weights=c(1, 1, 0, 1, 1)),
               "requires finite positive weights")
})
test_that("robust and gls methods fit when available", {
  d <- data.frame(y=1+2*seq_len(40)+sin(seq_len(40)),x=seq_len(40))
  skip_if_not_installed("MASS")
  skip_if_not_installed("nlme")
  expect_equal(hv_fit_model(y~x,d,"robust")$method,"robust")
  expect_equal(hv_fit_model(y~x,d,"gls")$method,"gls")
})

