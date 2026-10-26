# Matriz adversarial — contrato v1

Base: commit 826f7d793f9989ee6a3583280d387f7ffa3a20dd. **Planejamento de testes, não resultados de testes da implementação futura.** As reproduções existentes apontam para o dossiê da etapa 1; o check real da base está no dossiê da etapa 2.

| ID | Cenário / entrada | Resultado esperado no contrato | Estado atual / evidência |
|---|---|---|---|
| C01 | `hv_fit(y~x,d)` e `hv_fit_model(y~x,d,"ols")` | esquema v1 idêntico e previsão numérica equivalente; formatos públicos distintos preservados | Campos divergentes e status vazio reproduzidos: F3 |
| C02 | OLS legado salvo dos dois formatos | migra sem reestimar; transformação/unidade desconhecidas quando não demonstradas; mantém coeficientes | Migração proposta; não implementada |
| C03 | versão futura, n divergente ou classe/método incompatíveis | erro claro, sem alterar arquivo salvo | Não implementado |
| C04 | `weights=rep(1,n)`, sem coluna weights | pesos efetivos são todos 1; equivalência a OLS quando pressupostos se aplicam | F9: falha com closure; CI ERROR |
| C05 | coluna `weights=1:n`, argumento `weights=rep(1,n)` | pesos efetivos são argumento, não coluna; teste numérico contra referência independente | F9: coluna sobrepõe argumento |
| C06 | WLS legado com pesos registrados no ajuste | preservar pesos efetivos; origem/intenção desconhecida não preenchida | Migração não implementada |
| C07 | WLS, intervalo preditivo via API antiga e nova | ambas rejeitam com razão; confiança somente quando pressupostos são satisfeitos | F5: antiga devolve intervalo com aviso |
| C08 | resposta `log(price)`, sem declaração confiável | saída marcada como escala do modelo, transformação unknown; triagem na escala original rejeitada; não presumir que a função chamada log seja log natural | F6: triagem aceita e classifica na escala log |
| C09 | resposta direta `y`, sem unidade | escala da variável y possível; unidade/quantidade desconhecidas; sem inferir que é preço | Não implementado |
| C10 | `y~x+offset(z)`, z não constante | explicação inclui offset; soma equivale a predict na mesma escala | F7: diferença igual ao offset |
| C11 | fator com nível novo ou NA em `newdata` | erro claro; não perder ou reciclar linhas | Falha/semântica a verificar por método |
| C12 | `subset` com pesos e IDs selecionados | seleção aplicada de maneira documentada; n, pesos e índices coincidem com ajuste | F10: encaminhamento atual falha |
| C13 | `...` desconhecido ou seleção não suportada | erro que identifique argumento e método, sem descarte | Não implementado |
| C14 | GLS/robusta: tidy, glance, augment treino | sem erros opacos por formato `lm`; campo não definido NA com razão ou rejeição documentada | F4: tidy e diagnósticos falham; glance GLS retornou uma linha |
| C15 | OLS com df residual insuficiente; colinearidade | rank não estimável é erro; intervalos/inferência sem df são rejeitados | Não validado |
| C16 | entradas vazias, NA, infinito, ID duplicado, colisão `.pred` | rejeitar antes de combinação; mensagem e nome de variável úteis | Não implementado |
| C17 | comparação: previsão log versus verdade em moeda | erro de incompatibilidade de escala, sem computar RMSE | Não implementado |
| C18 | `hv_ols_cpp` com matriz singular/mal condicionada e referência R | fora do caminho padrão; testes futuros com erro explícito e paridade demonstrada antes de ativar | Código existente sem paridade verificada |
| C19 | `print` e `hv_model_capabilities` sobre ambos os construtores | mesmo estado normativo; capacidades corretas e razões, sem declarações contraditórias | F3/F5 reproduzidos |
| C20 | objetos legados inconsistentes ou incompletos | migração falha ou usa NA explícito; nunca inventa dados nem reavalia fórmula | Não implementado |
| C21 | interação, fator, modelo sem intercepto | explicação codificada soma à previsão; níveis e contrastes preservados | Não validado |
| C22 | API legada OLS, intervalo de confiança | `data.frame` com fit/lwr/upr, ordem e nomes de linha preservados; igualdade a referência | Cobertura parcial do formato; não verificado sob novo contrato |

Os dados e as asserções planejadas para cada caso estão nas [fixtures reproduzíveis](HV_MODEL_FIXTURES_V1.md). **Referências de evidência:** [código de referência](https://github.com/lemeantoniopaulo/hedonic-value/tree/826f7d793f9989ee6a3583280d387f7ffa3a20dd) e [CI da etapa 2](https://github.com/lemeantoniopaulo/hedonic-value/actions/runs/40401101037). IDs F3–F10 são achados da etapa 1. Cada linha sem teste executado deve permanecer marcada não verificada até a implementação, testes do pacote instalado e revisão da etapa correspondente.
