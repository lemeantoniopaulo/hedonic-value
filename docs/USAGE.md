# Guia de uso do hedonicValue

## 1. Escopo e limites

`hedonicValue` é um pacote experimental de R para estimar relações hedônicas
de preços de imóveis, produzir previsões, organizar diagnósticos e gerar
relatórios reprodutíveis. Ele não é um laudo, não substitui vistoria ou
responsabilidade técnica e não certifica conformidade com ABNT, IBAPE ou CAIXA.

Os resultados são associações condicionais. A qualidade da conclusão depende da
origem dos dados, da representatividade da amostra, das transformações, da
dependência espacial, da extrapolação e das hipóteses do modelo.

## 2. Instalação

Com o R instalado, a versão publicada no GitHub pode ser instalada com:

```r
install.packages("remotes")
remotes::install_github("lemeantoniopaulo/hedonic-value")
library(hedonicValue)
```

Para executar os testes completos e todos os métodos opcionais, instale também
as dependências sugeridas:

```r
install.packages(c("testthat", "rmarkdown", "knitr", "MASS", "nlme",
                   "sandwich", "lmtest", "car"))
```

## 3. Fluxo mínimo reproduzível

O fluxo recomendado é: preparar os dados, separar a variável resposta das
covariáveis, ajustar o modelo, inspecionar diagnósticos, avaliar em dados não
utilizados no ajuste e registrar limitações.

```r
library(hedonicValue)

dados <- read.csv(
  system.file("extdata", "synthetic_property_test.csv",
              package = "hedonicValue"),
  stringsAsFactors = FALSE
)

# O fixture mistura locação e venda; filtre um mercado antes de modelar.
locacao <- subset(dados, observation_type == "rent")

modelo <- hv_fit_model(
  rent_brl_month ~ area_built_m2 + bedrooms + lake_view + furnished,
  data = locacao,
  method = "ols"
)

print(modelo)
hv_model_capabilities(modelo)
hv_plot(modelo, type = "residuals")
hv_plot(modelo, type = "observed_vs_fitted")
```

O fixture unitário é artificial e todos os seus registros têm `is_synthetic = 1`.
Ele serve para testes de esquema. A demonstração usa adicionalmente
`synthetic_urban_market_120.csv`, com 120 observações e variáveis estruturais,
locacionais e de conservação; ele continua sendo sintético e não serve para
inferência de mercado.

## 3.1 Demonstração pronta

Para executar a demonstração padrão instalada pelo pacote:

```r
demo("hedonicValue", package = "hedonicValue")
```

Para uso programático, `hv_demo()` retorna os dados sintéticos filtrados, o
modelo, as previsões e dois gráficos diagnósticos sem criar arquivos:

```r
resultado <- hv_demo(method = "ols", include_plots = TRUE)
resultado$model
resultado$predictions
resultado$plots$residuals
```

Para renderizar o relatório completo da demonstração, incluindo amostra,
registro de evidências, matriz normativa, vistoria, responsabilidade técnica e
limitações:

```r
relatorio <- hv_demo_report(output_format = "html_document")
```

O relatório usa o template do pacote e deixa todos os requisitos como
`NÃO AVALIADO`. Ele não declara conformidade com a ABNT NBR 14653-2 ou com o
IBAPE/SP; a análise e a responsabilidade permanecem com o avaliador.

`hv_demo()` compara três especificações candidatas em um conjunto temporal de
treino/teste, escolhe a de menor RMSE de teste com `hv_select_model()`, expõe a
tabela de RMSE/MAE/viés e calcula uma estimativa com intervalo de confiança de
80%. `hv_fundamentacao()` faz apenas uma triagem quantitativa: para regressão,
os limiares de dados efetivamente usados são `3(k+1)` para Grau I, `4(k+1)` para
Grau II e `6(k+1)` para Grau III. Significância de regressoras, teste F,
identificação, extrapolação e documentação continuam sujeitos à revisão
profissional; o pacote não declara o grau final.

## 4. Formato dos dados

Para um modelo, a fórmula deve apontar para uma resposta numérica e para
covariáveis existentes no `data.frame`. As colunas do fixture sintético são:

| Coluna | Uso |
| --- | --- |
| `observation_id` | identificador sintético único |
| `observation_type` | `rent` ou `sale` |
| `area_built_m2`, `area_land_m2` | áreas em m² |
| `bedrooms`, `suites`, `bathrooms` | contagens inteiras |
| `asking_price_brl` | preço de oferta de venda em reais |
| `rent_brl_month` | aluguel mensal em reais |
| `price_m2_brl` | preço unitário de venda em reais/m² |
| `condo_brl_month`, `iptu_brl_month` | encargos mensais em reais |
| `furnished`, `lake_view`, `solar_energy`, `pool_private` | indicadores 0/1 |
| `observation_status` | papel do registro no teste |
| `is_synthetic` | deve ser 1 para o fixture |

Não misture aluguel e venda na mesma resposta sem uma justificativa explícita.
Converta datas com `as.Date()`, normalize unidades e documente qualquer
tratamento de ausentes, duplicidades, ofertas e transações efetivas.

## 5. Métodos de ajuste

`hv_fit_model()` aceita:

- `method = "ols"`: mínimos quadrados ordinários via `stats::lm()`;
- `method = "wls"`: mínimos quadrados ponderados; exige um peso positivo e
  finito para cada linha;
- `method = "gls"`: mínimos quadrados generalizados via `nlme::gls()`;
- `method = "robust"`: regressão robusta via `MASS::rlm()`.

Exemplos:

