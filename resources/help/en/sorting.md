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

Os itens triados ficam na **área de triagem** até alguém colocá-los em uma palete do armazém — veja o guia [Movimento de estoque](/help/inventory-movement).

## Iniciando ou retomando uma sessão

Abra [Triagem de doações](/donation-sorting) para ver até três listas:

- **Em andamento** — sessões que alguém já começou. Toque em uma para retomar exatamente de onde parou.
- **Aguardando triagem** — doações registradas em Recebimento, aguardando triagem. Toque em uma para começar a triagem.
- **Concluídas recentemente** — as últimas 25 sessões concluídas, abertas em modo somente leitura.

Uma doação cujo doador ainda é desconhecido mostra a etiqueta vermelha *identificação do doador pendente* em cada lista.

**Iniciar triagem sem recebimento**, no topo da página, abre uma nova sessão sem nenhum registro de Recebimento por trás — use isso apenas para
bens que apareceram sem passar pelo recebimento primeiro. O campo do doador é totalmente editável, ao contrário de uma sessão que veio de
Recebimento.

## Trabalhando com uma palete

1. Digite ou escaneie a etiqueta da palete (por exemplo, `R00000042`) em **Etiqueta do palete**, ou toque no botão de câmera para usar a câmera do
dispositivo e depois em **Definir palete**. Apenas paletes de Recebimento (etiquetas começando com R) funcionam aqui — a etiqueta de um armazém ou de
outra palete é recusada, assim como uma palete de Recebimento que pertence a outra doação (abra essa doação em Ready to Sort em vez
disso). Tudo o que você inserir em seguida será atribuído a esta palete: a barra mostra *Sorting from pallet …*. Linhas inseridas sem
uma palete definida ainda são salvas, mas não ficam registradas como origem. Definir uma palete pela primeira vez também marca essa palete
como sendo triada.
2. Para cada item da palete, escaneie o código de barras ou pesquise pelo nome na caixa do item. O campo **Qtd.** é preenchido com 1 —
pressione Enter para salvar um, digite outro número e pressione Enter, ou continue escaneando (veja abaixo). Em seguida, verifique a opção de
**condição/destino**: **Novo** (sem uso, ainda na embalagem original — conta para o estoque), **Aproveitável** (usado ou aberto, em bom estado — conta
para o estoque), **Vencido** (vencido na chegada), **Descartar** (danificado/irrecuperável) ou **Redirecionar** (útil, mas enviado para outra
organização). Você também pode clicar em **Adicionar**. A opção usada por último permanece selecionada, porque sequências do mesmo tipo de
mercadoria são comuns. Apenas **Novo** e **Aproveitável** entram no estoque disponível; **Vencido**, **Descartar** e **Redirecionar** são registrados para
relatórios de qualidade do doador.
3. Sabe a data de validade? Clique no botão do calendário ao lado de Qtd., escolha a data e depois **Concluir** (**Limpar** remove a data).
Ela é opcional e é salva com essa linha e exibida na coluna *Vencimento*. Ela é limpa após cada linha adicionada.
4. Cometeu um erro em uma linha? Clique no ícone de lixeira ao lado dela e depois em **Excluir?** para confirmar — é uma exclusão em dois toques,
sem popup.
5. Quando a palete estiver vazia, clique em **Palete vazio**, então diga se ela está **em boas condições** ou deve ser **separada por estar danificada**. Essa é uma anotação
em um toque para um supervisor acompanhar mais tarde; não bloqueia nada aqui. Esvaziar a última palete da doação conclui automaticamente a
doação. Use **Trocar palete** em vez disso para mudar para outra palete sem esvaziar esta.

## Escaneando códigos de barras

Um leitor de código de barras funciona como um datilógrafo muito rápido, então um scan vai para onde o cursor estiver. Depois de clicar, a página
coloca o cursor de volta no lugar em que o próximo scan deve ir: na caixa do item ou na caixa de Qty quando um item já foi escolhido. Não se
preocupe em clicar ao redor.

- **Escaneie em sequência.** Depois que um item é selecionado, escaneie o próximo código de barras diretamente na caixa **Qtd.**: o item em que
você estava é salvo (quantidade 1, ou o que a caixa Qtd. mostrava) e o novo código de barras é consultado. Digite um número e pressione Enter em
vez disso quando houver mais de um.
- **Mesmo item de novo?** Escanear o mesmo item novamente, diretamente na caixa Qty, conta como quantidade: escaneie cada um dos dez itens
idênticos e a quantidade sobe para 10. Escaneie um item diferente e a contagem é salva.
- **Caixas e embalagens.** Um código de barras de caixa já configurado seleciona o único item dentro e preenche Qtd. com o número na caixa. Você
ainda pode alterar o número.
- **Combinar linhas duplicadas.** Se você escaneou cada item individualmente, a lista de linhas terá muitas linhas idênticas. Quando houver alguma,
um botão **Combinar linhas duplicadas** aparece no topo; clique nele e confirme para somar linhas com o mesmo item, palete, destino, condição e
data de validade (digitada pela mesma pessoa no mesmo dia). Isso não pode ser desfeito, então um único scan errado não pode mais ser excluído
individualmente depois. Os totais não mudam.

