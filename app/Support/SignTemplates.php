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
                $sign('receiving', 'RECEBIMENTO', 'Todas as doações devem ser registradas aqui'),
                $sign('donation-drop-off', 'ENTREGA DE DOAÇÕES', 'Aguarde aqui a ajuda de um voluntário para descarregar'),
                $sign('sorting', 'TRIAGEM'),
                $sign('sorting-area', 'TRIADOS — AGUARDANDO ARMAZENAMENTO', 'Não retire itens desta área para pedidos'),
                $sign('to-be-sorted', 'AGUARDANDO TRIAGEM', 'Paletes aguardando a triagem'),
                $sign('picking', 'SEPARAÇÃO DE PEDIDOS'),
                $sign('ready-to-ship', 'PRONTO PARA ENVIO', 'Pedidos separados aguardando retirada ou entrega'),
                $sign('shipping', 'EXPEDIÇÃO'),
                $sign('partner-pickup', 'RETIRADA POR ENTIDADE PARCEIRA', 'Registre-se no escritório antes de carregar'),
                $sign('loading-dock', 'DOCA DE CARGA'),
                $sign('office', 'ESCRITÓRIO'),
                $sign('volunteer-sign-in', 'REGISTRO DE VOLUNTÁRIOS', 'Todos devem registrar entrada e saída, sempre'),
                $sign('break-room', 'SALA DE DESCANSO', 'Não consuma alimentos ou bebidas na área do armazém'),
                $sign('restrooms', 'BANHEIROS'),
                $sign('first-aid', 'PRIMEIROS SOCORROS', 'Informe qualquer lesão à liderança da equipe', 'safety'),
            ],
            'Caixas de triagem' => [
                $sign('bin-new', 'NOVO', 'Fechado, na embalagem original', null, 'portrait'),
                $sign('bin-usable', 'UTILIZÁVEL', 'Limpo, funcionando e completo', null, 'portrait'),
                $sign('bin-outdated', 'VENCIDO', 'Com a data de validade vencida', null, 'portrait'),
                $sign('bin-trash', 'DESCARTE', 'Danificado, sujo, aberto ou inseguro', null, 'portrait'),
                $sign('bin-divert', 'DESTINAR A OUTRO LOCAL', 'Itens em boas condições que não distribuímos — separe para outra organização', null, 'portrait'),
                $sign('bin-hold', 'AGUARDE — CONSULTE A LIDERANÇA', 'Não sabe o que é ou para onde vai? Deixe aqui.', 'notice', 'portrait'),
                $sign('cardboard', 'RECICLAGEM DE PAPELÃO', 'Desmonte todas as caixas'),
                $sign('empty-pallets', 'PALETES VAZIOS', 'Deixe os paletes vazios aqui'),
            ],
            'Itens' => [
                $sign('goods-water', 'ÁGUA'),
                $sign('goods-food', 'ALIMENTOS'),
                $sign('goods-hygiene', 'HIGIENE'),
                $sign('goods-cleaning', 'MATERIAIS DE LIMPEZA'),
                $sign('goods-baby', 'ARTIGOS PARA BEBÊS'),
                $sign('goods-paper', 'PRODUTOS DE PAPEL'),
                $sign('goods-bedding', 'ROUPAS DE CAMA E BANHO'),
                $sign('goods-pet', 'ARTIGOS PARA ANIMAIS'),
                $sign('goods-tools', 'FERRAMENTAS E EQUIPAMENTOS'),
            ],
            'Segurança' => [
                $sign('authorized-only', 'SOMENTE PESSOAL AUTORIZADO', 'Voluntários e funcionários somente além deste ponto', 'warning'),
                $sign('forklift-traffic', 'ATENÇÃO: EMPILHADEIRAS', 'A preferência é das empilhadeiras', 'caution'),
                $sign('no-forklift-ride', 'PROIBIDO PEGAR CARONA EM EMPILHADEIRAS OU PALETEIRAS', '', 'danger'),
                $sign('closed-toe-shoes', 'OBRIGATÓRIO USAR CALÇADOS FECHADOS', 'Sempre na área do armazém', 'notice'),
                $sign('team-lift', 'LEVANTAMENTO EM EQUIPE', 'Mais de 23 kg? Peça ajuda. Levante usando as pernas.', 'caution'),
                $sign('keep-clear', 'MANTENHA LIVRE', 'Não bloqueie esta saída, porta ou painel', 'warning'),
                $sign('wet-floor', 'PISO MOLHADO', '', 'caution', 'portrait'),
                $sign('no-smoking', 'PROIBIDO FUMAR', 'Em qualquer lugar dentro ou perto do prédio', 'danger'),
                $sign('assembly-point', 'PONTO DE ENCONTRO DE EMERGÊNCIA', 'Reúna-se aqui se o prédio for evacuado', 'safety'),
                $sign('supervise-children', 'CRIANÇAS DEVEM SER SUPERVISIONADAS', 'Consulte a liderança antes de trazer crianças para a área de trabalho', 'notice'),
            ],
            'Doadores e visitantes' => [
                $sign('no-clothing', 'NÃO ACEITAMOS ROUPAS', 'Agradecemos por pensar em nós — leve as roupas a um brechó local', 'notice'),
                $sign('no-donations-today', 'NÃO ESTAMOS RECEBENDO DOAÇÕES HOJE', 'Ligue antes de trazer doações', 'notice'),
                $sign('thank-you', 'OBRIGADO!', 'Sua doação ajuda famílias a se reerguerem'),
                $sign('visitors-check-in', 'TODOS OS VISITANTES DEVEM SE REGISTRAR NO ESCRITÓRIO', '', 'notice'),
                $sign('this-way', 'POR AQUI', '', null, 'landscape', ['right']),
                $sign('deliveries', 'ENTREGAS', 'Caminhões devem usar a entrada da doca', null, 'landscape', ['right']),
                $sign('volunteer-parking', 'ESTACIONAMENTO DE VOLUNTÁRIOS', '', null, 'landscape', ['right']),
                $sign('no-parking', 'PROIBIDO ESTACIONAR', 'Faixa de circulação de caminhões — mantenha livre', 'warning'),
            ],
        ];
    }

    /** @return array<string, array> every template by key */
    public static function all(): array
    {
        return collect(self::groups())->flatten(1)->keyBy('key')->all();
    }
}