```r
m_ols <- hv_fit_model(rent_brl_month ~ area_built_m2 + bedrooms,
                      locacao, method = "ols")
m_wls <- hv_fit_model(rent_brl_month ~ area_built_m2 + bedrooms,
                      locacao, method = "wls",
                      weights = locacao$area_built_m2)
```

GLS e robusta exigem os pacotes opcionais correspondentes. Valores ausentes
nas variáveis da fórmula devem ser tratados antes do ajuste; a API falha
explicitamente em vez de remover linhas silenciosamente.

`hv_fit()` é a API legada e oferece apenas OLS. Para código novo, prefira
`hv_fit_model()`.

## 6. Previsão e explicação

Para a API nova:

```r
novos <- data.frame(area_built_m2 = c(280, 330), bedrooms = c(3, 4),
                    lake_view = c(0, 1), furnished = c(0, 1))
hv_predict_model(modelo, novos, interval = "confidence", level = .80)
```

Intervalos clássicos são suportados para OLS e WLS apenas com as limitações
documentadas no objeto; GLS e robusta aceitam somente `interval = "none"`.
`hv_explain()` decompõe a previsão na escala do modelo e não promete
retrotransformação automática.

## 7. Diagnóstico, organização e comparação

```r
hv_diagnostics(modelo)
broom::tidy(modelo)
broom::glance(modelo)
hv_plot_data(modelo, type = "qq")
```

Para uma avaliação fora da amostra, mantenha um conjunto de teste separado:

```r
resultado <- hv_benchmark(
  models = list(ols = modelo),
  test_data = locacao_teste,
  truth = "rent_brl_month",
  id = "observation_id"
)
```

Quando houver data de observação, `hv_temporal_split()` cria partições por um
limiar explícito. Não use o registro de alvo conciliado do fixture como uma
observação independente ao medir desempenho.

## 8. Relatórios R Markdown

Crie um relatório a partir do template instalado:

```r
rmarkdown::draft("relatorio.Rmd", template = "relatorio_avaliacao",
                 package = "hedonicValue", edit = FALSE)
hv_render_report("relatorio.Rmd", output_format = "html_document")
```

Informe estudo, finalidade, modelo, pendências de evidência e estado da
avaliação nos parâmetros do template. O estado padrão é
`NÃO AVALIADO`; ele não deve ser alterado sem revisão profissional e evidência
versionada. `CONFORMIDADE_NAO_DETERMINADA` continua sendo o estado interno dos
objetos estatísticos do pacote e não substitui a matriz do relatório.

### Matriz normativa no relatório

O template também aceita os parâmetros `normative_references`,
`requirement_matrix`, `evidence_register`, `inspection` e
`professional_responsibility`. Use uma linha por requisito e mantenha os
estados limitados a `ATENDIDO`, `PARCIAL`, `PENDENTE`, `NÃO APLICÁVEL` ou
`NÃO AVALIADO`.

```r
params <- list(
  normative_references = c("ABNT NBR 14653-2:2011", "IBAPE/SP:2011"),
  requirement_matrix = data.frame(
    id = "N-001",
    reference = "8.2.1",
    requirement = "Identificar e qualificar as fontes de dados",
    status = "NÃO AVALIADO",
    evidence = "",
    gap = "Registrar fonte e data",
    responsible = "",
    stringsAsFactors = FALSE
  ),
  evidence_register = data.frame(
    id = "E-001", description = "Base de mercado",
    source = "arquivo versionado", version_date = "2026-01-01",
    location = "dados/base.csv", status = "PENDENTE",
    stringsAsFactors = FALSE
  ),
  inspection = list(performed = FALSE, date = NA, responsible = NA),
  professional_responsibility = list(name = NA, registration = NA,
                                      technical_record = NA)
)
```

A matriz é um registro de verificação, não uma cópia integral das normas. Ela
deve apontar para a edição normativa usada, a evidência versionada, a lacuna e
o responsável pela análise. O pacote não converte uma matriz preenchida em
certificação automática.

Quando nenhuma matriz é fornecida, o template inicia oito itens para revisão:
finalidade e escopo; fontes e dados de mercado; caracterização e vistoria;
comparabilidade e homogeneização; ofertas, duplicidades, outliers e ausências;
método e diagnósticos; extrapolação, fundamentação, precisão e limitações; e
responsabilidade técnica e conclusão. Esses itens são uma pauta de verificação,
não uma afirmação de que o requisito foi atendido.

## 9. Privacidade e proveniência

Antes de adicionar dados ao pacote:

1. remova nomes, endereços, inscrições cadastrais, telefones, e-mails e códigos
   que permitam reidentificação;
2. substitua identificadores por IDs sintéticos estáveis;
3. registre se a linha é sintética, oferta ou transação efetiva;
4. não distribua documentos de origem com dados pessoais em `inst/extdata`;
5. registre unidade, moeda, data de observação, transformações e regras de
   exclusão.

O dataset distribuído pelo pacote é deliberadamente sintético e anonimizado.

## 10. Testes e limitações conhecidas

Execute os testes com:

```r
testthat::test_local()
```

O CI também executa `R CMD check` em Linux e Windows. A ausência de erros de
execução não demonstra validade econômica, precisão normativa ou adequação da
amostra. Ainda não estão automatizados validação espacial completa, controle
abrangente de extrapolação, modelos espaciais e certificação normativa.

## 11. Licença

O pacote é distribuído sob a licença aberta MIT, conforme o arquivo `LICENSE`.
Ela permite uso, cópia, modificação e redistribuição, preservando o aviso de
copyright e a isenção de garantias. A licença do código não transforma dados
de terceiros em dados redistribuíveis; somente os fixtures sintéticos do pacote
são destinados à distribuição.
