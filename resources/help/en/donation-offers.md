<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o registro de doações oferecidas por telefone (ou email, ou pessoalmente) antes de qualquer envio, decida se as aceita e relacione cada uma com a carga quando ela chega em [Recebimento](/help/receiving).

## Para que servem as ofertas

Nem toda doação é combinada por telefone antes — uma entrada espontânea ou um caminhão surpresa é registrada direto em Recebimento e nunca precisa de oferta. Mas quando alguém liga antes, uma oferta oferece um único lugar para ver o que está vindo, quem concordou em aceitá-la e quando ela deve chegar. Cada oferta mantém um histórico completo de todas as ligações e decisões.

Abra pelo botão **Ofertas de doação** em [Recebimento](/receiving). Qualquer pessoa que possa usar Recebimento pode abrir a página, registrar uma ligação e editar uma oferta aberta. **Decidir** uma oferta (Aprovar, Recusar, Redirecionar, Cancelar oferta, Vincular à chegada) exige a permissão separada **Ofertas de doação**. Sem ela, você ainda pode registrar e atualizar ofertas, e os botões de decisão são substituídos por uma nota dizendo que a permissão é necessária.

## A vida de uma oferta

- **Oferecida** — alguém ligou; ninguém decidiu ainda.
- **Aguardando chegada** — aceita (Aprovar). Estamos esperando pela previsão de chegada.
- **Recebida** — chegou e foi relacionada a um registro de Recebimento. Concluída.
- **Recusada** ou **Redirecionada** — dissemos não ou encaminhamos o doador para outra organização. Concluída.
- **Cancelada** — uma oferta aceita que não se concretizou. Concluída.

Só ofertas **Oferecida** e **Aguardando chegada** podem ser editadas. Depois que uma oferta é recusada, redirecionada, cancelada ou recebida, ela é mantida como histórico e bloqueada. Uma oferta pendente cuja previsão de chegada já passou mostra a etiqueta **atrasada** na lista.

## Registrando uma nova oferta

1. Clique em **Registrar oferta de doação**.
2. Escolha o **Doador / origem**. Se não estiver no sistema, use a opção de criação (nome, sobrenome ou organização basta).
3. Se o doador for uma organização, aparece o campo **Pessoa de contato**. Escolha ou adicione a pessoa que ligou.
4. Descreva **O que está sendo oferecido** e, se o doador souber, preencha as datas da **Previsão aproximada de chegada (se conhecida)**. Você também pode registrar **Como a oferta chegou?** e qualquer **Anotações da conversa**; elas entram na primeira entrada do histórico da oferta.
5. Salve. A oferta começa como **Oferecida** e seu histórico mostra **Registrada como Oferecida**.

## Trabalhando com a lista

A lista mostra o doador da oferta, situação, previsão de chegada (intervalo de datas) e descrição. Ofertas com a previsão mais próxima ficam no topo; ofertas sem previsão ficam no fim. Marque **Somente pendentes (ordenadas por previsão de chegada)** para ver apenas as ofertas aceitas que estamos esperando — uma visão útil de “o que está chegando?”. A lista mostra todas as ofertas abertas mais as 150 mais recentes concluídas. **← Voltar para recebimento** retorna à página de recebimento.

## Decidindo uma oferta

Abra uma oferta e veja primeiro **Histórico do doador** — ele lista doações, pedidos e ofertas anteriores do doador, para a decisão não ser feita às cegas. Em seguida, em **Decisão** (estes botões precisam da permissão Ofertas de doação), escolha uma. Cada opção abre um formulário curto; preencha e pressione **Confirmar**. Você também pode escolher uma **Forma de contato** (Telefone, e-mail, pessoalmente, outro) e adicionar **Observações**, que são registradas no histórico.

### Em uma oferta Offered

- **Aprovar** — aceita. Digite a **Previsão de chegada** (a data de início é obrigatória, a final é opcional) e quaisquer **Observações de transporte**. A oferta passa a Aguardando chegada.
- **Recusar** — digite o **Motivo (obrigatório)**.
- **Redirecionar** — digite **Redirecionada para (obrigatório)**, a organização para a qual o doador foi encaminhado.

### Em uma oferta aguardando chegada

- **Cancelar oferta** — a doação não virá, afinal. Digite o **Motivo (obrigatório)**.
- **Vincular à chegada** — veja a próxima seção.

### Em qualquer uma

- **Registrar ligação / atualizar previsão** — o doador ligou de volta para mudar a data ou adicionar detalhes, sem que uma decisão fosse tomada. Altere a **Previsão de chegada** ou a descrição se necessário e escreva uma observação (obrigatória). A situação continua a mesma e a ligação é adicionada ao histórico.

## Quando a doação chega: vinculação

A vinculação liga a oferta aceita ao registro real de Recebimento e marca a oferta **Received**. Há três formas, todas com o mesmo resultado:

1. **No cais (mais fácil).** Em [Recebimento](/receiving), clique em **Registrar recebimento**. No topo, em **Esta carga corresponde a uma oferta feita por telefone?**, clique no cartão deste doador. O doador, a pessoa de contato e a descrição são preenchidos para você, e a oferta é marcada como Recebida quando você salva a entrada.
2. **Pela oferta.** Abra a oferta Aguardando chegada e clique no link **iniciar novo recebimento para esta oferta**. O Recebimento abre uma nova entrada com a oferta já selecionada.
3. **Depois do fato.** Se a carga já foi registrada em Recebimento sem escolher a oferta, abra a oferta, clique em **Vincular à chegada**, escolha a entrada em **Vincular à doação recebida** (procure na lista de entradas ainda não vinculadas a uma oferta — as 50 mais recentes são oferecidas) e pressione **Confirmar**.

Um registro de Recebimento pode ser vinculado a apenas uma oferta, e apenas uma oferta aguardando chegada pode ser vinculada.

## Histórico

No rodapé de cada oferta, **Histórico** lista cada etapa: quem fez, quando, como o doador foi contatado e as observações. As entradas aparecem como **Oferecida → Aguardando chegada** para uma decisão, **Atualização — Aguardando chegada** para uma ligação que mudou apenas os detalhes, e **Registrada como Oferecida** para a primeira entrada. Nada do histórico pode ser editado ou removido.
