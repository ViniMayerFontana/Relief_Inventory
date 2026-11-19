<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): traduz o nome de exibição do armazém padrão semeado
 * por 2025_03_06_231836_create_default_warehouse.php ("Default Warehouse"
 * permanece EN lá dentro porque o down() desse arquivo casa por nome).
 * Campos de endereço fictícios ficam como estão (placeholder).
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('warehouses')->where('name', 'Default Warehouse')->update(['name' => 'Armazém Padrão']);
    }

    public function down(): void
    {
        DB::table('warehouses')->where('name', 'Armazém Padrão')->update(['name' => 'Default Warehouse']);
    }
};
