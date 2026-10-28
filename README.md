# hedonic-value

**Avaliação hedônica auditável de imóveis urbanos brasileiros — R base, tidyverse e ggplot2**

> **Estado: experimental (v0.0.4).** O pacote não é certificado ou homologado pela ABNT ou pela CAIXA. Não substitui vistoria, responsabilidade técnica, laudo ou julgamento profissional.

## Finalidade

O pacote oferece ferramentas explicáveis para modelagem hedônica, diagnóstico estatístico, validação e geração de relatório R Markdown:

- stats::lm() para OLS e WLS;
- nlme::gls() para GLS;
- MASS::rlm() para regressão robusta;
- broom, tibble, dplyr e ggplot2 para resultados organizados e gráficos;
- rmarkdown para relatórios reprodutíveis.

Não há código nativo. A implementação numérica utiliza funções consolidadas do R.

## Uso rápido

    remotes::install_github("lemeantoniopaulo/hedonic-value")
    library(hedonicValue)
    dados <- read.csv(system.file("extdata", "synthetic_property_test.csv",
      package = "hedonicValue"))
    locacao <- subset(dados, observation_type == "rent")
    modelo <- hv_fit_model(rent_brl_month ~ area_built_m2 + suites,
      locacao, method = "ols")
    hv_predict_model(modelo, locacao[1:5, ], interval = "confidence")
    hv_plot(modelo, type = "residuals")
    broom::tidy(modelo)

A API legada hv_fit() / hv_predict() permanece disponível. A API hv_fit_model() suporta ols, wls, gls e robust, com limitações específicas por estimador.

## Relatório R Markdown

O pacote adota R Markdown como formato canônico:

    rmarkdown::draft("relatorio.Rmd",
      template = "relatorio_avaliacao",
      package = "hedonicValue", edit = FALSE)

Consulte o [guia completo de uso](docs/USAGE.md).

## Dados de exemplo

O arquivo em `inst/extdata` é artificial e anonimizado, para testes de esquema,
validação e demonstrações. Não representa transações verificadas.

## Limites

Coeficientes são associações condicionais, não efeitos causais automáticos. Representatividade, dependência espacial, transformações, incerteza, extrapolação, fundamentação e precisão devem ser avaliadas separadamente.

As limitações e o estado experimental estão descritos em [docs/USAGE.md](docs/USAGE.md).
