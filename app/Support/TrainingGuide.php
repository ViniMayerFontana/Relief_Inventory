<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Support;

use App\Services\TrainingMode;

/**
 * The Training Mode class plan: six stations, five teams, two 50-minute segments. Team N starts at station N
 * (station 6 is empty in the first slot) and every slot each team moves on one station (6 -> 1), so a segment is
 * one full rotation, about 8 minutes per station. Segment 1 does each station's Round 1 activity, segment 2 its
 * Round 2. This is the one source for every printed team sheet (reports/training/team-sheet.blade.php) — edit the
 * activities here.
 */
class TrainingGuide
{
    public const SEGMENT_MINUTES = 50;

    /** Station number => [page, round 1 steps, round 2 steps]. Each round is about 6 minutes of hands-on work. */
    public const ACTIVITIES = [
        1 => [
            'page' => 'Recebimento',
            'round1' => [
                'title' => 'Receber uma entrega',
                'steps' => [
                    'Abra Recebimento e toque em Registrar recebimento.',
                    'Confira a lista de ofertas: se esta entrega corresponder a uma oferta feita por telefone, selecione-a.',
                    'Escolha o doador, o motorista e como a doação chegou; depois, conte os recipientes (paletes, caixas, sacolas).',
                    'Em seguida, adicione uma foto da carga (ou ignore esta etapa) e toque em Imprimir etiquetas.',
                    'Coloque uma etiqueta em cada palete ou recipiente e leve-o para a área de triagem.',
                ],
            ],
            'round2' => [
                'title' => 'Registrar uma oferta por telefone e receber a doação',
                'steps' => [
                    'Abra Recebimento > Ofertas de doação e toque em Registrar oferta de doação.',
                    'Um instrutor lerá para você a mensagem de um doador: informe o doador, o que está oferecendo e quando a doação chegará.',
                    'Aprove a oferta para que ela aguarde a chegada (Pendente).',
                    'Quando os itens chegarem, registre o recebimento e associe-o à oferta; depois, imprima e aplique as etiquetas.',
                ],
            ],
        ],
        2 => [
            'page' => 'Triagem de doações',
            'round1' => [
                'title' => 'Triar uma doação',
                'steps' => [
                    'Abra Triagem de doações. Se houver uma doação em Aguardando triagem, toque nela e leia a etiqueta do palete.',
                    'Caso contrário, toque em Iniciar triagem (sem etiqueta) e depois em Editar ao lado do doador para indicar de quem veio.',
                    'Para cada item: leia o código de barras ou pesquise-o, informe a quantidade e escolha Novo ou Utilizável.',
                    'Registre itens vencidos ou danificados em linhas separadas como Vencido ou Descartado.',
                    'Com etiqueta de palete: quando ele estiver vazio, toque em Palete vazio e depois em Palete em boas condições. Sem etiqueta: toque em Concluir sessão.',
                ],
            ],
            'round2' => [
                'title' => 'Códigos de barras e caixas',
                'steps' => [
                    'Pegue outro palete em Aguardando triagem e leia sua etiqueta.',
                    'Leia o código de barras de um item avulso e depois o de uma caixa: observe como a caixa preenche a quantidade.',
                    'Se o código de barras não for reconhecido, adicione-o quando a janela Novo item / Novo código de caixa abrir.',
                    'Finalize o palete (Palete vazio) e, quando terminar a doação, toque em Concluir sessão.',
                ],
            ],
        ],
        3 => [
            'page' => 'Movimentação de estoque',
            'round1' => [
                'title' => 'Montar um palete do armazém',
                'steps' => [
                    'Abra Movimentação de estoque (aba Paletes). Se nenhum palete aparecer, você está montando um novo.',
                    'Toque nos itens em Na área de triagem e informe quantos serão colocados no palete.',
                    'Leia a etiqueta do espaço de mesa (A-1 a C-4) onde ele ficará e toque em Lacrar e posicionar.',
                    'Imprima as etiquetas de itens sugeridas e coloque-as no palete.',
                ],
            ],
            'round2' => [
                'title' => 'Localizar e mover um palete',
                'steps' => [
                    'Leia a etiqueta de um palete W: veja onde está, o que contém e seu histórico.',
                    'Leia o código de barras de outro local para movê-lo para lá.',
                    'Abra um palete, adicione itens da área de triagem e lacre-o novamente.',
                    'Abra a aba Locais e descubra o que está em um espaço de mesa.',
                ],
            ],
        ],
        4 => [
            'page' => 'Separação de pedidos',
            'round1' => [
                'title' => 'Separar um pedido',
                'steps' => [
                    'Abra Separação de pedidos e toque em Iniciar separação em um pedido Pronto para separar.',
                    'Siga a instrução Separar de cada linha — primeiro a área de triagem, depois o palete indicado.',
                    'Informe o que você realmente separou (Adicionar separação). Abra um palete lacrado se o plano indicar.',
                    'Quando todas as linhas tiverem uma separação registrada, toque em Concluir separação.',
                ],
            ],
            'round2' => [
                'title' => 'Listas de separação impressas',
                'steps' => [
                    'Confira Revisar alocação: o que acontece quando a quantidade solicitada é maior que o estoque disponível?',
                    'Imprima uma Lista de separação para um pedido e separe os itens usando o papel.',
                    'Informe as quantidades separadas na tela Separação de pedidos e toque em Concluir separação.',
                ],
            ],
        ],
        5 => [
            'page' => 'Expedição',
            'round1' => [
                'title' => 'Atribuir um motorista e enviar',
                'steps' => [
                    'Abra Expedição. Em Separado — pronto para atribuir motorista, escolha o motorista da sua equipe (Motorista da equipe N) e toque em Atribuir.',
                    'Imprima o conhecimento de embarque gerado para o pedido.',
                    'Deixe a carga pronta na doca e toque em Marcar como enviado quando ela sair.',
                ],
            ],
            'round2' => [
                'title' => 'Enviar uma segunda carga',
                'steps' => [
                    'Atribua outro pedido separado a um motorista da equipe.',
                    'Imprima o conhecimento de embarque e uma etiqueta de envio; confira os itens do pedido na carga.',
                    'Marque-o como enviado.',
                ],
            ],
        ],
        6 => [
            'page' => 'Registro de pedidos / Portal do motorista',
            'round1' => [
                'title' => 'Registrar um pedido de uma entidade parceira',
                'steps' => [
                    'Abra Registro de pedidos e toque em Novo pedido.',
                    'Escolha uma entidade parceira de treinamento e confirme os dados de contato e entrega.',
                    'Adicione três ou quatro itens com as quantidades (marque um como Crítico).',
                    'Revise e confirme; depois, conclua o pedido — ele ficará Pronto para separar.',
                ],
            ],
            'round2' => [
                'title' => 'Entregar e revisar o comprovante',
                'steps' => [
                    'No telefone ou tablet da estação (sem entrar), abra o Portal do motorista e acesse com o telefone e o PIN do motorista da equipe (abaixo).',
                    'Abra sua carga enviada, toque em Enviar comprovante assinado e fotografe o comprovante impresso assinado.',
                    'De volta à Expedição (com acesso), localize-a em Entregue — aguardando revisão, toque em Revisar e aprove-a (ou recuse-a com uma justificativa).',
                ],
            ],
        ],
    ];

    /** The station team $team is at in slot $slot (0-based) of a segment. */
    public static function stationFor(int $team, int $slot): int
    {
        return (($team - 1 + $slot) % count(TrainingMode::STATIONS)) + 1;
    }

    /** Minutes from the start of a segment to the start of each of the six slots. */
    public static function slotStart(int $slot): int
    {
        return (int) round($slot * self::SEGMENT_MINUTES / count(TrainingMode::STATIONS));
    }

    /** Everything a team sheet prints, in that team's rotation order. */
    public static function sheetFor(int $team): array
    {
        $slots = [];
        foreach (range(0, count(TrainingMode::STATIONS) - 1) as $slot) {
            $station = self::stationFor($team, $slot);
            $slots[] = [
                'slot' => $slot + 1,
                'start' => self::slotStart($slot),
                'end' => self::slotStart($slot + 1),
                'station' => $station,
                'name' => TrainingMode::STATIONS[$station],
                'activity' => self::ACTIVITIES[$station],
            ];
        }

        return ['team' => $team, 'slots' => $slots];
    }
}
