# Dataset de teste do pacote

Este diretório contém somente dados artificiais e anonimizados distribuídos
para testes de leitura, validação de esquema e demonstrações da API.

## Arquivos

- synthetic_property_test.csv: dataset artificial e anonimizado para
  testes de esquema, validação, exemplos de regressão e casos de conflito.

O arquivo `synthetic_property_test.csv` foi gerado a partir de faixas e
relações numéricas fornecidas para teste. Não contém endereços, inscrições
cadastrais, nomes de imóveis ou identificadores reais.
Todos os registros possuem `is_synthetic = 1` e `source_reference` indica que
se trata de uma reprodução sintética, não de uma transação observada.

As linhas combinam observações de locação (`observation_type = rent`) e venda
(`observation_type = sale`). Campos que não se aplicam ao tipo da observação
ficam vazios. O registro `SYN-RENT-002` representa um alvo conciliado; ele não
deve ser tratado como observação independente ao estimar um modelo.

Valores vazios indicam atributo não aplicável ao tipo da observação. Valores
monetários estão em reais; áreas estão em metros quadrados.
