<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Separe os itens das solicitações que foram lançadas na [Entrada de pedidos](/help/order-entry) e registre o que foi
de fato retirado. É daqui que o estoque sai do inventário.

## Como o atendimento funciona

Você precisa da permissão **manage-orders**. Abra [Atendimento de pedidos](/order-filling). Há dois modos de
trabalhar, e ambos chegam ao mesmo lugar:

- **No papel** — imprima folhas de separação, caminhe pelo armazém com elas e depois digite o que foi separado.
- **Na tela** — abra um pedido com **Iniciar atendimento** e lance cada separação conforme você trabalha.

Cada separação é salva como o seu próprio **registro de atendimento** no momento em que você a adiciona. Os
registros só são adicionados, nunca sobrescritos: se uma linha é separada em duas viagens, ambos os registros são
mantidos e o número **Atendido** da linha é o total deles. Um registro de atendimento diz quantos foram levados e,
se vieram de um pallet de armazém, de qual pallet — ali está onde os bens estavam, não quem os doou.

## As duas filas

- **Pronto para atendimento** — pedidos enviados aguardando serem trabalhados (Pedido, Parceiro, Linhas). **Iniciar
  atendimento** em uma linha move apenas aquele pedido para Em atendimento e o abre.
- **Em atendimento** — pedidos já iniciados, com progresso como *2 de 5 linhas atendidas*. **Continuar** reabre o
  pedido; o menu **Imprimir** dessa linha reimprime a folha de separação dele.

## Caminho do papel: Imprimir folhas de separação

**Imprimir folhas de separação** (canto superior direito) imprime uma folha por pedido para *todos* os pedidos em
Pronto para atendimento, listando onde encontrar cada item ao longo da rota de separação do armazém. Escolha
**Baixar PDF** ou uma impressora.

Importante: escolher qualquer opção aqui move **todos** os pedidos de Pronto para atendimento para Em atendimento
de uma vez, e a partir daí as quantidades dos separadores ficam fixas. O botão fica desabilitado quando nada está
Pronto para atendimento. Depois de separar, clique em **Continuar** em cada pedido e registre o que foi retirado,
como abaixo.

## Opcional: Revisar alocação (quando não há o suficiente)

**Revisar alocação** (canto superior direito; clique de novo para **Ocultar**) lista os itens cujo total solicitado
em todos os pedidos de Pronto para atendimento é maior do que o disponível. Para cada item você vê uma tabela com
**Pedido**, **Parceiro**, **Solicitado**, **Sugerido**, **Aprovar** e **Necessidade**.

- **Sugerido** é uma divisão proporcional simples do que temos. É um ponto de partida, não uma regra.
- **Necessidade** é a própria nota Crítico / Moderado / Baixo do parceiro da Entrada de pedidos (um traço se
  nenhuma). As linhas são listadas das mais urgentes para as menos urgentes.
- Digite a quantidade que você quer em **Aprovar** e clique em **Salvar quantidades aprovadas**. Os separadores
  então veem apenas o número aprovado como **Qtd. a separar** na folha de separação e na tela de atendimento.
  Aprovar **0** e a linha fica de fora por completo. Deixe uma caixa em branco para dar ao separador a solicitação
  completa. Um visto mostra uma aprovação salva.
- Você não pode aprovar mais do que foi solicitado, e as aprovações só podem ser mudadas enquanto o pedido está
  Pronto para atendimento. A solicitação original nunca é mudada, então os relatórios ainda podem comparar
  solicitado, aprovado e atendido.
- Nada aqui é obrigatório. Se preferir ordem de chegada, ignore este painel e imprima ou comece a atender.

## A tela de atendimento

A tela tem o título **Pedido #** com o nome do parceiro. **← Voltar** retorna às filas. A tabela tem as colunas
**Item**, **Qtd. a separar**, **Atendido**, **Disponível** e **Adicionar atendimento**, listadas na ordem em que
você caminharia pelo armazém.

1. Olhe as sugestões de **Separar:** sob uma linha (veja a próxima seção).
2. Se o item vem em mais de uma variedade, busque ou escaneie a certa em **Escanear ou buscar item...** (ou use
   **Escanear** para a câmera). Se há apenas uma variedade, ela é escolhida para você.
