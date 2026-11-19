<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): traduz o itemtype "Unknown" semeado por
 * 2025_01_24_013228_update_items_table.php (itemtype_name é display; sem
 * referência lógica por nome no código — verificado por grep em app/ e
 * resources/js). Localiza por item_number='0000' (chave técnica estável).
 * O packagetype 'Each' inserido no mesmo arquivo fica EN (coluna histórica
 * `type`, renomeada para singular/plural em migration posterior; não tocar
 * na chain).
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('itemtypes')->where('item_number', '0000')->update([
            'itemtype_name' => 'Desconhecido',
            'itemtype_desc' => 'Tipo de item padrão para itens não vinculados',
        ]);
    }

    public function down(): void
    {
        DB::table('itemtypes')->where('item_number', '0000')->update([
            'itemtype_name' => 'Unknown',
            'itemtype_desc' => 'Default item type for unlinked items',
        ]);
    }
};
