# Validação dos resultados

Antes de levar qualquer número pro dashboard, eu quis ter certeza de que as
queries estavam realmente certas — não dá pra apresentar "o Norte paga 50% de
frete" sem ter conferido isso por outro caminho. Então peguei a análise mais
importante e mais arriscada de errar (o frete por região, que envolve uma média
de proporção) e refiz a conta do zero, por fora do SQL.

## Como validei

A ideia era simples: se o SQL e um caminho totalmente independente chegarem no
mesmo número, dá pra confiar. Então exportei o dado cru — cada item de pedido com
sua região, preço e frete, sem nenhuma conta pronta — e joguei no Excel. Lá,
montei uma tabela dinâmica e recalculei na mão o frete médio, o preço médio e o
frete como % do preço por região. Depois coloquei os dois resultados lado a lado.

A diferença é que isso não é copiar o resultado do SQL e olhar — é refazer a
agregação com outra ferramenta, partindo do dado bruto. Se eu só tivesse exportado
o resultado pronto, não teria validado nada.

## O que deu

Os números bateram nas cinco regiões:

![Validação do frete por região no Excel](<img width="718" height="254" alt="Captura de tela 2026-06-03 175459" src="https://github.com/user-attachments/assets/c81f4f9d-9e17-4130-97a0-51ee7437cfc5" />)

A diferença nas casas decimais é só arredondamento. O frete médio e o preço médio
também bateram, o que valida tanto o numerador quanto o denominador do cálculo.

## O que aprendi no caminho

Duas coisas que só apareceram por causa da validação:

Existem itens com frete acima de 100% do preço — produtos baratos e leves enviados
pra longe, onde o frete custa mais que o próprio produto. Não é erro, é o dado
real, e ainda reforça a tese do frete desproporcional.

A tabela dinâmica mostrou uma linha "(vazio)" que me assustou no começo — parecia
que tinha item sem região. Investiguei e era só artefato visual do Excel (uma linha
em branco no fim do arquivo), não dado faltando. Confirmei que todos os ~112 mil
itens têm região atribuída, ou seja, a dimensão de regiões cobriu o dataset inteiro.

A planilha completa da validação está em `validacao_frete_regiao.xlsx`.
