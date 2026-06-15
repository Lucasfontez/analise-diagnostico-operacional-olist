# Dashboard — Power BI

Documentação do modelo de dados, das medidas DAX e das decisões de construção do
dashboard. Todos os números aqui já vêm validados de forma independente no Excel (ver a
seção **Validação cruzada** no README da raiz); este documento foca no **como**
e no **porquê** de cada escolha de modelagem.

---

## 1. Fonte de dados: duas views, não uma

O dashboard consome **duas views** do PostgreSQL, em grãos diferentes:

| View | Grão | Tabela no modelo | Sustenta |
|---|---|---|---|
| `vw_pedido_analise` | 1 linha por **pedido** | `Pedidos` | Tese principal (atraso × satisfação) e tempo de entrega |
| `vw_item_frete` | 1 linha por **item** | `Frete` | Análise do peso do frete por região |

**Por que duas, e não uma view achatada:** o frete só fecha em grão de item. A
métrica validada é a média da proporção `frete/preço` calculada **item a item**
(49,7% no Norte). Esse número não pode ser reconstruído a partir de dados agregados
por pedido — um pedido junta o preço de vários itens mas costuma ter um frete só,
então `frete / preço_somado` cai artificialmente (vira ~22,7%). A tentativa inicial
foi uma view única em grão de pedido; a validação contra o Excel expôs a divergência
e forçou a separação. Cada natureza de número no seu grão certo.

## 2. Modelo: star schema

```
            ┌───────────────┐
            │  dim_regiao   │   (5 linhas: uma por região)
            └───────┬───────┘
                    │ 1
        ┌───────────┴───────────┐
        │ N                     │ N
 ┌──────┴──────┐         ┌──────┴──────┐
 │  Pedidos    │         │   Frete     │
 │ (pedido)    │         │  (item)     │
 └─────────────┘         └─────────────┘
```

`dim_regiao` no centro, ligada por relacionamento **um-para-muitos** a
`Pedidos[regiao]` e a `Frete[regiao]`. É o eixo de filtro comum: selecionar uma
região filtra os dois fatos de uma vez, de forma consistente — o que não
aconteceria se cada fato carregasse sua própria coluna de região solta.

A `dim_regiao` foi derivada no Power Query a partir da tabela `regioes` do banco
(27 UFs), reduzida a **5 linhas únicas** de região, já que no dashboard o corte é
por região, não por UF.

## 3. Transformações no Power Query

**Coluna de ordenação `ordem_faixa`.** A coluna `faixa_atraso` é texto, e o Power BI
a ordenava em ordem alfabética — "+7 dias" vinha antes de "No prazo", bagunçando o
eixo do gráfico-âncora. Criei uma coluna condicional `ordem_faixa` com quatro regras
e configurei `faixa_atraso` para ordenar por ela (**Sort by column**):

| faixa_atraso | ordem_faixa |
|---|---|
| No prazo | 1 |
| 1–3 dias | 2 |
| 4–7 dias | 3 |
| +7 dias | 4 |

Assim o eixo segue a severidade real do atraso, não o alfabeto.

## 4. Medidas DAX

Todas centralizadas numa tabela dedicada **`0_Medidas`** (o prefixo `0_` mantém ela
no topo do painel de campos, separando medida de coluna).

### Nota Média
```dax
Nota Média = AVERAGE(Pedidos[nota])
```
Média da nota de avaliação. É o eixo Y do gráfico-âncora.

### % Atrasos
```dax
% Atrasos =
DIVIDE(
    CALCULATE(COUNTROWS(Pedidos), Pedidos[dias_atraso] > 0),
    COUNTROWS(Pedidos)
)
```
Proporção de pedidos entregues **após** a data prometida (`dias_atraso > 0`).
Retorna **~6,77%**. `DIVIDE` em vez de `/` para tratar denominador zero sem erro.
Número-chave de contexto: a maioria dos pedidos chega no prazo — o atraso é minoria,
mas quando acontece, derruba a nota com força.

### Qtd Pedidos
```dax
Qtd Pedidos = COUNTROWS(Pedidos)
```
Total de pedidos no recorte (entregues, com as duas datas preenchidas): **~97 mil**.
Serve de denominador e de card de volume.

### % Frete
```dax
% Frete = AVERAGEX(Frete, DIVIDE(Frete[frete_item], Frete[preco_item]))
```
**A medida mais delicada do modelo.** `AVERAGEX` itera **item a item**, calcula a
razão `frete/preço` de cada item e só então tira a média — reproduzindo exatamente a
métrica validada (`AVG(frete/preço)` por item no SQL). `DIVIDE` faz o papel do
`NULLIF` da query: blinda contra item de preço zero.

> Interpretação correta: "no item típico, o frete equivale a X% do preço."
> **Não** é "X% do faturamento" — isso seria `SUM(frete)/SUM(preço)`, outro número
> (22,7% no Norte). As duas contas estão certas e respondem perguntas diferentes;
> esta é a que sustenta a tese.

Por que `AVERAGEX` e não uma coluna calculada + `AVERAGE`: mantém o cálculo como
**medida**, recalculada dinamicamente conforme o filtro de `dim_regiao` — em vez de
um valor fixo gravado linha a linha.

### Tempo Médio Entrega
```dax
Tempo Médio Entrega = AVERAGE(Pedidos[dias_entrega])
```
Tempo absoluto da compra até a entrega (não o atraso). É o que revela a lentidão
estrutural do Norte/Nordeste mesmo quando entregam dentro do prazo prometido.

## 5. Páginas do dashboard

### Página 1 — Atraso × Satisfação (tese principal)
- **Gráfico-âncora:** `Nota Média` por `faixa_atraso` — mostra a queda contínua de
  **4,29** (no prazo) a **1,70** (+7 dias), ordenada por `ordem_faixa`.
- **Cards:** `Qtd Pedidos`, `Nota Média` geral, `% Atrasos`.

### Página 2 — Frete e tempo por região (camada de apoio)
- `% Frete` por região (`dim_regiao` no eixo) — Norte 49,7% … Sudeste 29,1%.
- `Tempo Médio Entrega` por região — Norte ~22,5 dias vs Sudeste ~10,7.
- **Gráfico combinado** tempo × nota por região (eixo duplo) — evidencia que quanto
  maior o tempo absoluto de espera, pior a nota.

## 6. Decisões e armadilhas (resumo para defesa)

- **Grão do frete:** item, não pedido. Agregar por pedido derruba a métrica pela
  metade. Pego na validação contra Excel.
- **`AVERAGEX` vs coluna calculada:** medida dinâmica que respeita o filtro de
  região, em vez de valor congelado.
- **Eixo de texto desordenado:** resolvido com coluna numérica + Sort by column.
- **"Item típico" vs "agregado":** dois números corretos, perguntas diferentes —
  nomear a métrica certo blinda o achado.
