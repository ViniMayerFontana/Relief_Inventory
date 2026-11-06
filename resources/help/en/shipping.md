<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Entregue os pedidos concluídos a um motorista, registre quando o caminhão sai e revise a Bill of Lading (BOL) assinada que volta.
Os pedidos chegam aqui depois que [Preenchimento de pedido](/help/order-filling) os marca como Filled.

## Como um pedido se move

Abra [Envio](/shipping). Ele tem uma tabela por etapa, nesta ordem, cada uma com uma contagem no cabeçalho. Você precisa da permissão
de gerenciamento de pedidos para usar a página.

1. **Separado — pronto para atribuir motorista** — a separação foi concluída e ainda não há motorista atribuído.
2. **Pronto para envio** — um motorista foi atribuído, mas o caminhão ainda não saiu.
3. **Enviado** — a equipe confirmou que a carga saiu da doca.
4. **Entregue — aguardando revisão** — a BOL assinada foi enviada e um gerente precisa verificá-la.
5. **Entregue — aguardando nova BOL** — a BOL enviada foi rejeitada; uma versão utilizável ainda é necessária.
6. **Concluídos recentemente** — a BOL assinada foi aprovada (os 25 mais recentes).

Nada se move sozinho: cada etapa abaixo é algo que uma pessoa faz. A página não tem outras etapas de envio, como números de rastreio ou datas de entrega.

## Atribuindo um motorista

1. Em **Separado — pronto para atribuir motorista**, cada linha mostra o número do pedido, a entidade parceira, o número de linhas e a quantidade total.
2. Escolha um nome em **Selecione um motorista...** e clique em **Atribuir**. O pedido vai para Pronto para envio.

Um motorista precisa estar na lista **Drivers** no rodapé da página antes que você possa escolhê-lo (veja abaixo).

## Imprimindo a BOL

Nas tabelas **Pronto para envio** e **Enviado**, a coluna **BOL gerada** tem um menu **Ver BOL**. Use-o para baixar o PDF ou enviá-lo para uma
impressora configurada para o seu site. Imprima-o para o motorista assinar. O número da BOL é atribuído na primeira vez que é gerada e continua
o mesmo se você a imprimir de novo.

Ao lado está um menu **Etiqueta de envio**. Ele cria uma etiqueta de 4 x 6,5 polegadas para colar na remessa, mostrando o número do pedido
(com código de barras), quem e para onde vai, o contato, o método de entrega, o número de paletes, a data de embalagem, a data solicitada e as
instruções especiais (encurtadas se forem longas). Apenas impressoras carregadas com etiquetas grandes são oferecidas; o download do PDF sempre
está disponível. A contagem de paletes vem de **Paletes embaladas** em Preenchimento de pedido, e a etiqueta fica em branco ali se ela não foi preenchida.
A data de embalagem é quando o último item foi separado.

## Marcando um pedido como enviado

Quando o caminhão de fato sai da doca, clique em **Marcar como enviado** nesse pedido na tabela **Pronto para envio**. É uma etapa manual — nada marca isso por
você.

Escolheu o motorista errado? A tabela Pronto para envio não tem como alterar o motorista depois que ele é atribuído, então verifique o nome antes de
clicar em Atribuir.

## Motoristas e o portal do motorista

Um motorista não precisa de conta. A tabela **Motoristas** no rodapé lista o nome do motorista, telefone, transportadora e se um PIN do Portal do motorista
foi definida.

- **+ Novo motorista** — digite um nome (obrigatório), telefone e transportadora (se for uma empresa de transporte) e clique em **Salvar motorista**.
- **Definir PIN** / **Redefinir PIN** — digite um PIN de 5 dígitos duas vezes e clique em **Salvar PIN**. PINs fáceis de adivinhar são recusados.

Entregue ao motorista o número de telefone e o PIN. Eles fazem login em [/driver-portal](/driver-portal) usando **Número de telefone** e **PIN**, e veem
apenas as cargas atribuídas a eles em **Cargas atuais** (Pronto para envio, Enviado ou aguardando uma nova BOL reenviada). Cada carga mostra detalhes da
entrega (endereço, contato, janela) em **Dados da entrega** quando o pedido tiver esses dados.

## A BOL assinada

Depois da entrega, o motorista toca em **Enviar BOL assinada** na carga e escolhe uma foto ou PDF (JPG, PNG ou PDF, até 10 MB). O envio move o
pedido direto para **Entregue** — não precisa ser marcado como Enviado primeiro. Se um funcionário abrir o portal enquanto estiver logado, ele verá
uma lista somente leitura de todas as cargas fora, sem botão de upload.

O pedido então aparece em **Entregue — aguardando revisão** na página de envio. Um gerente clica em **Revisar**, que abre o arquivo enviado:

- **Aprovar** — aceita e move o pedido para Concluído. Para uma foto, você pode primeiro arrastar um retângulo sobre a parte a ser mantida, e o
botão vira **Aprovar imagem recortada** (um PDF não pode ser recortado, então abra em uma nova aba).
- **Rejeitar**, então **Confirmar rejeição** — opcionalmente diga o que está errado. O arquivo ruim é descartado e o pedido vai para **Entregue —
aguardando nova BOL**. O motorista vê a carga de novo com sua observação e faz upload de outra, o que a envia de volta para revisão.

Pedidos aprovados listam um link **Ver BOL assinada** em **Concluídos recentemente**.
