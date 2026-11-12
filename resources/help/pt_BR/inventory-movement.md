<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Acompanhe onde os pallets estão e coloque os bens triados em pallets de armazém para que os separadores os
encontrem.

## Para que serve esta tela

Abra [Movimentação de estoque](/inventory-movement) (você precisa da permissão Gerenciar pallets). Ela tem três
abas: **Pallets** (a que você usará o dia todo — orientada a leitura), **Localizações** e **Movimentações recentes**
(somente consulta).

**Sem pallet atribuído significa "ainda na área de triagem".** Quando os bens são triados (veja o guia de
[Triagem](/help/sorting)), eles contam como estoque disponível, mas ficam na área de triagem. Colocá-los em um pallet
de armazém os tira de "sem atribuição" e dá a eles um lugar na prateleira. O estoque é reunido por tipo de item,
então você informa ao sistema *quantos* de um item foram para um pallet — não de qual doação vieram.

As tags de pallet começam com uma letra indicando o tipo: **R** Recebimento, **W** Armazenagem, **S** Expedição,
**H** Retenção, **Q** Quarentena, seguidas de oito dígitos (por exemplo `W00000123`). Um pallet de Armazenagem está
*lacrado* (embrulhado e fechado), *aberto* ou *vazio*. Os separadores só podem pegar de pallets abertos — veja o
guia de [Atendimento de pedidos](/help/order-filling).

## A barra de leitura

No topo da aba Pallets há uma caixa, sempre pronta para a próxima leitura. Depois que você clicar em qualquer lugar
da página, o cursor retorna a ela (a menos que você esteja digitando em outro campo). Escaneie ou digite um código e
pressione Enter ou **Buscar**.

- Sem pallet na tela, uma leitura é interpretada como um **código de barras de pallet**.
- Com um pallet na tela, uma leitura que corresponde a um **código de localização** move o pallet para lá na hora.
  Qualquer outra leitura é interpretada como um pallet e substitui o que está na tela.
- Uma mensagem verde confirma o que aconteceu; uma vermelha diz o que deu errado (por exemplo, um pallet
  desconhecido). O botão de alto-falante à direita silencia ou reativa os sons de leitura.

## Consultando um pallet

Escaneie a tag de um pallet. A tela mostra a tag e o tipo dele, onde está (*em* uma localização, ou *sem localização
registrada*), o status, quando foi atualizado pela última vez e, para um pallet de Armazenagem, a validade mais
próxima do que está nele. Abaixo disso:

- **Conteúdo do pallet** — para um pallet de Armazenagem, cada item e a sua quantidade. Para um pallet de
  Recebimento, o que a triagem registrou saindo dele (item, destinação, quantidade). Os outros tipos não rastreiam
  conteúdo.
- **Histórico de movimentação** — cada movimento e mudança de status, do mais recente para o mais antigo (data,
  localização, status, notas).

**Limpar / novo pallet** remove o pallet da tela para que você escaneie outro ou monte um novo.

## Movendo um pallet

1. Escaneie a tag do pallet.
2. Escaneie o código de barras da localização na prateleira ou no rack. O movimento é registrado imediatamente
   ("… movido para …") e o pallet mantém o seu status. Escanear a localização em que ele já está apenas informa
   isso.
3. Prefere o formulário? Digite ou escolha um código em **Localização**, adicione **Notas** se quiser e clique em
   **Registrar movimentação**. A localização precisa ser uma localização ativa conhecida.

Para pallets de Recebimento, Expedição, Retenção e Quarentena há também uma lista de **Status**; mude-a e clique em
**Registrar status** (o botão mostra Registrar movimentação quando a localização mudou). Um pallet de Armazenagem
não tem lista de Status — o status dele muda pelo lacrar e deslacr abaixo.

## Montando um novo pallet de Armazenagem

Um líder ou motorista de empilhadeira faz isso quando um pallet sai da área de triagem. Sem pallet na tela, a
página mostra **Montar um novo pallet de Armazenagem**.

1. Em **Na área de triagem** está a lista de coleta: cada item ainda aguardando, quantos (*Aguardando*) e a sua
   validade mais próxima. Clique em **Colocar todos os N no pallet** para preparar um item. Itens que compartilham
   um ACS Item# são agrupados em uma única linha; clique nela para expandir os itens individuais, ou use o botão
   dela para preparar todos.
2. Os itens preparados aparecem em uma tabela acima. Mude a **Quantidade** se apenas parte vai para este pallet (não
   pode exceder o que está aguardando) ou clique em **Remover**.
3. Confira a data de **Validade** de cada item na lista — é a data mais próxima conhecida para aquele item e vai
   para a etiqueta dele; mude-a ou limpe-a se estiver errada. Digite ou escaneie a **Localização** para a qual o
   pallet vai. A **Validade** do próprio pallet é preenchida com a data mais próxima entre os itens; mude-a ou
   clique em **Auto** para voltar. Adicione **Notas** se necessário.
