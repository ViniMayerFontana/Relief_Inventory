<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o registro de cada parceiro, doador, fornecedor e contato. Estas são as pessoas e organizações escolhidas
no [Recebimento](/help/receiving) e na [Entrada de pedidos](/help/order-entry).

## Encontrando e adicionando pessoas

Abra [Configurações → Cadastro de pessoas](/setup/people) (precisa da permissão Gerenciar pessoas). Cada linha da
lista mostra o nome, a organização se houver, telefone, e-mail, os papéis e se a pessoa é voluntária. Digite em
**Buscar por nome ou organização...** para estreitar a lista, clique em uma linha para abri-la, ou use o botão de
novo registro no topo para adicionar alguém.

Clique em **Salvar** para manter as suas alterações ou **Cancelar alterações** para descartá-las. Se um
salvamento falha, o motivo aparece no formulário (por exemplo, um e-mail ou código de crachá já usado por outra
pessoa).

## Nomes e organizações

Preencha um **Nome** e um **Sobrenome**, uma **Organização**, ou ambos — **pelo menos um dos três é
obrigatório**. Uma doação muitas vezes chega apenas com o nome de uma empresa, ou sem nada conhecido; para isso,
use o registro interno **Unknown Donor** (doador desconhecido) em vez de inventar um nome.

## Organizações e seus contatos

1. Crie o próprio registro da organização (por exemplo "Igreja Adventista da Macedônia") e marque **Este registro
   é a própria organização**. Ela então aparece com uma tag *org* na lista.
2. Crie um registro para cada pessoa de contato. Em **Organização pai**, busque e selecione a organização.
3. Um campo **Função do contato** aparece quando um pai é escolhido — digite algo como Primário, Entrega ou
   Faturamento.

Os contatos mostram "Pai: ..." na lista. Somente registros marcados como organização podem ser escolhidos como
pai, e um registro não pode ser o pai dele mesmo.

## Outros detalhes

- **Categoria** — uma tag aberta para filtragem (Doador, Fornecedor, Contato do armazém...). Digite uma nova para
  adicioná-la. Não é obrigatória e não tem nada a ver com permissões.
- **Código do crachá** — o código do crachá físico da pessoa, se ela tiver um. Cada código pode pertencer a
  apenas uma pessoa.
- **Telefone** e **E-mail** — um endereço de e-mail só pode ser usado em um registro.
- **Voluntário** — marque se a pessoa é voluntária; é separado do papel dela.
- **Comentários** — notas livres.

## Endereço, cidade, estado e condado

Informe o **CEP** primeiro e depois o **Endereço**. Quando você sai de um campo de endereço, o sistema o verifica
on-line e preenche **Cidade**, **Estado** e **Condado** em branco para você. Se a grafia do sistema para o
endereço difere da sua, ele mostra ambas e deixa você aceitar a versão dele ou manter a sua. O Condado também é
usado em relatórios, por isso vale a pena conferir.

- Se um endereço nunca foi conferido, um botão **Verificar endereço** aparece durante a edição. Ele fica
  desabilitado e diz que não pode verificar quando o sistema está em modo offline.
- Nada do que você digita é sobrescrito silenciosamente: Cidade, Estado e CEP só são preenchidos onde estão em
  branco. Você sempre pode digitá-los ou escolher o condado você mesmo.

## Papéis e aprovação de parceiro

A caixa **Papéis** aqui oferece apenas os papéis de acompanhamento de parceiros (como Partner, Donor e
Volunteer). O acesso de login da equipe e as mudanças individuais de permissão ficam em Configurações →
Administração de usuários, não nesta página.

- Você só pode dar um papel a alguém se você mesmo tiver todas as permissões daquele papel. A mesma regra vale
  para editar alguém que já tenha uma permissão que você não tem: o registro dele abre somente leitura com a
  mensagem "Você não tem permissão para editar este registro." Use **Voltar à lista** para sair.
- Uma pessoa com o papel Partner também ganha uma linha **Status do parceiro** com botões para os movimentos que
  fazem sentido a partir do status atual: **Aprovar**, **Negar**, **Bloquear**, **Reconsiderar** e **Desbloquear
  (Aprovar)**. Adicione uma nota opcional e clique em **Confirmar**. Cada mudança é registrada abaixo com quem a
  fez e quando.

## Excluindo um registro

Clique em **Excluir** e depois em **Confirmar exclusão — não pode ser desfeita** (ou **Manter registro** para
voltar atrás). O botão Excluir só aparece para pessoas com a permissão separada Excluir pessoas, que a maioria
dos papéis não tem. O registro interno **Unknown Donor** (doador desconhecido) nunca pode ser excluído.
