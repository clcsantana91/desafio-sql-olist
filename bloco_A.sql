-- 1. Listar os 20 pedidos com status 'delivered' mais recentes,
-- ordenados pela data de entrega.
SELECT *
FROM public.olist_orders_dataset
WHERE order_status = 'delivered'
ORDER BY order_delivered_customer_date DESC
LIMIT 20;
