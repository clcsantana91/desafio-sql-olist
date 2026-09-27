-- BLOCO G - Views

-- 1. View com pedido + cliente + itens + pagamento + vendedor, tudo junto
DROP VIEW IF EXISTS vw_pedidos_completos;
CREATE VIEW vw_pedidos_completos AS
SELECT o.order_id, c.customer_state, c.customer_city, oi.product_id, oi.price, op.payment_type, op.payment_installments, s.seller_id, s.seller_state
FROM public.olist_orders_dataset o
JOIN public.olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN public.olist_order_payments_dataset op ON o.order_id = op.order_id
JOIN public.olist_sellers_dataset s ON oi.seller_id = s.seller_id;


-- 2. View com nota média e volume de avaliação por categoria
DROP VIEW IF EXISTS vw_avaliacoes_categoria;
CREATE VIEW vw_avaliacoes_categoria AS
SELECT categoria, AVG(review_score::numeric) AS nota_media, COUNT(*) AS qtd_avaliacoes
FROM (
SELECT DISTINCT p.product_category_name AS categoria, r.order_id, r.review_score
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p ON oi.product_id = p.product_id
JOIN public.olist_order_reviews_dataset r ON oi.order_id = r.order_id) sub
GROUP BY categoria;


Consulta:
SELECT * FROM vw_pedidos_completos;
