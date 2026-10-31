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

Também inclui um núcleo 2026 independente para:

- importar CSV/XLS/XLSX (Excel requer `readxl`) e classificar variáveis;
- aplicar Box-Cox com domínio explícito, sem deslocamento silencioso;
- pesquisar as famílias Y e `ln(Y)` com validação cruzada na escala original;
- executar busca genética discreta com cache, elitismo, mutação, cruzamento,
  convergência e referência exaustiva em espaços pequenos;
- calcular retransfomação logarítmica por smearing de Duan ou correção lognormal;
- produzir diagnósticos, extrapolação, evidências normativas e trilha de auditoria;
- iniciar uma interface Shiny mínima e modular com `hv_run_app()`.

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

## Fluxo automatizado

    dados <- hv_import_data("mercado.xlsx", sheet = 1)
    hv_validate_data(dados, y = "preco", predictors = c("area", "quartos"),
      missing = "complete_cases")
    resultado <- hv_optimize_hedonic(
      dados, y = "preco", predictors = c("area", "quartos"),
      population_size = 20, generations = 30, seed = 2026,
      exhaustive_limit = 256
    )
    modelo <- resultado$selected_models[[resultado$recommended_family]]
    hv_predict_selected(modelo, data.frame(area = 100, quartos = 3))

`resultado$comparison` é uma comparação preditiva fora da amostra em escala
original. A recomendação é apenas algorítmica e requer revisão do perito.
Para iniciar a interface, instale `shiny` e execute `hv_run_app()`.

## Relatório R Markdown

O pacote adota R Markdown como formato canônico:

    rmarkdown::draft("relatorio.Rmd",
      template = "relatorio_avaliacao",
      package = "hedonicValue", edit = FALSE)

Consulte o [guia completo de uso](docs/USAGE.md).

## Bases abertas para pesquisa

O catálogo em português de bases oficiais para regressão hedônica, com classificação,
licenças, vieses e plano de integração em R, está em
[docs/BASES_ABERTAS_REGRESSAO_HEDONICA.md](docs/BASES_ABERTAS_REGRESSAO_HEDONICA.md).

## Dados de exemplo

O arquivo em `inst/extdata` é artificial e anonimizado, para testes de esquema,
validação e demonstrações. Não representa transações verificadas.

## Limites

Coeficientes são associações condicionais, não efeitos causais automáticos. Representatividade, dependência espacial, transformações, incerteza, extrapolação, fundamentação e precisão devem ser avaliadas separadamente.

As limitações, o estado experimental e a separação entre desempenho estatístico
e verificação normativa estão descritos em [docs/USAGE.md](docs/USAGE.md) e
[docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md).
