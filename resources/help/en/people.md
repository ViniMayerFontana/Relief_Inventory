<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o registro de cada parceiro, doador, fornecedor e contato. Essas são as pessoas e organizações escolhidas em [Recebimento](/help/receiving)
e [Cadastro de pedidos](/help/order-entry).

## Encontrando e adicionando pessoas

Abra [Configuração → People Entry](/setup/people) (precisa da permissão Manage People). Cada linha da lista mostra o nome, qualquer organização, telefone,
email, funções e se a pessoa é voluntária. Digite em **Search by name or organization...** para estreitar a lista, clique em uma linha para abri-la ou use o botão de novo registro no topo para adicionar alguém.

Clique em **Save** para manter as alterações ou **Cancel Changes** para descartá-las. Se um salvamento falhar, a razão aparece no formulário (por exemplo,
email ou badge code já usados por outra pessoa).

## Nomes e organizações

Preencha um **First Name** e um **Last Name**, uma **Organization**, ou ambos — **pelo menos um dos três é obrigatório**. Muitas vezes uma doação chega
com apenas o nome da empresa ou com nada conhecido; nesse caso, use o registro interno **Unknown Donor** em vez de inventar um nome.

## Organizações e seus contatos

1. Crie o registro da própria organização (por exemplo, “Macedonia SDA Church”) e marque **This record is the organization itself**. Ele então aparece
como uma tag *org* na lista.
2. Crie um registro para cada pessoa de contato. Em **Parent Organization**, procure e escolha a organização.
3. Um campo **Contact Role** aparece quando a organização pai é escolhida — digite algo como Primary, Delivery ou Billing.

Os contatos aparecem como “Parent: ...” na lista. Apenas registros marcados como organização podem ser escolhidos como pai, e um registro não pode ser
seu próprio pai.

## Outros detalhes

- **Category** — uma categoria livre para filtragem (Donor, Supplier, Warehouse Contact...). Digite uma nova para adicioná-la. Não é obrigatória e não tem
relação com permissões.
- **Badge Code** — o código do crachá físico da pessoa, se houver. Cada código pode pertencer a apenas uma pessoa.
- **Phone** e **Email** — um endereço de email pode ser usado em apenas um registro.
- **Volunteer** — marque se a pessoa é voluntária; isso é separado da função.
- **Comments** — observações livres.

## Endereço, cidade, estado e município

Digite o **ZIP Code** primeiro, depois o **Address**. Quando você sai de um campo de endereço, o sistema verifica online e preenche os campos vazios de
**City**, **State** e **County** para você. Se a grafia do endereço diferir da sua, ele mostra os dois e permite aceitar a versão dele ou manter a sua.
County também é usado em relatórios, então vale a pena conferir.

- Se um endereço nunca foi verificado, um botão **Verify Address** aparece durante a edição. Ele fica desativado e diz que não consegue verificar quando
o sistema está em modo off-line.
- Nada que você digitar é sobrescrito silenciosamente: City, State e ZIP só são preenchidos onde estiverem em branco. Você pode sempre digitar ou
escolher o município você mesmo.

## Funções e aprovação de parceiro

A caixa **Roles** aqui oferece apenas as funções de cadastro de participantes (como Partner, Donor e Volunteer). Acesso de login do pessoal e alterações
individuais de permissão são tratadas em Configuração → User Administration, não nesta página.

- Você só pode dar uma função a alguém se tiver todas as permissões dessa função. A mesma regra vale para editar alguém que já tenha uma permissão que você não tem: o registro abre em modo somente leitura com a mensagem “You don't have permission to edit this record.” Use **Back to List** para sair.
- Uma pessoa com a função Partner também recebe uma linha **Partner Status** com botões para os movimentos que fazem sentido a partir do status atual:
**Approve**, **Deny**, **Block**, **Reconsider** e **Unblock (Approve)**. Adicione uma observação opcional e clique em **Confirm**. Cada alteração é registrada abaixo com quem a fez e quando.

## Excluindo um registro

Clique em **Delete**, depois **Confirm Delete — cannot be undone** (ou **Keep Record** para retroceder). O botão Delete só aparece para pessoas com a
permissão separada Delete People, que a maioria das funções não tem. O registro interno **Unknown Donor** nunca pode ser deletado.
