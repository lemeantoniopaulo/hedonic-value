# Plano de adequação à avaliação imobiliária por tratamento científico

## 1. Finalidade

Este documento registra a auditoria do pacote **hedonicValue** perante os requisitos metodológicos associados à avaliação de imóveis urbanos pela ABNT NBR 14653-2 e pelos materiais técnicos do IBAPE/SP.

O documento não declara certificação normativa. A finalidade é separar:

- capacidade computacional;
- validade estatística;
- rastreabilidade da pesquisa;
- fundamentação e precisão da avaliação;
- requisitos documentais e profissionais do laudo.

Um pacote de software pode auxiliar o avaliador, mas não substitui a inspeção, a responsabilidade técnica, a análise crítica ou a emissão do laudo.

## 2. Escopo atual do pacote

O pacote fornece wrappers experimentais para:

- regressão OLS e WLS por `stats::lm()`;
- GLS por `nlme::gls()`;
- regressão robusta por `MASS::rlm()`;
- previsões e intervalos;
- métodos `broom`;
- gráficos e dados para diagnósticos;
- divisão temporal simples;
- benchmark fora da amostra.

O código não contém C++ nem implementação numérica própria. A remoção da camada Rcpp/RcppArmadillo foi deliberada: a rotina nativa duplicava uma regressão OLS já disponível no R e aumentava o custo de instalação, compilação e auditoria.

## 3. Classificação atual

| Dimensão | Situação |
|---|---|
| Ajuste de modelos lineares | Parcialmente atendido |
| Inferência estatística aplicada | Parcialmente atendida |
| Diagnóstico de pressupostos | Insuficiente |
| Validação temporal | Parcial |
| Validação espacial | Não implementada |
| Rastreabilidade da amostra | Não implementada |
| Fundamentação normativa | Não implementada |
| Precisão normativa | Não implementada |
| Tratamento por fatores IBAPE/SP | Não implementado |
| Emissão automática de laudo conforme | Não permitida |

A classificação correta do pacote é **ferramenta experimental de modelagem e auditoria estatística**, não sistema autônomo de conformidade normativa.

## 4. Requisitos que precisam ser atendidos

### 4.1 Pesquisa e amostra

O pacote deve registrar, por observação:

- fonte;
- data de coleta;
- data da transação ou da oferta;
- natureza do preço;
- localização;
- identificação do imóvel;
- características físicas;
- características de conservação e padrão;
- condição de oferta ou negócio;
- unidade monetária;
- tratamento de dados ausentes;
- critérios de inclusão e exclusão;
- evidência de validade regional e temporal.

Preços de oferta não podem ser tratados silenciosamente como preços de transação. O ajuste de oferta deve ser explícito, parametrizado e documentado.

### 4.2 Especificação do modelo

Devem ser suportados e documentados:

- variável dependente e sua unidade;
- transformações de preço e atributos;
- variáveis quantitativas, qualitativas e dicotômicas;
- interações justificadas;
- forma funcional;
- hipótese teórica de cada variável;
- justificativa para inclusão ou exclusão;
- identificação de variáveis omitidas relevantes;
- controle de extrapolação.

### 4.3 Inferência e pressupostos

O subsistema de auditoria deve verificar:

- significância global pelo teste F;
- significância individual dos regressores;
- linearidade e forma funcional;
- normalidade dos resíduos;
- homocedasticidade;
- independência;
- multicolinearidade e VIF;
- pontos de alta alavancagem;
- distância de Cook;
- resíduos studentizados;
- especificação funcional por RESET ou teste equivalente;
- estabilidade dos coeficientes;
- sensibilidade a observações influentes.

Nenhum teste isolado deve ser tratado como prova absoluta de validade. O resultado deve ser acompanhado da hipótese testada, do nível de significância, da decisão e da limitação.

### 4.4 Dependência espacial e temporal

Para dados imobiliários, o pacote deve permitir:

- definição documentada da matriz de pesos espaciais;
- diagnóstico de Moran dos resíduos;
- comparação entre modelos OLS, SAR, SEM e SDM quando justificável;
- decomposição de impactos espaciais;
- validação por blocos geográficos;
- validação temporal;
- controle de vazamento entre treino e teste;
- registro do sistema de coordenadas e da unidade espacial.

### 4.5 Fundamentação e precisão

A camada normativa deve permanecer separada do estimador estatístico. Ela deverá verificar, com base na edição normativa aplicável:

- caracterização do imóvel avaliando;
- adequação e quantidade da amostra;
- fundamentação das variáveis;
- significância global e individual;
- aderência regional e temporal;
- amplitude do intervalo de confiança de 80%;
- limites de aplicação;
- extrapolação;
- documentação da metodologia;
- cálculos reproduzíveis;
- justificativas e ressalvas.

O intervalo de confiança de 80% não deve ser confundido com campo de arbítrio, saneamento de discrepantes ou intervalo de predição.

## 5. Plano sequencial de execução

### Fase 0 — Contrato metodológico e controle de escopo

**Objetivo:** impedir que o pacote declare mais do que efetivamente demonstra.

Entregas:

1. congelar a distinção entre diagnóstico estatístico e conformidade normativa;
2. renomear telas preliminares para evitar aparência de certificação;
3. registrar versão, fonte e edição dos documentos normativos;
4. definir a estrutura de objetos de auditoria;
5. criar testes que impeçam `TRUE` de conformidade sem evidência suficiente.

**Critério de aceite:** nenhum resultado exploratório pode ser apresentado como grau normativo.

