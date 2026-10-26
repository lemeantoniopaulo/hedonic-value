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
test_that("robust and gls methods fit when available", {
  d <- data.frame(y=1+2*seq_len(40)+sin(seq_len(40)),x=seq_len(40))
  skip_if_not_installed("MASS")
  skip_if_not_installed("nlme")
  expect_equal(hv_fit_model(y~x,d,"robust")$method,"robust")
  expect_equal(hv_fit_model(y~x,d,"gls")$method,"gls")
})
