<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o controle de onde as paletes estão e coloque os itens triados em paletes do armazém para que os separadores possam encontrá-los.

## Para que serve esta tela

Abra [Movimento de estoque](/inventory-movement) (você precisa da permissão Manage Pallets). Ela tem três guias: **Pallets** (a que você usará o dia inteiro — guiada por leitura), **Locations** e **Recent Movements** (somente consulta).

**Unassigned significa “ainda na sorting area”.** Quando os itens são triados (veja o guia [Triagem](/help/sorting)), eles contam como estoque disponível, mas ficam na sorting area. Colocá-los em uma palete do armazém os tira de “unassigned” e dá a eles um lugar na prateleira. O estoque é agrupado por tipo de item, então você informa ao sistema *quantos* do item foram para a palete — não de qual doação vieram.

As tags de palete começam com uma letra para o tipo: **R** Receiving, **W** Warehouse, **S** Shipping, **H** Hold, **Q** Quarantine, seguidas de oito dígitos (por exemplo `W00000123`). Uma palete do armazém pode ser *sealed* (embrulhada e fechada), *open* ou *empty*. Os separadores só podem retirar itens de paletes abertas — veja o guia [Preenchimento de pedido](/help/order-filling).

## A barra de leitura

No topo da guia Pallets há uma caixa sempre pronta para o próximo scan. Depois de clicar em qualquer lugar da página, o cursor volta para ela (a menos que você esteja digitando em outro campo). Escaneie ou digite um código e pressione Enter ou **Find**.

- Sem uma palete mostrando, um scan é lido como um **pallet barcode**.
- Com uma palete mostrando, um scan que corresponda a um **location code** move essa palete para lá imediatamente. Qualquer outro scan é lido como uma palete e substitui a que está na tela.
- Uma mensagem verde confirma o que aconteceu; uma vermelha diz o que deu errado (por exemplo, uma palete desconhecida). O botão do alto-falante à direita silencia ou ativa os sons de scan.

## Consultando uma palete

Escaneie a tag de uma palete. A tela mostra sua tag e tipo, onde ela está (*at* um local ou *no location recorded*), seu status, quando foi atualizada pela última vez e, para uma palete do armazém, a data de vencimento mais próxima dos itens nela. Abaixo disso:

- **Pallet Contents** — para uma palete do armazém, cada item e sua quantidade. Para uma palete de Recebimento, o que a triagem registrou saindo dela (item, disposição, quantidade). Outros tipos não rastreiam conteúdo.
- **Movement History** — cada movimento e mudança de status, mais recente primeiro (data, local, status, observações).

**Clear / new pallet** remove a palete da tela para que você possa escanear outra ou montar uma nova.

## Movendo uma palete

1. Escaneie a tag da palete.
2. Escaneie o código da prateleira ou rack. O movimento é registrado imediatamente (“… moved to …”), e a palete mantém seu status. Escanear o local em que já está apenas informa isso.
3. Prefere o formulário? Digite ou escolha um código em **Location**, acrescente **Notes** se quiser e clique em **Record Movement**. O local deve ser conhecido e ativo.

Para paletes de Receiving, Shipping, Hold e Quarantine também há um menu suspenso **Status**; altere e clique em **Record Status** (o botão fica **Record Movement** quando o local mudou). Uma palete do armazém não tem menu suspenso de Status — seu status muda por meio de lacrar e abrir abaixo.

## Montando uma nova palete do armazém

Um líder ou motorista de empilhadeira faz isso quando uma palete sai da sorting area. Sem nenhuma palete mostrando, a página diz **Build a new Warehouse pallet**.

1. Em **In the sorting area** está a lista de coleta: cada item ainda esperando, quantos (*Waiting*) e sua data de vencimento mais próxima. Clique em **Put all N on pallet** para preparar um item. Itens que compartilham um número ACS de item são agrupados em uma linha; clique nele para expandir os itens individuais ou use o botão para preparar todos.
2. Itens preparados aparecem em uma tabela acima. Altere uma **Quantity** se apenas parte dele vai para esta palete (não pode exceder o que está esperando), ou clique em **Remove**.
3. Verifique a data **Expires** de cada item na lista — é a data mais próxima conhecida para esse item e vai no rótulo do item; altere ou limpe se estiver errada. Digite ou escaneie o **Location** para onde a palete vai. A própria **Expires** da palete é preenchida com a data mais próxima entre os itens; altere-a ou clique em **Auto** para voltar. Adicione **Notes** se necessário.
4. Clique em **Seal & Place**. Uma nova palete do armazém é criada, lacrada e colocada nesse local. Uma linha verde mostra sua tag e conteúdo, com um botão **Print Pallet Label** — imprima-o e coloque-o na palete — e um botão **Print Item Labels**: uma pequena etiqueta para cada item que você colocou, mostrando o número ACS do item e a descrição, quantidade, data de vencimento mais próxima e palete, com código de barras. Cole cada uma em suas caixas. Etiquetas de item são impressas no tamanho pequeno de etiqueta (definido na página Printers). Para imprimi-las de novo depois, escaneie a palete: sua lista **Inventory Labels** tem um botão Print para cada uma.