### Fase 1 — Proveniência, amostra e transformação

**Objetivo:** tornar a base de dados auditável.

Entregas:

1. classe ou lista estruturada para metadados da amostra;
2. registro da fonte, data, unidade, moeda e natureza do preço;
3. tratamento explícito de oferta versus transação;
4. funções para caracterização descritiva;
5. registro de exclusões e valores ausentes;
6. apoio a transformações com metadados;
7. documentação da população, região e período.

**Critério de aceite:** qualquer modelo deve poder ser reproduzido a partir da fórmula, dados, metadados e parâmetros registrados.

### Fase 2 — Auditoria estatística básica

**Objetivo:** cobrir os pressupostos clássicos da regressão.

Entregas:

1. teste F e testes individuais integrados;
2. VIF e matriz de correlação;
3. Breusch–Pagan/White ou equivalente;
4. RESET;
5. diagnósticos de normalidade;
6. resíduos studentizados, leverage e Cook;
7. relatório integrado de diagnóstico;
8. classificação de alertas, sem exclusão automática.

**Critério de aceite:** o relatório deve declarar hipótese, teste, estatística, p-valor, decisão e limitação.

### Fase 3 — Especificação, seleção e estabilidade

**Objetivo:** reduzir arbitrariedade na escolha do modelo.

Entregas:

1. comparação de formas funcionais;
2. AIC, BIC e R² ajustado;
3. ajuste de Jacobiano quando comparações envolverem escalas distintas;
4. seleção baseada em teoria, diagnóstico e desempenho;
5. análise de sensibilidade;
6. comparação com e sem observações influentes;
7. documentação das variáveis descartadas.

**Critério de aceite:** o modelo final deve ser justificável por evidência estatística e conhecimento do mercado, não apenas por p-valores.

### Fase 4 — Validação fora da amostra

**Objetivo:** separar ajuste interno de capacidade preditiva.

Entregas:

1. holdout temporal;
2. validação cruzada;
3. validação por blocos espaciais;
4. RMSE, MAE, viés e cobertura dos intervalos;
5. proteção contra vazamento;
6. diagnóstico de extrapolação;
7. intervalos de previsão distintos dos intervalos de confiança.

**Critério de aceite:** o desempenho deve ser reportado na partição de teste e por submercado relevante.

### Fase 5 — Econometria espacial

**Objetivo:** tratar a dependência espacial quando demonstrada.

Entregas:

1. integração com `sf`;
2. construção documentada de `W`;
3. Moran’s I;
4. Lagrange Multiplier e diagnósticos equivalentes;
5. SAR, SEM e SDM via `spatialreg`;
6. impactos diretos, indiretos e totais;
7. validação espacial;
8. mapas diagnósticos.

**Critério de aceite:** a adoção ou rejeição de modelo espacial deve ser documentada e reproduzível.

### Fase 6 — Camada de fundamentação e precisão

**Objetivo:** implementar a verificação normativa sem misturá-la ao ajuste estatístico.

Entregas:

1. tabela versionada de requisitos;
2. cálculo reproduzível dos critérios aplicáveis;
3. separação entre fundamentação e precisão;
4. bloqueios para amostra insuficiente;
5. controle de validade regional e temporal;
6. relatório de não atendimento;
7. exportação de evidências, cálculos e ressalvas.

**Critério de aceite:** a função deve poder retornar “não demonstrado” ou “não aplicável”; nunca deve inferir conformidade por ausência de erro computacional.

### Fase 7 — Tratamento por fatores e documentação profissional

**Objetivo:** cobrir a alternativa metodológica e a documentação de avaliação.

Entregas:

1. módulo separado para tratamento por fatores;
2. situação paradigma;
3. fatores de localização, testada, profundidade, área e outros aplicáveis;
4. distinção entre ajuste dos comparativos e ajuste do avaliando;
5. documentação das fontes dos fatores;
6. relatório técnico reproduzível;
7. integração com dados cadastrais e espaciais.

**Critério de aceite:** o módulo de fatores não pode ser confundido com regressão hedônica nem operar com fatores sem fonte, validade e justificativa.

## 6. Ordem técnica recomendada

A execução deve seguir esta ordem:

1. contrato de escopo e nomenclatura;
2. metadados e proveniência;
3. auditoria estatística básica;
4. especificação e estabilidade;
5. validação temporal e espacial;
6. econometria espacial;
7. fundamentação e precisão;
8. tratamento por fatores;
9. relatório técnico e integração com dados reais;
10. validação independente e revisão normativa.

A ordem é necessária porque a camada normativa depende de uma amostra rastreável e de diagnósticos válidos. Implementar graus de fundamentação antes de controlar dados, pressupostos e extrapolação apenas produziria uma aparência formal de conformidade.

## 7. Critério de conclusão

O pacote somente poderá afirmar que **apoia uma avaliação conforme** quando:

- a edição normativa aplicável estiver identificada;
- a amostra tiver proveniência documentada;
- os diagnósticos relevantes tiverem sido executados;
- as limitações tiverem sido registradas;
- os critérios de fundamentação e precisão forem reproduzíveis;
- a saída não substituir a responsabilidade profissional;
- houver revisão independente do módulo normativo.

Até lá, a formulação correta é:

> “O pacote oferece ferramentas experimentais para modelagem hedônica, diagnóstico e validação estatística de dados imobiliários. Não certifica conformidade com a ABNT NBR 14653-2 nem substitui laudo de avaliação.”
