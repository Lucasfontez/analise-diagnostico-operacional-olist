# Recomendações estratégicas

Esta camada traduz os achados do projeto. Cada recomendação parte de um
problema **medido no dado**, declara a hipótese por trás, propõe uma ação e define
**como medir se ela funcionou**. Nada aqui assume custo ou margem que o dataset não
tem — onde a análise esbarra nesse limite, está dito explicitamente.

> Princípio: os dados mostram **correlação** forte e consistente entre tempo, frete
> e satisfação, não causa isolada. Por isso toda recomendação abaixo deve ser
> validada por **piloto / teste controlado** antes de rollout amplo.

---

## 1. Trocar o KPI de logística: Medir tempo absoluto, não só "% no prazo"

**Problema.** Apenas **6,77%** dos pedidos atrasam, então um indicador de "% no prazo"
mostra a operação ~93% saudável. Mas esse número esconde o real: Norte e Nordeste
esperam **22,5** e **19,9 dias** e estão entre os mais insatisfeitos (4,03 e 3,97) —
*mesmo cumprindo o prazo prometido*. O prazo folgado dessas regiões maquia a lentidão.

**Hipótese.** Gerida por "% no prazo", a logística parece performar enquanto perde
satisfação nas regiões distantes. Medir o **tempo absoluto** (da compra à entrega)
expõe o problema que o KPI atual abafa.

**Ação.** Adotar o tempo absoluto de entrega por região, mediana e P90 de
`dias_entrega`, como KPI **primário** de logística, rebaixando "% no prazo" a
secundário. Definir metas de tempo por região, não uma média nacional única.

**Como medir o sucesso.** Queda do P90 de `dias_entrega` em Norte/Nordeste, com a
nota média dessas regiões subindo na esteira.

## 2. Tratar pontualidade como piso: atacar o atraso desde o primeiro dia

**Problema.** A nota cai **um ponto inteiro** já em 1–3 dias de atraso (4,29 → 3,29)
e despenca a 1,7 no atraso grave. Não existe "atraso pequeno e inofensivo". Mas o
atraso é **minoria** (6,77%), ou seja, é um problema concentrado e gerenciável.

**Hipótese.** Por ser pouco volume e muito impacto, uma intervenção focada nos
pedidos em risco de atraso tem ROI alto: evita estrago de reputação desproporcional
ao esforço.

**Ação.** Criar gatilho operacional para pedidos em risco (monitorar contra
`shipping_limit_date` e `order_estimated_delivery_date`), com priorização de despacho
e comunicação proativa ao cliente antes de o prazo estourar.

**Como medir o sucesso.** `% Atrasos` caindo abaixo dos 6,77% atuais, nota média do
grupo de pedidos historicamente propenso a atraso.

## 3. Aproximar a oferta das regiões distantes (atacar a raiz, não o sintoma)

**Problema.** Norte e Nordeste sofrem **tempo alto e frete alto ao mesmo tempo**
(frete = 49,7% do preço no Norte vs 29,1% no Sudeste). Os dois sintomas apontam para
a mesma origem de vendedores concentrados no Sudeste, então o produto viaja mais é o
que custa mais tempo *e* mais frete simultaneamente.

**Hipótese.** Se a causa é distância, mexer no prazo prometido não resolve (só maquia).
Aumentar a densidade de sellers regionais ou criar um hub de distribuição encurtaria
tempo **e** frete de uma vez.

**Ação.** Recrutar/incentivar sellers nas regiões Norte/Nordeste e avaliar a
viabilidade de um centro de distribuição regional, começando por um **piloto** numa
praça, não por investimento amplo de imediato.

**Como medir o sucesso.** Redução conjunta de tempo médio e de `% Frete` na praça do
piloto, com a nota média acompanhando.

> ⚠️ **É a recomendação mais ambiciosa e a de menor lastro no dado.** A relação
> distância -> tempo/frete é fortíssima na correlação, mas o dataset não prova a
> causa isoladamente, nem traz o custo de abrir um CD. Por isso, piloto e medição
> antes de qualquer aposta grande.

## 4. Frete como alavanca de curto prazo nas regiões onde ele mais pesa

**Problema.** No Norte o frete consome metade do preço do item. O cliente sente isso
no bolso numa região que já está insatisfeita, uma dor imediata enquanto a solução
estrutural (recomendação 3) amadurece.

**Hipótese.** Uma política de frete direcionada (subsídio parcial, ou frete grátis
acima de um ticket) poderia aliviar a insatisfação no curto prazo nas regiões de
maior peso de frete.

**Ação.** Testar uma política de frete segmentada por região, em A/B controlado.

**Como medir o sucesso.** Elasticidade de variação de conversão e de nota contra o
custo do subsídio.

> ⚠️ **Limite explícito:** sem dado de margem/custo, este projeto **não consegue
> dimensionar o trade-off financeiro** dessa política, só sinalizar a oportunidade.
> Quantificar o retorno exigiria os dados de custo que, por escolha de método, ficaram
> de fora.

---

## Priorização sugerida

| Recomendação | Custo/esforço | Prazo | Lastro no dado |
|---|---|---|---|
| 1. KPI de tempo absoluto | Baixo | Curto | Forte |
| 2. Gatilho de atraso | Baixo–médio | Curto | Forte |
| 3. Aproximar oferta (CD/sellers) | Alto | Longo | Médio (correlação) |
| 4. Política de frete | Médio | Curto–médio | Parcial (falta custo) |

As recomendações 1 e 2 são **quick wins**: Baixo custo, lastro forte, retorno rápido.
A 3 é a aposta estrutural de longo prazo. A 4 depende de dados de custo que o projeto
não cobre. Começar pelo barato e bem-fundamentado, validar com piloto, e só então
escalar.

## Limites desta análise

- **Correlação, não causa.** Tempo, frete e nota andam juntos nas cinco regiões, mas
  o estudo não isola causalidade. As ações acima são hipóteses a testar, não verdades.
- **Sem custo/margem.** O projeto se sustenta só em dado medido (sem COGS inventado).
  Isso é uma força analítica, mas significa que o **retorno financeiro** das ações não
  é quantificável com os dados atuais.
- **Recorte temporal.** Dados de 2016–2018; padrões podem ter mudado.
