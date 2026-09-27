-- BLOCO I - Window functions

-- 1. Ranking dos vendedores por faturamento, dentro de cada estado
SELECT s.seller_state, s.seller_id, SUM(oi.price::numeric) AS faturamento,
RANK() OVER (PARTITION BY s.seller_state ORDER BY SUM(oi.price::numeric) DESC) AS posicao
FROM public.olist_order_items_dataset oi
JOIN public.olist_sellers_dataset s ON oi.seller_id = s.seller_id
GROUP BY s.seller_state, s.seller_id
ORDER BY s.seller_state, posicao;


-- 2. Faturamento acumulado de cada vendedor ao longo do tempo
SELECT oi.seller_id, o.order_purchase_timestamp::date AS data_pedido, oi.price::numeric AS valor,
SUM(oi.price::numeric) OVER (PARTITION BY oi.seller_id ORDER BY o.order_purchase_timestamp::date) AS faturamento_acumulado
FROM public.olist_order_items_dataset oi
JOIN public.olist_orders_dataset o ON oi.order_id = o.order_id
ORDER BY oi.seller_id, data_pedido;


-- 3. % de participação de cada estado no faturamento total
SELECT c.customer_state AS estado, SUM(oi.price::numeric) AS faturamento,
ROUND(SUM(oi.price::numeric) / SUM(SUM(oi.price::numeric)) OVER () * 100, 2) AS percentual_participacao
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY percentual_participacao DESC;


-- 4. Variação de faturamento mês a mês, usando LAG
SELECT mes, faturamento, faturamento - LAG(faturamento) OVER (ORDER BY mes) AS variacao
FROM (
SELECT date_trunc('month', o.order_purchase_timestamp::timestamp) AS mes, SUM(oi.price::numeric) AS faturamento
FROM public.olist_orders_dataset o
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY date_trunc('month', o.order_purchase_timestamp::timestamp)) sub
ORDER BY mes;
