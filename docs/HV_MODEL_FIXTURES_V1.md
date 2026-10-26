# Fixtures e asserções planejadas — contrato v1

A fixture abaixo é executável em R base. Sua execução só verifica dados e pré-condições; **não testa a implementação futura**. Ela gera as entradas da matriz C01–C22. Execute-a de modo isolado e capture a sessão/versões; os modelos legados devem ser obtidos de fixtures confiáveis salvas pela versão 0.0.3 da base, sem reexecutar fórmula na migração.

Para C02/C06 foram gerados três RDS a partir dos arquivos `R/model.R` e `R/engines.R` da base fixada, em `verificacao-hedonic-value-etapa3/fixtures-legadas/` no dossiê local; `gerar-legados.R`, `fixtures-legadas.log` e `fixtures-legadas-sha256.json` registram o procedimento e hashes. São evidências locais, não arquivos já versionados no repositório. Antes da etapa 4, incorporar os três RDS confiáveis e hashes aos testes do pacote; se não estiverem disponíveis, os casos C02/C06 permanecem não verificados. O objeto WLS foi construído com `d_shadow` e `w_one`: os pesos efetivos 1:40 foram conferidos; não se deve converter essa observação em intenção correta do usuário.

Para regenerar fixtures equivalentes, executar o bloco de dados abaixo em um checkout limpo e confiável do commit fixado e então executar:

```r
source("R/model.R")
source("R/engines.R")
m_old <- hv_fit(y~x, d)
m_new <- hv_fit_model(y~x, d, "ols")
m_wls <- hv_fit_model(y~x, d_shadow, "wls", weights=w_one)
stopifnot(identical(as.numeric(stats::weights(m_wls$model)),
                    as.numeric(d_shadow$weights)))
fixed_time <- as.POSIXct("2026-10-26 12:00:00", tz="UTC")
m_old$created <- fixed_time
m_new$fitted_at <- fixed_time
m_wls$fitted_at <- fixed_time
dir.create("fixtures-legadas", showWarnings=FALSE)
saveRDS(m_old, "fixtures-legadas/ols-antigo.rds", version=3)
saveRDS(m_new, "fixtures-legadas/ols-novo.rds", version=3)
saveRDS(m_wls, "fixtures-legadas/wls-sombra.rds", version=3)
```

Registrar versão do R e os hashes dos arquivos realmente produzidos. A equivalência semântica deve ser testada; não se promete que RDS de versões/ambientes distintos terá hash idêntico. Usar apenas fixtures confiáveis; o processo de migração não deve reexecutar as fórmulas.

```r
# Fixture determinística para o contrato proposto; não executa o contrato novo.
x <- seq_len(40L)
d <- data.frame(id=sprintf("imovel-%02d", x), x=x,
                z=10+x/10, grupo=factor(rep(c("A","B"),20L)))
d$y <- 100+3*d$x+d$z+sin(d$x)
d$price <- exp(12+0.02*d$x+0.3*sin(d$x))
d_shadow <- d
d_shadow$weights <- seq_len(nrow(d_shadow))
w_one <- rep(1, nrow(d))
w_seq <- seq_len(nrow(d))
selected <- d$x <= 20
d2 <- data.frame(x=c(1,2), y=c(4,7))
singular <- data.frame(x=x, duplicate=x, y=d$y)
d_factor <- d
d_factor$grupo <- factor(d_factor$grupo, levels=c("A","B","C"))
new_factor_c <- d_factor[1L,,drop=FALSE]
new_factor_c$grupo <- factor("C",levels=c("A","B","C"))
missing_x <- d[1:2,,drop=FALSE]; missing_x$x[1] <- NA_real_
infinite_x <- d[1:2,,drop=FALSE]; infinite_x$x[1] <- Inf
duplicate_ids <- d[1:2,,drop=FALSE]; duplicate_ids$id <- c("same","same")
collision <- d[1:2,,drop=FALSE]; collision$.pred <- c(1,2)
X_bad <- cbind(intercept=1, x=x, near=x+1e-12*(-1)^x)
well_conditioned <- cbind(intercept=1, x=(x-mean(x))/sd(x))
reference <- stats::lm(y~x, data=d, weights=w_one)
legacy_formula_env <- local({
  log <- function(x) x
  stats::lm(log(price)~x, data=d)
})
stopifnot(nrow(d)==40L, length(w_one)==40L, sum(selected)==20L,
          is.finite(kappa(X_bad,exact=TRUE)), kappa(X_bad,exact=TRUE)>=1e8,
          kappa(well_conditioned,exact=TRUE)<1e8,
          identical(as.numeric(stats::model.response(stats::model.frame(legacy_formula_env))), d$price))
cat("Fixtures validadas: n=40, subset=20, kappa(X_bad)=",
    format(kappa(X_bad,exact=TRUE), digits=5), 
    "; função local chamada log é identidade.\n",sep="")
```

## Asserções para implementar posteriormente

Todas as comparações numéricas usam erro por elemento `abs(a-b) <= 1e-8 * pmax(1, abs(b))`, salvo a condição exata ou os campos lógicos/textuais indicados.

