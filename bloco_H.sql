-- BLOCO H - Procedures parametrizadas
-- obs: procedure "de verdade" no Postgres (CREATE PROCEDURE) não devolve linhas,
-- só serve pra executar comandos. Como aqui a ideia é gerar um relatório (retornar dados),
-- usei FUNCTION com RETURNS TABLE, que na prática funciona como um select parametrizado.
 
-- 1. Relatório de vendas por vendedor, filtrando por período
CREATE OR REPLACE FUNCTION sp_relatorio_vendedor(id_vendedor text, data_inicio date, data_fim date)
RETURNS TABLE (order_id text, price numeric, data_pedido text) AS $$
SELECT oi.order_id, oi.price::numeric, o.order_purchase_timestamp
FROM public.olist_order_items_dataset oi
JOIN public.olist_orders_dataset o ON oi.order_id = o.order_id
WHERE oi.seller_id = id_vendedor
AND o.order_purchase_timestamp::date BETWEEN data_inicio AND data_fim;
$$ LANGUAGE sql;
 
 
-- 2. Relatório de vendas por categoria, filtrando por período
CREATE OR REPLACE FUNCTION sp_relatorio_categoria(categoria_nome text, data_inicio date, data_fim date)
RETURNS TABLE (product_id text, price numeric, data_pedido text) AS $$
SELECT oi.product_id, oi.price::numeric, o.order_purchase_timestamp
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p ON oi.product_id = p.product_id
JOIN public.olist_orders_dataset o ON oi.order_id = o.order_id
WHERE p.product_category_name = categoria_nome
AND o.order_purchase_timestamp::date BETWEEN data_inicio AND data_fim;
$$ LANGUAGE sql;
 
-- exemplos de chamada:
SELECT seller_id FROM public.olist_sellers_dataset LIMIT 1;
SELECT * FROM sp_relatorio_vendedor('3442f8959a84dea7ee197c632cb2df15', '2017-01-01', '2017-12-31');

