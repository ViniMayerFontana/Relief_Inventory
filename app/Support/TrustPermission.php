<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Support;

/**
 * What a trusted peer may do. Worded from the peer acting on us: an inbound grant of `feedback.send` lets
 * the peer send feedback to this instance. Only the ones marked built() have endpoints yet; the rest are
 * defined so trusts can already carry them and the console can describe the risk.
 */
enum TrustPermission: string
{
    case PrintShare = 'print.share';
    case FeedbackSend = 'feedback.send';
    case FeedbackReceive = 'feedback.receive';
    case OffersSend = 'offers.send';
    case OffersReceive = 'offers.receive';
    case InventoryQueryExact = 'inventory.query_exact';
    case SuppliesRequest = 'supplies.request';
    case SuppliesQueryAvailable = 'supplies.query_available';
    case OperatorFullRead = 'operator.full_read';

    public function label(): string
    {
        return match ($this) {
            self::PrintShare => 'Compartilhamento de impressoras',
            self::FeedbackSend => 'Envio de comentários',
            self::FeedbackReceive => 'Recebimento de comentários',
            self::OffersSend => 'Enviar ofertas de doação',
            self::OffersReceive => 'Receber ofertas de doação',
            self::InventoryQueryExact => 'Consultar quantidades exatas do estoque',
            self::SuppliesRequest => 'Solicitar materiais',
            self::SuppliesQueryAvailable => 'Consultar itens disponíveis para solicitação',
            self::OperatorFullRead => 'Operador de backup e relatórios (acesso completo de leitura)',
        };
    }

    public function description(): string
    {
        return match ($this) {
            self::PrintShare => 'A outra parte é um servidor de impressão (ou pode usar impressoras compartilhadas com ele) e pode reivindicar trabalhos de impressão.',
            self::FeedbackSend => 'A outra parte pode enviar relatórios de erros e sugestões para esta instalação.',
            self::FeedbackReceive => 'A outra parte pode ler os relatórios recebidos por esta instalação.',
            self::OffersSend => 'A outra parte pode oferecer doações a esta instalação.',
            self::OffersReceive => 'A outra parte pode receber ofertas de doação desta instalação.',
            self::InventoryQueryExact => 'A outra parte pode consultar as quantidades exatas do estoque.',
            self::SuppliesRequest => 'A outra parte pode enviar solicitações de materiais, que a equipe analisará como qualquer outro pedido.',
            self::SuppliesQueryAvailable => 'A outra parte pode consultar quais itens estão disponíveis para solicitação.',
            self::OperatorFullRead => 'A outra parte pode criar e baixar backups desta instalação (e, futuramente, ler seus relatórios). Um backup do banco de dados contém credenciais e dados pessoais: conceda esta permissão somente a um operador em quem você confiaria o sistema inteiro.',
        };
    }

    /** low | medium | high — how much a peer holding it could see or do. */
    public function risk(): string
    {
        return match ($this) {
            self::PrintShare, self::FeedbackSend, self::OffersSend => 'low',
            self::FeedbackReceive, self::OffersReceive, self::SuppliesRequest, self::SuppliesQueryAvailable => 'medium',
            self::InventoryQueryExact, self::OperatorFullRead => 'high',
        };
    }

    /** Whether an endpoint enforcing this exists yet. */
    public function built(): bool
    {
        return in_array($this, [self::PrintShare, self::FeedbackSend, self::OperatorFullRead], true);
    }

    /** @return list<string> */
    public static function keys(): array
    {
        return array_column(self::cases(), 'value');
    }

    public static function catalog(): array
    {
        return array_map(fn (self $p) => [
            'key' => $p->value, 'label' => $p->label(), 'description' => $p->description(),
            'risk' => $p->risk(), 'built' => $p->built(),
        ], self::cases());
    }
}