| Caso | Fixture e asserção futura |
|---|---|
| C01 | Com `d`, construir pelos dois pontos de entrada; exigir schema_version=1L, seis capacidades e previsão pontual equivalente. A identidade de estrutura não exige idêntico timestamp/proveniência. |
| C02 | Carregar duas fixtures v0.0.3 confiáveis, construídas por ambas as APIs em `d`. Preservar coeficientes; não executar fórmula; transformação/unidade/proveniência desconhecidas se ausentes. Arquivos originais byte a byte intactos. |
| C03 | Copiar objeto v1; mudar `schema_version=2L`, ou `n=39L`, ou `method="gls"` com objeto `lm`. Cada um deve ser rejeitado com motivo, sem alterar fixture salva. |
| C04 | Com `d` sem coluna weights, WLS `weights=w_one`: pesos efetivos idênticos a w_one e coeficientes iguais a `reference`. |
| C05 | Com `d_shadow`, WLS `weights=w_one`: pesos idênticos a w_one, não coluna 1:40; coeficientes iguais a `reference`. |
| C06 | Fixture WLS v0.0.3 que contém pesos reais 1:40: migrar preservando 1:40; `weight_interpretation="unknown"`; não afirmar intenção original. |
| C07 | WLS com `w_seq`, tanto API antiga como nova: intervalo preditivo gera erro de capacidade; IC só disponível quando interpretação `inverse_variance_relative` declarada e demais condições satisfeitas. |
| C08 | Em `d`, `log(price)~x` sem metadados: escala de saída `model`, transformação `unknown`; triagem de razão em escala original rejeitada. Repetir com `legacy_formula_env`, cujo `log` é identidade: jamais detectar log apenas pelo nome. |
| C09 | `y~x,d` sem metadados: `quantity` e `unit` NA; sem rótulo automático de moeda. |
| C10 | `y~x+offset(z),d` e `d[1:2,]`: somar todos os componentes inclusive .offset, comparar com `stats::predict` na escala do modelo; retirar z de newdata e exigir erro. |
| C11 | Ajustar `y~x+grupo` usando os níveis observados A/B; prever `new_factor_c` com C não observado e `missing_x`: erro identificado, sem reduzir/reordenar linhas. |
| C12 | WLS em `d_shadow`, pesos `w_seq`, `id="id"`, subset `x<=20`: n=20L, rows=1:20, pesos efetivos 1:20; comparar com `stats::lm(y~x,data=d[1:20,],weights=w_seq[1:20])`; ID selecionado preservado. |
| C13 | Solicitar argumento adicional `unsupported=1` e `correlation` num OLS: erros nomeando argumento/método. `subset` numérico `1:20` e vetor lógico reciclável também são rejeitados. |
| C14 | Ajustar GLS e robusto em `d`: tidy sem índice fora da matriz; inferência não suportada tipada NA e razão; glance sem R² fabricado; augment treino/diagnósticos não suportados rejeitam com motivo. Colisão `.fitted` nos dados novos é erro. |
| C15 | `d2`: fit pontual pode existir, mas intervalo com df residual zero gera erro. `singular` com `y~x+duplicate` gera erro de posto não estimável. |
| C16 | `d[0,]`, `missing_x`, `infinite_x`, `duplicate_ids` com id solicitado, `collision` no wrapper tabular: cada entrada é recusada, sem perda de linhas nem sobrescrita. |
| C17 | Modelo `log(price)~x` e verdade `price`: escala desconhecida/transformada implica erro. Para `y~x`, fornecer ao ajuste `response_metadata=list(transformation="identity",quantity="valor",unit="BRL")` e ao benchmark `truth_metadata=list(scale="identity",quantity="valor",unit="BRL")`: permitir RMSE entre média prevista e valores individuais `d$y`; mudar unidade para `USD`, ou escala para `log`, ou omitir metadados, e exigir erro. |
| C18 | Na etapa de ativação C++, comparar `well_conditioned` e y com `stats::lm.fit`, incluindo RSS/df; validar coeficientes/resíduos/sigma² na tolerância acima, df exato. Rejeitar `X_bad` com kappa >=1e8, coluna duplicada, n<=p e não finitos; nenhum fallback silencioso. |
| C19 | Imprimir e consultar capacidades para os dois construtores OLS: estado NOT_ASSESSED, seis capacidades coerentes, razões e status iguais. |
| C20 | Em fixture legada retirar índices originais ou marcá-los irrecuperáveis; migrar com indices_known=FALSE e indices=NULL ou rejeitar operação que dependa deles. Nunca deduzir índices de rownames, refazer ajuste ou sobregravar RDS. |
| C21 | `y~0+grupo+x:grupo+offset(z)` em `d`: preservar níveis/contrastes; soma das contribuições e offset equivale a `stats::predict`; sem intercepto fictício. |
| C22 | Com `d`, API OLS antiga em `d[1:3,]`: data.frame exatamente fit/lwr/upr, mesma ordem/rownames; comparar a `stats::predict(lm(...), interval="confidence",level=.8)`. |

O contrato deve rejeitar entrada inválida de maneira determinística. Mensagens devem identificar método/operação e motivo; os testes não dependem de pontuação exata ou de mensagens internas de bibliotecas terceiras. Os casos propostos não substituem testes de cobertura empírica, pressupostos, dados de mercado ou revisão normativa.
