<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Support;

/**
 * The ready-made warehouse signs on the Signs page (SignController). They are
 * code, not data: a template only fills in the sign form, which the person can
 * still change before printing, so nothing about a printed sign depends on a
 * template existing. Each one gives a title, optional smaller text, an optional
 * safety header (SignLayout::HEADERS), an orientation and any arrows
 * (SignLayout::ARROWS) it usually needs.
 *
 * These are workplace reminders, not code-compliant safety signage: a real exit
 * sign, fire-extinguisher marker or no-smoking notice the fire marshal requires
 * still has to be the approved kind, which is why there is no EXIT template.
 */
class SignTemplates
{
    /** @return array<string, array<int, array{key: string, title: string, subtitle: string, header: ?string, orientation: string, arrows: array<int, string>}>> */
    public static function groups(): array
    {
        $sign = fn (string $key, string $title, string $subtitle = '', ?string $header = null, string $orientation = 'landscape', array $arrows = []) => [
            'key' => $key, 'title' => $title, 'subtitle' => $subtitle, 'header' => $header,
            'orientation' => $orientation, 'arrows' => $arrows,
        ];

        return [
            'Áreas e estações' => [
                $sign('receiving', 'RECEBIMENTO', 'Todas as doações recebidas são registradas aqui'),
                $sign('donation-drop-off', 'ENTREGA DE DOAÇÕES', 'Aguarde aqui para um voluntário ajudar na descarga'),
                $sign('sorting', 'TRIAGEM'),
                $sign('sorting-area', 'TRIADO — AGUARDANDO GUARDA', 'Não retire itens desta área para pedidos'),
                $sign('to-be-sorted', 'A TRIAR', 'Pallets aguardando a linha de triagem'),
                $sign('picking', 'SEPARAÇÃO DE PEDIDOS'),
                $sign('ready-to-ship', 'PRONTO PARA EXPEDIÇÃO', 'Pedidos atendidos aguardando coleta ou entrega'),
                $sign('shipping', 'EXPEDIÇÃO'),
                $sign('partner-pickup', 'COLETA DE PARCEIRO', 'Registre-se no escritório antes de carregar'),
                $sign('loading-dock', 'DOCAS'),
                $sign('office', 'ESCRITÓRIO'),
                $sign('volunteer-sign-in', 'LOGIN DE VOLUNTÁRIO', 'Todos registram entrada e saída, sempre'),
                $sign('break-room', 'SALA DE DESCANSO', 'Sem comida ou bebida no piso do armazém'),
                $sign('restrooms', 'BANHEIROS'),
                $sign('first-aid', 'PRIMEIROS SOCORROS', 'Comunique todo ferimento a um líder', 'safety'),
            ],
            'Caixas de triagem' => [
                $sign('bin-new', 'NOVO', 'Não aberto, na embalagem original', null, 'portrait'),
                $sign('bin-usable', 'UTILIZÁVEL', 'Limpo, funcionando e completo', null, 'portrait'),
                $sign('bin-outdated', 'VENCIDO', 'Past its expiration or best-by date', null, 'portrait'),
                $sign('bin-trash', 'DESCARTE', 'Danificado, sujo, aberto ou inseguro', null, 'portrait'),
                $sign('bin-divert', 'REDIRECIONAR', 'Bens bons que não distribuímos — separe para outra instituição', null, 'portrait'),
                $sign('bin-hold', 'RETENÇÃO — CONSULTE UM LÍDER', 'Não sabe o que é nem para onde vai? Deixe aqui.', 'notice', 'portrait'),
                $sign('cardboard', 'RECICLAGEM DE PAPELÃO', 'Desmonte todas as caixas'),
                $sign('empty-pallets', 'PALLETS VAZIOS', 'Devolva pallets vazios aqui'),
            ],
            'Bens' => [
                $sign('goods-water', 'ÁGUA'),
                $sign('goods-food', 'COMIDA'),
                $sign('goods-hygiene', 'HIGIENE'),
                $sign('goods-cleaning', 'PRODUTOS DE LIMPEZA'),
                $sign('goods-baby', 'SUPRIMENTOS DE BEBÊ'),
                $sign('goods-paper', 'PRODUTOS DE PAPEL'),
                $sign('goods-bedding', 'ROUPAS DE CAMA E MESA'),
                $sign('goods-pet', 'SUPRIMENTOS PARA PETS'),
                $sign('goods-tools', 'FERRAMENTAS E EQUIPAMENTOS'),
            ],
            'Segurança' => [
                $sign('authorized-only', 'SOMENTE PESSOAL AUTORIZADO', 'Voluntários e equipe além deste ponto', 'warning'),
                $sign('forklift-traffic', 'CUIDADO COM EMPILHADEIRAS', 'Empilhadeiras têm preferência', 'caution'),
                $sign('no-forklift-ride', 'PROIBIDO CARONA EM EMPILHADEIRAS OU PALETEIRAS', '', 'danger'),
                $sign('closed-toe-shoes', 'USO OBRIGATÓRIO DE CALÇADO FECHADO', 'No piso do armazém a todo momento', 'notice'),
                $sign('team-lift', 'TRANSPORTE EM EQUIPE', 'Mais de 50 lb? Peça ajuda. Levante com as pernas.', 'caution'),
                $sign('keep-clear', 'MANTENHA LIVRE', 'Não bloqueie esta saída, porta ou painel', 'warning'),
                $sign('wet-floor', 'PISO MOLHADO', '', 'caution', 'portrait'),
                $sign('no-smoking', 'PROIBIDO FUMAR', 'Em qualquer lugar dentro ou perto do prédio', 'danger'),
                $sign('assembly-point', 'PONTO DE ENCONTRO DE EMERGÊNCIA', 'Reúna-se aqui se o prédio for evacuado', 'safety'),
                $sign('supervise-children', 'CRIANÇAS DEVEM SER SUPERVISIONADAS', 'Consulte um líder antes de trazer crianças ao piso', 'notice'),
            ],
            'Doadores e visitantes' => [
                $sign('no-clothing', 'NÃO ACEITAMOS ROUPAS', 'Obrigado por pensar em nós — leve as roupas a um brechó local', 'notice'),
                $sign('no-donations-today', 'NÃO ACEITAMOS DOAÇÕES HOJE', 'Ligue antes de trazer doações', 'notice'),
                $sign('thank-you', 'OBRIGADO!', 'Sua doação ajuda famílias a se recuperarem'),
                $sign('visitors-check-in', 'TODOS OS VISITANTES SE REGISTRAM NO ESCRITÓRIO', '', 'notice'),
                $sign('this-way', 'POR AQUI', '', null, 'landscape', ['right']),
                $sign('deliveries', 'ENTREGAS', 'Caminhões usam a entrada da doca', null, 'landscape', ['right']),
                $sign('volunteer-parking', 'ESTACIONAMENTO DE VOLUNTÁRIOS', '', null, 'landscape', ['right']),
                $sign('no-parking', 'NO PARKING', 'Truck lane — keep clear', 'warning'),
            ],
        ];
    }

    /** @return array<string, array> every template by key */
    public static function all(): array
    {
        return collect(self::groups())->flatten(1)->keyBy('key')->all();
    }
}
