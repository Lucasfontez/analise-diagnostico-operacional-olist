/*
Quebra a análise de atraso x satisfação por estado (UF).

- Motivo: investigar se o impacto do atraso varia geograficamente.

Resultado: revelou que estados com poucos pedidos (RR, AP, AC) geram nota
média instável, o que motivou a análise agregada por região.
*/

WITH Atraso_por_Estado AS (
SELECT
	o.order_id AS id_pedido,
	c.customer_state AS cliente_uf,
    r.review_score AS avaliacao_pedido,
    (o.order_delivered_customer_date::DATE -
     o.order_estimated_delivery_date::DATE) AS dias_atraso
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE
	o.order_status = 'delivered'
	AND o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    cliente_uf AS estado,
    COUNT(*) AS qtd_pedidos,
    ROUND(AVG(avaliacao_pedido), 2) AS nota_media,
    ROUND(AVG(dias_atraso), 1) AS atraso_medio_dias
FROM Atraso_por_Estado
GROUP BY cliente_uf 
ORDER BY nota_media DESC; 
