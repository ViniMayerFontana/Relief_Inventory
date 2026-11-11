<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

O catálogo de tudo o que o armazém conta. Triagem, pedidos e atendimento escolhem todos desta lista, então
mantê-la organizada mantém todo o resto organizado.

## Tipos de item e linhas de SKU

A lista tem dois níveis. Um **tipo de item** é a coisa que o armazém conta e pede (por exemplo "Fraldas de
recém-nascido"); o estoque é reunido por tipo de item. Sob cada tipo de item há uma ou mais **linhas de SKU**
(mostradas na tabela **Itens** do formulário) — os produtos específicos e os tamanhos de embalagem que contam como
aquele tipo de item, como o código de barras de uma marca específica. Todos que triam uma linha de SKU acabam
somando ao total do mesmo tipo de item.

Você precisa das permissões Gerenciar itens e Gerenciar tipos de item para abrir [Configurações → Lista mestra de
itens](/setup/items). Sem ambas, a página não abre — peça a um administrador.

## Encontrando um item

Digite na caixa **Buscar por ACS Item# ou tipo de item...** para estreitar a lista. Clique em um título de coluna
(**Categoria**, **ACS Item#**, **Tipo de item**, **Unidade**, **Ativo**) para ordenar por ela; clique de novo para
inverter. Um visto em **Ativo** significa que o tipo de item está em uso. Clique em uma linha para abri-la.

## Adicionando ou editando um tipo de item

Clique em **Adicionar novo item**, ou abra uma linha existente. O formulário tem estes campos:

- **Categoria** — o grupo a que o item pertence (escolha da lista).
- **Família** e **Variante (opcional)** — o número do item (veja abaixo).
- **Descrição do tipo de item** — o nome que as pessoas verão em todo lugar (obrigatório).
- **Unidade padrão para pedidos** — a unidade em que as quantidades são contadas (por exemplo unidade, caixa, lb).
  Os totais na tabela Itens usam esta unidade.
- **Ativo** — desmarque para tirar um tipo de item de uso sem excluí-lo.

Clique em **Salvar** quando terminar. Um novo tipo de item ganha automaticamente uma linha de SKU "GENERIC ITEM"
para poder ser triado de imediato.

## Números de item: família e variante

O **ACS Item#** é feito de duas partes que são armazenadas separadamente. A **Família** é de um a quatro dígitos
(`42` é salvo como `0042`). A **Variante** é de um ou dois dígitos e distingue versões dentro da família, como
tamanhos.

- Cada par família + variante pode ser usado apenas uma vez. Se está ocupado, você verá "Esse número de
  família/variante já está em uso."
- Deixe a Variante em branco e ela é salva como `00`, o item padrão daquela família. O número é então mostrado sem
  a variante (por exemplo `318`); as outras variantes aparecem como `318-90`.
- A maioria das famílias é mostrada sem o zero à esquerda (`042`, não `0042`); famílias de 1000 para cima mostram
  os quatro dígitos.

## Itens que ainda não têm número

Quando um triador encontra algo que não está no catálogo, ele pode adicioná-lo direto da página de
[Triagem](/help/sorting). Um tipo de item adicionado assim não tem família nem variante e é colocado em **espera
de numeração (sort hold)**: pode ser triado, mas fica retido dos formulários de pedido até receber um número
real. Dê a ele uma Família aqui para numerá-lo. Note que este formulário não tem campo para a espera de
numeração em si, então salvar não suspende a espera por conta própria — se um item numerado ainda não aparece nos
formulários de pedido, avise um administrador.

## Linhas de SKU e códigos de barras UPC

A tabela **Itens** dentro do formulário lista as linhas de SKU. Clique em **Nova linha** para adicionar uma. Para
mudar uma linha, clique no ícone de lápis dela; com uma linha aberta, o ícone de lixeira remove-a. Cada linha
tem:

- **Plus Code** — um código curto (até 4 caracteres) que distingue as linhas.
- **Descrição do item** — o que este produto específico é.
- **Unid. emb.**, **Tamanho** e **Qtd. por caixa** — a embalagem (caixa, saco, caixa...), quantas unidades ela
  contém e, se é uma caixa, quantas embalagens há nela. **Total** mostra o resultado (quantidade da caixa vezes
  tamanho).
- **UPC** — o código de barras do fabricante naquele produto. Um UPC pertence a uma linha e não pode ser
  reutilizado em outra.

Um UPC em uma linha de SKU é o que permite a um triador escanear o produto na página de Triagem e ter o tipo de
item e a descrição corretos preenchidos. As grafias UPC-A, EAN-13 e GTIN-14 do mesmo número são reconhecidas como
uma. Se um produto tem dois códigos de barras diferentes, faça duas linhas de SKU.

Excluir uma linha remove-a do tipo de item. Não muda o estoque já contado para o tipo de item.

## Códigos de barras de caixa master

Uma caixa master (caixa com vários pacotes) frequentemente tem o próprio código de barras, diferente dos itens
únicos dentro dela. Quando um triador escaneia uma caixa master que o sistema não conhece, a página de Triagem
abre **Novo código de barras de caixa master** e pergunta qual item está dentro e quantos (pacotes × itens por
pacote). Uma vez salvo, escanear aquela caixa de novo preenche o item contido e a quantidade, de modo que
leituras de caixa e de item único acabam na mesma linha.

[Configurações → Códigos de barras de caixa master](/setup/carton-codes) lista cada caixa master confirmada
(também precisa de Gerenciar itens). Use a caixa **Buscar** para encontrar uma por código de barras, item ou quem
a adicionou. A tabela mostra **Código de barras da caixa master**, **Contém**, **Itens por caixa master** e
**Adicionado**.

- Caixas master não podem ser adicionadas ou editadas aqui. Para remover uma, clique em **Remover** e depois em
  **Confirmar remoção**.
- Remover não muda nenhum item nem nada já triado. A próxima leitura daquela caixa pergunta de novo o que há
  dentro. Para corrigir um lançamento errado, remova-o e escaneie a caixa de novo.
