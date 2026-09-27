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

-- Passo 1: pega cada combinação única de vendedor + pedido + nota
-- (isso evita contar a mesma nota mais de uma vez quando o pedido tem vários itens)
-- Passo 2: calcula a média por vendedor em cima dessa lista já sem repetição
SELECT 
    vendedor_nota.seller_id,
    AVG(vendedor_nota.review_score::numeric) AS nota_media
FROM (
    SELECT DISTINCT
        oi.seller_id,
        oi.order_id,
        r.review_score
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_order_reviews_dataset r 
        ON oi.order_id = r.order_id
) AS vendedor_nota
GROUP BY vendedor_nota.seller_id
HAVING AVG(vendedor_nota.review_score::numeric) < 3
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

-- Passo 1: soma as parcelas de cada pedido (um pedido pode ter mais de uma forma
-- de pagamento, então somamos tudo para saber o total de parcelas daquele pedido)
-- Passo 2: junta essa informação com produtos, pegando cada pedido só uma vez por categoria
-- Passo 3: calcula a média de parcelas por categoria
SELECT 
    pedido_categoria.categoria,
    AVG(pedido_categoria.parcelas::numeric) AS media_parcelas
FROM (
    SELECT DISTINCT
        p.product_category_name AS categoria,
        oi.order_id,
        parcelas_por_pedido.parcelas
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_products_dataset p 
        ON oi.product_id = p.product_id
    JOIN (
        SELECT 
            order_id,
            SUM(payment_installments::numeric) AS parcelas
        FROM public.olist_order_payments_dataset
        GROUP BY order_id
    ) AS parcelas_por_pedido
        ON oi.order_id = parcelas_por_pedido.order_id
) AS pedido_categoria
GROUP BY pedido_categoria.categoria
ORDER BY media_parcelas DESC;
