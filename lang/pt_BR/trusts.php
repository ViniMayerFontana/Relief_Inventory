<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

/*
 * Display strings for trust permissions (App\Support\TrustPermission). Keys are
 * the permission value with dots replaced by dashes ('print.share' →
 * 'print-share'); the '-desc' suffix holds the description. Missing keys fall
 * back to the English text in the enum.
 */

return [
    'print-share' => 'Compartilhar impressoras',
    'print-share-desc' => 'O par é um servidor de impressão (ou pode usar impressoras compartilhadas com ele) e pode assumir trabalhos de impressão.',
    'feedback-send' => 'Enviar feedback',
    'feedback-send-desc' => 'O par pode enviar relatórios de bugs e sugestões a esta instância.',
    'feedback-receive' => 'Receber feedback',
    'feedback-receive-desc' => 'O par pode ler os relatórios de feedback que esta instância guarda.',
    'offers-send' => 'Enviar ofertas de doação',
    'offers-send-desc' => 'O par pode ofertar doações a esta instância.',
    'offers-receive' => 'Receber ofertas de doação',
    'offers-receive-desc' => 'O par pode receber ofertas de doação desta instância.',
    'inventory-query_exact' => 'Consultar estoque exato',
    'inventory-query_exact-desc' => 'O par pode ler as quantidades exatas em estoque.',
    'supplies-request' => 'Solicitar suprimentos',
    'supplies-request-desc' => 'O par pode enviar solicitações de suprimentos, que a equipe revisa como qualquer outra solicitação.',
    'supplies-query_available' => 'Consultar itens disponíveis para solicitação',
    'supplies-query_available-desc' => 'O par pode ver quais itens estão disponíveis para solicitação.',
    'operator-full_read' => 'Operador de backup e relatórios (acesso completo de leitura)',
    'operator-full_read-desc' => 'O par pode criar e baixar backups desta instância (e, mais adiante, ler seus relatórios). Um backup do banco contém credenciais e dados pessoais: conceda apenas a um operador em quem você confiaria o sistema inteiro.',
];
