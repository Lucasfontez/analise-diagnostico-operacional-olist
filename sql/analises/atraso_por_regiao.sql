/*
Agrupa a análise de atraso x satisfação por região do Brasil, usando a dimensão
de regioes (JOIN por uf). Uma amostra instavel da análise por estado e limpa
onde nos lista 5 grupos robustos no lugar de 27 UFS, com várias com pouco volume.

Observação: Somente com pedidos entregues (delivered) com as duas datas preenchidas.

Insight: Aqui conseguimos ver o ponto mais intrigante do projeto. O Norte (4,03) e Nordeste
(3,97) têm as piores notas! Mesmo entregando bem antes do prazo prometido
(atraso médio de -15,7 e -11,4 dias). Ou seja, não é atraso que derruba a nota
dessas regiões, elas cumprem o prazo e ainda assim insatisfazem.

Isso abre uma nova questão, onde se não é o atraso, o que é? Hipóteses a investigar:
O tempo total de espera (prazo folgado pode esconder entrega lenta) e o peso do
frete. Ver tempo_entrega_por_regiao.sql e frete_por_regiao.sql.
*/

WITH Atraso_por_Regiao AS (
SELECT
	o.order_id AS id_pedido,
	rg.regiao AS regiao,
	r.review_score AS avaliacao_pedido,
	(o.order_delivered_customer_date::DATE -
    o.order_estimated_delivery_date::DATE) AS dias_atraso
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN regioes rg ON rg.uf = c.customer_state
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
	AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
	regiao,
	COUNT(*) AS qtd_pedidos,
	ROUND(AVG(avaliacao_pedido), 2) AS nota_media,
	ROUND(AVG(dias_atraso), 1) AS atraso_medio_dias
FROM Atraso_por_Regiao
GROUP BY regiao
ORDER BY nota_media ASC;
