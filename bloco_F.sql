-- BLOCO F - CTE

-- 1. Faturamento mensal por estado, com variação % em relação ao mês anterior
WITH fat_mensal AS (
SELECT c.customer_state AS estado, date_trunc('month', o.order_purchase_timestamp::timestamp) AS mes, SUM(oi.price::numeric) AS faturamento
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_state, date_trunc('month', o.order_purchase_timestamp::timestamp))
SELECT estado, mes, faturamento,
ROUND(((faturamento - LAG(faturamento) OVER (PARTITION BY estado ORDER BY mes)) / LAG(faturamento) OVER (PARTITION BY estado ORDER BY mes)) * 100, 2) AS variacao_percentual
FROM fat_mensal
ORDER BY estado, mes;

-- 2. Nota média e quantidade de avaliações por categoria
WITH avaliacoes AS (
SELECT DISTINCT p.product_category_name AS categoria, r.order_id, r.review_score
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p ON oi.product_id = p.product_id
JOIN public.olist_order_reviews_dataset r ON oi.order_id = r.order_id)
    
SELECT categoria, AVG(review_score::numeric) AS nota_media, COUNT(*) AS qtd_avaliacoes
FROM avaliacoes
GROUP BY categoria
ORDER BY nota_media DESC;

-- 3. Frete médio por estado, comparado com a média geral
WITH frete_estado AS (
SELECT c.customer_state AS estado, AVG(oi.freight_value::numeric) AS frete_medio
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_state)
    
SELECT estado, frete_medio, (SELECT AVG(frete_medio) FROM frete_estado) AS frete_medio_geral
FROM frete_estado
ORDER BY frete_medio DESC;

