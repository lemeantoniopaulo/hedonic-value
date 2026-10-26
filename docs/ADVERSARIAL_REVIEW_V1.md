# Revisão adversarial consolidada — hedonic-value
**Versão:** 1.0 | **Data:** 2026-10-26 | **Estado:** decisão de arquitetura proposta e critérios de aceite; não comprova execução dos testes.

## 0. Corpus auditado e método
Documentos lidos diretamente do repositório: `docs/SPECIFICATION.md`, `docs/VISUALIZATION_SPECIFICATION.md`, `docs/tidyverse-contract.md`, `ROADMAP.md`; implementação confrontada: `DESCRIPTION`, `NAMESPACE`, `R/model.R`, `R/tidy.R`, `R/plots.R`. A avaliação é documental e estática; **não houve execução de R CMD check, compilação ou benchmark**. Não foram verificadas as edições oficiais da ABNT nem requisitos contratuais específicos da CAIXA nesta auditoria.

**Método adversarial:** examinar cada proposta sob perspectivas independentes de estatística, engenharia de avaliações, econometria espacial, engenharia de software, integração tidyverse, visualização e auditoria. Para cada contestação, exigir evidência, hipótese alternativa, consequência e critério objetivo de aceite. Não conferir privilégio epistêmico ao código atual, às bibliotecas externas, aos documentos normativos ou à proposta de arquitetura.

## 1. Veredito
**Aprovação condicional da arquitetura, reprovação da prontidão de lançamento.** OLS como baseline é justificável, mas não é o escopo completo; o produto será multimetodológico. A arquitetura exige contratos verificáveis antes de qualquer alegação de qualidade preditiva ou conformidade normativa.

## 2. Matriz de achados
| ID | Severidade | Constatação verificada | Risco | Ação corretiva | Evidência de aceite |
|---|---|---|---|---|---|
| A01 | Crítica | `DESCRIPTION` não declara `tibble`, `dplyr`, `ggplot2`, `broom` apesar do uso; `NAMESPACE` não registra métodos S3 e `hv_predict_tbl` | Dependências/dispatch/export incompletos | Corrigir Imports/Suggests e registros S3 | R CMD check limpo, testes de dispatch |
| A02 | Crítica | `hv_normative_check` embute triagem de n e largura de IC e rótulos de precisão | Aparência de classificação normativa completa | Isolar regras versionadas e exigir edição oficial validada | Casos de teste rastreáveis à fonte e estado INDETERMINADO quando falta evidência |
| A03 | Crítica | `hv_predict` devolve `data.frame`, `hv_predict_tbl` devolve tibble, sem esquema unificado por família | Semântica de intervalos ambígua | Contrato de estimando/escala/tipo de intervalo por família | Testes de schema e cobertura |
| A04 | Crítica | Validação bloqueada está prevista sem algoritmo de partição especificado | Vazamento espacial/temporal | Definir folds agrupados, buffers quando necessários e nested tuning | Testes sem interseção e relatório de partições |
| A05 | Alta | `src/hedonic_core.cpp` não possui integração R gerada e testada | Núcleo C++ não executável pela API | compileAttributes, registro, comparação com lm/QR | Paridade em dados bem e mal condicionados |
| A06 | Alta | `hv_explain` soma termos na escala linear sem contrato para log, interação ou SAR | Contribuição confundida com efeito causal ou valor monetário | Decomposição dependente da família e da escala | Igualdade com previsão na escala declarada; avisos |
| A07 | Alta | Falta detecção formal de extrapolação | Avaliação fora do suporte | Regras multivariadas e suporte por segmentos, sem corte universal | Testes com imóveis fora do domínio |
| A08 | Alta | `hv_compare` só calcula erros in-sample/na amostra fornecida, sem metadados de split | Comparações otimistas | Resampling, holdout, incerteza e relatórios de seleção | Benchmarks sem leakage |
| A09 | Alta | Gráficos definidos por nome, sem contrato completo de dados, exclusões e escalas | Figuras convincentes porém enganosas | `hv_plot_data` e metadados verificáveis | Testes numéricos e de integridade |
| A10 | Alta | `ROADMAP.md` e `docs/SPECIFICATION.md` divergem em M1–M3 | Prioridades conflitantes | Uma matriz única de dependências e gates | Marcos sincronizados |
| A11 | Alta | Não há política de dados reais e metadados de mercado | Viés de anúncios vs transações e temporalidade | Registrar natureza da evidência, duplicatas, moeda, data-base e fonte | Esquema de dados validado |
| A12 | Média | OLS, WLS, GLS, robusto, GAM, quantis, SAR/SEM/SDM e Bayes não compartilham inferência equivalente | API aparentemente homogênea, mas incorreta | Matriz de capacidades e erros explícitos para operação indisponível | Testes por classe e família |
| A13 | Média | Contrato sf não define unidades, CRS, geometrias, vizinhança e privacidade | Erro espacial e exposição de dados | Adaptador explícito, validação CRS e geometrias | Testes com CRS e coordenadas |
| A14 | Média | Não há protocolo de testes de gráficos exportados | Reprodutibilidade limitada | SVG/PDF/PNG, metadados, acessibilidade | Testes de renderização e inspeção |
| A15 | Média | Identidade do mantenedor ainda é placeholder | Falha de metadados de distribuição | Corrigir dados autorizados do mantenedor | R CMD check e revisão de publicação |

