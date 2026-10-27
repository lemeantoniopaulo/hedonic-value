# Estado da implementação

| Componente | Situação |
|---|---|
| OLS por stats::lm | Implementação inicial |
| WLS por stats::lm | Implementação inicial |
| GLS por nlme::gls | Wrapper experimental |
| Robusta por MASS::rlm | Wrapper experimental |
| Previsões e intervalos | Implementação inicial, com limitações por método |
| broom e ggplot2 | Integração inicial |
| Validação temporal | Divisão temporal simples |
| Benchmark fora da amostra | Implementação inicial |
| Relatório R Markdown | Template inicial |
| Diagnósticos normativos | Não implementados integralmente |
| SAR, SEM e SDM | Não implementados |
| Fundamentação e precisão normativas | Não implementadas |
| Tratamento por fatores | Não implementado |

## Limitações críticas

O pacote ainda não foi validado integralmente por R CMD check neste ciclo. Não declara conformidade com a ABNT NBR 14653-2, com normas do IBAPE ou com requisitos da CAIXA.

A API antiga e a nova coexistem por compatibilidade. A consolidação futura deverá preservar a rastreabilidade das mudanças.
