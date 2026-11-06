<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o controle de onde as paletes estão e coloque os itens triados em paletes do armazém para que os separadores possam encontrá-los.

## Para que serve esta tela

Abra [Movimento de estoque](/inventory-movement) (você precisa da permissão de gerenciamento de paletes). Ela tem três guias: **Paletes** (a que você usará o dia inteiro — guiada por leitura), **Locais** e **Movimentos recentes** (somente consulta).

**Sem palete significa “ainda na área de triagem”.** Quando os itens são triados (veja o guia [Triagem](/help/sorting)), eles contam como estoque disponível, mas ficam na área de triagem. Colocá-los em uma palete do armazém os tira de “sem palete” e dá a eles um lugar na prateleira. O estoque é agrupado por tipo de item, então você informa ao sistema *quantos* do item foram para a palete — não de qual doação vieram.

As tags de palete começam com uma letra para o tipo: **R** Receiving, **W** Warehouse, **S** Shipping, **H** Hold, **Q** Quarantine, seguidas de oito dígitos (por exemplo `W00000123`). Uma palete do armazém pode ser *sealed* (embrulhada e fechada), *open* ou *empty*. Os separadores só podem retirar itens de paletes abertas — veja o guia [Preenchimento de pedido](/help/order-filling).

## A barra de leitura

No topo da guia Paletes há uma caixa sempre pronta para a próxima leitura. Depois de clicar em qualquer lugar da página, o cursor volta para ela (a menos que você esteja digitando em outro campo). Escaneie ou digite um código e pressione Enter ou **Localizar**.

- Sem uma palete mostrando, uma leitura é interpretada como **código de barras da palete**.
- Com uma palete mostrando, uma leitura que corresponda a um **código de local** move essa palete para lá imediatamente. Qualquer outra leitura é interpretada como uma palete e substitui a que está na tela.
- Uma mensagem verde confirma o que aconteceu; uma vermelha diz o que deu errado (por exemplo, uma palete desconhecida). O botão do alto-falante à direita silencia ou ativa os sons de leitura.

## Consultando uma palete

Escaneie a etiqueta de uma palete. A tela mostra sua etiqueta e tipo, onde ela está (*em* um local ou *nenhum local registrado*), seu status, quando foi atualizada pela última vez e, para uma palete do armazém, a data de vencimento mais próxima dos itens nela. Abaixo disso:

- **Conteúdo da palete** — para uma palete do armazém, cada item e sua quantidade. Para uma palete de Recebimento, o que a triagem registrou saindo dela (item, disposição, quantidade). Outros tipos não rastreiam conteúdo.
- **Histórico de movimentações** — cada movimento e mudança de status, mais recente primeiro (data, local, status, observações).

**Limpar / nova palete** remove a palete da tela para que você possa escanear outra ou montar uma nova.

## Movendo uma palete

1. Escaneie a tag da palete.
2. Escaneie o código da prateleira ou estante. O movimento é registrado imediatamente (“… movida para …”), e a palete mantém seu status. Escanear o local em que já está apenas informa isso.
3. Prefere o formulário? Digite ou escolha um código em **Local**, acrescente **Observações** se quiser e clique em **Registrar movimentação**. O local deve ser conhecido e ativo.

Para paletes de Recebimento, Expedição, Retenção e Quarentena também há um menu suspenso **Status**; altere e clique em **Registrar status** (o botão fica **Registrar movimentação** quando o local mudou). Uma palete do armazém não tem menu suspenso de Status — seu status muda por meio de lacrar e abrir abaixo.

## Montando uma nova palete do armazém

Um líder ou motorista de empilhadeira faz isso quando uma palete sai da área de triagem. Sem nenhuma palete mostrando, a página diz **Montar nova palete do armazém**.

1. Em **Na área de triagem** está a lista de coleta: cada item ainda esperando, quantos (*Aguardando*) e sua data de vencimento mais próxima. Clique em **Colocar todos os N na palete** para preparar um item. Itens que compartilham um número ACS de item são agrupados em uma linha; clique nele para expandir os itens individuais ou use o botão para preparar todos.
2. Itens preparados aparecem em uma tabela acima. Altere uma **Quantidade** se apenas parte dele vai para esta palete (não pode exceder o que está esperando), ou clique em **Remover**.
3. Verifique a data **Vence em** de cada item na lista — é a data mais próxima conhecida para esse item e vai no rótulo do item; altere ou limpe se estiver errada. Digite ou escaneie o **Local** para onde a palete vai. A própria data **Vence em** da palete é preenchida com a data mais próxima entre os itens; altere-a ou clique em **Automático** para voltar. Adicione **Observações** se necessário.
4. Clique em **Lacrar e posicionar**. Uma nova palete do armazém é criada, lacrada e colocada nesse local. Uma linha verde mostra sua etiqueta e conteúdo, com um botão **Imprimir etiqueta da palete** — imprima-a e coloque-a na palete — e um botão **Imprimir etiquetas dos itens**: uma pequena etiqueta para cada item que você colocou, mostrando o número ACS do item e a descrição, quantidade, data de vencimento mais próxima e palete, com código de barras. Cole cada uma em suas caixas. Etiquetas de item são impressas no tamanho pequeno de etiqueta (definido na página Impressoras). Para imprimi-las de novo depois, escaneie a palete: sua lista **Etiquetas de estoque** tem um botão Imprimir para cada uma.

