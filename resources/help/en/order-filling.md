<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Escolha os itens de pedidos já cadastrados em [Cadastro de pedidos](/help/order-entry) e registre o que foi realmente retirado. É aqui que o estoque sai do estoque.

## Como o preenchimento funciona

Você precisa da permissão de gerenciamento de pedidos. Abra [Preenchimento de pedido](/order-filling). Há duas formas de trabalhar, e ambas terminam no mesmo lugar:

- **Em papel** — imprima fichas de separação, caminhe pelo armazém com elas e depois digite o que foi separado.
- **Na tela** — abra um pedido com **Iniciar separação** e insira cada separação conforme avança.

Cada separação é salva como um **registro de separação** próprio no momento em que você a adiciona. Os registros só são adicionados, nunca substituídos: se uma linha foi separada em duas viagens, ambos os registros são mantidos e a quantidade **Separada** da linha é a soma deles. Um registro de separação diz quantos foram retirados e, se vieram de uma palete do armazém, qual palete — isso mostra onde os itens estavam, não quem doou.

## As duas filas

- **Pronto para separação** — pedidos enviados aguardando atendimento (Pedido, Parceiro, Linhas). **Iniciar separação** numa linha move apenas esse pedido para Em separação e abre-o.
- **Em separação** — pedidos já iniciados, com progresso como *2 de 5 linhas separadas*. **Continuar** reabre o pedido; o menu **Imprimir** nessa linha reimprime a ficha de separação.

## Caminho em papel: imprimir fichas de separação

**Imprimir fichas de separação** (superior direito) imprime uma folha por pedido para *todos* os pedidos em Pronto para separação, listando onde encontrar cada item ao longo do caminho de separação do armazém. Escolha **Baixar PDF** ou uma impressora.

Importante: escolher qualquer opção aqui move **todos** os pedidos em Ready to Fill para Filling de uma vez, e a partir daí as quantidades separadas ficam fixas. O botão fica acinzentado quando não há nada em Ready to Fill. Depois de separar, clique em **Continue** em cada pedido e insira o que foi retirado, como abaixo.

## Opcional: revisar alocação (quando não há o suficiente)

**Revisar alocação** (superior direito; clique de novo para **Ocultar**) lista itens em que o total solicitado em todos os pedidos Pronto para separação é maior do que o que há em estoque. Para cada item, você vê uma tabela com **Pedido**, **Parceiro**, **Solicitado**, **Sugerido**, **Aprovar** e **Necessidade**.

- **Sugerido** é uma divisão proporcional simples do que temos. É um ponto de partida, não uma regra.
- **Necessidade** é a própria observação do parceiro em Crítica / Moderada / Baixa do Cadastro de pedidos (um traço se não houver). Linhas são listadas pela maior urgência primeiro.
- Digite a quantidade que deseja em **Aprovar** e clique em **Salvar quantidades aprovadas**. Os separadores então veem apenas o número aprovado como **Qtd. a separar** na ficha e na tela de preenchimento. Aprovar **0** deixa a linha totalmente de fora. Deixe uma caixa em branco para dar ao separador o pedido completo. Um sinal de verificação mostra uma aprovação salva.
- Você não pode aprovar mais do que foi solicitado, e as aprovações só podem ser alteradas enquanto o pedido ainda está Pronto para separação. O pedido original nunca é alterado, então os relatórios ainda podem comparar solicitado, aprovado e separado.
- Nada aqui é obrigatório. Se você preferir seguir a ordem de chegada, ignore este painel e imprima ou inicie o preenchimento.

## A tela de preenchimento

A tela tem o título **Nº do pedido** com o nome da entidade parceira. **← Voltar** retorna às filas. A tabela tem colunas **Item**, **Qtd. a separar**, **Separado**, **Disponível** e **Adicionar separação**, listadas na ordem em que você caminharia pelo armazém.