3. Digite a **Qtd.** que você separou. Se ela veio de um pallet de armazém específico, digite ou escaneie a tag
   daquele pallet em **De pallet aberto (opcional)**; a tag fica na caixa para a sua próxima separação. Pressione
   **Enter** ou clique em **Adicionar**.
4. A separação aparece em uma lista sob a linha (quantidade e item). Para remover um erro, clique no ícone de
   lixeira e depois em **Excluir?** (ou **Manter**). O estoque volta, e um pallet que tinha sido marcado como vazio
   por aquela separação é reaberto.

Você pode lançar **0** de propósito quando olhou e não havia nada: isso conta como "tratado" e não leva estoque
nenhum.

## Sugestões de "Separar:" e onde está o estoque

Sob cada linha, **Separar:** mostra caixas dizendo de onde levar o item, recalculadas do estoque vivo a cada vez.
São apenas conselhos — nada é reservado e você pode separar de outro jeito.

- **Área de triagem ×N** — estoque solto ainda não colocado em um pallet. É usado primeiro.
- **Localização, tag do pallet ×N** — leve N daquele pallet (com uma data de validade, se uma for conhecida).
  Pallets que vencem primeiro, e depois pallets mais antigos, são sugeridos primeiro. Pallets lacrados inteiros são
  sugeridos antes de abrir qualquer pallet novo, para que pallets cheios possam expedir intactos.
- **aberto** significa que você pode separar daquele pallet agora. **lacrado — leve o pallet inteiro** significa
  que o pallet todo vai neste pedido, então ele pode ir como está. **lacrado — abra primeiro** significa que só
  parte dele é necessária: clique em **Abrir pallet** primeiro. (Usar fica desabilitado até você fazer isso.)
- **Usar** copia uma sugestão para a linha de lançamento (a tag do pallet, a quantidade e, onde for relevante, a
  variedade do item). Confira-a e clique em **Adicionar**.
- *N não encontrados no estoque* significa que o sistema acha que faltam N. *totalmente separado* significa que
  nada mais é necessário naquela linha.

Mais sobre pallets, lacrar e localizações: [Movimentação de estoque](/help/inventory-movement).

## Quando os números não batem

- **Nenhum pallet nomeado:** a separação vem primeiro da área de triagem e depois dos pallets *abertos* mais
  antigos, dividida em vários registros de atendimento se necessário.
- **Pallets lacrados seguram o resto:** você receberá uma mensagem como *Somente 30 de 50 podem vir da área de
  triagem e de pallets abertos. Abra um pallet lacrado para separar os outros 20.* Nada é salvo. Abra um pallet
  (use **Abrir pallet** na sugestão) e adicione a separação de novo.
- **Nomeando um pallet lacrado:** só funciona se você estiver levando tudo o que está nele. Caso contrário, abra-o
  primeiro. Uma tag que não é de pallet de armazenagem é recusada (*Tag de pallet de Armazenagem desconhecida*),
  assim como um pallet que está vazio ou que de outro modo não pode ser separado.
- **Mais do que o sistema diz que temos:** a separação é aceita, com um aviso como *Isso são 5 a mais do que o
  banco de dados indica em estoque — confira a contagem.* Significa que os registros e a prateleira divergem:
  conte a prateleira e avise um supervisor.
- Um pallet é marcado como vazio automaticamente quando o total registrado dele chega a zero.

## Concluindo o pedido

1. Cada linha que tem algo a separar precisa de pelo menos um registro de atendimento. Uma linha sem nada aprovado
   para separar (aprovada em 0) não aparece na tela e não precisa de nenhum. Até todas estarem prontas,
   **Concluir atendimento** fica desabilitado e a mensagem diz *Cada linha precisa de pelo menos um registro de
   atendimento (mesmo 0)…*.
2. Opcionalmente informe **Pallets embalados** (em quantos pallets o pedido acabou) — é registrado no pedido e
   impresso na etiqueta de expedição.
3. Clique em **Concluir atendimento**. O pedido passa a **Atendido** e segue para [Expedição](/help/shipping).

**Se nada de fato foi separado** (toda separação é 0), a tela avisa *Nada foi separado — concluir vai encerrar esta
solicitação como Não atendida, em vez de enviá-la à Expedição.* O pedido então termina como **Encerrado - não
atendido** e nunca chega à Expedição.

Uma vez Atendido, os registros de atendimento do pedido não podem mais ser mudados aqui.