O sistema não deixa você colocar em paletes mais itens do que ainda estão na área de triagem (“Somente N de … ainda não estão em uma palete”). Quando tudo está em uma palete, a lista diz *Nada aguardando — todos os itens triados já estão em uma palete.*

**Adicionando a uma palete existente:** escaneie uma palete do armazém que esteja *aberta*; a mesma lista agora mostra **Adicionar itens à W…** e o botão é **Adicionar à palete**. Uma palete lacrada precisa ser aberta primeiro.

## Lacrando e abrindo

- Uma palete do armazém **lacrada** só pode ser movida ou aberta. A página lembra: abra o lacre para adicionar itens ou ajustar o conteúdo. Os separadores também não podem retirar de uma palete lacrada — a menos que a separação leve a palete inteira ou alguém a abra antes.
- Clique em **Abrir lacre** para abri-la; clique em **Lacrar novamente** quando terminar.
- Uma palete que acaba ficando sem itens (um separador leva os últimos) é marcada como vazia automaticamente.

## Ajustando o estoque em uma palete

As contagens às vezes se desviam: algo está danificado, falta uma caixa ou alguém colocou o item errado. Um ajuste corrige o que está registrado em uma palete. Ele precisa de uma permissão separada, **Ajustar estoque** (normalmente disponível para Escritório e Administrador) — sem ela, você não verá os botões abaixo.

Ele só está disponível para uma palete do armazém que está **aberta** e já tem **local**. Então aparecem dois botões: **Adicionar da área de triagem** e **Ajustar estoque** — você pode usar um por vez.

1. Clique em **Ajustar estoque**.
2. Para cada item, digite um número em **Alteração**: um sinal de menos remove (`-3`), um número simples adiciona. **Após** mostra o resultado. Para adicionar um item que ainda não está na palete, pesquise em **Outro item**.
3. Escolha um **Motivo**: Perda, Itens danificados, Correção de contagem, Correção do tipo de item ou Outro. Para Outro você deve explicar em **Observações**.
4. Clique em **Registrar ajuste**. Você não pode tirar mais do que a palete tem.

Cada ajuste é registrado com quem, quando e por quê, e altera o estoque disponível — não é um lançamento de triagem.

## Locais e movimentos recentes

- **Locais** — uma tabela de todos os locais ativos com o número de paletes ativas ali, separadas por status. Clique em um local para listar suas paletes e clique na etiqueta da palete para abri-la na guia Paletes. Paletes esvaziadas, enviadas, recolhidas, liberadas, condenadas e desaparecidas não são contadas.
- **Movimentos recentes** — as 100 entradas mais recentes em todas as paletes (data, palete, local, status, observações).

A ordem dos locais ao longo do armazém (o caminho de separação) é definida em Configuração por um administrador; isso decide o caminho que os separadores percorrem.

## Gestão de paletes

[Gerenciamento de paletes](/pallet-management) (também precisa da permissão de gerenciamento de paletes) é a lista simples de registros de paletes — use para **reimprimir uma etiqueta de palete** (Imprimir etiqueta da palete) ou corrigir o registro de uma palete manualmente. Ela lista paletes ainda em uso; abra uma para ver sua etiqueta, tipo, data de embalagem, local, status, tipo de recipiente (palete, gaylord, caixa, saco ou caixa plástica) e histórico de status. O tipo não pode ser alterado depois que a palete é rotulada.

Para o trabalho diário — mover paletes, montá-las, ajustá-las — use Movimento de estoque: ele registra cada mudança no histórico e verifica as regras para você, enquanto Gerenciamento de paletes permite definir o status diretamente (a partir de uma lista dos status válidos para esse tipo de palete).

## Guias relacionados

- [Triagem de doações](/help/sorting) — como os itens entram na sorting area.
- [Preenchimento de pedido](/help/order-filling) — como os separadores retiram itens das paletes.
- [Envio](/help/shipping) — o que acontece depois que um pedido é preenchido.
