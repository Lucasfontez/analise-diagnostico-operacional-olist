/*
vw_item_frete, fonte do Power BI (página 2: peso do frete por região)

GRÃO: 1 linha por ITEM de pedido (tabela order_items).

Por que item, e não pedido? Porque a definição de frete que validei mede o
frete sobre o preço NO ITEM. Quando tentei somar frete e preço por pedido,
o número caiu pela metade (49,7% virou 22,7%). Um pedido junta o preço de
vários itens mas costuma ter um frete só, então frete / preço_somado fica
artificialmente baixo. Foi o próprio dado que me forçou a separar o grão
por isso esta view existe à parte da vw_pedido_analise. Cada natureza de
número no seu grão certo.

DEFINIÇÃO DO PESO DO FRETE (a parte que MAIS confunde!!! Leia com atenção):

frete_pct = AVG(frete_item / preco_item) -> peso no ITEM TÍPICO = 49,7% (Norte)

OBS: NÃO SUM(frete) / SUM(preco) -> peso AGREGADO = 22,7% (Norte)

As duas contas estão corretas, mas respondem perguntas DIFERENTES:

	49,7% = "no item médio do Norte, o frete equivale a ~50% do preço"

			(é esta que sustenta a tese, a definição validada)

	22,7% = "de cada real em produto vendido no Norte, ~23% foi frete"
	
            (o agregado, fica no bolso como resposta alternativa)

AVG(frete/preço) é sensível a item barato a um produto de R$10 com R$8 de frete vira 80% e
puxa a média pra cima. Por isso o número se chama "item típico", não
"metade do faturamento". Nomear ele certo blinda o achado na consulta.

O QUE ESTA VIEW PROVA (validada de forma independente no Excel):
AVG(frete/preço) por região -> Norte 49,7%...Sudeste 29,1%
*/

CREATE OR REPLACE VIEW vw_item_frete AS
SELECT
    i.order_id,
    i.order_item_id,
    i.price          AS preco_item,
    i.freight_value  AS frete_item,
    c.customer_state AS uf,
    reg.regiao       AS regiao
FROM order_items i
JOIN orders o    ON o.order_id    = i.order_id
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN regioes reg ON reg.uf   = c.customer_state;

SELECT * FROM vw_item_frete LIMIT 100;

-- frete_pct = AVG(frete_item / preco_item): peso do frete no ITEM TÍPICO.
-- Não confundir com SUM(frete)/SUM(preco) (=22,7% Norte), que é o peso AGREGADO.

SELECT
    regiao,
    ROUND(AVG(frete_item / preco_item) * 100, 1) AS frete_pct
FROM vw_item_frete
WHERE preco_item > 0
GROUP BY regiao
ORDER BY frete_pct DESC;

/*
Repare bem, SEM filtro de status 'delivered', e isso é de propósito. A análise
original do frete varreu TODOS os itens (112.650 o dataset inteiro), não
só os entregues. Pra o número casar com o que validei, esta view tem que
olhar o mesmo universo por completo. Faz sentido de negócio também, onde frete é cobrado
independente de o pedido acabar entregue, cancelado ou não.
*/
