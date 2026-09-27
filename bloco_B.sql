-- BLOCO B - JOINs
 
-- 1. Categoria do produto, valor do item e cidade do vendedor
SELECT p.product_category_name AS categoria, oi.price, s.seller_city
FROM public.olist_order_items_dataset oi
JOIN public.olist_products_dataset p ON oi.product_id = p.product_id
JOIN public.olist_sellers_dataset s ON oi.seller_id = s.seller_id;
 
 
-- 2. Pedidos que atrasaram (entregue depois da data estimada)
SELECT order_id, order_estimated_delivery_date, order_delivered_customer_date
FROM public.olist_orders_dataset
WHERE order_delivered_customer_date <> ''
    AND order_estimated_delivery_date <> ''
    AND order_delivered_customer_date::date > order_estimated_delivery_date::date;
 
 
-- 3. Pedidos pagos em mais de uma parcela
SELECT o.order_id, op.payment_installments
FROM public.olist_orders_dataset o
JOIN public.olist_order_payments_dataset op ON o.order_id = op.order_id
WHERE op.payment_installments::numeric > 1;
 
 
-- 4. Produtos com categoria traduzida, incluindo os que não têm tradução
SELECT p.product_id, p.product_category_name AS categoria, t.product_category_name_english AS categoria_traduzida
FROM public.olist_products_dataset p
LEFT JOIN public.product_category_name_translation t ON p.product_category_name = t.product_category_name;
 
 
-- 5. Pedidos onde cliente e vendedor são do mesmo estado
SELECT o.order_id, c.customer_state, s.seller_state
FROM public.olist_orders_dataset o
JOIN public.olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN public.olist_sellers_dataset s ON oi.seller_id = s.seller_id
WHERE c.customer_state = s.seller_state;
