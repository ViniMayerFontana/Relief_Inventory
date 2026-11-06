<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o registro de doações oferecidas por telefone (ou email, ou pessoalmente) antes de qualquer envio, decida se as aceita e relacione cada uma com a carga quando ela chega em [Recebimento](/help/receiving).

## Para que servem as ofertas

Nem toda doação é combinada por telefone antes — uma entrada espontânea ou um caminhão surpresa é registrada direto em Recebimento e nunca precisa de oferta. Mas quando alguém liga antes, uma oferta oferece um único lugar para ver o que está vindo, quem concordou em aceitá-la e quando ela deve chegar. Cada oferta mantém um histórico completo de todas as ligações e decisões.

Abra-a no botão **Donation Offers** em [Recebimento](/receiving). Qualquer pessoa que possa usar Recebimento pode abrir a página, registrar uma ligação e editar uma oferta aberta. **Decidir** uma oferta (Approve, Refuse, Divert, Cancel Offer, Match to Arrival) exige a permissão separada **Donation Offers**. Sem ela, você ainda pode registrar e atualizar ofertas, e os botões de decisão são substituídos por uma nota dizendo que a permissão é necessária.

## A vida de uma oferta

- **Offered** — alguém ligou; ninguém decidiu ainda.
- **Pending Arrival** — aceita (Approve). Estamos esperando pela janela de ETA.
- **Received** — chegou e foi relacionada a um registro de Recebimento. Concluída.
- **Refused** ou **Diverted** — dissemos não ou encaminhamos o doador para outra organização. Concluída.
- **Cancelled** — uma oferta aceita que não se concretizou. Concluída.

Só ofertas **Offered** e **Pending Arrival** podem ser editadas. Depois que uma oferta é Refused, Diverted, Cancelled ou Received, ela é mantida como histórico e bloqueada. Uma oferta pendente cuja janela ETA (ou um único dia de ETA) já passou mostra uma tag **overdue** na lista.

## Registrando uma nova oferta

1. Clique em **Log a Donation Offer**.
2. Escolha o **Donor / Source**. Se não estiver no sistema, use a opção de criação (nome, sobrenome ou organização basta).
3. Se o doador for uma organização, aparece um campo **Contact Person**. Escolha ou adicione a pessoa que ligou.
4. Descreva **What's being offered** e, se o doador souber, preencha as datas da **Rough ETA Window (if known)**. Você também pode registrar **How did the offer come in?** e qualquer **Notes from the conversation**; eles entram na primeira entrada do histórico da oferta.
5. Salve. A oferta começa como **Offered** e seu histórico mostra **Logged as Offered**.

## Trabalhando com a lista

A lista mostra o doador da oferta, status, ETA (intervalo de datas) e descrição. Ofertas com a ETA mais próxima ficam no topo; ofertas sem ETA no fim. Marque **Pending (ETA-sorted) only** para ver apenas as ofertas aceitas que estamos esperando — uma visão útil de “o que está chegando?”. A lista mostra todas as ofertas abertas mais as 150 mais recentes concluídas. **← Back to Receiving** retorna à página de recebimento.

## Decidindo uma oferta

Abra uma oferta e veja primeiro **Donor History** — ela lista doações, pedidos e ofertas anteriores do doador, para a decisão não ser feita às cegas. Em seguida, em **Decision** (estes botões precisam da permissão Donation Offers), escolha uma. Cada um abre um formulário curto; preencha e pressione **Confirm**. Você também pode escolher um **Contact Method** (Phone, Email, In Person, Other) e adicionar **Notes**, que são registradas no histórico.

### Em uma oferta Offered

- **Approve** — aceita. Digite a **ETA Window** (a data de início é obrigatória, a final é opcional) e quaisquer **Transit Notes**. A oferta vira Pending Arrival.
- **Refuse** — digite o **Reason (required)**.
- **Divert** — digite **Diverted to (required)**, a organização para a qual o doador foi encaminhado.

### Em uma oferta Pending Arrival

- **Cancel Offer** — a doação não virá, afinal. Digite o **Reason (required)**.
- **Match to Arrival** — veja a próxima seção.

### Em qualquer uma

- **Log a Call / Update ETA** — o doador ligou de volta para mudar a data ou adicionar detalhes, sem que uma decisão fosse tomada. Altere a **ETA Window** ou a descrição se necessário e escreva uma nota (obrigatória). O status continua o mesmo e a ligação é adicionada ao histórico.

## Quando a doação chega: vinculação

A vinculação liga a oferta aceita ao registro real de Recebimento e marca a oferta **Received**. Há três formas, todas com o mesmo resultado:

1. **No dock (mais fácil).** Em [Recebimento](/receiving), clique em **Record an Intake**. No topo, em **Does this match a phoned-in offer?**, clique no cartão deste doador. O doador, a pessoa de contato e a descrição são preenchidos para você, e a oferta é marcada como Received quando você salva a entrada.
2. **Pela oferta.** Abra a oferta Pending Arrival e clique no link **start a new Receiving intake for this offer**. O Recebimento abre uma nova entrada com a oferta já selecionada.
3. **Depois do fato.** Se a carga já foi registrada em Recebimento sem escolher a oferta, abra a oferta, clique em **Match to Arrival**, escolha a entrada em **Match to arrived donation** (procure na lista de entradas ainda não vinculadas a uma oferta — as 50 mais recentes são oferecidas) e pressione **Confirm**.

Um registro de Recebimento pode ser vinculado a apenas uma oferta, e apenas uma oferta Pending Arrival pode ser correspondida.

## Histórico

No rodapé de cada oferta, **History** lista cada etapa: quem fez, quando, como o doador foi contatado e as observações. As entradas aparecem como **Offered → Pending Arrival** para uma decisão, **Update — Pending Arrival** para uma ligação que mudou apenas os detalhes, e **Logged as Offered** para a primeira entrada. Nada do histórico pode ser editado ou removido.
