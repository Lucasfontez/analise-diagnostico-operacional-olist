/*
Tese principal da analise: O atraso na entrega derruba a satisfação do cliente.

- Mede o atraso (data de entrega real - data prometida) e cruza com a nota
do review, agrupando em faixas de atraso. 

- Recorte: apenas pedidos entregues (delivered) com as duas datas preenchidas.

Resultado: a nota média cai de forma monotônica conforme o atraso aumenta
de 4,29 (no prazo) para 1,7 (atraso grave +7 dias). Bastam 1-3 dias de
atraso para a nota perder ~1 ponto. Pontualidade não é diferencial, é piso.
*/

WITH Entregas AS (
SELECT
	o.order_id AS id_pedido,
	r.review_score AS avaliacao_pedido,
	(o.order_delivered_customer_date::DATE - 
	o.order_estimated_delivery_date::DATE) AS dias_atraso
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
WHERE
	o.order_status = 'delivered'
	AND o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
	CASE 
		WHEN dias_atraso <= 0 THEN '1. Dentro do prazo ou adiantado'
		WHEN dias_atraso BETWEEN 1 AND 3 THEN '2. Atraso leve (1-3 dias)'
		WHEN dias_atraso BETWEEN 4 AND 7 THEN '3. Atraso moderado (4-7 dias)'
		ELSE '4. Atraso grave (+7 dias)'
	END AS faixa_atraso,
	COUNT(*) AS qtd_pedidos,
	ROUND(AVG(avaliacao_pedido), 2) AS nota_media,
	ROUND(AVG(avaliacao_pedido), 1) AS atraso_medio_dias
FROM Entregas
GROUP BY faixa_atraso
ORDER BY faixa_atraso;
	
