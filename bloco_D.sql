-- BLOCO D - Subqueries

-- passo 1: soma o total gasto (preço + frete) de cada cliente
CREATE TEMP TABLE gasto_cliente AS
SELECT c.customer_id, SUM(oi.price::numeric + oi.freight_value::numeric) AS gasto_total
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_id;

-- 1. Clientes com gasto total acima da média geral de gasto por cliente
SELECT customer_id, gasto_total
FROM gasto_cliente
WHERE gasto_total > (SELECT AVG(gasto_total) FROM gasto_cliente)
ORDER BY gasto_total DESC;


-- 2. Produtos que nunca receberam avaliação
SELECT p.product_id
FROM public.olist_products_dataset p
WHERE p.product_id NOT IN (
    SELECT oi.product_id
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_order_reviews_dataset r ON oi.order_id = r.order_id
);


-- 3. Vendedores que vendem produtos de mais de 5 categorias diferentes
SELECT sub.seller_id, COUNT(sub.categoria) AS qtd_categorias
FROM (
    SELECT DISTINCT oi.seller_id, p.product_category_name AS categoria
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_products_dataset p ON oi.product_id = p.product_id) sub
GROUP BY sub.seller_id
HAVING COUNT(sub.categoria) > 5
ORDER BY qtd_categorias DESC;


-- 4. Pedidos em que o frete total foi maior que o valor total dos itens
SELECT sub.order_id, sub.valor_itens, sub.valor_frete
FROM (
    SELECT oi.order_id, SUM(oi.price::numeric) AS valor_itens, SUM(oi.freight_value::numeric) AS valor_frete
    FROM public.olist_order_items_dataset oi
    GROUP BY oi.order_id) sub
WHERE sub.valor_frete > sub.valor_itens
ORDER BY sub.valor_frete DESC;
