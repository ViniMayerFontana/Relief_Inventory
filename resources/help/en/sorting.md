<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Transforme as paletes registradas em [Recebimento](/help/receiving) em lançamentos do livro razão, item por item — é aqui que uma doação
realmente se torna estoque contado.

## Para que serve a triagem

A triagem é guiada por leitura de código e salva conforme você avança — cada linha que você insere é enviada ao servidor imediatamente,
portanto uma conexão caída ou uma falha nunca perde mais do que a linha em que você estava. Trabalhe uma palete por vez: escaneie a
tag dela uma vez e cada item que você inserir conta para essa palete até que você escaneie (ou limpe) outra. Isso registra o que cada
doação e cada palete realmente continham — depois de triado, o estoque é agrupado por tipo de item, então um item na prateleira não pode
mais ser rastreado até um doador ou palete específicos.

Os itens triados ficam na **sorting area** até alguém colocá-los em uma palete do armazém — veja o guia [Movimento de estoque](/help/inventory-movement).

## Iniciando ou retomando uma sessão

Abra [Triagem de doações](/donation-sorting) para ver até três listas:

- **In Progress** — sessões que alguém já começou. Toque em uma para retomar exatamente de onde parou.
- **Ready to Sort** — doações registradas em Recebimento, aguardando triagem. Toque em uma para começar a triagem.
- **Recently Completed** — as últimas 25 sessões concluídas, abertas em modo somente leitura.

Uma doação cujo doador ainda é desconhecido mostra uma etiqueta vermelha *donor ID pending* em cada lista.

**Start Sorting (untagged)**, no topo da página, abre uma nova sessão sem nenhum registro de Recebimento por trás — use isso apenas para
bens que apareceram sem passar pelo recebimento primeiro. O campo do doador é totalmente editável, ao contrário de uma sessão que veio de
Recebimento.

## Trabalhando com uma palete

1. Digite ou escaneie a tag da palete (por exemplo, `R00000042`) em **Pallet Tag**, ou toque em **Camera Scan** para usar a câmera do
dispositivo e depois em **Set Pallet**. Apenas paletes de Recebimento (tags começando com R) funcionam aqui — a tag de um armazém ou de
outra palete é recusada, assim como uma palete de Recebimento que pertence a outra doação (abra essa doação em Ready to Sort em vez
disso). Tudo o que você inserir em seguida será atribuído a esta palete: a barra mostra *Sorting from pallet …*. Linhas inseridas sem
uma palete definida ainda são salvas, mas não ficam registradas como origem. Definir uma palete pela primeira vez também marca essa palete
como sendo triada.
2. Para cada item da palete, escaneie o código de barras ou pesquise pelo nome na caixa do item. O campo **Qty** é preenchido com 1 —
pressione Enter para salvar um, digite outro número e pressione Enter, ou continue escaneando (veja abaixo). Em seguida, verifique o botão de
**disposition**: **New** (não usado, ainda na embalagem original — conta para o estoque), **Usable** (usado ou aberto, em bom estado — conta
para o estoque), **Outdated** (vencido na chegada), **Trash** (danificado/irrecuperável) ou **Divert** (útil, mas enviado para outra
organização). Você também pode clicar em **Add**. A disposição usada por último permanece selecionada, porque sequências do mesmo tipo de
mercadoria são comuns. Apenas **New** e **Usable** entram no estoque disponível; **Outdated**, **Trash** e **Divert** são registrados para
relatórios de qualidade do doador.
3. Sabe a data de validade? Clique no botão do calendário ao lado de Qty, escolha a data e depois **Done** (**Clear** remove a data).
Ela é opcional e é salva com essa linha e exibida na coluna *Expires*. Ela é limpa após cada linha adicionada.
4. Cometeu um erro em uma linha? Clique no ícone de lixeira ao lado dela e depois em **Delete?** para confirmar — é uma exclusão em dois toques,
sem popup.
5. Quando a palete estiver vazia, clique em **Pallet Empty**, então diga se ela **looks OK** ou deve ser **set aside — damaged?**. Essa é uma anotação
em um toque para um supervisor acompanhar mais tarde; não bloqueia nada aqui. Esvaziar a última palete da doação conclui automaticamente a
doação. Use **Change Pallet** em vez disso para mudar para outra palete sem esvaziar esta.

## Escaneando códigos de barras

Um leitor de código de barras funciona como um datilógrafo muito rápido, então um scan vai para onde o cursor estiver. Depois de clicar, a página
coloca o cursor de volta no lugar em que o próximo scan deve ir: na caixa do item ou na caixa de Qty quando um item já foi escolhido. Não se
preocupe em clicar ao redor.

