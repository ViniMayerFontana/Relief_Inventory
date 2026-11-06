<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Escolha os itens de pedidos já cadastrados em [Cadastro de pedidos](/help/order-entry) e registre o que foi realmente retirado. É aqui que o estoque sai do estoque.

## Como o preenchimento funciona

Você precisa da permissão **manage-orders**. Abra [Preenchimento de pedido](/order-filling). Há duas formas de trabalhar, e ambas terminam no mesmo lugar:

- **On paper** — imprima fichas de separação, caminhe pelo armazém com elas e depois digite o que foi separado.
- **On screen** — abra um pedido com **Start Filling** e insira cada separação conforme avança.

Cada separação é salva como um **fill record** próprio no momento em que você a adiciona. Os registros só são adicionados, nunca substituídos: se uma linha foi separada em duas viagens, ambos os registros são mantidos e o número **Filled** da linha é a soma deles. Um registro de preenchimento diz quantos foram retirados e, se vieram de uma palete do armazém, qual palete — isso mostra onde os itens estavam, não quem doou.

## As duas filas

- **Ready to Fill** — pedidos enviados aguardando atendimento (Order, Partner, Lines). **Start Filling** numa linha move apenas esse pedido para Filling e abre-o.
- **Filling** — pedidos já iniciados, com progresso como *2 of 5 lines filled*. **Continue** reabre o pedido; o menu **Print** nessa linha reimprime a ficha de separação.

## Caminho em papel: imprimir fichas de separação

**Print Pick Sheets** (superior direito) imprime uma folha por pedido para *todos* os pedidos em Ready to Fill, listando onde encontrar cada item ao longo do caminho de separação do armazém. Escolha **Download PDF** ou uma impressora.

Importante: escolher qualquer opção aqui move **todos** os pedidos em Ready to Fill para Filling de uma vez, e a partir daí as quantidades separadas ficam fixas. O botão fica acinzentado quando não há nada em Ready to Fill. Depois de separar, clique em **Continue** em cada pedido e insira o que foi retirado, como abaixo.

## Opcional: revisar alocação (quando não há o suficiente)

**Review Allocation** (superior direito; clique de novo para **Hide**) lista itens em que o total solicitado em todos os pedidos Ready to Fill é maior do que o que há em estoque. Para cada item, você vê uma tabela com **Order**, **Partner**, **Requested**, **Suggested**, **Approve** e **Need**.

- **Suggested** é uma divisão proporcional simples do que temos. É um ponto de partida, não uma regra.
- **Need** é a própria observação do parceiro em Critical / Moderate / Low do Order Entry (um traço se não houver). Linhas são listadas pela maior urgência primeiro.
- Digite a quantidade que deseja em **Approve** e clique em **Save Approved Quantities**. Os separadores então veem apenas o número aprovado como **Qty to Pick** na ficha e na tela de preenchimento. Aprovar **0** deixa a linha totalmente de fora. Deixe uma caixa em branco para dar ao separador o pedido completo. Um sinal de verificação mostra uma aprovação salva.
- Você não pode aprovar mais do que foi solicitado, e as aprovações só podem ser alteradas enquanto o pedido ainda está Ready to Fill. O pedido original nunca é alterado, então os relatórios ainda podem comparar solicitado, aprovado e preenchido.
- Nada aqui é obrigatório. Se você preferir seguir a ordem de chegada, ignore este painel e imprima ou inicie o preenchimento.

## A tela de preenchimento

A tela tem o título **Order #** com o nome da entidade parceira. **← Back** retorna às filas. A tabela tem colunas **Item**, **Qty to Pick**, **Filled**, **On Hand** e **Add Fill**, listadas na ordem em que você caminharia pelo armazém.