O sistema não deixa você colocar em paletes mais de um item do que ainda está na sorting area (“Only N of … are not already on a pallet”). Quando tudo está em uma palete, a lista diz *Nothing waiting — everything sorted is already on a pallet.*

**Adicionando a uma palete existente:** escaneie uma palete do armazém que esteja *open*; a mesma lista agora mostra **Add items to W…** e o botão é **Add to pallet**. Uma palete lacrada precisa ser aberta primeiro.

## Lacrando e abrindo

- Uma palete do armazém **sealed** só pode ser movida ou aberta. A página lembra: unseal it to add items or adjust what is on it. Os separadores também não podem retirar de uma palete lacrada — a menos que a separação leve a palete inteira ou alguém a abra antes.
- Clique em **Unseal** para abri-la; clique em **Re-seal** quando terminar.
- Uma palete que acaba ficando sem itens (um separador leva os últimos) é marcada como vazia automaticamente.

## Ajustando o estoque em uma palete

As contagens às vezes se desviam: algo está danificado, falta uma caixa ou alguém colocou o item errado. Um ajuste corrige o que está registrado em uma palete. Ele precisa de uma permissão separada, **Adjust Inventory** (normalmente Office e Administrator) — sem ela, você não verá os botões abaixo.

Ele só está disponível para uma palete do armazém que está **open** e já tem **location**. Então aparecem dois botões: **Add from sorting area** e **Adjust inventory** — você pode usar um por vez.

1. Clique em **Adjust inventory**.
2. Para cada item, digite um número em **Change**: um sinal de menos remove (`-3`), um número simples adiciona. **After** mostra o resultado. Para adicionar um item que ainda não está na palete, pesquise sob **Another item**.
3. Escolha um **Reason**: Shrinkage, Damaged items, Correcting count, Correcting item type ou Other. Para Other você deve explicar em **Notes**.
4. Clique em **Record Adjustment**. Você não pode tirar mais do que a palete tem.

Cada ajuste é registrado com quem, quando e por quê, e altera o estoque disponível — não é um lançamento de triagem.

## Locais e movimentos recentes

- **Locations** — uma tabela de todos os locais ativos com o número de paletes ativas ali, separadas por status. Clique em um local para listar suas paletes e clique na tag da palete para abri-la na guia Pallets. Paletes esvaziadas, enviadas, recolhidas, liberadas, condenadas e desaparecidas não são contadas.
- **Recent Movements** — as 100 entradas mais recentes em todas as paletes (data, palete, local, status, observações).

A ordem dos locais ao longo do armazém (o caminho de separação) é definida em Setup por um administrador; isso decide o caminho que os separadores percorrem.

## Gestão de paletes

[Pallet Management](/pallet-management) (também precisa de Manage Pallets) é a lista simples de registros de paletes — use para **reimprimir uma etiqueta de palete** (Print Pallet Label) ou corrigir o registro de uma palete manualmente. Ela lista paletes ainda em uso; abra uma para ver sua Pallet Tag, Kind, Date Packed, Location, Status, Container Type (Pallet, Gaylord, Box, Bag ou Tote) e seu Pallet Status History. O tipo não pode ser alterado depois que a palete é rotulada.

Para o trabalho diário — mover paletes, montá-las, ajustá-las — use Inventory Movement em vez disso: ele registra cada mudança no histórico e verifica as regras para você, enquanto Pallet Management permite definir o status diretamente (a partir de uma lista dos status válidos para esse tipo de palete).

## Guias relacionados

- [Triagem de doações](/help/sorting) — como os itens entram na sorting area.
- [Preenchimento de pedido](/help/order-filling) — como os separadores retiram itens das paletes.
- [Envio](/help/shipping) — o que acontece depois que um pedido é preenchido.
