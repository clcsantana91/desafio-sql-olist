-- ============================================
-- BLOCO A - SELECT BÁSICO
-- ============================================

-- 1. Listar os 20 pedidos com status 'delivered' mais recentes, ordenados pela data de entrega.
-- Pergunta de negócio: quais foram as entregas mais recentes concluídas com sucesso?
SELECT *
FROM public.olist_orders_dataset
WHERE order_status = 'delivered'
ORDER BY NULLIF(order_delivered_customer_date, '')::timestamp DESC
LIMIT 20;

-- 2. Listar todos os produtos de uma categoria específica, usando a tabela de tradução
-- para filtrar pelo nome em português.
-- Pergunta de negócio: quais produtos pertencem a uma determinada categoria (ex: beleza e saúde)?
SELECT p.*, t.product_category_name_english
FROM public.olist_products_dataset p
JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name = 'beleza_saude';

-- 3. Listar os métodos de pagamento distintos utilizados na base.
-- Pergunta de negócio: quais formas de pagamento os clientes utilizam na plataforma?
SELECT DISTINCT payment_type
FROM public.olist_order_payments_dataset;

-- 4. Listar os produtos com peso acima de 10kg, ordenados do mais pesado para o mais leve.
-- Pergunta de negócio: quais são os produtos mais pesados vendidos na plataforma
-- (relevante para logística e frete)?
SELECT *
FROM public.olist_products_dataset
WHERE product_weight_g::numeric > 10000
ORDER BY product_weight_g::numeric DESC;
