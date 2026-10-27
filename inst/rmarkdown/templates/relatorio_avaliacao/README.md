# Template de relatório de avaliação

Este template R Markdown gera um relatório reprodutível de avaliação hedônica e auditoria estatística.

Uso:

    rmarkdown::draft("relatorio.Rmd", template = "relatorio_avaliacao",
      package = "hedonicValue", edit = FALSE)

Depois, edite os parâmetros e renderize com rmarkdown::render().
A função hv_render_report() oferece uma chamada programática.

O template não certifica conformidade normativa, não substitui laudo e não substitui responsabilidade técnica.
