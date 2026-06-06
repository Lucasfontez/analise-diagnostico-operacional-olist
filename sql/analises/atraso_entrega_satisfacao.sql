/*
Tese principal: o atraso na entrega derruba a satisfação do cliente.

Calculei o atraso como a diferença entre a data de entrega real e a data
prometida, e cruzo junto com a nota do review, agrupando em faixas de atraso.

Observação: Só pedidos entregues (delivered) com as duas datas preenchidas.

Insight: a nota cai de forma consistente conforme o atraso piora, de 4,29
(no prazo) para 1,7 (atraso grave, +7 dias). O salto mais revelador é logo
no início, onde basta 1 a 3 dias de atraso para a nota perder um ponto inteiro
(4,29 -> 3,29). Ou seja, não existe "atraso pequeno e inofensivo"
pontualidade não é diferencial, é piso.
*/

WITH Entregas AS (
SELECT
	o.order_id AS id_pedido,
	r.review_score AS avaliacao_pedido,
	(o.order_delivered_customer_date::DATE - 
	o.order_estimated_delivery_date::DATE) AS dias_atraso
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL 
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
	ROUND(AVG(dias_atraso), 1) AS atraso_medio_dias
FROM Entregas
GROUP BY faixa_atraso
ORDER BY faixa_atraso;
	
