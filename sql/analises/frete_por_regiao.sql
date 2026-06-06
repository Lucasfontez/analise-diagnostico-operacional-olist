/*
Busquei medir o peso do frete por região, onde valor médio absoluto e frete como % do preço
(média das proporções item a item, com NULLIF para evitar divisão por zero).
O frete_value está em order_items, então a análise parte do item de pedido.

Insight: o frete fecha a tese, as regiões mais lentas e insatisfeitas são também
as que pagam frete proporcionalmente mais caro. O Norte paga 49,7% do valor do
produto só em frete (vs. 29,1% no Sudeste). Tempo de espera, peso do frete e
insatisfação andam juntos, na mesma ordem, nas cinco regiões.

Leitura de negócio pelo insight: o problema do Norte/Nordeste não é atraso pontual, é
estrutural os vendedores se concentram no Sudeste, então o produto viaja mais,
o que custa mais tempo e mais frete ao mesmo tempo. As duas dores somadas
derrubam a satisfação. Para melhorar, não adianta mexer no prazo, tem que
aproximar a oferta dessas regiões (vendedores regionais, centros de distribuição).
*/

WITH Frete_Regiao AS (
SELECT
	rg.regiao AS regiao,
	oi.price AS preco,
	oi.freight_value AS frete
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN regioes rg ON rg.uf = c.customer_state
)
SELECT
	regiao,
	COUNT(*) AS qtd_itens,
	ROUND(AVG(frete), 2) AS frete_medio,
    ROUND(AVG(preco), 2) AS preco_medio,
    ROUND(AVG(frete / NULLIF(preco, 0)) * 100, 1) AS frete_pct_preco
FROM Frete_Regiao
GROUP BY regiao
ORDER BY frete_pct_preco DESC;
