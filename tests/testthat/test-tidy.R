test_that("tidyverse contract returns tibbles and ggplots", {
  set.seed(42)
  d <- tibble::tibble(price=100+seq_len(25)*5+stats::rnorm(25),
                      area=seq_len(25))
  m <- hv_fit(price~area, d)
  expect_s3_class(broom::tidy(m), "tbl_df")
  expect_s3_class(broom::glance(m), "tbl_df")
  expect_s3_class(broom::augment(m), "tbl_df")
  expect_s3_class(hv_predict_tbl(d[1:3,],m), "tbl_df")
  expect_s3_class(ggplot2::autoplot(m), "ggplot")
})
