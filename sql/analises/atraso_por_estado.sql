/*
Quebra a análise de atraso x satisfação por estado (UF), para ver se o
impacto do atraso varia geograficamente.

Observação: Somente pedidos entregues (delivered) com as duas datas preenchidas.

Insight: a nota varia entre estados (de 4,25 em SP a 3,84 em MA/AL), mas o
resultado expôs um problema de método mais importante que o próprio ranking onde
estados com pouquíssimos pedidos (RR com 41, AP com 66, AC com 80) aparecem
lado a lado com SP (40 mil), e suas notas são estatisticamente frágeis, onde com
poucos clientes mudam a média toda.

Por isso essa análise não serve como uma conclusão final, ela somente motivou agrupar os
estados em regiões (atraso_por_regiao.sql e a dimensão 04_dimensao_regioes),
onde a amostra fica robusta e a leitura, confiável.
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
