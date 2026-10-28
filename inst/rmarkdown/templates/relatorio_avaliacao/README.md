# Template de relatório de avaliação

Este template R Markdown gera um relatório reprodutível de avaliação hedônica e auditoria estatística.

Uso:

    rmarkdown::draft("relatorio.Rmd", template = "relatorio_avaliacao",
      package = "hedonicValue", edit = FALSE)

Depois, edite os parâmetros e renderize com rmarkdown::render().
A função hv_render_report() oferece uma chamada programática.

O template inclui referências normativas, registro de evidências, vistoria,
responsabilidade profissional e uma matriz de requisitos com os estados
`ATENDIDO`, `PARCIAL`, `PENDENTE`, `NÃO APLICÁVEL` e `NÃO AVALIADO`.

O template não certifica conformidade normativa, não substitui laudo e não substitui responsabilidade técnica.
