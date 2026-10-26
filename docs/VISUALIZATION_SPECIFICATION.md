# hedonic-value — Especificação do subsistema hv.viz
Versão: 0.1 | Data: 2026-10-26 | Status: planejado, não implementado integralmente.

## Princípios
- ggplot2 como motor gráfico obrigatório; gráficos retornam objetos ggplot modificáveis.
- Dados subjacentes disponibilizados em tibble para inspeção e reprodução.
- Nunca omitir silenciosamente observações excluídas, NAs, escalas, transformações, ponderações ou extrapolações.
- Indicar fonte, data-base, moeda, unidade, população de referência, modelo, partição (treino/teste), tipo e nível dos intervalos.
- Não interpretar coeficientes associativos como efeitos causais.
- Visualizações não são provas isoladas de conformidade ABNT/CAIXA.
- Para mapas, aceitar sf, respeitar CRS e anonimizar geolocalizações sensíveis.
- Separar visualização de cálculo: diagnósticos são computados na camada estatística; hv.viz apenas representa resultados validados.

## API geral
- `ggplot2::autoplot(hv_model, type=...)` para diagnóstico padrão.
- `hv_plot_*(object, ...)` para gráficos especializados.
- `hv_plot_data(object, type=...)` devolve tibble com os dados usados no gráfico.
- `hv_dashboard(object, panel=...)` devolve composição patchwork; gráficos individuais permanecem ggplot.
- Temas opcionais `hv_theme_report()`, `hv_theme_audit()` e `hv_theme_publication()`, respeitando a personalização ggplot2.
- Evitar dependência obrigatória do metapacote tidyverse; declarar ggplot2, tibble e demais pacotes conforme uso real.

## Catálogo P0: exploração, diagnóstico, inferência e auditoria
| Categoria | Função | Conteúdo e exigência |
|---|---|---|
| Exploração | hv_plot_distribution | Histograma/densidade de preços com unidade e transformação explícita |
| Exploração | hv_plot_relationship | Dispersão preço-atributo, suavização opcional e estratificação |
| Exploração | hv_plot_correlation | Correlações com tratamento de NAs e variáveis categóricas |
| Diagnóstico | hv_plot_residuals | Resíduos vs ajustados, referência zero e identificação de extremos |
| Diagnóstico | hv_plot_qq | Q-Q de resíduos apropriados ao estimador |
| Diagnóstico | hv_plot_scale_location | Raiz dos resíduos padronizados absolutos vs ajustados |
| Diagnóstico | hv_plot_influence | Leverage, Cook e limiares identificados como heurísticos |
| Diagnóstico | hv_plot_vif | VIF/GVIF, graus de liberdade e limiares contextualizados |
| Inferência | hv_plot_coefficients | Estimativas e IC com escala e codificação de variáveis |
| Inferência | hv_plot_predictions | Observado vs previsto, identidade, distinção treino/teste |
| Inferência | hv_plot_intervals | IC vs IP identificados, cobertura e ordenação por previsão |
| Seleção | hv_plot_comparison | MAE, RMSE, viés e métricas com incerteza, por partição |
| Seleção | hv_plot_cv | Erro por fold, dispersão e desenho de reamostragem |
| Auditoria | hv_plot_bias | Viés e dispersão por segmento com tamanho amostral |
| Auditoria | hv_plot_coverage | Cobertura observada vs nominal e largura por segmento |

## Catálogo P1: extensões
- `hv_plot_regularization()`: trajetórias de coeficientes e parâmetro lambda, identificando escala.
- `hv_plot_smooths()`: efeitos GAM, bandas e distribuição de observações.
- `hv_plot_map()`: preços e valores por localização com privacidade.
- `hv_plot_spatial_residuals()`: resíduos espacializados e legenda de unidades.
- `hv_plot_moran()`: dispersão Moran com matriz W, padronização e teste documentados.
- `hv_plot_spatial_acf()`: dependência espacial por distância e escolhas de binning.
- `hv_plot_quantiles()`: quantis condicionais e cruzamento de quantis, quando ocorrer.
- `hv_plot_impacts()`: impactos diretos, indiretos e totais para SAR/SDM.

## Catálogo P2: probabilístico e temporal
- `hv_plot_posterior()`: densidades posteriores e diagnósticos de convergência.
- `hv_plot_credible()`: intervalos de credibilidade e distribuição preditiva posterior identificados separadamente.
- `hv_plot_index()`: índices hedônicos com base, período, método e incerteza.

## Painéis
A. Qualidade do modelo: resíduos, Q-Q, scale-location, influência.
B. Capacidade preditiva: observado vs previsto, distribuição de erros, erros por faixa, cobertura.
C. Inferência: coeficientes, estabilidade e contribuições condicionais.
D. Econometria espacial: mapas, Moran, autocorrelação e impactos.
E. Auditoria: desempenho por segmento, extrapolações e pendências documentais.

## Compatibilidade e testes
- `inherits(plot, "ggplot")`; composição com `+`, `facet_*`, `scale_*` e `theme()`.
- `hv_plot_data()` deve retornar tibble; valores e contagens idênticos aos diagnósticos.
- Testar transformações, valores ausentes, pesos, observações influentes, escalas log e ausência de geometria.
- Testes de snapshots visuais opcionais, sem substituir testes numéricos.
- Testes de acessibilidade: legendas, unidades, contraste e ausência de codificação apenas por cor.
- Sem gráficos vazios silenciosos: falhar com mensagens explicativas quando dados forem insuficientes.
- Critério de aceite: resultado reproduzível, interpretação correta, teste automatizado e integração ggplot2.

## Dependências e implementação
ggplot2, tibble, dplyr e broom; patchwork opcional para dashboards; sf para mapas; tidybayes/bayesplot opcionais para métodos bayesianos. Priorizar APIs existentes e manter compatibilidade com R CMD check.

## Status
Apenas `autoplot.hv_model` básico existe no código inicial. Este documento descreve a meta arquitetural, não funcionalidade já entregue.
