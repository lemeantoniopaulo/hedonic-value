# HEDONIC VALUE 2026 — estado da implementação

Esta branch adiciona um núcleo incremental ao pacote existente. O objetivo é
oferecer contratos testáveis e auditáveis; não declarar conformidade normativa.

## Implementado

- importação CSV e Excel opcional via `readxl`;
- classificação de colunas, seleção explícita de Y, detecção conservadora de
  identificadores, duplicidades, constantes e ausentes;
- transformação Box-Cox com lambdas configuráveis, `lambda = 1` excluído da
  lista de alternativas equivalentes e domínio `x + shift > 0` explícito;
- validação cruzada com partições reproduzíveis e métricas RMSE, MAE, MedAE,
  MAPE e viés na escala original;
- famílias de resposta original e logarítmica, com smearing de Duan ou correção
  lognormal estimada apenas no treino de cada partição;
- cromossomo discreto com exclusão, inclusão categórica, linear ou Box-Cox;
- seleção, cruzamento, mutação, elitismo, cache, histórico, paciência,
  sementes, múltiplas execuções e busca exaustiva de referência;
- diagnósticos de coeficientes, resíduos, influência, VIF exploratório,
  singularidade e condição da matriz;
- comparação descritiva de extrapolação e matriz de requisitos com evidência,
  fonte, item, critério, resultado e status individual;
- objeto de trilha de auditoria persistível e app Shiny fino.

## Deliberadamente pendente

- o texto normativo aplicável e sua edição/item não são inventados pelo código;
  sem uma fonte confirmada, os estados permanecem pendentes ou não verificáveis;
- intervalos de predição para modelos selecionados e intervalos retransfomados
  exigem uma especificação adicional da quantidade estatística desejada;
- a extrapolação implementada é univariada e descritiva, não uma garantia de
  ausência de extrapolação multivariada;
- a função objetivo da busca é usada para seleção e, por isso, não é uma
  estimativa final não enviesada. Use validação externa ou aninhada para a
  afirmação final de generalização;
- a UI ainda é uma camada mínima de integração; lógica estatística fica nas
  funções do pacote e o relatório profissional requer dados e revisão do perito.

## Segurança de interpretação

Um modelo ajustado, um modelo com bom erro preditivo, um modelo com diagnósticos
examinados e um modelo tecnicamente aceito pelo perito são estados diferentes.
`hv_normative_checks()` não certifica ABNT, IBAPE ou CAIXA e não converte R²,
p-valores ou aptidão genética em conformidade.
