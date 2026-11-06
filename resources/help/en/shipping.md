<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Entregue os pedidos concluídos a um motorista, registre quando o caminhão sai e revise a Bill of Lading (BOL) assinada que volta.
Os pedidos chegam aqui depois que [Preenchimento de pedido](/help/order-filling) os marca como Filled.

## Como um pedido se move

Abra [Envio](/shipping). Ele tem uma tabela por etapa, nesta ordem, cada uma com uma contagem no cabeçalho. Você precisa da permissão
Manage Orders para usar a página.

1. **Filled — Ready to Assign a Driver** — a separação foi concluída e ainda não há motorista atribuído.
2. **Ready to Ship** — um motorista foi atribuído, mas o caminhão ainda não saiu.
3. **Shipped** — o pessoal confirmou que a carga saiu do dock.
4. **Delivered — Pending Review** — a BOL assinada foi enviada e um gerente precisa verificá-la.
5. **Delivered — Waiting on BOL** — a BOL enviada foi rejeitada; uma versão utilizável ainda é necessária.
6. **Recently Completed** — a BOL assinada foi aprovada (as 25 mais recentes).

Nada se move sozinho: cada etapa abaixo é algo que uma pessoa faz. A página não tem outras etapas de envio, como números de rastreio ou datas de entrega.

## Atribuindo um motorista

1. Em **Filled — Ready to Assign a Driver**, cada linha mostra o número do pedido, a entidade parceira, o número de linhas e a quantidade total.
2. Escolha um nome em **Select a driver...** e clique em **Assign**. O pedido vai para Ready to Ship.

Um motorista precisa estar na lista **Drivers** no rodapé da página antes que você possa escolhê-lo (veja abaixo).

## Imprimindo a BOL

Nas tabelas **Ready to Ship** e **Shipped**, a coluna **Generated BOL** tem um menu **View BOL**. Use-o para baixar o PDF ou enviá-lo para uma
impressora configurada para o seu site. Imprima-o para o motorista assinar. O número da BOL é atribuído na primeira vez que é gerada e continua
o mesmo se você a imprimir de novo.

Ao lado está um menu **Shipping Label**. Ele cria uma etiqueta de 4 x 6,5 polegadas para colar na remessa, mostrando o número do pedido
(com código de barras), quem e para onde vai, o contato, o método de entrega, o número de paletes, a data de embalagem, a data solicitada e as
instruções especiais (encurtadas se forem longas). Apenas impressoras carregadas com etiquetas grandes são oferecidas; o download do PDF sempre
está disponível. A contagem de paletes vem de **Pallets packed** em Order Filling, e a etiqueta fica em branco ali se ela não foi preenchida.
A data de embalagem é quando o último item foi separado.

## Marcando um pedido como enviado

Quando o caminhão de fato sai do dock, clique em **Mark Shipped** nesse pedido na tabela **Ready to Ship**. É uma etapa manual — nada marca isso por
você.

Escolheu o motorista errado? A tabela Ready to Ship não tem como alterar o motorista depois que ele é atribuído, então verifique o nome antes de
clicar em Assign.

## Motoristas e o portal do motorista

Um motorista não precisa de conta. A tabela **Drivers** no rodapé lista o nome do motorista, telefone, transportadora e se um PIN do Driver Portal
foi definida.

- **+ New Driver** — digite um nome (obrigatório), telefone e transportadora (se for uma empresa de transporte) e clique em **Save Driver**.
- **Set PIN** / **Reset PIN** — digite um PIN de 5 dígitos duas vezes e clique em **Save PIN**. PINs fáceis de adivinhar são recusados.

Entregue ao motorista o número de telefone e o PIN. Eles fazem login em [/driver-portal](/driver-portal) usando **Phone Number** e **PIN**, e veem
apenas as cargas atribuídas a eles em **Current Loads** (Ready to Ship, Shipped ou aguardando uma nova BOL reenviada). Cada carga mostra detalhes da
entrega (endereço, contato, janela) em **Delivery Details** quando o pedido tiver esses dados.

## A BOL assinada

Depois da entrega, o motorista toca em **Upload Signed BOL** na carga e escolhe uma foto ou PDF (JPG, PNG ou PDF, até 10 MB). O upload move o
pedido direto para **Delivered** — não precisa ser marcado como Shipped primeiro. Se um funcionário abrir o portal enquanto estiver logado, ele verá
uma lista somente leitura de todas as cargas fora, sem botão de upload.

O pedido então aparece em **Delivered — Pending Review** na página de envio. Um gerente clica em **Review**, que abre o arquivo enviado:

- **Approve** — aceita e move o pedido para Completed. Para uma foto, você pode primeiro arrastar um retângulo sobre a parte a ser mantida, e o
botão vira **Approve Cropped** (um PDF não pode ser recortado, então abra em uma nova aba).
- **Reject**, então **Confirm Reject** — opcionalmente diga o que está errado. O arquivo ruim é descartado e o pedido vai para **Delivered —
Waiting on BOL**. O motorista vê a carga de novo com sua observação e faz upload de outra, o que a envia de volta para revisão.

Pedidos aprovados listam um link **View Signed BOL** em **Recently Completed**.
