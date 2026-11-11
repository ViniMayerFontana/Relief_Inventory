<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Receba a solicitação de um parceiro — por telefone, ou por um formulário em papel que ele devolveu — e lance-a para
que o armazém a atenda. Depois de enviada, ela segue para [Atendimento de pedidos](/help/order-filling).

## Para que serve a Entrada de pedidos

Os parceiros chamam de *solicitações*; esta tela (e o lado da equipe do aplicativo) ainda as chama de **pedidos**.
São a mesma coisa. Você precisa da permissão **manage-orders** para usar a página.

O lançamento salva conforme você trabalha: o pedido é criado no momento em que você confirma o parceiro, e cada
linha de item é enviada ao servidor assim que você a adiciona. Uma queda de conexão ou uma falha nunca perde mais do
que a linha que você estava digitando.

## A lista de pedidos

Abra [Entrada de pedidos](/order-entry) para ver duas listas. Toque em qualquer linha para abrir aquele pedido.

- **Pedidos abertos - toque para abrir** — tudo o que ainda não terminou: Novo pedido, Pronto para atendimento, Em
  atendimento, Atendido, Pronto para expedição, Expedido e Entregue (incluindo Entregue aguardando um BOL assinado).
  Colunas: Data, Parceiro, Linhas, Itens, Status, Registrado por.
- **Concluídos recentemente** — os últimos 25 pedidos terminados (por exemplo Concluído ou Encerrado - não
  atendido).

**Novo pedido** inicia uma solicitação. **Formulário de pedido offline** (um menu no estilo **Imprimir**) produz um
formulário imprimível listando os números de item dos quais temos algum estoque, para enviar a um parceiro que
preencherá as quantidades à mão e o devolverá para você digitar. Ele nunca mostra números de estoque.

## Etapa 1 — Para quem é?

1. Clique em **Novo pedido**. A tela tem o título **Novo pedido — Para quem é?**
2. Busque na caixa **Parceiro** por nome, organização ou cidade e selecione o parceiro. (É a organização receptora
   ou o ponto de distribuição que faz a solicitação.)
3. Não está na lista? Digite o nome e escolha a opção de criação. Um formulário **Novo parceiro** abre: nomes,
   organização, telefone, e-mail, **CEP** primeiro, depois **Endereço**, Cidade, Estado e Condado. Você precisa de
   um nome e sobrenome, ou de uma organização. Quando o CEP/endereço é preenchido, o aplicativo pode consultar o
   condado e sugerir um endereço corrigido — aceite ou mantenha o que digitou. Se um condado está faltando na
   lista, digite-o na caixa Condado para adicioná-lo (informe o estado de 2 letras primeiro). Clique em **Salvar
   parceiro**.
4. **Confirmar contato e dados de expedição** aparece com os dados do parceiro. É para cá que o pedido é expedido,
   então confira se está atualizado e corrija o que tiver mudado. **Verificar endereço** reconfere o endereço se ele
   ainda não foi conferido. Pressionar Enter em uma caixa passa para a próxima.
5. Clique em **Iniciar pedido →**. Se você mudou algo, o botão mostra **Salvar dados e iniciar pedido →** e as
   alterações são salvas no registro do parceiro para todos.

## Etapa 2 — Lançando os itens

O cabeçalho mostra o **Pedido #** e a data, e uma barra fina mostra o nome do parceiro, cidade/estado e telefone.
**Alterar** ali permite escolher outro parceiro (enquanto o pedido ainda é editável).

1. Digite um número de item (ou parte do nome dele) na caixa **Item #** e selecione-o. O cursor pula para a
   **Qtd.**. Uma nota ao lado do nome do item mostra aproximadamente quantos estão disponíveis (por exemplo *~40
   utilizáveis disponíveis*, ou *nada disponível*). Isso é só uma dica para você — nunca leia números de estoque em
   voz alta para o parceiro, e você ainda pode lançar mais do que temos.
2. Digite a quantidade (1 ou mais) e pressione **Enter** (ou clique em **Adicionar**). A linha é salva e o cursor
   volta para o **Item #** para o próximo. Uma caixa **Comentário da linha (opcional)** também está disponível para
   notas sobre aquela linha.
3. Quando um item está acabando (no nível de estoque mínimo ou abaixo), uma caixa **Nível de necessidade
   (opcional)** aparece: **Crítico**, **Moderado** ou **Baixo**. Registre o que o parceiro lhe diz sobre o quanto
   precisa dele. É apenas contexto para quem dividir os itens em falta depois — deixe em branco se ele não disser.
4. Lançou o mesmo item duas vezes? Uma caixa intitulada **Ops** mostra o que você já lançou. Digite uma **Qtd.
   adicional** e clique em **Combinar →** para somá-la à linha existente, ou **Cancelar** (ou pressione Esc) para
   descartar.
5. Linha errada? Clique no ícone de lixeira ao lado dela e depois em **Excluir?** para confirmar (ou **Manter**
   para voltar atrás). Para mudar uma quantidade, exclua a linha e adicione-a de novo, ou use a caixa Combinar para
   somar mais.

A barra superior mostra *Salvando…*, *Todas as alterações salvas*, ou *N linha(s) não salvaram* com **Repetir
todas** (cada linha falhada também tem **Repetir**; linhas falhadas também tentam de novo sozinhas quando a conexão
volta). Os totais de **Linhas** e **Total de itens** aparecem sob a tabela. **← Todos os pedidos** volta à lista; o
pedido fica aberto para depois.

## Etapa 3 — Revisão e confirmação

Quando todos os itens estiverem lançados, clique em **Concluir pedido** (canto superior direito). A tela **Revisão
e confirmação — Pedido #** tem:

- **Resumo do pedido** — parceiro, número de linhas e total de itens.
- **Comentários** — qualquer coisa que o armazém deva saber.
- **Necessidades fora do catálogo** — coisas que o parceiro precisa e que não estão na nossa lista de itens (o
  mesmo que "Outras necessidades" no formulário em papel).
- **Entrega ou retirada** — escolha uma, além de uma **Data desejada**. Para entrega, escolha também os dias em que
  podem recebê-la (**Qualquer dia** ou dias individuais) e um **Horário de preferência**. Para retirada, o armazém
  define dias e horários.
- **Contato de entrega** (ou **Contato de retirada**) — nome e telefone, preenchidos a partir do parceiro; mude-os
  se outra pessoa receberá.
- **Instruções especiais de entrega** — códigos de portão, localização da doca, com quem falar na chegada. Elas
  seguem para o BOL quando o pedido é expedido.

Clique em **Enviar pedido** para terminar. **← Voltar** retorna aos itens sem enviar.

## Depois de enviar — o ciclo de vida do pedido

Enviar move o pedido de **Novo pedido** para **Pronto para atendimento**. Daí em diante o sistema o move:

`Novo pedido → Pronto para atendimento → Em atendimento → Atendido → Pronto para expedição → Expedido → Entregue →
Concluído`

- **Somente um pedido Novo pode ser editado.** Depois de enviado, as linhas e os detalhes ficam bloqueados, porque o
  piso trabalha a partir deles. Abrir tal pedido mostra os itens somente leitura com o selo de status.
- O status é definido pelo aplicativo conforme o trabalho acontece — você nunca o escolhe de uma lista. O
  atendimento é coberto em [Atendimento de pedidos](/help/order-filling) e a expedição em
  [Expedição](/help/shipping).
- Um pedido em que nada pôde ser separado termina como **Encerrado - não atendido** e nunca chega à Expedição.