1. Veja as sugestões de **Pick:** em uma linha (veja a próxima seção).
2. Se o item vier em mais de uma variedade, pesquise ou escaneie a certa em **Scan or search item...** (ou use **Scan** para a câmera). Se houver apenas uma variedade, ela é escolhida para você.
3. Digite a **Qty** que foi separada. Se veio de uma palete específica do armazém, digite ou escaneie a tag da palete em **From open pallet (optional)**; a tag fica na caixa para a próxima separação. Pressione **Enter** ou clique em **Add**.
4. A separação aparece em uma lista abaixo da linha (quantidade e item). Para remover um erro, clique no ícone de lixeira e depois em **Delete?** (ou **Keep**). O estoque volta, e uma palete marcada como vazia por essa separação é reaberta.

Você pode digitar **0** de propósito quando viu que não havia nada: isso conta como “tratado” e não retira nenhum item do estoque.

## Sugestões de "Pick:" e onde o estoque está

Abaixo de cada linha, **Pick:** mostra caixas dizendo de onde retirar o item, recalculadas a partir do estoque em tempo real a cada vez. Elas são apenas orientações — nada é reservado e você pode separar de outra forma.

- **Sorting area ×N** — estoque solto ainda não colocado em uma palete. É usado primeiro.
- **Location, pallet tag ×N** — pegue N dessa palete (com data de validade, se houver). Paletes que vencem primeiro, seguidas pelas mais antigas, são sugeridas primeiro. Paletes inteiras e lacradas são sugeridas antes de abrir qualquer nova, para que paletes cheias possam ser enviadas inteiras.
- **open** significa que você pode retirar da palete agora. **sealed — take the whole pallet** significa que a palete inteira vai para este pedido, então pode ir assim mesmo. **sealed — open it first** significa que parte dela é necessária: clique em **Open pallet** primeiro. (Use fica acinzentado até você fazer isso.)
- **Use** copia uma sugestão para a linha de entrada (a tag da palete, a quantidade e, quando relevante, a variedade do item). Verifique e clique em **Add**.
- *N not found in stock* significa que o sistema acha que faltam N. *fully picked* significa que nada mais é necessário nessa linha.

Mais sobre paletes, lacre e locais: [Movimento de estoque](/help/inventory-movement).

## Quando os números não batem

- **No pallet named:** a separação vem primeiro da sorting area, depois das paletes abertas mais antigas, dividida em vários registros de preenchimento, se necessário.
- **Sealed pallets hold the rest:** você receberá uma mensagem como *Only 30 of 50 can come from the sorting area and open pallets. Open a sealed pallet to pick the other 20.* Nada é salvo. Abra uma palete (use **Open pallet** na sugestão) e insira a separação de novo.
- **Naming a sealed pallet:** isso só funciona se você estiver levando tudo dela. Caso contrário, abra a palete primeiro. Uma tag que não seja de uma palete do armazém é recusada (*Unknown Warehouse pallet tag*), assim como uma palete vazia ou da qual não seja possível retirar itens.
- **More than the system says we have:** a separação é aceita, com aviso como *That's 5 more than the database says is in stock — check the count.* Isso significa que os registros e a prateleira discordam: conte a prateleira e avise um supervisor.
- Uma palete é marcada como vazia automaticamente quando o total registrado chega a zero.

## Finalizando o pedido

1. Cada linha que precisa ser separada exige pelo menos um registro de preenchimento. Uma linha com nada aprovado para separar (aprovada em 0) não aparece na tela e não precisa. Até que tudo esteja concluído, **Complete Filling** fica acinzentado e a mensagem diz *Every line needs at least one fill record (even 0)…*.
2. Opcionalmente, digite **Pallets packed** (quantas paletes o pedido acabou tendo) — isso é registrado no pedido e impresso na etiqueta de envio.
3. Clique em **Complete Filling**. O pedido vira **Filled** e segue para [Envio](/help/shipping).

**Se nada foi separado de jeito algum** (toda separação é 0), a tela avisa *Nothing has been picked — completing will close this request as Unfulfilled instead of sending it to Shipping.* O pedido termina como **Closed - Unfulfilled** e nunca chega a Shipping.

Depois que um pedido é Filled, seus registros de preenchimento não podem mais ser alterados aqui.
