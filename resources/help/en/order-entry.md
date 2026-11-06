<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Receba a solicitação de um parceiro — por telefone ou por um formulário em papel que ele enviou — e cadastre-a para que o armazém possa atendê-la.
Depois de enviada, ela vai para [Preenchimento de pedido](/help/order-filling).

## Para que serve o cadastro de pedidos

Parceiros podem chamar isso de *solicitações*; a equipe do aplicativo usa **pedidos**. São a mesma coisa. Você precisa da
permissão de gerenciamento de pedidos para usar a página.

O cadastro salva conforme você avança: o pedido é criado no momento em que você confirma o parceiro, e cada linha de item é enviada ao servidor assim
que você a adiciona. Uma conexão caindo ou uma falha nunca perde mais do que a linha que você estava digitando.

## A lista de pedidos

Abra [Cadastro de pedidos](/order-entry) para ver duas listas. Toque em qualquer linha para abrir esse pedido.

- **Pedidos abertos — toque para abrir** — tudo que ainda não foi concluído: Novo pedido, Pronto para separação, Em separação, Separado, Pronto para envio, Enviado e Entregue
(incluindo entregas aguardando uma BOL assinada). Colunas: Data, Parceiro, Linhas, Itens, Status, Cadastrado por.
- **Concluídos recentemente** — os últimos 25 pedidos concluídos (por exemplo, Concluído ou Encerrado — não atendido).

**Novo pedido** começa uma solicitação. **Formulário de pedido off-line** (um menu no estilo **Imprimir**) produz um formulário imprimível listando os números de item que temos em estoque para enviar a um parceiro, que preenche as quantidades manualmente e envia de volta para você digitar. Ele nunca mostra números de estoque.

## Etapa 1 — Para quem é este pedido?

1. Clique em **Novo pedido**. A tela se chama **Novo pedido — Para quem é?**
2. Pesquise na caixa **Parceiro** por nome, organização ou cidade e escolha o parceiro. (Esta é a organização receptora ou o ponto de distribuição que está fazendo o pedido.)
3. Não está na lista? Digite o nome e escolha a opção de adicionar. Abre um formulário **Novo parceiro**: nomes, organização, telefone, email, **CEP** primeiro, depois **Endereço**, Cidade, Estado e Município. Você precisa de nome e sobrenome, ou de uma organização. Quando o CEP/endereço for preenchido, o app pode procurar o município e sugerir um endereço corrigido — aceite ou mantenha o que você digitou. Se o município estiver ausente na lista, digite-o na caixa Município para adicioná-lo (digite a sigla do estado antes). Clique em **Salvar parceiro**.
4. **Confirmar contato e dados de entrega** aparece com os dados do parceiro. Este é o local para onde o pedido será enviado, então verifique se está atualizado e corrija o que mudou. **Verificar endereço** revalida o endereço se ele ainda não foi verificado. Pressionar Enter em uma caixa passa para a próxima.
5. Clique em **Iniciar pedido →**. Se você mudou alguma coisa, o botão passa a dizer **Salvar dados e iniciar pedido →**, e as mudanças são salvas no registro do parceiro para todos.

## Etapa 2 — Inserindo os itens

O cabeçalho mostra **Nº do pedido** e a data, e uma barra fina mostra o nome do parceiro, cidade/estado e telefone. **Alterar** ali permite escolher outro parceiro (enquanto o pedido ainda é editável).

1. Digite um número do item (ou parte do nome) na caixa **Nº do item** e escolha-o. O cursor salta para **Quantidade**. Uma nota ao lado do nome do item mostra aproximadamente quantos itens há em estoque (por exemplo, *~40 disponíveis* ou *nenhum disponível*). Isso é apenas uma pista para você — nunca leia números de estoque ao parceiro, e você pode até inserir mais do que temos.
2. Digite a quantidade (1 ou mais) e pressione **Enter** (ou clique em **Adicionar**). A linha é salva e o cursor volta para **Nº do item** para o próximo. Há também uma caixa **Comentário da linha (opcional)** para observações dessa linha.
3. Quando um item está acabando (no nível mínimo ou abaixo dele), aparece uma caixa **Nível de necessidade (opcional)**: **Crítico**, **Moderado** ou **Baixo**. Registre o que o parceiro lhe diz sobre o quanto precisa dele. É apenas contexto para quem dividirá itens escassos depois — deixe em branco se não disserem.
4. Digitou o mesmo item duas vezes? Uma caixa intitulada **Opa!** mostra o que você já inseriu. Digite uma **Quantidade adicional** e clique em **Combinar →** para somar à linha existente, ou **Cancelar** (ou pressione Esc) para descartar.
5. Linha errada? Clique no ícone de lixeira ao lado dela e depois em **Excluir?** para confirmar (ou **Manter** para desistir). Para alterar a quantidade, apague a linha e adicione novamente, ou use a caixa Combinar para adicionar mais.

A barra superior mostra *Salvando…*, *Todas as alterações salvas* ou *Falha ao salvar N linha(s)* com **Tentar novamente em todas** (cada linha com falha também tem **Tentar novamente**; linhas com falha tentam de novo sozinhas quando a conexão volta). Totais de **Linhas** e **Total de itens** aparecem abaixo da tabela. **← Todos os pedidos** volta para a lista; o pedido continua aberto para depois.

## Etapa 3 — Revisar e confirmar

Quando todos os itens estiverem dentro, clique em **Concluir pedido** (canto superior direito). A tela **Revisar e confirmar — Nº do pedido** mostra:

- **Resumo do pedido** — parceiro, número de linhas e total de itens.
- **Comentários** — qualquer coisa que o armazém deva saber.
- **Necessário, mas fora do catálogo** — itens de que o parceiro precisa e que não estão na nossa lista (o mesmo que “Outras necessidades” no formulário em papel).
- **Entrega ou retirada** — escolha um, mais uma **Data necessária**. Para entrega também escolha os dias em que aceitam (**Qualquer dia** ou dias individuais) e um **Horário preferencial**. Para retirada, o armazém define dias e horários.
- **Contato para entrega** (ou **Contato para retirada**) — nome e telefone, preenchidos do parceiro; altere se outra pessoa estiver recebendo.
- **Instruções especiais de entrega** — códigos de portaria, local da doca, quem contatar na chegada. Isso vai para a BOL quando o pedido for enviado.

Clique em **Enviar pedido** para concluir. **← Voltar** retorna aos itens sem enviar.

## Depois de enviar — o ciclo de vida do pedido

Enviar move o pedido de **Novo pedido** para **Pronto para separação**. A partir daí, o sistema o move assim:

`Novo pedido → Pronto para separação → Em separação → Separado → Pronto para envio → Enviado → Entregue →
Concluído`

- **Somente um pedido novo pode ser editado.** Depois de enviado, linhas e detalhes ficam bloqueados, porque a equipe do armazém está trabalhando com eles. Abrir um pedido assim mostra os itens em modo somente leitura com seu indicador de status.
- O status é definido pelo app conforme o trabalho avança — você nunca o escolhe em uma lista. O preenchimento é explicado em [Preenchimento de pedido](/help/order-filling) e o envio em [Envio](/help/shipping).
- Um pedido em que nada pôde ser separado termina como **Encerrado — não atendido** e nunca chega à etapa de envio.