1. Veja as sugestões de **Pick:** em uma linha (veja a próxima seção).
2. Se o item vier em mais de uma variedade, pesquise ou escaneie a certa em **Escaneie ou pesquise um item...** (ou use **Escanear** para a câmera). Se houver apenas uma variedade, ela é escolhida para você.
3. Digite a **Quantidade** que foi separada. Se veio de uma palete específica do armazém, digite ou escaneie a etiqueta da palete em **Da palete aberta (opcional)**; a etiqueta fica na caixa para a próxima separação. Pressione **Enter** ou clique em **Adicionar**.
4. A separação aparece em uma lista abaixo da linha (quantidade e item). Para remover um erro, clique no ícone de lixeira e depois em **Excluir?** (ou **Manter**). O estoque volta, e uma palete marcada como vazia por essa separação é reaberta.

Você pode digitar **0** de propósito quando viu que não havia nada: isso conta como “tratado” e não retira nenhum item do estoque.

## Sugestões de "Pick:" e onde o estoque está

Abaixo de cada linha, **Separar:** mostra caixas dizendo de onde retirar o item, recalculadas a partir do estoque em tempo real a cada vez. Elas são apenas orientações — nada é reservado e você pode separar de outra forma.

- **Área de triagem ×N** — estoque solto ainda não colocado em uma palete. É usado primeiro.
- **Local, etiqueta da palete ×N** — pegue N dessa palete (com data de validade, se houver). Paletes que vencem primeiro, seguidas pelas mais antigas, são sugeridas primeiro. Paletes inteiras e lacradas são sugeridas antes de abrir qualquer nova, para que paletes cheias possam ser enviadas inteiras.
- **aberta** significa que você pode retirar da palete agora. **lacrada — leve a palete inteira** significa que a palete inteira vai para este pedido, então pode ir assim mesmo. **lacrada — abra primeiro** significa que parte dela é necessária: clique em **Abrir palete** primeiro. (**Usar** fica acinzentado até você fazer isso.)
- **Usar** copia uma sugestão para a linha de entrada (a etiqueta da palete, a quantidade e, quando relevante, a variedade do item). Verifique e clique em **Adicionar**.
- *N não encontrado em estoque* significa que o sistema acha que faltam N. *separação concluída* significa que nada mais é necessário nessa linha.

Mais sobre paletes, lacre e locais: [Movimento de estoque](/help/inventory-movement).

## Quando os números não batem

- **Sem indicar uma palete:** a separação vem primeiro da área de triagem, depois das paletes abertas mais antigas, dividida em vários registros de separação, se necessário.
- **Paletes lacradas retêm o restante:** você receberá uma mensagem como *Somente 30 de 50 podem vir da área de triagem e das paletes abertas. Abra uma palete lacrada para separar os outros 20.* Nada é salvo. Abra uma palete (use **Abrir palete** na sugestão) e insira a separação de novo.
- **Informar uma palete lacrada:** isso só funciona se você estiver levando tudo dela. Caso contrário, abra a palete primeiro. Uma etiqueta que não seja de uma palete do armazém é recusada (*Etiqueta de palete do armazém desconhecida*), assim como uma palete vazia ou da qual não seja possível retirar itens.
- **Quantidade maior que a registrada pelo sistema:** a separação é aceita, com aviso como *São 5 a mais do que o sistema registra em estoque — confira a contagem.* Isso significa que os registros e a prateleira discordam: conte a prateleira e avise um supervisor.
- Uma palete é marcada como vazia automaticamente quando o total registrado chega a zero.

## Finalizando o pedido

1. Cada linha que precisa ser separada exige pelo menos um registro de separação. Uma linha com nada aprovado para separar (aprovada em 0) não aparece na tela e não precisa. Até que tudo esteja concluído, **Concluir separação** fica acinzentado e a mensagem diz *Cada linha precisa de pelo menos um registro de separação (mesmo 0)…*.
2. Opcionalmente, digite **Paletes embaladas** (quantas paletes o pedido acabou tendo) — isso é registrado no pedido e impresso na etiqueta de envio.
3. Clique em **Concluir separação**. O pedido vira **Separado** e segue para [Envio](/help/shipping).

**Se nada foi separado de jeito algum** (toda separação é 0), a tela avisa *Nenhum item foi separado — ao concluir, esta solicitação será encerrada como não atendida, em vez de enviada para expedição.* O pedido termina como **Encerrado — não atendido** e nunca chega à etapa de envio.

Depois que um pedido é Filled, seus registros de preenchimento não podem mais ser alterados aqui.
