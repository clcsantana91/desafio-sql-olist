-- ============================================
-- BLOCO C - Funções agregadas + GROUP BY + HAVING
-- ============================================

-- 1. Faturamento total por estado do cliente.
-- Pergunta de negócio: qual é o faturamento total gerado pelos clientes de cada estado?
SELECT 
    c.customer_state AS estado,
    SUM(oi.price::numeric) AS faturamento_total
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o 
    ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY faturamento_total DESC;


-- 2. Top 10 vendedores por faturamento.
-- Pergunta de negócio: quais são os 10 vendedores com maior faturamento?
SELECT 
    oi.seller_id,
    SUM(oi.price::numeric) AS faturamento_total
FROM public.olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY faturamento_total DESC
LIMIT 10;


-- 3. Ticket médio por categoria de produto.
-- Pergunta de negócio: qual é o valor médio dos itens vendidos em cada categoria?
SELECT 
    p.product_category_name AS categoria,
    AVG(oi.price::numeric) AS ticket_medio
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p 
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY ticket_medio DESC;


-- 4. Vendedores com nota média de avaliação abaixo de 3.
-- Pergunta de negócio: quais vendedores possuem média de avaliação inferior a 3?
SELECT 
    oi.seller_id,
    AVG(r.review_score::numeric) AS nota_media
FROM public.olist_order_items_dataset oi
JOIN public.olist_order_reviews_dataset r 
    ON oi.order_id = r.order_id
GROUP BY oi.seller_id
HAVING AVG(r.review_score::numeric) < 3
ORDER BY nota_media;


-- 5. Quantidade de pedidos por forma de pagamento.
-- Pergunta de negócio: quantos pedidos utilizaram cada forma de pagamento?
SELECT 
    op.payment_type,
    COUNT(DISTINCT op.order_id) AS quantidade_pedidos
FROM public.olist_order_payments_dataset op
GROUP BY op.payment_type
ORDER BY quantidade_pedidos DESC;


-- 6. Peso médio dos produtos por categoria.
-- Pergunta de negócio: qual é o peso médio dos produtos de cada categoria?
SELECT 
    p.product_category_name AS categoria,
    AVG(p.product_weight_g::numeric) AS peso_medio
FROM public.olist_products_dataset p
GROUP BY p.product_category_name
ORDER BY peso_medio DESC;


-- 7. Número médio de parcelas por categoria de produto.
-- Pergunta de negócio: qual é a média de parcelas utilizadas nas compras de cada categoria?
SELECT 
    p.product_category_name AS categoria,
    AVG(op.payment_installments::numeric) AS media_parcelas
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN public.olist_order_payments_dataset op 
    ON oi.order_id = op.order_id
GROUP BY p.product_category_name
ORDER BY media_parcelas DESC;
