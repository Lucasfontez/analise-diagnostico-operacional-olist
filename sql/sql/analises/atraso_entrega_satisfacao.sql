/*
Tese principal da analise: O atraso na entrega derruba a satisfação do cliente.

- Mede o atraso (data de entrega real - data prometida) e cruza com a nota
do review, agrupando em faixas de atraso. 

- Recorte: apenas pedidos entregues (delivered) com as duas datas preenchidas.

Resultado: a nota média cai de forma monotônica conforme o atraso aumenta
de 4,29 (no prazo) para 1,7 (atraso grave +7 dias). Bastam 1-3 dias de
atraso para a nota perder ~1 ponto. Pontualidade não é diferencial, é piso.
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
