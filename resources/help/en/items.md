<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

O catálogo de tudo que o armazém conta. Triagem, pedidos e preenchimento usam esta lista, então mantê-la organizada mantém tudo o mais organizado.

## Tipos de item e linhas SKU

A lista tem dois níveis. Um **tipo de item** é a coisa que o armazém conta e solicita (por exemplo, “fraldas para recém-nascidos”);
o estoque é agrupado por tipo de item. Abaixo de cada tipo de item há uma ou mais **linhas SKU** (mostradas na tabela **Itens** do
formulário) — os produtos específicos e tamanhos de embalagem que contam como esse tipo de item, como a marca específica do código de barras. Qualquer pessoa que faça a triagem de uma linha SKU acaba adicionando ao mesmo total do tipo de item.

Você precisa das permissões de gerenciamento de itens e de tipos de item para abrir [Configuração → Lista mestre de itens](/setup/items).
Sem as duas, a página não abre — peça a um administrador.

## Encontrando um item

Digite na caixa **Buscar por nº ACS ou tipo de item...** para estreitar a lista. Clique em um cabeçalho de coluna (**Categoria**, **Nº do item ACS**, **Tipo de item**, **Unidade**, **Ativo**) para ordenar por ele; clique de novo para inverter. Uma marca em **Ativo** significa que o tipo do item está em uso. Clique em uma linha para abri-la.

## Adicionando ou editando um tipo de item

Clique em **Adicionar novo item**, ou abra uma linha existente. O formulário tem estes campos:

- **Categoria** — a qual grupo o item pertence (escolha na lista).
- **Família** e **Variante (opcional)** — o número do item (veja abaixo).
- **Descrição do tipo de item** — o nome que as pessoas verão em todo lugar (obrigatório).
- **Unidade padrão para pedidos** — a unidade em que as quantidades são contadas (por exemplo, unidade, caixa, libra). Os totais na tabela Itens usam essa unidade.
- **Ativo** — desmarque para tirar um tipo de item de uso sem excluí-lo.

Clique em **Salvar** quando terminar. Um novo tipo de item recebe automaticamente uma linha SKU “GENERIC ITEM” para poder ser triado imediatamente.

## Números de item: family e variant

O **Nº do item ACS** é feito de duas partes que são armazenadas separadamente. A **Família** é de um a quatro dígitos (`42` é salvo como `0042`).
A **Variante** é de um a dois dígitos e distingue versões dentro da família, como tamanhos.

- Cada par família + variante pode ser usado apenas uma vez. Se estiver ocupado, você verá “Este número de família/variante já está em uso.”
- Deixe Variante em branco e ele é salvo como `00`, o item padrão da família. O número é então exibido sem a variante (por exemplo, `318`); outras variantes aparecem como `318-90`.
- A maioria das famílias é mostrada sem zero à esquerda (`042`, não `0042`); famílias de 1000 e acima mostram os quatro dígitos.

## Itens que ainda não têm número

Quando um triador encontra algo que não está no catálogo, ele pode adicioná-lo direto da página [Triagem](/help/sorting). Um tipo de item adicionado dessa forma não tem família nem variante e é colocado em **retenção de triagem**, para poder ser triado, mas fica fora dos formulários de pedido até receber um número real. Informe uma Família aqui para numerá-lo. Note que este formulário não tem um campo para a retenção de triagem em si, então salvar não remove a retenção por conta própria — se um item numerado ainda não aparecer nos formulários de pedido, avise um administrador.

## Linhas SKU e códigos de barras UPC

A tabela **Itens** dentro do formulário lista as linhas SKU. Clique em **Nova linha** para adicionar uma linha. Para alterar uma linha, clique no ícone de lápis; enquanto a linha estiver aberta, o ícone de lixeira a remove. Cada linha tem:

- **Código adicional** — um código curto (até 4 caracteres) que distingue as linhas.
- **Descrição do item** — o que este produto específico é.
- **Unidade da embalagem**, **Tamanho** e **Qtd. por caixa** — o pacote (caixa, saco, pacote...), quantas unidades ele contém e, se for uma caixa, quantos pacotes estão dentro. **Total** mostra o resultado (quantidade da caixa vezes tamanho).
- **UPC** — o código de barras do fabricante naquele produto. Um UPC pertence a uma linha e não pode ser reutilizado em outra.

Um UPC em uma linha SKU é o que permite a um triador escanear o produto na página de Triagem e ter o tipo e a descrição corretos preenchidos. UPC-A, EAN-13 e GTIN-14 com a mesma numeração são reconhecidos como um. Se um produto tiver dois códigos de barras diferentes, faça duas linhas SKU.

Excluir uma linha remove-a do item type. Isso não altera o estoque já contado para o item type.

## Códigos de barras de caixa

Uma caixa (caso de vários pacotes) costuma ter seu próprio código de barras, diferente dos itens individuais dentro. Quando um triador escaneia uma caixa que o sistema não conhece, a página de Triagem abre **Novo código de barras de caixa** e pergunta qual item está dentro e quantos (pacotes × itens por pacote). Depois de salvar, escanear essa caixa novamente preenche o item contido e a quantidade, para que as leituras de caixa e de item individual acabem na mesma linha.

[Configuração → Códigos de barras de caixas](/setup/carton-codes) lista todas as caixas confirmadas (também precisa da permissão de gerenciamento de itens). Use a caixa **Buscar** para encontrar uma por código de barras, item ou quem a adicionou. A tabela mostra **Código de barras da caixa**, **Contém**, **Itens por caixa** e **Adicionado por**.

- Caixas não podem ser adicionadas ou editadas aqui. Para remover uma, clique em **Remover** e depois em **Confirmar remoção**.
- Remover não altera nenhum item nem nada já triado. A próxima leitura dessa caixa pergunta de novo o que está dentro. Para corrigir uma entrada errada, remova e escaneie a caixa de novo.
