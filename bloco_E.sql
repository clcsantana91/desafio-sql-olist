-- BLOCO E - CASE WHEN

-- 1. Classificação do prazo de entrega: adiantado, no prazo ou atrasado
SELECT o.order_id, o.order_estimated_delivery_date::date AS data_estimada, o.order_delivered_customer_date::date AS data_entregue,
CASE
WHEN o.order_delivered_customer_date::date < o.order_estimated_delivery_date::date THEN 'adiantado'
WHEN o.order_delivered_customer_date::date = o.order_estimated_delivery_date::date THEN 'no prazo'
ELSE 'atrasado'
END AS situacao_entrega
FROM public.olist_orders_dataset o
WHERE o.order_delivered_customer_date IS NOT NULL AND o.order_delivered_customer_date <> ''
AND o.order_estimated_delivery_date IS NOT NULL AND o.order_estimated_delivery_date <> '';


-- 2. Classificação dos clientes por faixa de gasto: bronze, prata ou ouro
SELECT sub.customer_id, sub.gasto_total,
CASE
WHEN sub.gasto_total < 100 THEN 'bronze'
WHEN sub.gasto_total BETWEEN 100 AND 500 THEN 'prata'
ELSE 'ouro'
END AS faixa_gasto
FROM (
SELECT c.customer_id, SUM(oi.price::numeric + oi.freight_value::numeric) AS gasto_total
FROM public.olist_customers_dataset c
JOIN public.olist_orders_dataset o ON c.customer_id = o.customer_id
JOIN public.olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_id) sub
ORDER BY sub.gasto_total DESC;


-- 3. Classificação dos produtos por faixa de peso: leve, médio ou pesado
SELECT p.product_id, p.product_weight_g::numeric AS peso_gramas,
CASE
WHEN p.product_weight_g::numeric < 1000 THEN 'leve'
WHEN p.product_weight_g::numeric BETWEEN 1000 AND 5000 THEN 'médio'
ELSE 'pesado'
END AS faixa_peso
FROM public.olist_products_dataset p
WHERE p.product_weight_g IS NOT NULL AND p.product_weight_g <> ''
ORDER BY peso_gramas DESC;


-- 4. Classificação dos pagamentos: à vista, parcelado ou parcelamento longo
SELECT op.order_id, op.payment_installments::numeric AS parcelas,
CASE
WHEN op.payment_installments::numeric = 1 THEN 'à vista'
WHEN op.payment_installments::numeric BETWEEN 2 AND 6 THEN 'parcelado'
ELSE 'parcelamento longo'
END AS tipo_pagamento
FROM public.olist_order_payments_dataset op
ORDER BY parcelas DESC;