## 3. Contrato de dados e rastreabilidade — requisito P0
Definir `hv_data_spec()` ou equivalente contendo: ID de imóvel, ID de observação, data do preço, data-base, natureza do preço (oferta/transação/avaliação), moeda, valor, tipologia, área e unidade, localização com CRS, origem e qualidade dos dados, versão e política de privacidade. Permitir atributos adicionais. Registrar deduplicação, inflação/deflação, transformações, exclusões e imputações com motivo. Não transformar ofertas em transações por suposição. Definir comportamento para amostras pequenas, colinearidade, novos níveis fatoriais, NAs, preços não positivos e múltiplas transações do mesmo imóvel.

## 4. Contrato de modelo e inferência
Cada objeto `hv_model` deve conter `family`, `engine`, `formula`, `response_scale`, `prediction_scale`, `training_window`, `data_fingerprint`, `preprocessing`, `fit_diagnostics`, `supported_inference`, `validation_id` e `normative_status`. Armazenar referências a dados sensíveis em vez de copiá-los indiscriminadamente.

**Matriz de capacidades, a validar por implementação:**
- OLS: coeficientes, IC da média, IP individual sob pressupostos; HC robusto não torna automaticamente válido o IP clássico.
- WLS/GLS: definir pesos/covariância e comportamento para novos imóveis; IC/IP específicos ao modelo.
- Regressão robusta: coeficientes e inferência conforme estimador; IP exige método próprio.
- Ridge/LASSO: seleção/predição; p-valores OLS ingênuos após seleção são proibidos.
- GAM: efeitos suaves, intervalos e extrapolação conforme suavizador.
- Quantílica: quantis condicionais; não chamar P10–P90 de intervalo de predição calibrado sem verificação.
- SAR/SDM: distinguir efeitos diretos/indiretos/totais; previsão fora da amostra requer definição da estrutura W e vizinhança de novos imóveis.
- SEM: tratar estrutura de erro espacial; não inferir impactos indiretos da mesma forma que SAR.
- Bayes: posterior, intervalos de credibilidade, predição posterior e diagnósticos de convergência.

**Saída padrão proposta:** tibble com `.row_id`, `.pred`, `.lower`, `.upper`, `.interval`, `.level`, `.scale`, `.currency`, `.base_date`, `.status`; campos de limites podem ser ausentes quando a família não os suporta, com erro/estado explícito. `hv_predict_tbl(data, model)` mantém colunas de entrada; chaves não podem duplicar ou desaparecer silenciosamente.

## 5. Política de seleção e benchmark
Separar modelos para inferência, avaliação individual e índice temporal. Pré-especificar função de perda e métricas (MAE, RMSE, viés, métricas relativas com denominador definido, cobertura e largura). Comparar baseline OLS com alternativas; não exigir superioridade de todos os métodos em todos os dados, mas justificar capacidade funcional e custo. Fazer splits agrupados por imóvel, região e tempo, com tuning interno e holdout final intocado; considerar buffers espaciais quando apropriados. Publicar tamanho e composição de cada fold e incerteza das métricas. Avaliar desempenho por tipologia, preço, localização e períodos. Reportar distribuição dos resíduos e estabilidade temporal.

## 6. Subsistema gráfico hv.viz — especificação revisada
**API:** `hv_plot_data(object, type, ...)` retorna tibble imutável de dados e colunas de metadados; `hv_plot_*(...)` e `ggplot2::autoplot(...)` retornam ggplot; `hv_dashboard(...)` retorna composição patchwork apenas se instalado. Gráficos não recalculam estimadores.

**P0, por objetivo:**
1. Exploração: distribuição de preço, relação com atributos e correlações; mostrar N, missingness e escala.
2. Diagnóstico OLS: resíduos vs ajustados, Q-Q, scale-location, Cook/alavancagem, VIF/GVIF; identificar limites como heurísticos e preservar IDs.
3. Inferência: coeficientes e IC na escala do coeficiente; previsões e intervalos com tipo e nível explícitos; não misturar IC de média com IP.
4. Validação: observado vs predito em **holdout**, resíduos e erro por segmento, cobertura empírica e dispersão entre folds; incluir linha identidade e unidades.
5. Auditoria: mapa de extrapolação/segmentos, observações removidas e classificação de evidência normativa, sem inferir aprovação pelo gráfico.

