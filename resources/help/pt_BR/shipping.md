<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Entregue os pedidos concluídos a um motorista, registre quando o caminhão sai e revise o Bill of Lading (BOL)
assinado que volta. Os pedidos chegam aqui quando o [Atendimento de pedidos](/help/order-filling) os marca como
Atendido.

## Como um pedido se move

Abra [Expedição](/shipping). Há uma tabela por estágio, nesta ordem, cada uma com uma contagem no título. Você
precisa da permissão Gerenciar pedidos para usar a página.

1. **Atendido — pronto para designar motorista** — a separação acabou e nenhum motorista está designado ainda.
2. **Pronto para expedição** — um motorista está designado, mas o caminhão não saiu.
3. **Expedido** — a equipe confirmou que a carga deixou a doca.
4. **Entregue — aguardando revisão** — o BOL assinado foi enviado e um gestor precisa conferi-lo.
5. **Entregue — aguardando BOL** — o BOL enviado foi rejeitado; ainda é preciso um utilizável.
6. **Concluídos recentemente** — o BOL assinado foi aprovado (os 25 mais recentes).

Nada se move sozinho: cada passo abaixo é algo que uma pessoa faz. A página não tem outros passos de expedição,
como números de rastreio ou datas de entrega.

## Designando um motorista

1. Em **Atendido — pronto para designar motorista**, cada linha mostra o número do pedido, o parceiro, o número de
   linhas e a quantidade total.
2. Escolha um nome em **Selecione um motorista...** e clique em **Designar**. O pedido passa para Pronto para
   expedição.

Um motorista precisa estar na lista **Motoristas** no fim da página antes de você poder escolhê-lo (veja abaixo).

## Imprimindo o BOL

Nas tabelas **Pronto para expedição** e **Expedido**, a coluna **BOL gerado** tem um menu **Ver BOL**. Use-o para
baixar o PDF ou enviar a uma impressora configurada para o seu site. Imprima-o para o motorista assinar. O número
do BOL é atribuído na primeira vez em que é gerado e permanece o mesmo se você imprimi-lo de novo.

Ao lado dele há um menu **Etiqueta de expedição**. Ele produz uma etiqueta de 4 x 6,5 pol. para colar na remessa,
mostrando o número do pedido (com um código de barras), para quem e para onde vai, o contato, o método de
atendimento, o número de pallets, a data de embalagem, a data solicitada e as instruções especiais (cortadas se
forem longas). Só são oferecidas impressoras carregadas com etiquetas grandes; o download do PDF está sempre
disponível. A contagem de pallets vem de **Pallets embalados** no Atendimento de pedidos, e a etiqueta fica em
branco ali se não foi informada. A data de embalagem é quando o último item foi separado.

## Marcando um pedido como Expedido

Quando o caminhão de fato deixa a doca, clique em **Marcar como expedido** naquele pedido na tabela **Pronto para
expedição**. É um passo manual — nada marca para você.

Escolheu o motorista errado? A tabela Pronto para expedição não tem como mudar o motorista depois que um é
designado, portanto confira o nome antes de clicar em Designar.

## Motoristas e o Portal do motorista

Um motorista não precisa de uma conta. A tabela **Motoristas** no fim da página lista o nome, o telefone e a
transportadora de cada motorista, e se um PIN do Portal do motorista está definido.

- **+ Novo motorista** — informe um nome (obrigatório), telefone e transportadora (se for uma empresa de
  transporte) e depois **Salvar motorista**.
- **Definir PIN** / **Redefinir PIN** — digite um PIN de 5 dígitos duas vezes e clique em **Salvar PIN**. PINs
  fáceis de adivinhar são recusados.

Dê ao motorista o número de telefone dele e o PIN. Ele entra em [/driver-portal](/driver-portal) usando **Número
de telefone** e **PIN** e vê apenas as cargas designadas a ele em **Cargas atuais** (Pronto para expedição,
Expedido ou aguardando um BOL reenviado). Cada carga mostra os detalhes de entrega (endereço, contato, janela) em
**Detalhes da entrega** quando o pedido os tem.

## O BOL assinado

Depois da entrega, o motorista toca em **Enviar BOL assinado** na carga e escolhe uma foto ou PDF (JPG, PNG ou
PDF, até 10 MB). O envio move o pedido direto para **Entregue** — ele não precisa ser marcado como Expedido
antes. Se um membro da equipe abre o portal enquanto está autenticado, ele recebe uma lista somente leitura de
toda carga atualmente em rota, sem botão de envio.

O pedido então aparece em **Entregue — aguardando revisão** na página de Expedição. Um gestor clica em
**Revisar**, que abre o arquivo enviado:

- **Aprovar** — aceita-o e move o pedido para Concluído. Para uma foto, você pode primeiro arrastar um retângulo
  sobre a parte a manter, e o botão passa a **Aprovar recortado** (um PDF não pode ser recortado, então abra-o em
  uma nova aba).
- **Rejeitar** e depois **Confirmar rejeição** — opcionalmente diga o que está errado. O arquivo ruim é
  descartado e o pedido vai para **Entregue — aguardando BOL**. O motorista vê a carga novamente com a sua nota e
  envia um novo, o que a devolve para revisão.

Pedidos aprovados listam um link **Ver BOL assinado** em **Concluídos recentemente**.
