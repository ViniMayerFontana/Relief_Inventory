<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Receba a solicitação de um parceiro — por telefone ou por um formulário em papel que ele enviou — e cadastre-a para que o armazém possa atendê-la.
Depois de enviada, ela vai para [Preenchimento de pedido](/help/order-filling).

## Para que serve o cadastro de pedidos

Parceiros chamam isso de *requests*; esta tela (e o lado da equipe do aplicativo) ainda chama de **orders**. São a mesma coisa. Você precisa da
permissão **manage-orders** para usar a página.

O cadastro salva conforme você avança: o pedido é criado no momento em que você confirma o parceiro, e cada linha de item é enviada ao servidor assim
que você a adiciona. Uma conexão caindo ou uma falha nunca perde mais do que a linha que você estava digitando.

## A lista de pedidos

Abra [Cadastro de pedidos](/order-entry) para ver duas listas. Toque em qualquer linha para abrir esse pedido.

- **Open Orders - tap to open** — tudo que ainda não foi concluído: New Order, Ready to Fill, Filling, Filled, Ready to Ship, Shipped e Delivered
(incluindo Delivered esperando uma BOL assinada). Colunas: Date, Partner, Lines, Items, Status, Entered By.
- **Recently Completed** — os últimos 25 pedidos concluídos (por exemplo, Completed ou Closed - Unfulfilled).

**New Order** começa uma solicitação. **Offline Order Form** (um menu no estilo **Print**) produz um formulário imprimível listando os números de item que temos em estoque para enviar a um parceiro, que preenche as quantidades manualmente e envia de volta para você digitar. Ele nunca mostra números de estoque.

## Etapa 1 — Para quem é este pedido?

1. Clique em **New Order**. A tela se chama **New Order — Who is this for?**
2. Pesquise a caixa **Partner** por nome, organização ou cidade e escolha o parceiro. (Esta é a organização receptora ou o ponto de distribuição que está fazendo o pedido.)
3. Não está na lista? Digite o nome e escolha a opção de adicionar. Abre um formulário **New Partner**: nomes, organização, telefone, email, **Zip** primeiro, depois **Address**, City, State e County. Você precisa de nome e sobrenome, ou de uma organização. Quando o CEP/endereço for preenchido, o app pode procurar o município e sugerir um endereço corrigido — aceite ou mantenha o que você digitou. Se o município estiver ausente na lista, digite-o na caixa County para adicioná-lo (digite o estado de duas letras antes). Clique em **Save Partner**.
4. **Confirm Contact & Shipping Details** aparece com os dados do parceiro. Este é o local para onde o pedido será enviado, então verifique se está atualizado e corrija o que mudou. **Verify Address** revalida o endereço se ele ainda não foi verificado. Pressionar Enter em uma caixa passa para a próxima.
5. Clique em **Start Order →**. Se você mudou alguma coisa, o botão passa a dizer **Save Details & Start Order →**, e as mudanças são salvas no registro do parceiro para todos.

## Etapa 2 — Inserindo os itens

O cabeçalho mostra **Order #** e a data, e uma barra fina mostra o nome do parceiro, cidade/estado e telefone. **Change** ali permite escolher outro parceiro (enquanto o pedido ainda é editável).

1. Digite um número do item (ou parte do nome) na caixa **Item #** e escolha-o. O cursor salta para **Qty**. Uma nota ao lado do nome do item mostra aproximadamente quantos itens há em estoque (por exemplo, *~40 usable on hand* ou *none on hand*). Isso é apenas uma pista para você — nunca leia números de estoque ao parceiro, e você pode até inserir mais do que temos.
2. Digite a quantidade (1 ou mais) e pressione **Enter** (ou clique em **Add**). A linha é salva e o cursor volta para **Item #** para o próximo. Há também uma caixa **Line comment (optional)** para observações dessa linha.
3. Quando um item está acabando (no nível mínimo ou abaixo dele), aparece uma caixa **Need level (optional)**: **Critical**, **Moderate** ou **Low**. Registre o que o parceiro lhe diz sobre o quanto precisa dele. É apenas contexto para quem dividirá itens escassos depois — deixe em branco se não disserem.
4. Digitou o mesmo item duas vezes? Uma caixa intitulada **Oops** mostra o que você já inseriu. Digite uma **Additional qty** e clique em **Combine →** para somar à linha existente, ou **Cancel** (ou pressione Esc) para descartar.
5. Linha errada? Clique no ícone de lixeira ao lado dela e depois em **Delete?** para confirmar (ou **Keep** para desistir). Para alterar a quantidade, apague a linha e adicione novamente, ou use a caixa Combine para adicionar mais.

A barra superior mostra *Saving…*, *All changes saved*, ou *N line(s) failed to save* com **Retry All** (cada linha com falha também tem **Retry**; linhas com falha tentam de novo sozinhas quando a conexão volta). Totais de **Lines** e **Total items** aparecem abaixo da tabela. **← All Orders** volta para a lista; o pedido continua aberto para depois.

## Etapa 3 — Revisar e confirmar

Quando todos os itens estiverem dentro, clique em **Complete Order** (canto superior direito). A tela **Review & Confirm — Order #** mostra:

- **Order Summary** — parceiro, número de linhas e total de itens.
- **Comments** — qualquer coisa que o armazém deva saber.
- **Needed But Not in Catalog** — itens de que o parceiro precisa e que não estão na nossa lista (o mesmo que “Other Needs” no formulário em papel).
- **Delivery or Pickup** — escolha um, mais uma **Needed By Date**. Para entrega também escolha os dias em que aceitam (**Any Day** ou dias individuais) e um **Preferred Time**. Para retirada, o armazém define dias e horários.
- **Delivery Contact** (ou **Pickup Contact**) — nome e telefone, preenchidos do parceiro; altere se outra pessoa estiver recebendo.
- **Special Delivery Instructions** — códigos de portaria, local do dock, quem contatar na chegada. Isso vai para a BOL quando o pedido for enviado.

Clique em **Submit Order** para concluir. **← Back** retorna aos itens sem enviar.

## Depois de enviar — o ciclo de vida do pedido

Enviar move o pedido de **New Order** para **Ready to Fill**. A partir daí, o sistema o move assim:

`New Order → Ready to Fill → Filling → Filled → Ready to Ship → Shipped →                               Delivered →
Completed`

- **Only a New Order can be edited.** Depois de enviado, linhas e detalhes ficam bloqueados, porque a equipe do armazém está trabalhando com eles. Abrir um pedido assim mostra os itens em modo somente leitura com seu badge de status.
- O status é definido pelo app conforme o trabalho avança — você nunca o escolhe em uma lista. O preenchimento é explicado em [Preenchimento de pedido](/help/order-filling) e o envio em [Envio](/help/shipping).
- Um pedido em que nada pôde ser separado termina como **Closed - Unfulfilled** e nunca chega a Shipping.
