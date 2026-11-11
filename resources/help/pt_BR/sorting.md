<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Transforme os pallets registrados no [Recebimento](/help/receiving) em lançamentos item a item no ledger — é aqui que
uma doação realmente vira estoque contado.

## Para que serve a triagem

A triagem é orientada a leitura de código de barras e salva conforme você trabalha — cada linha que você lança é
enviada ao servidor imediatamente, de modo que uma queda de conexão ou uma falha nunca perde mais do que a linha em
que você estava. Trabalhe um pallet por vez: escaneie a tag dele uma vez e, então, cada item que você lançar conta
para aquele pallet até você escanear (ou limpar) outro. Isso registra o que cada doação e pallet realmente continham —
uma vez triado, o estoque é reunido por tipo de item, de modo que um item de prateleira não pode depois ser rastreado
de volta a um doador ou pallet específico.

Os bens triados permanecem na **área de triagem** até alguém colocá-los em um pallet de armazém — veja o guia de
[Movimentação de estoque](/help/inventory-movement).

## Iniciando ou retomando uma sessão

Abra [Triagem de doações](/donation-sorting) para ver até três listas:

- **Em andamento** — sessões que alguém já iniciou. Toque em uma para retomar exatamente de onde ela parou.
- **Prontas para triagem** — doações registradas no Recebimento, aguardando serem pegas. Toque em uma para começar a
  triá-la.
- **Concluídas recentemente** — as últimas 25 sessões terminadas, abertas somente leitura.

Uma doação cujo doador ainda é desconhecido mostra uma tag vermelha *doador a identificar* em cada lista.

**Iniciar triagem (sem etiqueta)**, no topo da página, abre uma sessão nova sem nenhum registro de Recebimento por
trás — use-a apenas para bens que chegaram sem passar pelo Recebimento antes. O campo do doador dela é totalmente
editável, ao contrário de uma sessão que veio do Recebimento.

## Trabalhando um pallet

1. Digite ou escaneie a tag do pallet (ex.: `R00000042`) em **Tag do pallet**, ou toque em **Leitura pela câmera**
   para usar a câmera do dispositivo, e depois **Definir pallet**. Somente pallets de Recebimento (tags começando com
   R) funcionam aqui — a tag de um pallet de armazenagem ou de outro tipo é recusada, e também é recusada a tag de um
   pallet de Recebimento que pertence a outra doação (abra essa doação a partir de Prontas para triagem). Tudo o que
   você lançar a seguir é atribuído a este pallet: a barra mostra *Triando do pallet …*. Linhas lançadas sem pallet
   definido ainda salvam, mas não serão registradas contra uma origem. Definir um pallet pela primeira vez também o
   marca como em triagem.
2. Para cada item no pallet, escaneie o código de barras dele ou busque pelo nome na caixa de item. A **Qtd.** é
   preenchida com 1 — pressione Enter para salvar uma, digite outro número e pressione Enter, ou continue escaneando
   (veja abaixo). Depois confira o botão de **destinação**: **Novo** (não usado, ainda na embalagem original — conta
   no estoque), **Utilizável** (usado ou aberto, em bom estado — conta no estoque), **Vencido** (vencido na chegada),
   **Descarte** (danificado/inutilizável) ou **Redirecionar** (utilizável, mas passado a outra organização). Você
   também pode clicar em **Adicionar**. A destinação que você usou por último permanece selecionada, já que lotes do
   mesmo tipo de bem são comuns. Somente Novo e Utilizável somam ao estoque disponível; Vencido, Descarte e
   Redirecionar são registrados para os relatórios de qualidade de doador.
3. Sabe a data de validade? Clique no botão de calendário ao lado da Qtd., escolha a data e depois **Pronto**
   (**Limpar** remove). É opcional, e é salvo com aquela linha e mostrado na coluna *Validade*. Ele se reinicia depois
   de cada linha que você adiciona.
4. Errou em uma linha? Clique no ícone de lixeira ao lado dela e depois em **Excluir?** para confirmar — é uma
   exclusão de dois toques, sem popup.
5. Quando o pallet estiver vazio, clique em **Pallet vazio** e depois diga se ele **está em ordem** ou se deve ser
   **apartado — danificado?**. É um aviso de um toque para um supervisor acompanhar depois; não bloqueia nada aqui.
   Esvaziar o último pallet da doação conclui a doação automaticamente. Use **Trocar pallet** para mover para outro
   pallet sem esvaziar este.

## Escaneando códigos de barras

Um leitor de código de barras funciona como um digitador muito rápido, então uma leitura vai para onde quer que o
cursor esteja. Depois de um clique, a página devolve o cursor ao lugar da próxima leitura: a caixa de item, ou a
caixa de Qtd. quando um item já está escolhido. Não se preocupe em ficar clicando.

- **Escaneie, escaneie, escaneie.** Depois que um item é escolhido, escaneie o próximo código de barras direto na
  caixa de **Qtd.**: o item em que você estava é salvo (quantidade 1, ou o que a caixa de Qtd. mostrava) e o novo
  código de barras é consultado. Digite um número e pressione Enter quando houver mais de um.
