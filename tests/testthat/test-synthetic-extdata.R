test_that("dataset sintético é seguro e consistente", {
  path <- system.file("extdata", "synthetic_property_test.csv",
                      package = "hedonicValue")
  skip_if(path == "")
  d <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)

  expect_equal(nrow(d), 14)
  expect_true(all(d$is_synthetic == 1))
  expect_true(all(grepl("^SYN-(RENT|SALE)-", d$observation_id)))
  expect_false(any(grepl("Rua|Inscri|Cadastral|00\\.",
                          paste(d$synthetic_development,
                                d$synthetic_region,
                                d$source_reference))))
  expect_true(all(d$area_built_m2 > 0))
  expect_true(all(d$condo_brl_month > 0))
  expect_true(all(d$observation_type %in% c("rent", "sale")))
  expect_true(all(!is.na(d$rent_brl_month[d$observation_type == "rent"])))
  expect_true(all(!is.na(d$asking_price_brl[d$observation_type == "sale"])))
})

test_that("demo programática usa somente o fixture sintético", {
  result <- hv_demo(method = "ols", include_plots = FALSE)
  expect_s3_class(result$model, "hv_model")
  expect_equal(nrow(result$data), 8)
  expect_true(all(result$data$is_synthetic == 1))
  expect_equal(result$plots, NULL)
  expect_equal(nrow(result$predictions), nrow(result$data))
})
