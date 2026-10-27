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
    modelo <- hv_fit_model(preco ~ area + idade, imoveis, method = "ols")
    hv_predict_model(modelo, imoveis[1:5, ], interval = "confidence")
    hv_plot(modelo, type = "residuals")
    broom::tidy(modelo)

A API legada hv_fit() / hv_predict() permanece disponível. A API hv_fit_model() suporta ols, wls, gls e robust, com limitações específicas por estimador.

## Relatório R Markdown

O pacote adota R Markdown como formato canônico:

    rmarkdown::draft("relatorio.Rmd",
      template = "relatorio_avaliacao",
      package = "hedonicValue", edit = FALSE)

Consulte docs/MODELO_RELATORIO_AVALIACAO.md.

## Dados de exemplo

Os arquivos em inst/extdata contêm exemplos documentados de apartamentos compactos no Ipiranga e casas de alto padrão no entorno da Represa Bortolan. São dados de oferta e intervalos de projeto, não transações verificadas.

## Limites

Coeficientes são associações condicionais, não efeitos causais automáticos. Representatividade, dependência espacial, transformações, incerteza, extrapolação, fundamentação e precisão devem ser avaliadas separadamente.

Consulte:

- docs/PLANO_ADEQUACAO_NBR14653_IBAPE.md;
- docs/ADVERSARIAL_REVIEW_V1.md;
- docs/IMPLEMENTATION_STATUS.md;
- ROADMAP.md.
