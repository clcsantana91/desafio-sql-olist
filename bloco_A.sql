-- BLOCO A - SELECT básico
 
-- 1. Os 20 pedidos entregues mais recentes
SELECT order_id, customer_id, order_status, order_delivered_customer_date
FROM public.olist_orders_dataset
WHERE order_status = 'delivered'
    AND NULLIF(order_delivered_customer_date, '') IS NOT NULL
ORDER BY order_delivered_customer_date::timestamp DESC
LIMIT 20;
 
 
-- 2. Produtos de uma categoria, mostrando o nome traduzido
SELECT p.product_id, p.product_category_name AS categoria, t.product_category_name_english AS categoria_traduzida
FROM public.olist_products_dataset p
JOIN public.product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IN ('cama_mesa_banho', 'beleza_saude');
 
 
-- 3. Formas de pagamento distintas usadas no dataset
SELECT DISTINCT payment_type
FROM public.olist_order_payments_dataset;
 
 
-- 4. Produtos com mais de 10kg, do mais pesado pro mais leve
SELECT product_id, product_weight_g::numeric AS peso_gramas
FROM public.olist_products_dataset
WHERE product_weight_g::numeric > 10000
ORDER BY peso_gramas DESC;
 
