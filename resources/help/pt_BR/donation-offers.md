<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Acompanhe as doações ofertadas por telefone (ou e-mail, ou pessoalmente) antes de qualquer coisa ser expedida, decida
se aceitá-las e vincule cada aceitação à carga quando ela chegar ao [Recebimento](/help/receiving).

## Para que servem as ofertas

Nem toda doação é avisada antes — uma chegada por conta própria ou um caminhão surpresa é registrada direto no
Recebimento e nunca precisa de uma oferta. Mas quando alguém liga com antecedência, uma oferta dá a todos um único
lugar para ver o que está vindo, quem concordou em recebê-la e quando é esperada. Cada oferta mantém um histórico
completo de cada ligação e decisão.

Abra-a pelo botão **Ofertas de doação** no [Recebimento](/receiving). Qualquer pessoa que possa usar o Recebimento
pode abrir a página, registrar uma ligação e editar uma oferta aberta. **Decidir** uma oferta (Aprovar, Recusar,
Redirecionar, Cancelar oferta, Vincular à chegada) exige a permissão separada **Ofertas de doação**. Sem ela você
ainda pode registrar e atualizar ofertas, e os botões de decisão são substituídos por um aviso de que a permissão é
necessária.

## A vida de uma oferta

- **Ofertada** — alguém ligou; ninguém decidiu ainda.
- **Aguardando chegada** — aceita (Aprovar). Estamos esperando dentro da janela de ETA.
- **Recebida** — chegou e foi vinculada a um registro de Recebimento. Encerrada.
- **Recusada** ou **Redirecionada** — dissemos não, ou encaminhamos o doador a outra organização. Encerrada.
- **Cancelada** — uma oferta aceita que não se concretizou. Encerrada.

Somente ofertas Ofertada e Aguardando chegada podem ser editadas. Uma vez Recusada, Redirecionada, Cancelada ou
Recebida, a oferta é mantida como histórico e bloqueada. Uma oferta pendente cuja janela de ETA (ou dia único de ETA)
já passou por completo mostra a tag **atrasada** na lista.

## Registrando uma nova oferta

1. Clique em **Registrar uma oferta de doação**.
2. Escolha o **Doador / Origem**. Se não está no sistema, use a opção de criação (um primeiro nome, um sobrenome ou
   uma organização bastam).
3. Se o doador é uma organização, uma caixa **Pessoa de contato** aparece. Selecione ou adicione a pessoa que fez a
   ligação.
4. Descreva **O que está sendo ofertado** e, se o doador souber, preencha as datas da **Janela de ETA aproximada (se
   souber)**. Você também pode registrar **Como a oferta chegou?** e quaisquer **Notas da conversa**; elas entram na
   primeira entrada do histórico da oferta.
5. Salve. A oferta começa como **Ofertada** e o histórico mostra **Registrada como Ofertada**.

## Trabalhando a lista

A lista mostra o doador, o status, a ETA (intervalo de datas) e a descrição de cada oferta. Ofertas com a ETA mais
próxima ficam no topo; ofertas sem ETA ficam no fim. Marque **Somente pendentes (por ETA)** para ver apenas as
ofertas aceitas que estamos aguardando — uma visão útil de "o que está vindo?". A lista mostra todas as ofertas
abertas mais as 150 encerradas mais recentes. **← Voltar ao Recebimento** retorna à página de entrada.

## Decidindo uma oferta

Abra uma oferta e olhe primeiro o **Histórico do doador** — ele lista as doações, solicitações e ofertas anteriores
daquele doador, para que a decisão não seja feita às cegas. Depois, em **Decisão** (estes botões exigem a permissão
Ofertas de doação), escolha uma. Cada uma abre um formulário curto; preencha e pressione **Confirmar**. Você também
pode escolher um **Meio de contato** (Telefone, E-mail, Pessoalmente, Outro) e adicionar **Notas**, que ficam
registradas no histórico.

### Em uma oferta Ofertada

- **Aprovar** — aceita a oferta. Informe a **Janela de ETA** (a data inicial é obrigatória, a final é opcional) e
  quaisquer **Notas de transporte**. A oferta passa a Aguardando chegada.
- **Recusar** — informe o **Motivo (obrigatório)**.
- **Redirecionar** — informe **Redirecionada para (obrigatório)**, a organização à qual o doador foi encaminhado.

### Em uma oferta Aguardando chegada

- **Cancelar oferta** — a doação não vem mais. Informe o **Motivo (obrigatório)**.
- **Vincular à chegada** — veja a próxima seção.

### Em qualquer uma

- **Registrar ligação / Atualizar ETA** — o doador ligou de volta para mudar a data ou acrescentar detalhe, e nada
  foi decidido. Mude a Janela de ETA ou a descrição, se necessário, e escreva uma nota (obrigatória). O status
  permanece o mesmo e a ligação é adicionada ao histórico.

## Quando a doação chega: vinculação

A vinculação liga a oferta aceita ao registro real de Recebimento e marca a oferta como **Recebida**. Há três
caminhos, todos com o mesmo resultado:

1. **Na doca (mais fácil).** No [Recebimento](/receiving), clique em **Registrar uma entrada**. No topo, em **Isto
   corresponde a uma oferta avisada por telefone?**, clique no cartão deste doador. O doador, a pessoa de contato e a
   descrição são preenchidos para você, e a oferta é marcada como Recebida quando você salva a entrada.
2. **A partir da oferta.** Abra a oferta Aguardando chegada e clique no link **iniciar uma nova entrada de
   Recebimento para esta oferta**. O Recebimento abre uma nova entrada com a oferta já selecionada.
3. **Depois do registro.** Se a carga já foi lançada no Recebimento sem escolher a oferta, abra a oferta, clique em
   **Vincular à chegada**, escolha a entrada em **Vincular à doação chegada** (busque na lista de entradas que ainda
   não estão vinculadas a uma oferta — as 50 mais recentes são oferecidas) e pressione **Confirmar**.

Um registro de Recebimento pode ser vinculado a apenas uma oferta, e apenas uma oferta Aguardando chegada pode ser
vinculada.

## Histórico

No fim de toda oferta, o **Histórico** lista cada passo: quem fez, quando, como o doador foi contatado e as notas. As
entradas se leem como **Ofertada → Aguardando chegada** para uma decisão, **Atualização — Aguardando chegada** para
uma ligação que só mudou detalhes, e **Registrada como Ofertada** para a primeira entrada. Nada no histórico pode ser
editado ou removido.