- **Scan, scan, scan.** Depois que um item é selecionado, escaneie o próximo código de barras diretamente na caixa **Qty**: o item em que
você estava é salvo (quantidade 1, ou o que a caixa Qty mostrava) e o novo código de barras é consultado. Digite um número e pressione Enter em
vez disso quando houver mais de um.
- **Mesmo item de novo?** Escanear o mesmo item novamente, diretamente na caixa Qty, conta como quantidade: escaneie cada um dos dez itens
idênticos e a quantidade sobe para 10. Escaneie um item diferente e a contagem é salva.
- **Cartons and cases.** Um código de barras de caixa já configurado seleciona o único item dentro e preenche Qty com o número na caixa. Você
ainda pode alterar o número.
- **Combine duplicate lines.** Se você escaneou cada item individualmente, a lista de linhas terá muitas linhas idênticas. Quando houver alguma,
um botão **Combine duplicate lines** aparece no topo; clique nele e confirme para somar linhas com o mesmo item, palete, disposição, condição e
data de validade (digitada pela mesma pessoa no mesmo dia). Isso não pode ser desfeito, então um único scan errado não pode mais ser excluído
individualmente depois. Os totais não mudam.

### O que os sinais sonoros significam

- Um bipe curto e alto — corresponde a um único item.
- Dois bipes rápidos e ascendentes — corresponde a uma caixa ou cartucho.
- Um tom mais baixo e mais longo — o código de barras não está na lista de itens; um formulário abre.
- Dois sons baixos — leitura falhada ou busca sem resultado. Escaneie novamente ou pesquise pelo nome.

Prefere silêncio? Clique no botão do alto-falante na barra superior para silenciar ou ativar som; a página lembra essa escolha no navegador.

## Um código de barras que o sistema não conhece

Nada é adicionado à lista de itens até você clicar em **Save Item**.

1. Um código de barras **single-item** desconhecido abre **Add New Item** com o UPC já preenchido. Se o código de barras for encontrado em um
banco de produtos online gratuito (Open Food Facts / Open Products Facts), uma descrição sugerida aparece alguns instantes depois, com uma nota
nomeando a fonte — confira a sugestão com o produto em frente a você. Se nada for encontrado, ou a busca estiver indisponível ou ocupada, a nota diz isso;
digite a descrição você mesmo. Continue escaneando neste ponto e você só ouvirá o tom baixo novamente — termine ou cancele o formulário primeiro.
2. Escolha o **Item Type** (pesquise por nome ou número). Se este for um tipo totalmente novo, escolha a opção de adicionar e preencha **New Item
Type**, **Measured By** (uma unidade como Each ou Pound) e **Category** — tudo pode ser criado em linha. Em seguida, **Save Item**; o novo item é
selecionado e o cursor salta para Qty.
3. Em *This barcode is on:*, escolha **A case of items already in the list** se o código de barras for realmente uma caixa de algo que você já
carrega. Isso abre **New Carton Barcode**.
4. Um código de barras **carton** desconhecido abre **New Carton Barcode** diretamente. Escaneie um dos itens individuais dentro dele (ou pesquise
por ele) — se o número do cartucho corresponder a um item, ele será sugerido, e itens do mesmo fabricante podem ser oferecidos como botões. Digite
**Packs in the carton** e **Items in each pack** (6 packs de 5 fazem 30 itens por cartucho; para itens soltos sem pacotes internos, deixe Packs em
1). Clique em **Confirm & Use**: a partir de então, escanear esse cartucho preenche a contagem automaticamente. **This is a single item, not a
carton** volta para Add New Item.
5. Não consegue encontrar o item por código de barras? Digite o nome dele na busca do item e escolha **Add "…" as a new item** para abrir o mesmo
formulário.

## Cabeçalho da sessão e fechamento

- Para uma sessão que veio de Recebimento, o doador aparece somente leitura (já foi registrado no dock) com um link **Edit** se precisar corrigir.
Para uma sessão sem tag, o campo do doador pode ser editado diretamente. Procure o doador ou adicione um novo na caixa de busca.
- **Donor unidentified — flag for follow-up** e **Comments** são salvos automaticamente conforme você muda — não há nada para enviar.
- A tabela abaixo da entrada de linhas lista todas as linhas (hora, item, quantidade, validade, disposição, palete), da mais recente para a mais
antiga, com totais acumulados embaixo: Usable, Outdated, Trash, Diverted e a taxa de descarte.
- Observe o indicador de salvamento na barra superior: *Saving…*, *All changes saved*, ou uma contagem de falhas com o botão **Retry All**.
Uma linha com falha também tem seu próprio **Retry**. Linhas com falha tentam novamente automaticamente assim que a conexão voltar.
- Clique em **Complete Session** quando todas as paletes estiverem concluídas. Um item que você selecionou mas ainda não adicionou é adicionado
primeiro (você será perguntado pela quantidade se ela estiver ausente). Se ainda houver linhas que não chegaram ao servidor, o sistema pede
confirmação antes de concluir mesmo assim.
- **All Sessions** volta para a lista sem perder o item que você estava digitando. Sair da página com trabalho não salvo mostra um aviso.
- Uma sessão concluída reabre em modo somente leitura. Se precisar corrigir algo, use **Reopen Session** para voltar a editar.