- **O mesmo item de novo?** Escanear o *mesmo* item de novo, direto na caixa de Qtd., conta-o: escaneie cada um de
  dez itens idênticos e a quantidade sobe para 10. Escaneie um item diferente e a contagem é salva.
- **Caixas master.** Um código de barras de caixa master já cadastrado escolhe o único item dentro dele e preenche a
  Qtd. com o número da caixa. Você ainda pode mudar o número.
- **Combine linhas duplicadas.** Se você escaneou cada item um por vez, a lista de linhas terá muitas linhas
  idênticas. Quando houver, um botão **Combinar linhas duplicadas** aparece no topo; clique nele e confirme para
  somar linhas com o mesmo item, pallet, destinação, estado e data de validade (lançadas pela mesma pessoa no mesmo
  dia). Não pode ser desfeito, então uma leitura errada única não pode mais ser excluída isoladamente depois. Os
  totais não mudam.

### O que os bipes significam

- Um bipe curto agudo — correspondeu a um único item.
- Dois bipes rápidos crescentes — correspondeu a uma caixa master.
- Um tom mais grave e longo — o código de barras não está na lista de itens; um formulário abre.
- Dois zunidos graves — leitura perdida ou consulta falhada. Escaneie de novo ou busque pelo nome.

Prefere silêncio? Clique no botão de alto-falante na barra superior para silenciar ou reativar; a página lembra da
escolha naquele navegador.

## Um código de barras que o sistema não conhece

Nada é adicionado à lista de itens até você clicar em **Salvar item**.

1. Um código de barras desconhecido de **item único** abre **Adicionar novo item** com o UPC já preenchido. Se o
   código de barras for encontrado em um banco de produtos on-line gratuito (Open Food Facts / Open Products Facts),
   uma descrição sugerida aparece um momento depois, com uma nota nomeando a fonte — confira contra o produto à sua
   frente. Se nada for encontrado, ou a consulta estiver desligada ou ocupada, a nota diz isso; digite a descrição
   você mesmo. Continue escaneando neste ponto e você só ouvirá o tom grave de novo — termine ou cancele o
   formulário primeiro.
2. Escolha o **Tipo de item** (busque por nome ou número). Se este for um tipo totalmente novo, escolha adicionar um
   e preencha **Novo tipo de item**, **Medido em** (uma unidade, como Unidade ou Libra) e **Categoria** — todos podem
   ser criados na hora. Depois **Salvar item**; o novo item é selecionado e o cursor pula para a Qtd.
3. Em *Este código de barras está em:*, escolha **Uma caixa master de itens já na lista** se o código de barras é
   realmente uma caixa de algo que você já tem. Isso abre **Novo código de barras de caixa master**.
4. Um código de barras desconhecido de **caixa master** abre **Novo código de barras de caixa master** direto.
   Escaneie um dos itens únicos dentro dele (ou busque-o) — se o número da caixa corresponde a um item, ele é
   sugerido, e itens do mesmo fabricante podem ser oferecidos como botões. Informe **Pacotes na caixa master** e
   **Itens em cada pacote** (6 pacotes de 5 fazem 30 itens por caixa; para itens soltos sem pacotes internos, deixe
   Pacotes em 1). Clique em **Confirmar e usar**: daí em diante, escanear aquela caixa preenche a contagem
   automaticamente. **Isto é um item único, não uma caixa master** volta para Adicionar novo item.
5. Não encontrou o item pelo código de barras? Digite o nome dele na busca de itens e escolha **Adicionar "…" como um
   novo item** para abrir o mesmo formulário.

## Cabeçalho da sessão e encerramento

- Para uma sessão que veio do Recebimento, o doador aparece somente leitura (já foi registrado na doca) com um link
  **Editar** se precisar de correção. Para uma sessão sem etiqueta, o campo do doador é editável diretamente. Busque
  o doador ou adicione um novo pela caixa de busca.
- **Doador não identificado — sinalizar para acompanhamento** e **Comentários** salvam automaticamente conforme você
  os altera — nada para enviar.
- A tabela abaixo do lançamento de linhas lista cada linha (hora, item, quantidade, validade, destinação, pallet), da
  mais recente para a mais antiga, com totais acumulados por baixo: Utilizável, Vencido, Descarte, Redirecionado e a
  taxa de descarte.
- Observe o indicador de salvamento na barra superior: *Salvando…*, *Todas as alterações salvas*, ou uma contagem de
  falhas com o botão **Repetir todas**. Uma linha falhada também tem o seu próprio **Repetir**. Linhas falhadas
  tentam de novo automaticamente quando a sua conexão volta.
- Clique em **Concluir sessão** quando cada pallet estiver pronto. Um item que você escolheu mas ainda não adicionou
  é adicionado primeiro (você receberá um pedido de quantidade se ela estiver faltando). Se alguma linha ainda não
  chegou ao servidor, ele pede confirmação antes de concluir mesmo assim.
- **Todas as sessões** volta à lista sem perder o item que você estava lançando. Sair da página com trabalho não
  salvo mostra um aviso.
- Uma sessão concluída reabre somente leitura. Se precisar corrigir algo, use **Reabrir sessão** para voltar à
  edição dela.
