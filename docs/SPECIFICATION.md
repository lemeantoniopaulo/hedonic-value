# Especificação técnica

## Objetivo

Fornecer ferramentas em R para modelagem hedônica explicável, diagnóstico estatístico, validação e geração de relatórios reprodutíveis para dados imobiliários urbanos.

## Princípios

- transparência sobre dados, hipóteses e limitações;
- separação entre associação estatística e causalidade;
- separação entre resultado computacional e juízo profissional;
- incerteza específica por estimador;
- validação temporal e espacial;
- rastreabilidade da amostra;
- ausência de certificação automática.

## API atual

- hv_fit() e hv_predict(): API legada OLS;
- hv_fit_model() e hv_predict_model(): API experimental multimétodo;
- hv_diagnostics(): resumo e diagnósticos iniciais;
- hv_plot_data() e hv_plot(): dados e gráficos;
- hv_benchmark(): métricas em dados de teste;
- hv_temporal_split(): separação temporal;
- hv_render_report(): renderização R Markdown.

## Estimadores

O pacote utiliza funções consolidadas:

- stats::lm() para OLS e WLS;
- nlme::gls() para GLS;
- MASS::rlm() para regressão robusta.

A ausência de código nativo é intencional. Qualquer nova implementação numérica deverá demonstrar necessidade, equivalência e ganho mensurável antes de ser aceita.

## Dados

Cada estudo futuro deverá registrar:

- fonte;
- data de coleta;
- data de referência;
- natureza do preço;
- localização;
- unidade monetária;
- critérios de inclusão e exclusão;
- ausências, duplicidades e transformações;
- região e período de validade.

## Diagnósticos previstos

- significância global e individual;
- forma funcional;
- normalidade;
- homocedasticidade;
- multicolinearidade;
- influência;
- dependência espacial;
- validade temporal;
- extrapolação;
- desempenho fora da amostra.

## Relatórios

R Markdown é o formato canônico. O relatório deve apresentar resultados, evidências, limitações e pendências. A conclusão normativa deve permanecer sob responsabilidade profissional.

## Segurança metodológica

O estado padrão é CONFORMIDADE_NAO_DETERMINADA. Falta de erro de execução não equivale a validade estatística ou conformidade normativa.