### O que os sinais sonoros significam

- Um bipe curto e alto — corresponde a um único item.
- Dois bipes rápidos e ascendentes — corresponde a uma caixa ou cartucho.
- Um tom mais baixo e mais longo — o código de barras não está na lista de itens; um formulário abre.
- Dois sons baixos — leitura falhada ou busca sem resultado. Escaneie novamente ou pesquise pelo nome.

Prefere silêncio? Clique no botão do alto-falante na barra superior para silenciar ou ativar som; a página lembra essa escolha no navegador.

## Um código de barras que o sistema não conhece

Nada é adicionado à lista de itens até você clicar em **Salvar item**.

1. Um código de barras de **item individual** desconhecido abre **Adicionar novo item** com o UPC já preenchido. Se o código de barras for encontrado em um
banco de produtos online gratuito (Open Food Facts / Open Products Facts), uma descrição sugerida aparece alguns instantes depois, com uma nota
nomeando a fonte — confira a sugestão com o produto em frente a você. Se nada for encontrado, ou a busca estiver indisponível ou ocupada, a nota diz isso;
digite a descrição você mesmo. Continue escaneando neste ponto e você só ouvirá o tom baixo novamente — termine ou cancele o formulário primeiro.
2. Escolha o **Tipo de item** (pesquise por nome ou número). Se este for um tipo totalmente novo, escolha a opção de adicionar e preencha **Novo tipo de
item**, **Unidade de medida** (uma unidade como unidade ou libra) e **Categoria** — tudo pode ser criado em linha. Em seguida, **Salvar item**; o novo item é
selecionado e o cursor salta para Qty.
3. Em *Este código de barras está em:*, escolha **Uma caixa de itens já cadastrados** se o código de barras for realmente uma caixa de algo que você já
armazena. Isso abre **Novo código de barras de caixa**.
4. Um código de barras de **caixa** desconhecido abre **Novo código de barras de caixa** diretamente. Escaneie um dos itens individuais dentro dela (ou pesquise
por ela) — se o número do código de barras corresponder a um item, ele será sugerido, e itens do mesmo fabricante podem ser oferecidos como botões. Digite
**Pacotes na caixa** e **Itens em cada pacote** (6 pacotes de 5 fazem 30 itens por caixa; para itens soltos sem pacotes internos, deixe Pacotes em
1). Clique em **Confirmar e usar**: a partir de então, escanear essa caixa preenche a contagem automaticamente. **Isto é um item individual, não uma
caixa** volta para Adicionar novo item.
5. Não consegue encontrar o item por código de barras? Digite o nome dele na busca do item e escolha **Adicionar "…" como novo item** para abrir o mesmo
formulário.

## Cabeçalho da sessão e fechamento

- Para uma sessão que veio de Recebimento, o doador aparece somente leitura (já foi registrado no cais) com um link **Editar** se precisar corrigir.
Para uma sessão sem tag, o campo do doador pode ser editado diretamente. Procure o doador ou adicione um novo na caixa de busca.
- **Doador não identificado — sinalizar para acompanhamento** e **Observações** são salvos automaticamente conforme você muda — não há nada para enviar.
- A tabela abaixo da entrada de linhas lista todas as linhas (hora, item, quantidade, validade, disposição, palete), da mais recente para a mais
antiga, com totais acumulados embaixo: Aproveitáveis, Vencidos, Descartados, Redirecionados e a taxa de descarte.
- Observe o indicador de salvamento na barra superior: *Salvando…*, *Todas as alterações salvas*, ou uma contagem de falhas com o botão **Tentar novamente em todas**.
Uma linha com falha também tem seu próprio **Tentar novamente**. Linhas com falha tentam novamente automaticamente assim que a conexão voltar.
- Clique em **Concluir sessão** quando todas as paletes estiverem concluídas. Um item que você selecionou mas ainda não adicionou é adicionado
primeiro (você será perguntado pela quantidade se ela estiver ausente). Se ainda houver linhas que não chegaram ao servidor, o sistema pede
confirmação antes de concluir mesmo assim.
- **Todas as sessões** volta para a lista sem perder o item que você estava digitando. Sair da página com trabalho não salvo mostra um aviso.
- Uma sessão concluída reabre em modo somente leitura. Se precisar corrigir algo, use **Reabrir sessão** para voltar a editar.
