<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

Mantenha o registro de cada parceiro, doador, fornecedor e contato. Essas são as pessoas e organizações escolhidas em [Recebimento](/help/receiving)
e [Cadastro de pedidos](/help/order-entry).

## Encontrando e adicionando pessoas

Abra [Configuração → Cadastro de pessoas](/setup/people) (precisa da permissão de gerenciamento de pessoas). Cada linha da lista mostra o nome, qualquer organização, telefone,
email, funções e se a pessoa é voluntária. Digite em **Buscar por nome ou organização...** para estreitar a lista, clique em uma linha para abri-la ou use o botão de novo registro no topo para adicionar alguém.

Clique em **Salvar** para manter as alterações ou **Cancelar alterações** para descartá-las. Se um salvamento falhar, a razão aparece no formulário (por exemplo,
email ou código do crachá já usados por outra pessoa).

## Nomes e organizações

Preencha um **Nome** e um **Sobrenome**, uma **Organização**, ou ambos — **pelo menos um dos três é obrigatório**. Muitas vezes uma doação chega
com apenas o nome da empresa ou com nada conhecido; nesse caso, use o registro interno **Doador desconhecido** em vez de inventar um nome.

## Organizações e seus contatos

1. Crie o registro da própria organização (por exemplo, “Igreja Adventista do Sétimo Dia de Macedônia”) e marque **Este registro representa a própria organização**. Ele então aparece
como uma tag *org* na lista.
2. Crie um registro para cada pessoa de contato. Em **Organização principal**, procure e escolha a organização.
3. Um campo **Função do contato** aparece quando a organização principal é escolhida — digite algo como Principal, Entrega ou Cobrança.

Os contatos aparecem como “Parent: ...” na lista. Apenas registros marcados como organização podem ser escolhidos como pai, e um registro não pode ser
seu próprio pai.

## Outros detalhes

- **Categoria** — uma categoria livre para filtragem (Doador, Fornecedor, Contato do armazém...). Digite uma nova para adicioná-la. Não é obrigatória e não tem
relação com permissões.
- **Código do crachá** — o código do crachá físico da pessoa, se houver. Cada código pode pertencer a apenas uma pessoa.
- **Telefone** e **Email** — um endereço de email pode ser usado em apenas um registro.
- **Voluntário** — marque se a pessoa é voluntária; isso é separado da função.
- **Comentários** — observações livres.

## Endereço, cidade, estado e município

Digite o **CEP** primeiro, depois o **Endereço**. Quando você sai de um campo de endereço, o sistema verifica online e preenche os campos vazios de
**Cidade**, **Estado** e **Município** para você. Se a grafia do endereço diferir da sua, ele mostra os dois e permite aceitar a versão sugerida ou manter a sua.
O município também é usado em relatórios, então vale a pena conferir.

- Se um endereço nunca foi verificado, um botão **Verificar endereço** aparece durante a edição. Ele fica desativado e informa que não consegue verificar quando
o sistema está em modo off-line.
- Nada que você digitar é sobrescrito silenciosamente: Cidade, Estado e CEP só são preenchidos onde estiverem em branco. Você pode sempre digitar ou
escolher o município você mesmo.

## Funções e aprovação de parceiro

A caixa **Funções** aqui oferece apenas as funções de cadastro de participantes (como Parceiro, Doador e Voluntário). Acesso de login da equipe e alterações
individuais de permissão são tratadas em Configuração → Administração de usuários, não nesta página.

- Você só pode dar uma função a alguém se tiver todas as permissões dessa função. A mesma regra vale para editar alguém que já tenha uma permissão que você não tem: o registro abre em modo somente leitura com a mensagem “Você não tem permissão para editar este registro.” Use **Voltar à lista** para sair.
- Uma pessoa com a função Parceiro também recebe uma linha **Status do parceiro** com botões para as mudanças que fazem sentido a partir do status atual:
**Aprovar**, **Recusar**, **Bloquear**, **Reconsiderar** e **Desbloquear (aprovar)**. Adicione uma observação opcional e clique em **Confirmar**. Cada alteração é registrada abaixo com quem a fez e quando.

## Excluindo um registro

Clique em **Excluir**, depois **Confirmar exclusão — não pode ser desfeita** (ou **Manter registro** para retroceder). O botão Excluir só aparece para pessoas com a
permissão separada de exclusão de pessoas, que a maioria das funções não tem. O registro interno **Doador desconhecido** nunca pode ser excluído.
