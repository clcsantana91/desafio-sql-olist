-- ============================================
-- BLOCO E - CASE WHEN
-- ============================================

-- 1. Classificar pedidos por prazo de entrega.
-- Pergunta de negócio: quais pedidos foram adiantados, entregues no prazo ou atrasados?
SELECT 
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE
        WHEN order_delivered_customer_date::timestamp < order_estimated_delivery_date::timestamp THEN 'adiantado'
        WHEN order_delivered_customer_date::timestamp = order_estimated_delivery_date::timestamp THEN 'no prazo'
        ELSE 'atrasado'
    END AS classificacao
FROM public.olist_orders_dataset
WHERE order_delivered_customer_date <> ''
  AND order_estimated_delivery_date <> '';

-- 2. Classificar clientes por faixa de gasto total.
-- Pergunta de negócio: quais clientes são bronze, prata ou ouro?
SELECT 
    o.customer_id,
    SUM(oi.price::numeric) AS gasto_total,
    CASE
        WHEN SUM(oi.price::numeric) < 500 THEN 'bronze'
        WHEN SUM(oi.price::numeric) < 1500 THEN 'prata'
        ELSE 'ouro'
    END AS classificacao
FROM public.olist_orders_dataset o
JOIN public.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id;

-- 3. Classificar produtos por faixa de peso.
-- Pergunta de negócio: quais produtos são leves, médios ou pesados?
SELECT 
    product_id,
    product_weight_g,
    CASE
        WHEN product_weight_g::numeric < 1000 THEN 'leve'
        WHEN product_weight_g::numeric < 5000 THEN 'médio'
        ELSE 'pesado'
    END AS classificacao
FROM public.olist_products_dataset;

-- 4. Classificar pagamentos como à vista ou parcelado.
-- Pergunta de negócio: quais pagamentos são à vista e quais são parcelados?
SELECT 
    order_id,
    payment_type,
    payment_installments,
    CASE
        WHEN payment_installments::integer = 1 THEN 'à vista'
        WHEN payment_installments::integer > 6 THEN 'parcelado longo'
        ELSE 'parcelado'
    END AS classificacao
FROM public.olist_order_payments_dataset;
