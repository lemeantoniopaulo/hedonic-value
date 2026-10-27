test_that("the packaged R Markdown template renders in an isolated directory", {
  expect_true(requireNamespace("rmarkdown", quietly=TRUE))
  expect_true(rmarkdown::pandoc_available())
  destination <- file.path(tempdir(), "hedonic-value-report-test")
  dir.create(destination, recursive=TRUE, showWarnings=FALSE)
  input <- file.path(destination, "relatorio.Rmd")
  drafted <- rmarkdown::draft(input, template="relatorio_avaliacao", package="hedonicValue", edit=FALSE)
  expect_true(file.exists(drafted))
  output <- hv_render_report(drafted, output_file="relatorio.html", output_dir=destination,
    params=list(study="Teste", purpose="Teste", status="CONFORMIDADE_NAO_DETERMINADA",
      evidence_gaps=character(), model=NULL))
  expect_true(file.exists(output))
  expect_match(paste(readLines(output, warn=FALSE), collapse="\n"), "Teste")
})
