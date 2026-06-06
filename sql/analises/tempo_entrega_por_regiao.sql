/*
Mede o tempo TOTAL de espera do cliente (da compra até a entrega) por região,
e cruza com a nota. Diferente das análises de atraso, que comparam a entrega com
o prazo prometido, aqui calculo o tempo real vivido pelo cliente:

					data de entrega - data da compra.

Observação: só pedidos entregues (delivered) com as duas datas preenchidas.

Insight: Esse resultado fecha o mistério da análise por região. A nota acompanha
o tempo de espera quase perfeitamente, o Norte espera 22,5 dias (nota 4,03) e
Nordeste 19,9 (3,97), contra 10,7 do Sudeste (4,18). Mais que o dobro de espera.

A lição é que "entregar antes do prazo" engana, a Olist dá um prazo folgado para
o Norte/Nordeste, então tecnicamente cumpre o prazo, mas o cliente ainda espera
3 semanas. O que derruba a satisfação é o tempo ABSOLUTO, não o cumprimento do
prazo. Medir performance só por "% no prazo" esconde esse problema.
*/

WITH Tempo_Entrega AS (
SELECT
	o.order_id AS id_pedido,
	rg.regiao AS regiao,
	r.review_score AS avaliacao_pedido,
	(o.order_delivered_customer_date::DATE -
    o.order_purchase_timestamp::DATE) AS dias_entrega
FROM orders o
JOIN order_reviews r ON r.order_id = o.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN regioes rg ON rg.uf = c.customer_state
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
	AND o.order_purchase_timestamp IS NOT NULL
)
SELECT
	regiao,
	COUNT(*) AS qtd_pedidos,
	ROUND(AVG(dias_entrega), 1) AS tempo_medio_dias,
	ROUND(AVG(avaliacao_pedido), 2) AS nota_media
FROM Tempo_Entrega
GROUP BY regiao
ORDER BY tempo_medio_dias DESC;
