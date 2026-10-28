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

test_that("demo programática usa somente a base sintética", {
  result <- hv_demo(method = "ols", include_plots = FALSE)
  expect_s3_class(result$model, "hv_model")
  expect_equal(nrow(result$data), 120)
  expect_true(all(result$data$is_synthetic == 1))
  expect_equal(result$plots, NULL)
  expect_equal(nrow(result$predictions), nrow(result$test_data))
})

test_that("demo de mercado compara modelos e calcula triagem quantitativa", {
  result <- hv_demo(method = "ols", include_plots = FALSE)
  expect_equal(nrow(result$data), 120)
  expect_equal(nrow(result$model_comparison), 3)
  expect_true(result$selected_name %in% result$model_comparison$model)
  expect_equal(result$confidence_interval_80$.level, 0.80)
  expect_equal(result$fundamentacao$k, 10)
  expect_equal(result$fundamentacao$quantitative_grade, "III")
})

test_that("hv_select_model escolhe o menor erro de teste", {
  d <- data.frame(y = 1:20, x = 1:20, z = rep(c(0, 1), 10))
  a <- hv_fit_model(y ~ x, d[1:15, ])
  b <- hv_fit_model(y ~ x + z, d[1:15, ])
  selected <- hv_select_model(list(a = a, b = b), d[16:20, ], "y")
  expect_true(selected$selected_name %in% c("a", "b"))
  expect_equal(selected$criterion, "rmse")
})
