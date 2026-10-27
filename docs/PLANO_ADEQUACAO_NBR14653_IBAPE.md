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


## 8. Contrato metodológico adversarial

### 8.1 Regra de interpretação

Este contrato adota a seguinte hierarquia:

1. texto oficial da edição normativa aplicável;
2. legislação e regulamentação vigente;
3. norma técnica regional aplicável;
4. literatura estatística e econométrica reconhecida;
5. decisões de projeto e conveniências computacionais.

Se houver conflito, uma conveniência da API não prevalece sobre um requisito normativo demonstrado. Se a edição aplicável não estiver identificada, o resultado normativo deve ser **NÃO DETERMINADO**, e não “conforme”.

### 8.2 Separação de enunciados

Toda saída deve distinguir quatro classes:

| Classe | Conteúdo | Pode ser apresentado como conclusão normativa? |
|---|---|---|
| Observação | dado coletado, valor calculado ou fato documental | Não, isoladamente |
| Resultado | estatística, coeficiente, teste, intervalo ou métrica | Não, isoladamente |
| Inferência | interpretação estatística condicionada às hipóteses | Não, sem limites e pressupostos |
| Juízo profissional | adequação do método, suficiência da amostra e conclusão do avaliador | Somente pelo responsável técnico |

O software não deve converter automaticamente uma estatística em juízo profissional.

### 8.3 Ônus de demonstração

O ônus de demonstrar conformidade pertence à saída que a afirma. Portanto:

- ausência de erro não é evidência de conformidade;
- p-valor favorável não prova adequação do modelo;
- R² elevado não prova validade de mercado;
- intervalo estreito não prova boa fundamentação;
- amostra grande não corrige amostra enviesada;
- modelo espacial não corrige variável omitida;
- regressão robusta não autoriza eliminar observações sem investigação;
- validação cruzada não substitui validade regional e temporal;
- preço de oferta não é transação apenas por estar em uma coluna chamada preço.

### 8.4 Portões de bloqueio

A camada de auditoria deve impedir a emissão de status **CONFORME** quando ocorrer qualquer uma das condições seguintes:

1. edição normativa ausente, ambígua ou incompatível com a jurisdição;
2. fonte ou natureza dos preços não documentada;
3. data de referência ausente;
4. localização insuficiente para o submercado analisado;
5. amostra sem critérios de inclusão e exclusão;
6. variável dependente sem unidade monetária ou temporal;
7. observações duplicadas não investigadas;
8. valores ausentes tratados sem registro;
9. extrapolação fora do suporte da amostra;
10. pressuposto crítico não avaliado ou resultado inconclusivo;
11. dependência espacial relevante ignorada sem justificativa;
12. transformação de variável sem registro;
13. exclusão de outlier sem trilha de decisão;
14. intervalo de confiança confundido com intervalo de predição;
15. fundamentação e precisão não calculadas separadamente;
16. ausência de revisão profissional quando a saída for usada em avaliação.

O resultado padrão diante de uma dessas situações será **NÃO DEMONSTRADO**, acompanhado das razões.

### 8.5 Invariantes estatísticos

O contrato exige que:

- treino e teste sejam separados antes de qualquer operação que aprenda com os dados;
- transformações e imputações sejam ajustadas somente no treino quando houver validação;
- a fórmula efetivamente ajustada seja registrada;
- o número de observações e parâmetros seja preservado;
- a unidade da variável dependente seja conservada na previsão;
- intervalos de confiança e de predição permaneçam semanticamente distintos;
- a previsão não seja apresentada fora do suporte sem alerta de extrapolação;
- a escolha de um estimador alternativo seja justificada por diagnóstico, teoria ou objetivo explícito;
- toda exclusão preserve o identificador original e a justificativa;
- os resultados sejam reproduzíveis a partir da versão do pacote, dados e parâmetros.

### 8.6 Invariantes normativos

O contrato exige que:

