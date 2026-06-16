# SQL: índice e ordem de execução

Este diretório contém todo o trabalho de banco do projeto, em três camadas:
**setup** (criar e carregar), **análises** (as queries que sustentam a tese) e
**views** (a camada que alimenta o Power BI).

## 1. Setup

| Arquivo | O que faz |
|---|---|
| `01_criacao_tabelas.sql` | Cria as 9 tabelas do dataset (sem constraints, para tolerar dado sujo na carga). |
| `02_importacoes.sql` | Carga dos CSVs via `COPY` nativo do PostgreSQL (o wizard do DBeaver corrompia campos com texto livre). |
| `03_chaves_indices.sql` | Aplica PKs e índices nas colunas usadas em JOINs, após a carga. |
| `04_dimensao_regioes.sql` | Cria a dimensão `regioes` (de/para UF → região), base para agregar a análise. |

## 2. Análises (`analises/`) — a investigação, na ordem em que ela aconteceu

São independentes (cada uma roda sozinha), mas lidas nesta sequência elas contam
o raciocínio do projeto de ponta a ponta:

| Ordem | Arquivo | O que prova |
|---|---|---|
| 1 | `atraso_entrega_satisfacao.sql` | **Tese principal.** A nota cai de 4,29 (no prazo) a 1,7 (+7 dias). Pontualidade é piso. |
| 2 | `atraso_por_estado.sql` | Quebra por UF — expôs que estados de baixo volume (RR, AP, AC) geram nota instável. Motivou agregar por região. |
| 3 | `atraso_por_regiao.sql` | Agrega em 5 regiões. **Achado intrigante:** Norte e Nordeste têm as piores notas *entregando antes do prazo*. Se não é atraso, o que é? |
| 4 | `tempo_entrega_por_regiao.sql` | Resolve o mistério: é o **tempo absoluto** de espera (Norte 22,5 dias vs Sudeste 10,7), não o cumprimento do prazo. |
| 5 | `frete_por_regiao.sql` | **Camada de apoio.** O frete pesa mais nas mesmas regiões lentas/insatisfeitas (Norte 49,7% vs Sudeste 29,1%). |

## 3. Views (`analises/views/`) — camada de consumo do Power BI

| Arquivo | Grão | Alimenta |
|---|---|---|
| `vw_pedido_analise.sql` | 1 linha por **pedido** | Página 1 do dashboard (atraso × satisfação) |
| `vw_item_frete.sql` | 1 linha por **item** | Página 2 do dashboard (peso do frete) |

> **Por que dois grãos:** a métrica de frete é `AVG(frete/preço)` *por item* (o
> "item típico"). Calculá-la em grão de pedido derruba o número pela metade
> (49,7% → 22,7%), porque um pedido soma o preço de vários itens mas costuma ter
> um frete só. Detalhe no cabeçalho de `vw_item_frete.sql`.

## Nota de método

As análises observam **correlação** forte e consistente entre tempo, frete e
satisfação, mas **não afirmam causa isolada**, a relação está documentada nos
cabeçalhos de cada query, sem extrapolar o que o dado mostra.
