-- ============================================
-- BLOCO G - VIEW
-- ============================================

-- 1. Criar uma view com informações completas dos pedidos.
-- Pergunta de negócio: como consultar pedido, cliente, item, pagamento e vendedor em um único lugar?

CREATE OR REPLACE VIEW public.vw_pedidos_completos AS
SELECT 
    o.order_id,
    o.customer_id,
    c.customer_city,
    c.customer_state,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    op.payment_type,
    op.payment_installments,
    s.seller_city,
    s.seller_state
FROM public.olist_orders_dataset o
JOIN public.olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN public.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN public.olist_order_payments_dataset op
    ON o.order_id = op.order_id
JOIN public.olist_sellers_dataset s
    ON oi.seller_id = s.seller_id;


-- 2. Criar uma view com nota média e volume de avaliações por categoria.
-- Pergunta de negócio: quais categorias possuem melhor ou pior avaliação?
CREATE OR REPLACE VIEW public.vw_avaliacoes_categoria AS
SELECT 
    p.product_category_name AS categoria,
    COUNT(r.review_id) AS quantidade_avaliacoes,
    AVG(r.review_score::numeric) AS nota_media
FROM public.olist_products_dataset p
JOIN public.olist_order_items_dataset oi
    ON p.product_id = oi.product_id
JOIN public.olist_order_reviews_dataset r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name;


view:

SELECT *
FROM public.vw_pedidos_completos;
