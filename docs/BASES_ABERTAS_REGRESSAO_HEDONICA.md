# Bases abertas para regressão hedônica de preços imobiliários

**Catálogo de pesquisa — 28 de outubro de 2026**

Este documento registra fontes públicas que podem alimentar uma regressão hedônica de imóveis. A classificação é de adequação metodológica para o uso pretendido, não uma certificação da qualidade dos dados. Os links foram consultados em 28/10/2026; páginas, arquivos, esquemas, licenças e períodos cobertos podem mudar.

## Síntese executiva

- Para São Paulo, a combinação prioritária é **ITBI-SP como fonte de preço/transação** e **GeoSampa como fonte de cadastro, geometria e contexto urbano**.
- Para comparação internacional com transações, as fontes mais diretamente aproveitáveis são **DVF/DVF+ (França), Cook County, NYC, HM Land Registry e NSW**. **King County** é útil, mas exige cuidado com termos de uso e com a distinção entre venda de mercado e registros não comparáveis.
- **PBH ITBI** é uma fonte municipal relevante para acompanhamento e validação de totais; o conjunto público consultado é descrito como relatório de lançamentos quitados por ano/mês, portanto não deve ser tratado automaticamente como microdado transacional.
- **PNAD Contínua** não é uma base de preços de imóveis. Pode fornecer covariáveis socioeconômicas e características domiciliares agregáveis, mas seus microdados têm desenho amostral, sigilo e ausência de uma chave pública para ligação com um imóvel transacionado.
- Nenhuma fonte deve ser baixada diretamente para o repositório. O plano recomendado é versionar manifesto, dicionário, código de ingestão, hashes e decisões de limpeza; manter os dados brutos fora do Git, salvo autorização explícita.

## Catálogo

