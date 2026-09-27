-- ============================================
-- BLOCO D - Subqueries
-- ============================================

-- 1. Clientes com gasto total acima da média geral de gasto por cliente.
-- Pergunta de negócio: quais clientes gastaram mais do que a média de gasto de todos os clientes?

-- Passo 1: calcula o gasto total de cada cliente (soma de preço + frete de todos os itens comprados)
-- Passo 2: compara esse gasto com a média geral de gasto entre todos os clientes
SELECT 
    gasto_cliente.customer_id,
    gasto_cliente.gasto_total
FROM (
    SELECT 
        c.customer_id,
        SUM(oi.price::numeric + oi.freight_value::numeric) AS gasto_total
    FROM public.olist_customers_dataset c
    JOIN public.olist_orders_dataset o 
        ON c.customer_id = o.customer_id
    JOIN public.olist_order_items_dataset oi 
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) AS gasto_cliente
WHERE gasto_cliente.gasto_total > (
    SELECT AVG(media_gasto.gasto_total)
    FROM (
        SELECT 
            c.customer_id,
            SUM(oi.price::numeric + oi.freight_value::numeric) AS gasto_total
        FROM public.olist_customers_dataset c
        JOIN public.olist_orders_dataset o 
            ON c.customer_id = o.customer_id
        JOIN public.olist_order_items_dataset oi 
            ON o.order_id = oi.order_id
        GROUP BY c.customer_id
    ) AS media_gasto
)
ORDER BY gasto_cliente.gasto_total DESC;


-- 2. Produtos que nunca receberam avaliação.
-- Pergunta de negócio: quais produtos foram vendidos mas nunca receberam nenhuma avaliação de cliente?

-- Pega todos os produtos e exclui aqueles cujo product_id aparece em algum pedido que tem review
SELECT 
    p.product_id
FROM public.olist_products_dataset p
WHERE p.product_id NOT IN (
    SELECT oi.product_id
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_order_reviews_dataset r 
        ON oi.order_id = r.order_id
);


-- 3. Vendedores que vendem produtos de mais de 5 categorias diferentes.
-- Pergunta de negócio: quais vendedores comercializam produtos de mais de 5 categorias diferentes?

-- Passo 1: pega as combinações únicas de vendedor + categoria (sem repetir a mesma categoria
-- várias vezes pelo mesmo vendedor, já que ele pode ter vendido vários itens da mesma categoria)
-- Passo 2: conta quantas categorias diferentes cada vendedor tem e filtra os que têm mais de 5
SELECT 
    vendedor_categoria.seller_id,
    COUNT(vendedor_categoria.categoria) AS qtd_categorias
FROM (
    SELECT DISTINCT
        oi.seller_id,
        p.product_category_name AS categoria
    FROM public.olist_order_items_dataset oi
    JOIN public.olist_products_dataset p 
        ON oi.product_id = p.product_id
) AS vendedor_categoria
GROUP BY vendedor_categoria.seller_id
HAVING COUNT(vendedor_categoria.categoria) > 5
ORDER BY qtd_categorias DESC;


-- 4. Pedidos em que o frete total foi maior que o valor total dos itens.
-- Pergunta de negócio: em quais pedidos o cliente pagou mais de frete do que o valor dos produtos?

-- Passo 1: soma o valor dos itens e o valor do frete de cada pedido
-- Passo 2: filtra os pedidos onde o frete total ficou maior que o valor dos itens
SELECT 
    pedido_valores.order_id,
    pedido_valores.valor_itens,
    pedido_valores.valor_frete
FROM (
    SELECT 
        oi.order_id,
        SUM(oi.price::numeric) AS valor_itens,
        SUM(oi.freight_value::numeric) AS valor_frete
    FROM public.olist_order_items_dataset oi
    GROUP BY oi.order_id
) AS pedido_valores
WHERE pedido_valores.valor_frete > pedido_valores.valor_itens
ORDER BY pedido_valores.valor_frete DESC;