- o software não crie grau de fundamentação por aproximação heurística;
- o software não crie grau de precisão a partir de limiares não documentados;
- o campo de arbítrio não seja confundido com intervalo de confiança;
- o intervalo de confiança de 80% não seja tratado como intervalo de predição;
- a classificação normativa seja versionada;
- cada regra tenha fonte, edição, item e interpretação registrada;
- regras dependentes de julgamento profissional sejam marcadas como tais;
- materiais didáticos do IBAPE não sejam tratados automaticamente como texto integral da ABNT;
- uma norma regional não seja generalizada para outra jurisdição sem justificativa;
- mudanças na norma invalidem ou coloquem em quarentena resultados anteriores.

### 8.7 Adversários obrigatórios

Cada modelo candidato deve ser submetido, no mínimo, a cinco tentativas de refutação:

1. **Adversário da amostra:** procura seleção, duplicação, viés de oferta e cobertura insuficiente.
2. **Adversário da especificação:** procura não linearidade, interações omitidas, transformação inadequada e variáveis omitidas.
3. **Adversário dos resíduos:** procura heterocedasticidade, não normalidade, dependência e influência excessiva.
4. **Adversário espacial/temporal:** procura autocorrelação, instabilidade regional, quebra temporal e vazamento.
5. **Adversário documental:** procura ausência de fonte, unidade, data, justificativa, versão e trilha de auditoria.

O modelo não deve ser “aprovado” por vencer um teste isolado. Deve ser mantido apenas quando as objeções relevantes forem respondidas ou explicitamente aceitas pelo responsável técnico.

### 8.8 Estrutura mínima do objeto auditável

A implementação futura deve registrar, no mínimo:

- identificador do estudo;
- identificador do imóvel avaliando;
- data de referência;
- finalidade;
- tipo de imóvel;
- região e submercado;
- fonte e versão dos dados;
- regra de seleção da amostra;
- fórmula e transformações;
- estimador;
- parâmetros;
- versão do R e do pacote;
- sistema de coordenadas, quando aplicável;
- diagnósticos executados;
- advertências;
- observações excluídas;
- critérios de fundamentação;
- critérios de precisão;
- revisão profissional;
- status final e razões.

### 8.9 Estados permitidos

A API normativa deve utilizar estados explícitos:

- EXPLORATORIO;
- ESTATISTICAMENTE_DIAGNOSTICADO;
- VALIDADO_FORA_DA_AMOSTRA;
- VALIDADE_ESPACIAL_NAO_DEMONSTRADA;
- FUNDAMENTACAO_NAO_DEMONSTRADA;
- PRECISAO_NAO_DEMONSTRADA;
- REVISAO_PROFISSIONAL_PENDENTE;
- NAO_CONFORME;
- CONFORMIDADE_NAO_DETERMINADA.

O estado CONFORME somente poderá existir quando todos os portões aplicáveis estiverem satisfeitos e a revisão profissional estiver registrada.

### 8.10 Proibição de automatização indevida

O pacote não deverá:

- emitir laudo;
- assinar responsabilidade técnica;
- afirmar atendimento à ABNT apenas por ajustar regressão;
- escolher automaticamente variáveis somente por p-valor;
- remover discrepantes sem preservar a observação e sua justificativa;
- tratar correlação como causalidade;
- transformar uma classificação auxiliar em grau normativo;
- ocultar alertas para produzir uma saída aparentemente limpa.

## 9. Critérios de aceite do contrato

A Fase 0 somente será considerada concluída quando houver:

1. documentação da edição normativa utilizada;
2. distinção entre observação, resultado, inferência e juízo profissional;
3. estados explícitos de conformidade indeterminada;
4. portões de bloqueio testáveis;
5. registro de versão, dados e parâmetros;
6. separação entre fundamentação e precisão;
7. testes contra extrapolação e vazamento;
8. trilha de exclusões e transformações;
9. declaração de limitações em toda saída normativa;
10. revisão por profissional habilitado antes de qualquer uso em laudo.

Este contrato é um mecanismo de contenção epistemológica e documental. Ele não transforma automaticamente o pacote em instrumento normativo. Ele define as condições que deverão ser satisfeitas para que tal afirmação possa ser examinada.