**P1:** caminhos de regularização; suaves GAM; curvas quantílicas; mapas de preço/resíduos com sf; Moran/correlogramas e impactos SAR/SDM.
**P2:** posteriores e convergência Bayes; índices hedônicos temporais.

**Dois modos de renderização:** `exploratory` (IDs, filtros, detalhes) e `forensic` (figura, legenda, data-base, modelo, versão, fonte, notas, escala, n e advertências). Exportação via `ggsave()` para SVG, PDF e PNG; exigir bibliotecas/dispositivos compatíveis. Não embutir dados pessoais em SVG/metadados. Testar cores, contraste, leitura em escala de cinza, resolução e integridade das unidades.

**Testes de cada gráfico:** classe ggplot, retorno dos dados via hv_plot_data, igualdade numérica com camada estatística, n usado/n omitido, metadados, escalas, resposta a NA, log, pesos, facet e ausência de dados. Snapshots visuais complementares, não substitutos.

## 7. Camadas normativas
Manter `normative_rule_id`, edição, fonte oficial, texto interpretado, critério, dados exigidos, implementação, testes e revisão técnica. Estados: `PASS`, `FAIL`, `INDETERMINATE`, `NOT_APPLICABLE`. Distinguir fundamentação, precisão e itens de laudo; impedir agregação automática em selo de conformidade. Se fonte/edição não verificada, estado INDETERMINATE. **Nenhum limiar normativo deste documento está validado contra o texto oficial.**

## 8. Dependências e arquitetura
- R: interface S3, tibble/broom/ggplot2; tidymodels por adaptadores opcionais; não importar o metapacote tidyverse.
- C++: RcppArmadillo para rotinas justificadas por benchmark; testar equivalência numérica com referências estáveis, inclusive matrizes mal condicionadas.
- Espacial: sf, spdep, spatialreg em módulos opcionais com CRS, W e suporte geográfico versionados.
- Relatórios: dados + resultados + gráficos separados para auditoria; exportação controlada e anonimizada.

## 9. Roadmap revisado e gates
| Marco | Entrega mínima verificável | Gate |
|---|---|---|
| M0 | Pacote carregável, DESCRIPTION/NAMESPACE corretos, CI, licença/metadados, documentação mínima | R CMD check aprovado |
| M1 | OLS, WLS, GLS, robusto; API tibble/broom/ggplot2; inferência válida por família | Testes numéricos, de S3 e gráficos P0 |
| M2 | Seleção, regularização, validação temporal/espacial bloqueada, métricas e intervalos calibrados quando aplicável | Sem leakage, benchmark reproduzível |
| M3 | GAM, quantílica, diagnósticos específicos, visualizações correspondentes | Paridade com bibliotecas de referência |
| M4 | SAR/SEM/SDM, W, impactos, validação espacial, mapas e gráficos | Testes de efeitos e suporte espacial |
| M5 | Inferência bayesiana e índices temporais em módulos separados | Diagnósticos posteriores e validação temporal |
| M6 | Matriz ABNT/CAIXA versionada, auditoria e relatórios | Revisão normativa independente |
| M7 | Robustez institucional, segurança, desempenho e reprodutibilidade | Avaliação externa e documentação de limitações |

**Nota:** M1 foi ampliado em relação ao ROADMAP anterior; prazo depende de equipe, dados e validação. M0 é pré-requisito de todos os marcos.

## 10. Registro de decisões
- **D01:** manter OLS como baseline, não como única família.
- **D02:** exigir interoperabilidade tidyverse/ggplot2 e semântica estatística por família.
- **D03:** gráficos são evidências auditáveis, não decoração.
- **D04:** validação espacial/temporal e teste externo precedem alegações de desempenho.
- **D05:** proibir classificação normativa automática sem regras oficiais versionadas.
- **D06:** manter modelos ML opacos fora do núcleo normativo; permitir benchmark externo.
- **D07:** modularidade e dependências opcionais, evitando duplicação de bibliotecas maduras.
- **D08:** separar especificação de implementação e declarar estado real dos recursos.

## 11. Próximas correções no código (não executadas por este commit)
1. Ajustar DESCRIPTION, NAMESPACE e registro S3; resolver exportações e integração C++.
2. Executar R CMD check, corrigir testes e documentação.
3. Implementar contratos de dados, modelo, inferência e extrapolação.
4. Integrar WLS/GLS/robusto com testes de referência.
5. Implantar hv_plot_data, painéis P0 e testes de integridade gráfica.
6. Revisar regras normativas exclusivamente com fontes oficiais e testes rastreáveis.

**Condição de publicação:** especificação aprovada documentalmente não implica código validado, benchmark concluído ou conformidade normativa.