| Fonte oficial | O que oferece | Granularidade e uso sugerido | Adequação | Ressalvas principais |
|---|---|---|---|---|
| [ITBI-SP — transações imobiliárias](https://smartsampa.prefeitura.sp.gov.br/web/fazenda/w/acesso_a_informacao/31501) | Arquivos mensais/anuais de DTI com transações para as quais houve recolhimento de ITBI; a página explica a diferença entre data de transação e mês de pagamento. | Uma linha por DTI paga no mês de referência; alvo principal para preço de transação em São Paulo, sujeito ao dicionário de cada entrega. | **Alta para o alvo** | Não cobre imóveis rurais nem ITBI pago via PPI; data de pagamento não é data da venda; pode haver valores declarados, valores de referência e naturezas distintas. A página não deve ser interpretada, sem conferência jurídica, como licença ampla para redistribuir os arquivos.
| [GeoSampa — camadas e downloads](https://geosampa.prefeitura.sp.gov.br/) e [metadados do Cadastro](https://metadados.geosampa.prefeitura.sp.gov.br/geonetwork/srv/search?keyword=Cadastro) | Lotes/cadastro fiscal, geometria, zoneamento, uso do solo e outras camadas urbanas. O SQL representa setor–quadra–lote; a camada de lotes é a representação cartográfica do cadastro fiscal. | Lote, geometria ou camada temática; usar para enriquecer o ITBI e construir variáveis de localização, zoneamento e vizinhança. | **Alta para atributos; baixa como alvo** | Não é uma série de preços transacionados. A camada exibida no site e os arquivos baixados podem ter ritmos de atualização diferentes; cadastros fiscais podem ser revistos. Acesso e uso das camadas devem seguir os metadados e atos indicados pela Prefeitura.
| [DVF — DGFiP/data.gouv.fr](https://www.data.gouv.fr/datasets/demandes-de-valeurs-foncieres) | Transações imobiliárias e fundiárias onerosas dos cinco anos disponíveis, derivadas de atos notariais e cadastro. | Mutação/disposição e parcela, em arquivos texto; bom benchmark de preço transacionado e análise temporal/geográfica na França coberta. | **Alta para o alvo** | Cobertura exclui Alsácia, Moselle e Mayotte; há latência e revisões semestrais; a DGFiP impõe cuidados contra reidentificação indireta e indexação por buscadores.
| [DVF+ / Datafoncier-Cerema](https://doc-datafoncier.cerema.fr/doc/guide/dv3f) | Estrutura o DVF em tabelas de mutação, disposição, parcela, local e endereço, com campos transformados/agregados e geometria; a documentação distingue DVF+, DV3F e a fonte DGFiP. | Uma mutação relacionada a várias disposições/parcels; usar para comparação internacional e para testar uma modelagem relacional/geoespacial mais rica. | **Alta, com engenharia de dados** | É uma transformação/estruturação da fonte fiscal, não uma observação independente; duplicidades e regras de agregação precisam ser auditadas. DV3F e Fichiers fonciers não devem ser presumidos de acesso aberto só porque DVF+ é aberto.
| [Cook County Open Data](https://datacatalog.cookcountyil.gov/) — [histórico de parcelas](https://datacatalog.cookcountyil.gov/Property-Taxation/Assessor-Parcel-Universe-Historical-/nj4t-kc8j) e [documentação do Assessor](https://datacatalog.cookcountyil.gov/stories/s/Assessor-2023-Open-Data-Refresh/9bqn-cfsv/) | Dados de vendas do Assessor, características de imóveis e universo histórico de parcelas; o Assessor descreve o uso dos dados em estudos de vendas e modelos de avaliação. | PIN/parcela, venda e características por ano; bom caso de estudo para unir preço, atributos e geografia por identificador. | **Alta** | Dados do Assessor, valores avaliados e preço de mercado são conceitos diferentes; PINs precisam preservar zeros à esquerda; há vendas envolvendo múltiplas parcelas, mudanças de classe e campos que podem não estar completos para o ano corrente.
| [NYC Rolling Sales](https://www.nyc.gov/site/finance/taxes/property-rolling-sales-data.page) e [vendas anualizadas](https://www.nyc.gov/site/finance/property/property-annualized-sales-update.page) | Vendas recentes e arquivos anualizados por borough, com bairro, classe/tipo construtivo, área e preço; há glossário oficial. | Registro de venda/parcela; bom benchmark para modelos com preço, tipologia, área e localização administrativa. | **Alta para o alvo** | Há vendas com preço zero ou transferências sem contraprestação; a janela rolling é de 12 meses e os arquivos recentes podem ser atualizados. O universo e as classes tributárias não são equivalentes a um cadastro residencial brasileiro.
| [HM Land Registry — Price Paid Data](https://www.gov.uk/government/collections/price-paid-data) e [guia de acesso](https://www.gov.uk/guidance/about-the-price-paid-data) | Preço, data de transferência, tipo, novo/usado, tenure e endereço/postcode de imóveis vendidos por valor na Inglaterra e no País de Gales desde 1995. | Transação residencial registrada; excelente benchmark com grande série temporal e tipos básicos. | **Alta para o alvo; média para atributos** | Transações recentes ficam incompletas por atraso de registro; há exclusões legais e transações não registradas; o OGL v3.0 não cobre automaticamente direitos de terceiros sobre dados de endereço (Ordnance Survey/Royal Mail).
| [King County Assessor — eSales](https://info.kingcounty.gov/assessor/esales/Residential.aspx?openSearchForm=1), [downloads do Assessor](https://info.kingcounty.gov/assessor/DataDownload/default.aspx) e [extrato GIS de vendas](https://www5.kingcounty.gov/sdc?Layer=rpsale_extr) | Busca e extratos de vendas com preço/data, atributos físicos e parcelamento; o material do Assessor informa uso de excise tax affidavits e verificação de vendas. | Parcela/PIN e venda; útil para comparar filtros de vendas de mercado e modelos de avaliação espacial. | **Média-alta** | A seleção de vendas pode remover transações não mercantis, multi-parcela ou de tipos específicos; os termos do portal impõem atribuição e alertas sobre uso comercial de listas de indivíduos. A licença/termos devem ser arquivados por dataset e data de acesso.
| [NSW Valuer General — bulk Property Sales Information](https://www.valuergeneral.nsw.gov.au/design/bulk_psi_content/bulk_psi) | Arquivos PSI desde 1990; de 2001 em diante, arquivos semanais por Local Government Area; há mapa de vendas e documentação de formato DAT. | Venda/imóvel e LGA; fonte forte para preço transacionado e séries locais na Nova Gales do Sul. | **Alta para o alvo; média para atributos** | O próprio órgão não garante completude ou exatidão; o PSI está sob CC BY-NC-ND 4.0, que limita uso comercial e obras derivadas. Não redistribuir transformações sem revisão dos termos.
| [PBH — ITBI Relatórios](https://dados.pbh.gov.br/pt_BR/dataset/itbi-relatorios) e [orientações municipais de ITBI](https://prefeitura.pbh.gov.br/fazenda/tributos/ITBI) | Relatórios mensais de lançamentos quitados, por ano/mês, quantidade e valor; a Prefeitura informa mudança de metodologia e correções de arquivos. | Agregado temporal/municipal; usar para conferência de volume, valor total e contexto de Belo Horizonte, não como microamostra sem localizar uma entrega mais granular. | **Baixa-média para o alvo; média para validação agregada** | A página pública consultada descreve relatórios e não garante uma linha por imóvel. Valores quitados/tributários não são necessariamente o preço de mercado; conferir dicionário, cobertura e licença de cada recurso.
| [PNAD Contínua — página de microdados](https://www.ibge.gov.br/estatisticas/sociais/trabalho/9173-pnadcontinua.html) e [FTP oficial](https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/Anual/Microdados/) | Microdados públicos de pesquisa domiciliar, com documentação, rendimento, trabalho, características do domicílio e módulos anuais. | Domicílio/pessoa em amostra; usar como covariável contextual ou análise de acessibilidade/renda, nunca como preço de uma unidade transacionada. | **Baixa para o alvo; média para contexto** | Desenho amostral, pesos, estratos/UPAs, sigilo e ausência de identificador público do imóvel impedem uma junção ingênua com ITBI. Estimativas devem respeitar o plano amostral e a documentação do IBGE.

### Leitura da classificação

“Alta” significa que a fonte tem, em princípio, uma observação de venda e um preço utilizável como variável dependente, após filtros e auditoria. Não significa que a fonte seja completa, representativa ou adequada para um laudo. “Alta para atributos” significa que a fonte ajuda a explicar o preço, mas não fornece o preço. “Média” sinaliza necessidade de seleção de vendas, reconstrução de chaves, tratamento de agregações ou verificação de licença. “Baixa” para o alvo significa que a fonte não deve ser usada para inventar uma variável de preço.

## Licença, privacidade e reuso

1. **Fonte oficial não equivale a licença única.** Guardar, em um manifesto, a URL do dataset, a licença/termos exibidos na data de aquisição, a data de consulta e o hash do arquivo.
2. **ITBI-SP, GeoSampa e PBH:** as páginas oficiais oferecem dados ou downloads, mas a permissão de redistribuição e os termos podem variar por camada/recurso. O repositório deve publicar instruções de obtenção e metadados, não cópias integrais, até que cada recurso seja conferido.
3. **DVF/DVF+:** a ficha DGFiP indica Licence Ouverte/Open Licence 2.0, mas também proíbe usos que permitam reidentificação indireta e indexação externa; a transformação do Cerema deve ser atribuída separadamente quando usada.
4. **HMLR:** usar a atribuição exigida pelo OGL v3.0 e revisar os direitos de terceiros sobre endereços. A licença da fonte não autoriza automaticamente qualquer base derivada de endereços.
5. **NSW:** CC BY-NC-ND 4.0 é incompatível com assumir que qualquer versão derivada pode ser redistribuída ou usada comercialmente.
6. **King County:** incluir a legenda exigida pelos termos do portal e avaliar a restrição da lei estadual de Washington sobre listas de indivíduos para fins comerciais.
7. **Dados pessoais e localização:** não publicar nomes, identificadores de pessoas, microendereço ou combinações que permitam reidentificação; conservar apenas o nível espacial necessário ao objetivo analítico.

## Vieses e decisões que precisam ficar explícitos

- **Preço observado:** preço declarado, preço pago, valor fiscal, valor avaliado e preço de anúncio não são sinônimos.
- **Seleção:** registros tributários/registrados excluem vendas não declaradas, não registradas, sem contraprestação, complexas, rurais ou com regras específicas de cobertura.
- **Tempo:** arquivos recentes podem receber retificações e atrasos; preços nominais precisam de uma regra de deflacionamento e data de referência.
- **Unidade de observação:** uma venda pode envolver vários lotes, unidades, disposições ou imóveis; somar linhas sem regra pode duplicar preço.
- **Características faltantes:** área, quartos, idade, conservação, padrão construtivo e amenidades não têm o mesmo conceito entre países e municípios.
- **Localização:** bairro, postcode, LGA, setor censitário, SQL e parcela são malhas diferentes; junções espaciais podem introduzir erro de geocodificação.
- **Dependência espacial e temporal:** erros correlacionados e choques locais justificam efeitos fixos, agrupamento de erros ou modelos espaciais; isso não é resolvido apenas por `lm()`.
- **Treino e teste:** separar por tempo e, quando possível, por área evita vazamento de informação de vendas muito próximas ou repetidas.
- **PNAD:** aplicar pesos e desenho amostral para estimativas populacionais; não usar microdados como se fossem um censo de imóveis.

## Pipeline R proposto

O pacote atualmente oferece a camada de modelagem e diagnóstico; este documento não afirma que os downloads, os joins ou os adaptadores abaixo já estejam implementados.

### 1. Manifesto e ingestão

Criar `data-raw/sources.yml` (ou equivalente) com `source_id`, `url`, `provider`, `retrieved_at`, `coverage`, `license`, `terms_url`, `raw_sha256` e `schema_version`. Baixar para armazenamento externo e manter o arquivo bruto imutável.

### 2. Esquema canônico

Mapear cada fonte para um contrato mínimo, preservando também as colunas originais:

```text
source, source_version, transaction_id, transaction_date, price_nominal,
currency, property_type, built_area_m2, land_area_m2, rooms, bedrooms,
bathrooms, year_built, tenure, new_build, parcel_id, geo_id, lon, lat
```

Campos ausentes devem permanecer ausentes, com indicador de cobertura; não preencher zero como sinônimo de “não informado”.

### 3. Normalização e filtros

- converter datas, moeda e unidades somente com regra documentada;
- separar vendas com `price == 0`, transferências sem contraprestação e registros multi-imóvel;
- deduplicar por identificador de transação e preservar uma tabela de rejeições;
- marcar, em vez de apagar silenciosamente, outliers e vendas potencialmente não mercantis;
- deflacionar preços apenas depois de escolher índice, mês-base e fonte do índice;
- registrar o número de linhas em cada etapa para permitir reconciliação.

### 4. Enriquecimento geográfico

Para São Paulo, testar primeiro a ligação ITBI–GeoSampa por SQL/endereço/parcela e medir taxa de correspondência, duplicidade e conflitos. Gerar variáveis de distância, zona, uso do solo, acessibilidade e vizinhança em uma etapa separada, com CRS e tolerância espacial registrados.

### 5. Modelagem no pacote

Uma primeira especificação comparável pode usar `log(price_real)` como resposta e área, tipologia, idade, quartos, tenure, efeitos de tempo e efeitos territoriais como explicadores. Comparar OLS/WLS/GLS/robusta apenas quando a base e a implementação suportarem a especificação; reportar RMSE/MAE fora da amostra, cobertura de intervalos, missingness e sensibilidade a filtros. O resultado é uma associação condicional, não uma inferência causal automática.

### 6. Validação reprodutível

Adicionar testes de esquema e invariantes: unicidade de IDs, preços não negativos, datas dentro da cobertura, áreas em unidades plausíveis, preservação de zeros à esquerda em chaves e reconciliação com totais oficiais. A validação final deve registrar a versão do arquivo, o hash, a data da execução e o que não pôde ser verificado.

## Plano de integração por etapas

1. **Etapa A — catálogo e contrato:** incorporar este documento, um manifesto sem dados e um dicionário canônico.
2. **Etapa B — adaptador ITBI-SP:** baixar uma competência histórica, documentar o esquema, medir duplicidades e criar uma tabela de transações normalizada sem publicar o bruto.
3. **Etapa C — GeoSampa:** selecionar camadas de lote/zoneamento, testar o join e publicar somente código, metadados e métricas de cobertura.
4. **Etapa D — benchmark externo:** implementar um adaptador pequeno para HMLR ou NYC e uma comparação de diagnóstico, sem misturar unidades monetárias ou conceitos de mercado.
5. **Etapa E — contexto:** incorporar PBH e PNAD/Censo como fontes de validação agregada e covariáveis, respeitando pesos e níveis geográficos.
6. **Etapa F — CI e documentação:** executar testes de esquema em fixtures sintéticas, checar links e licenças, e manter uma tabela de alterações de fonte. Nenhuma etapa deve sugerir que uma regressão já foi validada enquanto os dados reais e a execução correspondente não estiverem registrados.

## Estado desta incorporação

Esta entrega é documentação e plano de integração. Não inclui download de bases, não inclui junção efetiva, não estima coeficientes e não declara validação empírica de qualquer fonte. A próxima implementação deve começar por um fixture pequeno e auditável de ITBI-SP + GeoSampa, com manifesto e métricas de cobertura antes de qualquer modelo.

