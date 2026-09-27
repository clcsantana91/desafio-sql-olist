-- ============================================
-- BLOCO F - CTE / TABELA TEMPORÁRIA
-- ============================================

-- 1. Faturamento mensal por estado e variação percentual de um mês para o outro.
-- Pergunta de negócio: como o faturamento de cada estado variou de um mês para o outro?
WITH faturamento_mensal AS (
    SELECT
        c.customer_state AS estado,
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS mes,
        SUM(oi.price::numeric) AS faturamento
    FROM public.olist_orders_dataset o
    JOIN public.olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN public.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_state,
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp))
SELECT
    estado,
    mes,
    faturamento,
    LAG(faturamento) OVER (
        PARTITION BY estado
        ORDER BY mes
    ) AS faturamento_mes_anterior,
    (
        (faturamento - LAG(faturamento) OVER (
            PARTITION BY estado
            ORDER BY mes
        ))
        / NULLIF(LAG(faturamento) OVER (
            PARTITION BY estado
            ORDER BY mes
        ), 0)
    ) * 100 AS variacao_percentual
FROM faturamento_mensal
ORDER BY estado, mes;


-- 2. Volume de avaliações e nota média por categoria.
-- Pergunta de negócio: quais categorias possuem pior reputação considerando nota média e volume de avaliações?
WITH avaliacoes_categoria AS (
    SELECT
        p.product_category_name AS categoria,
        COUNT(r.review_id) AS quantidade_avaliacoes,
        AVG(r.review_score::numeric) AS nota_media
    FROM public.olist_products_dataset p
    JOIN public.olist_order_items_dataset oi
        ON p.product_id = oi.product_id
    JOIN public.olist_order_reviews_dataset r
        ON oi.order_id = r.order_id
    GROUP BY p.product_category_name
)
SELECT
    categoria,
    quantidade_avaliacoes,
    nota_media
FROM avaliacoes_categoria
WHERE quantidade_avaliacoes >= 100
ORDER BY nota_media;


-- 3. Frete médio por estado comparado com a média geral.
-- Pergunta de negócio: quais estados possuem frete médio acima ou abaixo da média geral?
WITH frete_estado AS (
    SELECT
        c.customer_state AS estado,
        AVG(oi.freight_value::numeric) AS frete_medio
    FROM public.olist_orders_dataset o
    JOIN public.olist_customers_dataset c
        ON o.customer_id = c.customer_id
    JOIN public.olist_order_items_dataset oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_state)
SELECT
    estado,
    frete_medio,
    (SELECT AVG(frete_medio) FROM frete_estado) AS media_geral,
    CASE
        WHEN frete_medio > (SELECT AVG(frete_medio) FROM frete_estado)
            THEN 'acima da média'
        WHEN frete_medio < (SELECT AVG(frete_medio) FROM frete_estado)
            THEN 'abaixo da média'
        ELSE 'igual à média'
    END AS comparacao
FROM frete_estado
ORDER BY frete_medio DESC;
