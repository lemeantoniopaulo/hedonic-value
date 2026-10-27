test_that("model status is explicit and consistent", {
  d <- data.frame(price = 100 + 5 * seq_len(20), area = seq_len(20))
  legacy <- hv_fit(price ~ area, d)
  modern <- hv_fit_model(price ~ area, d)
  expect_equal(legacy$normative_status, "CONFORMIDADE_NAO_DETERMINADA")
  expect_equal(modern$normative_status, "CONFORMIDADE_NAO_DETERMINADA")
  expect_no_error(print(legacy))
  expect_no_error(print(modern))
})

test_that("report renderer validates input before invoking rmarkdown", {
  skip_if_not_installed("rmarkdown")
  expect_error(
    hv_render_report("file-that-does-not-exist.Rmd"),
    "existing R Markdown"
  )
  expect_error(
    hv_render_report(system.file("rmarkdown/templates/relatorio_avaliacao/skeleton/skeleton.Rmd",
                                 package = "hedonicValue"),
                     params = list()),
    NA
  )
})
