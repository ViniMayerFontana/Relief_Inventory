<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): reinsere as unidades extras de pedido com `name` em
 * português. `abbreviation`/`type` são técnicos (referenciados por selects
 * e pelo down do legado) e permanecem idênticos — legado EN em
 * disabled_en/backup_en_add_more_default_ordering_units.php. Roda DEPOIS do
 * UnitsSeeder/legado (data posterior).
 */
return new class extends Migration
{
    private const UNITS = [
        ['abbreviation' => 'case', 'name' => 'caixa', 'type' => 'other'],
        ['abbreviation' => 'bag', 'name' => 'saco', 'type' => 'other'],
        ['abbreviation' => 'pallet', 'name' => 'pallet', 'type' => 'other'],
        ['abbreviation' => 'jug', 'name' => 'garrafão', 'type' => 'other'],
    ];

    public function up(): void
    {
        foreach (self::UNITS as $unit) {
            DB::table('units')->insertOrIgnore(array_merge($unit, [
                'created_at' => now(),
                'updated_at' => now(),
            ]));
        }
    }

    public function down(): void
    {
        DB::table('units')->whereIn('abbreviation', array_column(self::UNITS, 'abbreviation'))->delete();
    }
};