4. Clique em **Lacrar e posicionar**. Um novo pallet de Armazenagem é criado, lacrado e posicionado naquela
   localização. Uma linha verde mostra a tag e o conteúdo dele, com um botão **Imprimir etiqueta do pallet** —
   imprima e cole no pallet — e um botão **Imprimir etiquetas de item**: uma etiqueta pequena para cada item que
   você colocou, mostrando o ACS Item# e a descrição, a quantidade, a validade mais próxima e o pallet, com um
   código de barras. Cole cada uma nas suas caixas. As etiquetas de item imprimem no tamanho pequeno de etiqueta
   (definido na página Impressoras). Para imprimi-las de novo depois, escaneie o pallet: a lista **Etiquetas de
   inventário** dele tem um botão Imprimir para cada.

O sistema não deixará você colocar em pallets mais de um item do que ainda está na área de triagem ("Somente N de …
ainda não estão em um pallet"). Quando tudo está em um pallet, a lista diz *Nada aguardando — tudo o que foi triado
já está em um pallet.*

**Adicionando a um pallet existente:** escaneie um pallet de Armazenagem que esteja *aberto*; a mesma lista agora
mostra **Adicionar itens ao W…** e o botão é **Adicionar ao pallet**. Um pallet lacrado precisa ser deslacrado
antes.

## Lacrando e deslacrando

- Um pallet de Armazenagem **lacrado** só pode ser movido ou deslacrado. A página lembra: deslacre-o para adicionar
  itens ou ajustar o que está nele. Os separadores também não podem pegar de um pallet lacrado — a menos que a
  separação leve o pallet inteiro, ou alguém o deslacre primeiro.
- Clique em **Deslacr** para abri-lo; clique em **Relacrar** quando terminar.
- Um pallet que esgota os bens (um separador leva os últimos itens) é marcado como vazio automaticamente.

## Ajustando o estoque de um pallet

As contagens às vezes divergem: algo é danificado, uma caixa desaparece, ou alguém colocou o item errado. Um ajuste
corrige o que está registrado em um pallet. Exige uma permissão separada, **Ajustar estoque** (normalmente Escritório
e Administrador) — sem ela, você não verá os botões abaixo.

Só está disponível para um pallet de Armazenagem **aberto** que já tenha **localização**. Então dois botões
aparecem: **Adicionar da área de triagem** e **Ajustar estoque** — você pode usar um por vez.

1. Clique em **Ajustar estoque**.
2. Para cada item, digite um número em **Alterar**: um sinal de menos remove (`-3`), um número simples soma.
   **Depois** mostra o resultado. Para adicionar um item que ainda não está no pallet, busque-o em **Outro item**.
3. Escolha um **Motivo**: Quebra, Itens danificados, Correção de contagem, Correção do tipo de item ou Outro. Para
   Outro você precisa explicar em **Notas**.
4. Clique em **Registrar ajuste**. Você não pode retirar mais do que o pallet tem.

Todo ajuste é registrado com quem, quando e por quê, e ele próprio altera o estoque disponível — não é um
lançamento de triagem.

## Localizações e Movimentações recentes

- **Localizações** — uma tabela de cada localização ativa com o número de pallets vivos ali, desdobrado por status.
  Clique em uma localização para listar os pallets dela e clique na tag de um pallet para abri-lo na aba Pallets.
  Pallets sem localização aparecem como *Sem localização registrada*. Pallets esvaziados, expedidos, recolhidos,
  liberados, inutilizados e perdidos não são contados.
- **Movimentações recentes** — as 100 entradas mais recentes de todos os pallets (data, pallet, localização, status,
  notas).

A ordem das localizações ao longo do armazém (a rota de separação) é configurada em Configurações por um
administrador; ela decide a ordem em que os separadores caminham.

## Gerenciamento de pallets

O [Gerenciamento de pallets](/pallet-management) (também precisa de Gerenciar pallets) é a lista de registros
simples dos pallets — use-o para **reimprimir a etiqueta de um pallet** (Imprimir etiqueta do pallet) ou para
corrigir à mão o registro de um pallet. Ele lista os pallets ainda em uso; abra um para ver a Tag do pallet, o
Tipo, a Data de embalagem, a Localização, o Status, o Tipo de contêiner (Pallet, Gaylord, Caixa, Saco ou Tote) e o
Histórico de status do pallet. O tipo não pode ser mudado depois de um pallet etiquetado.

Para o trabalho do dia a dia — mover pallets, montá-los, ajustá-los — use a Movimentação de estoque: ela registra
cada mudança no histórico e confere as regras para você, enquanto o Gerenciamento de pallets deixa você definir o
status diretamente (de uma lista dos status válidos para aquele tipo de pallet).

## Guias relacionados

- [Triagem de doações](/help/sorting) — como os bens entram na área de triagem.
- [Atendimento de pedidos](/help/order-filling) — como os separadores pegam bens dos pallets.
- [Expedição](/help/shipping) — o que acontece depois que um pedido é atendido.
