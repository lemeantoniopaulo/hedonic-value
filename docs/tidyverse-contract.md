# Contrato de integração com tidyverse

O pacote aceita data.frame e tibble como entradas e retorna tibbles nas funções novas de previsão, benchmark e diagnóstico.

## Regras

- nomes de colunas devem ser preservados;
- a fórmula deve ser informada separadamente dos dados;
- resultados tabulares devem manter uma linha por observação quando forem observacionais;
- métricas agregadas devem declarar a partição utilizada;
- conversões de sf devem ser explícitas;
- geometrias não devem ser removidas silenciosamente;
- dados ausentes devem ser tratados antes do ajuste ou registrados;
- o uso do metapacote tidyverse não é obrigatório.

A integração não altera o significado estatístico do modelo.
