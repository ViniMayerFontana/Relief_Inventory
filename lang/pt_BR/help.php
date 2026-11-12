<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

return [

    /*
    |--------------------------------------------------------------------------
    | Guias de ajuda
    |--------------------------------------------------------------------------
    | Títulos dos guias de ajuda do aplicativo (HelpReportController::GUIDES é o
    | registro de slugs) e as strings compartilhadas dos shells de PDF
    | (resources/views/reports/help/*.blade.php).
    */

    'guides' => [
        'receiving' => 'Guia de Recebimento',
        'donation-offers' => 'Guia de Ofertas de Doação',
        'sorting' => 'Guia de Triagem de Doações',
        'inventory-movement' => 'Guia de Movimentação de Estoque',
        'order-entry' => 'Guia de Entrada de Pedidos',
        'order-filling' => 'Guia de Atendimento de Pedidos',
        'shipping' => 'Guia de Expedição',
        'items' => 'Guia da Lista Mestra de Itens',
        'people' => 'Guia de Informações de Parceiros e Doadores',
    ],

    'all_guides' => 'Guias de ajuda',
    'contents' => 'Sumário',
    'footer' => 'Dúvidas ou algo que não funciona como este guia descreve? Use "Relatar um problema" no menu do perfil no aplicativo.',
];
