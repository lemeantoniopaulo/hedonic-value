# hedonic-value — Especificação funcional, estatística e arquitetural

**Status:** especificação de projeto; não constitui comprovação de conformidade ABNT ou homologação CAIXA.  
**Versão da especificação:** 0.1 — 2026-10-26  
**Repositório:** lemeantoniopaulo/hedonic-value

## 1. Objetivo e escopo
Desenvolver pacote **R com núcleo numérico em C++ (RcppArmadillo)** para precificação hedônica e avaliação de imóveis urbanos brasileiros, privilegiando modelos **estatísticos convencionais, interpretáveis, auditáveis e reproduzíveis**. Abrange imóveis residenciais, comerciais, terrenos e glebas quando houver dados e método adequados. O produto deve apoiar a engenharia de avaliações, e não substituir inspeção, responsabilidade profissional ou laudo técnico.

**Resultados esperados:** estimativa de valor, explicação dos componentes de preço, seleção de variáveis e modelos, diagnósticos, intervalos de confiança e predição, intervalos bayesianos de credibilidade, percentis condicionais, indicadores de desempenho, evidências e verificações normativas rastreáveis.

**Restrição arquitetural:** não utilizar XGBoost, CatBoost ou redes neurais como núcleo normativo. Podem ser benchmarks externos, com critérios e resultados transparentes.

## 2. Princípios não negociáveis
1. **Simetria epistêmica:** toda hipótese, exclusão, transformação, premissa e resultado deve ser justificável, contestável e rastreável, independentemente de sua origem.
2. **Explicabilidade não é causalidade:** coeficientes hedônicos são associações condicionais; alegações causais exigem desenho identificador.
3. **Validação fora da amostra:** não equiparar R² de treinamento a desempenho preditivo; prevenir vazamento espacial, temporal e de seleção.
4. **Incerteza corretamente tipada:** não intercambiar IC da média condicional, intervalo de predição individual, intervalo de credibilidade posterior e percentis condicionais.
5. **Precisão estatística não equivale a conformidade normativa:** requisitos da ABNT, requisitos contratuais da CAIXA e responsabilidade técnica são camadas distintas.
6. **Reutilizar métodos maduros:** não reimplementar indiscriminadamente algoritmos estabelecidos em R; reservar C++ para operações justificadas e testadas.
7. **Reprodutibilidade:** versões de dados, critérios de limpeza, sementes, partições, pesos espaciais, fórmulas, parâmetros e decisões de seleção devem integrar trilha de auditoria.
8. **Tidyverse-native:** entrada e saída interoperáveis com data.frame/tibble, dplyr, tidyr, purrr, ggplot2 e broom; extensão espacial via sf.

## 3. Escopo estatístico

### 3.1 Núcleo de referência (P0)
- Regressão hedônica OLS com especificações linear, semilog e log-log, quando justificadas.
- WLS/GLS, erros-padrão robustos, heterocedasticidade, multicolinearidade, resíduos, observações influentes, alavancagem e qualidade de ajuste.
- Inferência para coeficientes e previsões, com identificação explícita do estimando e pressupostos.
- Decomposição de preços por atributos, com advertências sobre codificação, interações, transformações e extrapolação.
- Seleção de variáveis com justificativa substantiva, AICc/BIC e/ou validação cruzada; controle de viés pós-seleção.
- Comparação de modelos com métricas definidas antes do ajuste e validação espacial/temporal bloqueada.
- Tratamento documentado de dados faltantes, observações extremas e heterogeneidade de segmentos.

### 3.2 Extensões explicáveis (P1)
- Regressão robusta; Ridge/LASSO/Elastic Net para seleção e regularização, sem presunção de superioridade.
- GAM com efeitos suaves interpretáveis e diagnóstico de suavização.
- Regressão quantílica para quantis condicionais; não confundir quantil com limite de predição.
- Econometria espacial: SAR, SEM e SDM, pesos de vizinhança explícitos, testes de autocorrelação residual, efeitos diretos/indiretos/totais e interpretação correta do multiplicador (I-rho W)^(-1).
- Controle de dependência espacial e temporal nos esquemas de validação.

### 3.3 Inferência probabilística e evolução temporal (P2)
- Regressão linear bayesiana, diagnósticos posteriores, intervalos de credibilidade e distribuição preditiva posterior.
- Índices hedônicos e atualização temporal por metodologias de índice, em módulo separado do AVM de avaliação individual.
- Regras explícitas para back-transformation de modelos logarítmicos e correção de viés quando aplicável.

## 4. Contratos de interface R / tidyverse

