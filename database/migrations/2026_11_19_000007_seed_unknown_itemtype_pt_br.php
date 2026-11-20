<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): traduz o itemtype "Unknown" (name/description são
 * display; sem referência lógica por nome no código — verificado por grep em
 * app/ e resources/js). Localiza por number='0000' (chave técnica estável).
 *
 * Em install FRESH essa linha nem existe (o insert EN de
 * 2025_01_24_013228 é condicional e usa colunas de um schema antigo que a
 * chain atual nem tem mais — nem `number` existe hoje). O update casa por
 * name='Unknown' (display; sem referência lógica por nome — verificado) e é
 * no-op quando a linha não existe. Instâncias antigas/migradas à mão ganham
 * a tradução.
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('itemtypes')->where('name', 'Unknown')->update([
            'name' => 'Desconhecido',
            'description' => 'Tipo de item padrão para itens não vinculados',
        ]);
    }

    public function down(): void
    {
        DB::table('itemtypes')->where('name', 'Desconhecido')->update([
            'name' => 'Unknown',
            'description' => 'Default item type for unlinked items',
        ]);
    }
};
