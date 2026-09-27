-- ============================================
-- BLOCO B - JOINs
-- ============================================

-- 1. Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor.
-- Pergunta de negócio: qual categoria, valor e cidade do vendedor estão envolvidos em cada item vendido?
SELECT 
    t.product_category_name_english AS categoria,
    oi.price::numeric AS valor_item,
    s.seller_city AS cidade_vendedor
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN public.product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
JOIN public.olist_sellers_dataset s 
    ON oi.seller_id = s.seller_id;

-- 2. Identificar pedidos com atraso na entrega, comparando data estimada com data real de entrega.
-- Pergunta de negócio: quais pedidos foram entregues depois do prazo estimado?
SELECT 
    o.order_id,
    c.customer_city,
    c.customer_state,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date
FROM public.olist_orders_dataset o
JOIN public.olist_customers_dataset c 
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date <> ''
  AND o.order_estimated_delivery_date <> ''
  AND o.order_delivered_customer_date::timestamp > o.order_estimated_delivery_date::timestamp;

-- 3. Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de uma parcela.
-- Pergunta de negócio: quais pedidos foram parcelados?
SELECT 
    o.order_id,
    op.payment_type,
    op.payment_installments
FROM public.olist_orders_dataset o
JOIN public.olist_order_payments_dataset op
    ON o.order_id = op.order_id
WHERE op.payment_installments::integer > 1;

-- 4. Listar produtos junto com a categoria traduzida, incluindo produtos cuja categoria
-- não possui tradução cadastrada (LEFT JOIN).
-- Pergunta de negócio: quais produtos não têm tradução de categoria cadastrada?
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english
FROM public.olist_products_dataset p
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name;

-- 5. Identificar pedidos em que o cliente e o vendedor são do mesmo estado.
-- Pergunta de negócio: quantas vendas acontecem dentro do mesmo estado (cliente e vendedor)?
SELECT 
    o.order_id,
    c.customer_state,
    s.seller_state
FROM public.olist_orders_dataset o
JOIN public.olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN public.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
JOIN public.olist_sellers_dataset s
    ON oi.seller_id = s.seller_id
WHERE c.customer_state = s.seller_state;