### 4.1 Objetos
- Classe S3 `hv_model` inicialmente; estrutura estável de metadados e histórico.
- Aceitar `data.frame` e `tibble`; `sf` mediante adaptador que preserve geometria e CRS, sem conversões silenciosas.
- Suporte a `formula` e à seleção programática documentada.
- Resultado tabular como `tibble`, com tipos, nomes e unidades previsíveis.

### 4.2 API
- `hv_fit(formula, data, method)`: interface estável atual; avaliar futuramente `hv_fit(data, formula)` ou função específica para uso pipe-first, **sem mudança silenciosa da assinatura**.
- `hv_predict(model, newdata, level, interval)`: API existente; convergir para saída tipada e compatível com tibble.
- `hv_predict_tbl(data, model, interval, level)`: interface pipe-first; colunas `.pred`, `.lower`, `.upper`, `.level`, `.interval`.
- `hv_explain()`, `hv_diagnostics()`, `hv_compare()`, `hv_normative_check()`.
- Métodos S3 `broom::tidy()`, `broom::glance()`, `broom::augment()`.
- `ggplot2::autoplot()` e `hv_plot_*()` devem devolver objetos `ggplot`, componíveis com camadas e temas.
- Integração futura `parsnip`, `recipes`, `workflows`, `rsample`, `yardstick` e `tune`, sem tornar o pacote dependente de todo o metapacote tidyverse.

### 4.3 Convenções de inferência
- Tabelas devem explicitar unidade monetária, moeda, data-base, escala do modelo, tipo e nível do intervalo.
- `.pred` deve designar o estimador pontual na escala explicitada; intervalos devem identificar população-alvo e hipóteses.
- `augment()` deve preservar linhas e chaves de observação, inclusive política explícita para NA e linhas descartadas.
- `tidy()` e `glance()` precisam de testes de paridade com os objetos de origem.
- `autoplot()` nunca deve ocultar exclusões ou suposições relevantes.

## 5. Arquitetura modular
| Módulo lógico | Responsabilidade | Prioridade |
|---|---|---|
| hv.model | OLS, WLS, GLS e extensões explicáveis | P0 |
| hv.inference | Diagnósticos, incerteza e inferência robusta | P0 |
| hv.selection | Seleção, comparação e validação bloqueada | P0 |
| hv.audit | Proveniência, desempenho, documentação e regras versionadas | P0 |
| hv.spatial | Pesos, autocorrelação e modelos espaciais | P1 |
| hv.distribution | Quantis, posteriores e distribuição preditiva | P1 |
| hv.index | Índices hedônicos temporais | P2 |

**Separação de camadas:** interface R/tibble; estimadores e validação; núcleo C++ desacoplado de objetos ggplot/tibble; regras normativas versionadas; relatório e visualização.

## 6. Dependências e referências técnicas
- `stats` e `broom`: referência OLS e organização dos resultados.
- `sandwich`, `lmtest`, `car`: diagnóstico e inferência robusta.
- `glmnet`: penalização; `mgcv`: GAM; `quantreg`: quantis.
- `sf`, `spdep`, `spatialreg`: estruturas e econometria espacial.
- `tibble`, `dplyr`, `tidyr`, `purrr`, `ggplot2`: contratos de integração.
- `rsample`, `yardstick`, `recipes`, `workflows`, `parsnip`: ecossistema tidymodels.
- `Rcpp`, `RcppArmadillo`: implementação e integração de C++.
- Referências de benchmarking: REPS (índices hedônicos), assessr (auditoria de avaliações), spatialreg, projetos abertos de regressão hedônica. **Referência não implica equivalência funcional nem desempenho demonstrado.**

## 7. Engenharia de avaliações: ABNT NBR 14653 e CAIXA
1. Manter **matriz de requisitos versionada por edição normativa e edital/contrato aplicável**. Verificar a edição efetiva, o texto oficial, interpretações institucionais e critérios específicos antes de implementar regras.
2. Separar **grau de fundamentação**, **grau de precisão**, adequação da amostra, pressupostos e documentação. Um único indicador não pode atestar conformidade global.
3. A largura relativa do IC bilateral de 80% da média estimada pode integrar uma triagem de precisão, mas a classificação depende da norma e do contexto; evitar aplicação automática fora do domínio válido.
4. Auditar suficiência e representatividade amostral, variáveis, testes de significância, extrapolação, diagnóstico do modelo, fontes, data-base e elementos obrigatórios do laudo.
5. O relatório deve identificar itens atendidos, não atendidos, não verificáveis e pendentes de evidência.
6. **Não emitir certificação automática de conformidade ABNT/CAIXA**; exigir validação humana e responsabilidade técnica quando cabíveis.
7. A aprovação de um AVM em processo institucional não equivale à validade de cada laudo ou à homologação genérica do pacote.

