<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

O catálogo de tudo que o armazém conta. Triagem, pedidos e preenchimento usam esta lista, então mantê-la organizada mantém tudo o mais organizado.

## Tipos de item e linhas SKU

A lista tem dois níveis. Um **item type** é a coisa que o armazém conta e pede (por exemplo, “Newborn diapers”);
o estoque é agrupado por item type. Abaixo de cada item type há uma ou mais **SKU rows** (mostradas na tabela **Items** do
formulário) — os produtos específicos e tamanhos de embalagem que contam como esse item type, como a marca específica do código de barras. Qualquer pessoa que triage uma SKU row acaba adicionando ao mesmo total do item type.

Você precisa das permissões Manage Items e Manage Item Types para abrir [Configuração → Master Item List](/setup/items).
Sem as duas, a página não abre — peça a um administrador.

## Encontrando um item

Digite na caixa **Search by ACS Item# or Item Type...** para estreitar a lista. Clique em um cabeçalho de coluna (**Category**, **ACS Item#**, **Item Type**, **Unit**, **Active**) para ordenar por ele; clique de novo para inverter. Uma marca em **Active** significa que o tipo do item está em uso. Clique em uma linha para abri-la.

## Adicionando ou editando um tipo de item

Clique em **Add New Item**, ou abra uma linha existente. O formulário tem estes campos:

- **Category** — a qual grupo o item pertence (escolha na lista).
- **Family** e **Variant (optional)** — o número do item (veja abaixo).
- **Item Type Desc** — o nome que as pessoas verão em todo lugar (obrigatório).
- **Default Ordering Unit** — a unidade em que as quantidades são contadas (por exemplo, each, case, lb). Os totais na tabela Items usam essa unidade.
- **Active** — desmarque para tirar um tipo de item de uso sem excluí-lo.

Clique em **Save** quando terminar. Um novo item type recebe automaticamente uma linha SKU “GENERIC ITEM” para poder ser triado imediatamente.

## Números de item: family e variant

O **ACS Item#** é feito de duas partes que são armazenadas separadamente. A **Family** é de um a quatro dígitos (`42` é salvo como `0042`).
A **Variant** é de um a dois dígitos e distingue versões dentro da família, como tamanhos.

- Cada par family + variant pode ser usado apenas uma vez. Se estiver ocupado, você verá “That family/variant number is already in use.”
- Deixe Variant em branco e ele é salvo como `00`, o item padrão da família. O número é então exibido sem a variante (por exemplo, `318`); outras variantes aparecem como `318-90`.
- A maioria das famílias é mostrada sem zero à esquerda (`042`, não `0042`); famílias de 1000 e acima mostram os quatro dígitos.

## Itens que ainda não têm número

Quando um triador encontra algo que não está no catálogo, ele pode adicioná-lo direto da página [Triagem](/help/sorting). Um item type adicionado dessa forma não tem family nem variant e é colocado em **sort hold**, para poder ser triado, mas fica fora dos formulários de pedido até receber um número real. Informe uma Family aqui para numerá-lo. Note que este formulário não tem um campo para sort hold em si, então salvar não remove a retenção por conta própria — se um item numerado ainda não aparecer nos formulários de pedido, avise um administrador.

## Linhas SKU e códigos de barras UPC

A tabela **Items** dentro do formulário lista as linhas SKU. Clique em **New Line** para adicionar uma linha. Para alterar uma linha, clique no ícone de lápis; enquanto a linha estiver aberta, o ícone de lixeira a remove. Cada linha tem:

- **Plus Code** — um código curto (até 4 caracteres) que distingue as linhas.
- **Item Description** — o que este produto específico é.
- **Pk Unit**, **Size** e **Case Qty** — o pacote (caixa, saco, caso...), quantas unidades ele contém e, se for um caso, quantos pacotes estão dentro. **Total** mostra o resultado (quantidade do caso vezes tamanho).
- **UPC** — o código de barras do fabricante naquele produto. Um UPC pertence a uma linha e não pode ser reutilizado em outra.

Um UPC em uma linha SKU é o que permite a um triador escanear o produto na página de Triagem e ter o tipo e a descrição corretos preenchidos. UPC-A, EAN-13 e GTIN-14 com a mesma numeração são reconhecidos como um. Se um produto tiver dois códigos de barras diferentes, faça duas linhas SKU.

Excluir uma linha remove-a do item type. Isso não altera o estoque já contado para o item type.

## Códigos de barras de caixa

Uma caixa (caso de vários pacotes) costuma ter seu próprio código de barras, diferente dos itens individuais dentro. Quando um triador escaneia uma caixa que o sistema não conhece, a página de Triagem abre **New Carton Barcode** e pergunta qual item está dentro e quantos (packs × items per pack). Depois de salvar, escanear essa caixa novamente preenche o item contido e a quantidade, para que as leituras de caixa e de item individual acabem na mesma linha.

[Configuração → Carton Barcodes](/setup/carton-codes) lista todas as caixas confirmadas (também precisa de Manage Items). Use a caixa **Search** para encontrar uma por código de barras, item ou quem a adicionou. A tabela mostra **Carton barcode**, **Contains**, **Items per carton** e **Added**.

- Caixas não podem ser adicionadas ou editadas aqui. Para remover uma, clique em **Remove** e depois em **Confirm remove**.
- Remover não altera nenhum item nem nada já triado. O próximo scan dessa caixa pergunta de novo o que está dentro. Para corrigir uma entrada errada, remova e escaneie a caixa de novo.
