# Análise SQL — a investigação

As cinco queries em [`sql/analises/`](../sql/analises/) não são consultas soltas:
são os passos de uma investigação que começa numa tese simples e termina numa
explicação estrutural. Este documento conta essa jornada em prosa — cada query
respondeu uma pergunta e abriu a próxima. (O código e os comentários de cada uma
estão nos arquivos; aqui está o fio que os conecta.)

---

## 1. O ponto de partida — o atraso derruba a nota

**Query:** `atraso_entrega_satisfacao.sql`

A primeira pergunta era a tese: atraso na entrega prejudica a satisfação? Cruzando
o atraso de cada pedido (entrega real − data prometida) com a nota do review,
agrupado em faixas, a resposta veio limpa: a nota cai de forma contínua, de **4,29**
(no prazo) até **1,7** (atraso grave, +7 dias).

O detalhe mais revelador não é o fundo do poço, é o começo: bastam **1 a 3 dias** de
atraso para a nota perder um ponto inteiro (4,29 → **3,29**). Ou seja, não existe
"atraso pequeno e inofensivo" — pontualidade não é diferencial, é piso. Tese
confirmada. Mas confirmar não basta: onde, e por quê?

## 2. Será que varia por região? — a quebra por estado (e a armadilha)

**Query:** `atraso_por_estado.sql`

O passo natural foi quebrar por UF. A nota varia entre estados (de **4,25** em SP a
**3,84** em MA/AL), mas a query expôs algo mais importante que o ranking: um
**problema de método**. Estados de pouquíssimo volume — RR com 41 pedidos, AP com 66,
AC com 80 — apareciam lado a lado com SP (40 mil). Com tão poucos clientes, a nota
média desses estados é estatisticamente frágil: meia dúzia de reviews ruins muda a
média inteira.

Conclusão honesta: este recorte **não serve como conclusão final**. Ele serviu pra
algo melhor — mostrou que era preciso agregar em grupos robustos. Daí nasceu a
dimensão de regiões.

## 3. O paradoxo — as piores notas entregam adiantado

**Query:** `atraso_por_regiao.sql`

Agregando as 27 UFs em 5 regiões, a amostra ficou sólida — e apareceu o ponto mais
intrigante do projeto. Norte (**4,03**) e Nordeste (**3,97**) têm as piores notas.
Mas o atraso médio dessas regiões é **negativo**: −15,7 e −11,4 dias. Elas entregam
*duas semanas antes* do prazo prometido e, ainda assim, são as mais insatisfeitas.

Isso quebra a leitura ingênua da tese. Se essas regiões cumprem o prazo com folga e
mesmo assim insatisfazem, **não é o atraso que derruba a nota delas**. Então o que é?
A query não responde — ela levanta a pergunta certa. Duas hipóteses ficaram na mesa:
o tempo total de espera (e não o atraso relativo ao prazo) e o peso do frete.

## 4. A virada — não é o atraso, é o tempo absoluto

**Query:** `tempo_entrega_por_regiao.sql`

Aqui a medida muda: em vez de comparar a entrega com o prazo prometido, calculei o
tempo **real vivido pelo cliente** — da compra até a entrega. E o mistério se resolve.
A nota acompanha o tempo de espera quase perfeitamente: Norte espera **22,5 dias**
(nota 4,03), Nordeste **19,9** (3,97), contra **10,7** do Sudeste (4,18). Mais que o
dobro de espera.

A lição: "entregar antes do prazo" engana. A Olist dá um prazo **folgado** ao
Norte/Nordeste, então tecnicamente cumpre o combinado — mas o cliente ainda espera
três semanas. O que derruba a satisfação é o tempo **absoluto**, não o cumprimento do
prazo. E a consequência prática é direta: medir performance só por "% no prazo"
esconde exatamente esse problema. (É daqui que sai a recomendação nº 1.)

## 5. O fechamento — o frete confirma a raiz estrutural

**Query:** `frete_por_regiao.sql`

Faltava a segunda hipótese: o frete. Medindo o peso do frete sobre o preço (média
item a item), o padrão fecha o quadro — as regiões mais lentas e insatisfeitas são
também as que pagam frete proporcionalmente mais caro. O Norte gasta **49,7%** do
valor do produto só em frete, contra **29,1%** no Sudeste.

Tempo de espera, peso do frete e insatisfação andam juntos, na mesma ordem, nas cinco
regiões. Isso aponta para uma causa comum: os vendedores se concentram no Sudeste,
então o produto viaja mais — o que custa mais tempo **e** mais frete ao mesmo tempo.
As duas dores somadas derrubam a satisfação. Não é um atraso pontual a corrigir; é
uma questão estrutural de distância. (É daqui que saem as recomendações nº 3 e 4.)

---

## Síntese

A investigação caminhou da tese ao diagnóstico estrutural:

1. Atraso derruba a nota — e o estrago começa cedo (tese confirmada).
2. Quebrar por UF não conclui, mas revela que é preciso agregar.
3. Por região, surge o paradoxo: as piores notas entregam adiantado.
4. O paradoxo se resolve: o vilão é o tempo absoluto, não o atraso relativo.
5. O frete confirma a raiz: distância encarece tempo e frete juntos.

O que parecia "um problema de pontualidade" terminou como "um problema de
distribuição geográfica" — e essa diferença é o que separa tratar o sintoma de
tratar a causa.

## Nota de método

Todas as relações acima são **correlações** fortes e consistentes nas cinco regiões.
O estudo **não isola causalidade** — não afirma que o frete *causa* a insatisfação,
e sim que tempo, frete e nota se movem juntos por uma raiz provável comum (distância).
Essa fronteira está marcada nos cabeçalhos das queries e nas recomendações, sem
extrapolar o que o dado mostra.