## 8. Benchmark experimental obrigatório
### Dados e desenho
- Bases sintéticas com verdade conhecida e cenários de heterocedasticidade, colinearidade, assimetria, outliers, dependência espacial e mudança temporal.
- Dados reais de transações, com proveniência, licenças, proteção de dados, documentação de amostragem e segmentos.
- Splits treino/validação/teste por tempo e espaço; evitar vazamento de imóveis duplicados e informação de mercado futura.
- Seleção de variáveis e tuning somente dentro das partições de treino; preservar teste final intocado.

### Indicadores
- MAE, RMSE, viés, métricas relativas com política de denominador e agregação.
- Cobertura empírica e largura dos intervalos por segmento e faixa de preço.
- Estabilidade de coeficientes, variáveis e sinais; sensibilidade a outliers e extrapolação.
- Moran dos resíduos e métricas espaciais pertinentes.
- Dispersão e equidade de avaliações entre segmentos, com documentação do desenho.
- Latência, consumo de memória e paridade R/C++.

### Critérios de aprovação
Cada método deve demonstrar valor incremental ou requisito funcional justificado frente a OLS. Métricas devem ser reportadas com incerteza e escopo. Resultados de repositórios externos não são diretamente comparáveis sem dados e protocolos comuns.

## 9. Auditoria adversarial (Forest of Thoughts + Gauntlet)
**Hipóteses concorrentes avaliadas:** OLS hedônico clássico, regressão robusta, modelos espaciais, GAM, penalização, quantis e abordagem bayesiana.  
**Decisão:** OLS auditável como baseline; extensões condicionadas a evidência de ganho e adequação do problema.

**Portões adversariais:**
- Dados: proveniência, seleção, representatividade, viés e observações extremas.
- Estatística: pressupostos, identificação, especificação, seleção e estabilidade.
- Espaço/tempo: vazamento, autocorrelação, efeitos e generalização.
- Incerteza: estimando, cobertura, calibração e escala.
- Norma: requisitos oficiais, evidências e classificação não automática.
- Software: precisão numérica, documentação, testes e rastreabilidade.
- Comunicação: ausência de alegações causais, normativas ou preditivas não demonstradas.

## 10. Marcos e critérios de entrega
**M0 — Estrutura:** pacote compilável, documentação, licença, API estável, CI e testes básicos.  
**M1 — OLS validado:** R CMD check, `broom`/ggplot2 registrados, intervalos testados, paridade numérica.  
**M2 — Diagnósticos e seleção:** inferência robusta, comparação fora da amostra, seleção e prevenção de vazamento.  
**M3 — Modelos explicáveis:** WLS/GLS, robusto, penalizado, GAM, quantílico.  
**M4 — Espacial:** `sf`, vizinhança, SAR/SEM/SDM, impactos e validação espacial.  
**M5 — Probabilístico:** regressão bayesiana e distribuição preditiva; índices temporais em trilha separada.  
**M6 — Auditoria normativa:** regras versionadas, matriz de evidências, relatórios e revisão técnica independente.  
**M7 — Prontidão institucional:** benchmark reproduzível, documentação e requisitos CAIXA aplicáveis.

## 11. Pendências explícitas do código atual
- Completar `DESCRIPTION` com dependências reais e metadados do mantenedor; substituir email placeholder.
- Registrar os métodos S3 em `NAMESPACE` e gerar `RcppExports`/registro de rotinas via `Rcpp::compileAttributes()`.
- Validar `R CMD check`, testes de `broom`, `ggplot2` e API pipe-first; corrigir falhas.
- Revisar matemática e parametrização das verificações preliminares de amostragem e precisão à luz da edição normativa oficial.
- Implementar testes de consistência numérica e cobertura, inclusive transformações logarítmicas.
- Concluir a integração de C++ com R; código C++ existente é experimental e não deve ser apresentado como motor validado.
- Documentar governança de versões, segurança de dados, reprodutibilidade e critérios de publicação.

## 12. Critério de definição de pronto (DoD)
Nenhuma funcionalidade será considerada pronta sem: contrato documentado, testes determinísticos, validação estatística, comparação de referência, comportamento sob erro, integração tidyverse/ggplot2 quando aplicável, trilha de auditoria e CI aprovado. **Conformidade normativa exige validação específica adicional.**
