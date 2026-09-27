-- ============================================
-- BLOCO D - Subqueries
-- ============================================

-- 1. Clientes cujo gasto total está acima da média geral de gasto por cliente.
-- Pergunta de negócio: quais clientes gastaram acima da média geral?

SELECT 
    o.customer_id,
    SUM(oi.price::numeric) AS gasto_total
FROM public.olist_orders_dataset o
JOIN public.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
HAVING SUM(oi.price::numeric)>(
    SELECT AVG(gasto_total)
    FROM (
        SELECT 
            o.customer_id,
            SUM(oi.price::numeric) AS gasto_total
        FROM public.olist_orders_dataset o
        JOIN public.olist_order_items_dataset oi
            ON o.order_id = oi.order_id
        GROUP BY o.customer_id ) clientes);

-- 2. Produtos que nunca receberam avaliação.
-- Pergunta de negócio: quais produtos nunca receberam uma avaliação?
SELECT 
    p.product_id,
    p.product_category_name
FROM public.olist_products_dataset p
WHERE NOT EXISTS (
    SELECT 1
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_order_reviews_dataset r
        ON oi.order_id = r.order_id
    WHERE oi.product_id = p.product_id);


-- 3. Vendedores que venderam produtos de mais de 5 categorias diferentes.
-- Pergunta de negócio: quais vendedores venderam produtos de mais de 5 categorias?
SELECT 
    oi.seller_id
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p
    ON oi.product_id = p.product_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT p.product_category_name) > 5;


-- 4. Pedidos cujo valor de frete é maior que o valor total dos itens do próprio pedido.
-- Pergunta de negócio: quais pedidos possuem frete maior que o valor dos produtos?

SELECT 
    order_id,
    SUM(price::numeric) AS valor_itens,
    SUM(freight_value::numeric) AS valor_frete
FROM public.olist_order_items_dataset
GROUP BY order_id
HAVING SUM(freight_value::numeric) > SUM(price::numeric);
