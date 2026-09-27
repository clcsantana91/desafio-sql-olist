-- BLOCO C - Funções agregadas + GROUP BY + HAVING

-- 1. Faturamento total por estado do cliente
SELECT c.customer_state AS estado, SUM(oi.price::numeric) AS faturamento_total
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY faturamento_total DESC;


-- 2. Top 10 vendedores por faturamento
SELECT oi.seller_id, SUM(oi.price::numeric) AS faturamento_total
FROM public.olist_order_items_dataset oi
GROUP BY oi.seller_id
ORDER BY faturamento_total DESC
LIMIT 10;


-- 3. Ticket médio por categoria de produto
SELECT p.product_category_name AS categoria, AVG(oi.price::numeric) AS ticket_medio
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY ticket_medio DESC;


-- 4. Vendedores com nota média de avaliação abaixo de 3
-- (uso um DISTINCT antes pra não contar a mesma nota repetida quando o pedido tem vários itens)
SELECT sub.seller_id, AVG(sub.review_score::numeric) AS nota_media
FROM (
    SELECT DISTINCT oi.seller_id, oi.order_id, r.review_score
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_order_reviews_dataset r ON oi.order_id = r.order_id
) sub
GROUP BY sub.seller_id
HAVING AVG(sub.review_score::numeric) < 3
ORDER BY nota_media;


-- 5. Quantidade de pedidos por forma de pagamento
SELECT op.payment_type, COUNT(DISTINCT op.order_id) AS quantidade_pedidos
FROM public.olist_order_payments_dataset op
GROUP BY op.payment_type
ORDER BY quantidade_pedidos DESC;


-- 6. Peso médio dos produtos por categoria
SELECT p.product_category_name AS categoria, AVG(p.product_weight_g::numeric) AS peso_medio
FROM public.olist_products_dataset p
GROUP BY p.product_category_name
ORDER BY peso_medio DESC;


-- passo 1: soma as parcelas de cada pedido
CREATE TEMP TABLE parcelas_pedido AS
SELECT order_id, SUM(payment_installments::numeric) AS parcelas
FROM public.olist_order_payments_dataset
GROUP BY order_id;

-- passo 2: pega cada combinação única de pedido + categoria
-- (evita repetir quando o pedido tem mais de um item da mesma categoria)
CREATE TEMP TABLE pedido_categoria AS
SELECT DISTINCT oi.order_id, p.product_category_name AS categoria
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p ON oi.product_id = p.product_id;

-- 7. Número médio de parcelas por categoria de produto
SELECT pc.categoria, AVG(pp.parcelas) AS media_parcelas
FROM pedido_categoria pc
JOIN parcelas_pedido pp ON pc.order_id = pp.order_id
GROUP BY pc.categoria
ORDER BY media_parcelas DESC;
