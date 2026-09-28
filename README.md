# Desafio SQL - Olist

Neste desafio, trabalhei com os dados da Olist, um e-commerce brasileiro, para praticar SQL e explorar informações sobre vendas, clientes, produtos, pagamentos e entregas.

## Arquivos

Organizei as consultas em arquivos separados, de acordo com cada assunto:

- bloco_A.sql – SELECT básico
- bloco_B.sql – JOINs
- bloco_C.sql – GROUP BY e HAVING
- bloco_D.sql – Subqueries
- bloco_E.sql – CASE WHEN
- bloco_F.sql – CTE
- bloco_G.sql – Views
- bloco_H.sql – Funções com parâmetros
- bloco_I.sql – Window Functions

## Alguns resultados que encontrei

Durante a análise, consegui identificar alguns dados interessantes:

- Estado com maior faturamento: São Paulo (SP)
- Vendedor com maior faturamento: 4869f7a5dfa277a7dca6462dcf3b52b2, com R$ 229.472,63 em vendas
- Forma de pagamento mais utilizada: cartão de crédito, com 76.795 pagamentos
- Categoria com menor nota média: moveis_escritorio, com nota 3,62 e 1.266 avaliações
- Prazo de entrega: cerca de 92% dos pedidos chegaram antes do prazo, 7% chegaram atrasados e 1% foram entregues na data estimada

## Tecnologias utilizadas

- PostgreSQL 18 (instalado localmente)
- DBeaver Community (para escrever e executar as consultas)
- Dataset: Brazilian E-Commerce Public Dataset by Olist (9 arquivos CSV)

## Como rodar o projeto localmente

1. Instale o PostgreSQL e o DBeaver Community.
2. Crie um banco de dados chamado `olist`.
3. Baixe os 9 arquivos CSV do dataset e guarde em uma pasta local simples, por exemplo `C:\dados\olist\`.
4. Crie as 9 tabelas com o mesmo nome dos arquivos CSV (sem o .csv) e com as colunas do cabeçalho de cada arquivo, todas com o tipo `text` para evitar erros de conversão na importação.
5. Importe cada CSV com o comando `COPY`, por exemplo:

```sql
COPY olist_customers_dataset
FROM 'C:\dados\olist\olist_customers_dataset.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
```

6. Confira se as contagens de linhas batem:

| Tabela | Linhas |
|---|---|
| olist_customers_dataset | 99.441 |
| olist_geolocation_dataset | 1.000.163 |
| olist_order_items_dataset | 112.650 |
| olist_order_payments_dataset | 103.886 |
| olist_order_reviews_dataset | 99.224 |
| olist_orders_dataset | 99.441 |
| olist_products_dataset | 32.951 |
| olist_sellers_dataset | 3.095 |
| product_category_name_translation | 71 |

7. Execute os arquivos `bloco_A.sql` até `bloco_I.sql` na ordem. Os blocos G e H criam views e funções, então precisam rodar depois que as tabelas estiverem prontas.

## Observações

- Como as colunas foram importadas como `text`, algumas consultas usam conversão de tipo (`::numeric` e `::date`) para trabalhar com números e datas.
- Nas tabelas `olist_orders_dataset` e `olist_products_dataset`, alguns IDs vieram com aspas duplas gravadas junto do valor, o que fazia os JOINs perderem linhas. Corrigi com `UPDATE` usando `TRIM`, e as junções voltaram a retornar o número esperado de linhas.
- No Bloco H usei `FUNCTION` com `RETURNS TABLE` em vez de `PROCEDURE`, porque no PostgreSQL uma procedure não devolve linhas e aqui a ideia era gerar relatórios.
