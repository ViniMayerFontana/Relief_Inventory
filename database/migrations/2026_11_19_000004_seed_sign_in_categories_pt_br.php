<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): reinsere os três Guest Types iniciais do quiosque em
 * português (nomes de exibição, editáveis pelo admin em Guest Types; sem
 * referência lógica no código). Legado EN em
 * disabled_en/backup_en_sign_in_categories.php. Roda DEPOIS da DDL de
 * 2026_08_26_000003 (mesma chain; kiosk_location_id=1 já backfillado).
 */
return new class extends Migration
{
    private const NAMES = ['Manutenção/Reparo', 'FEMA', 'Estadual'];

    public function up(): void
    {
        foreach (self::NAMES as $name) {
            DB::table('sign_in_categories')->insertOrIgnore([
                'kiosk_location_id' => 1,
                'name' => $name,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    public function down(): void
    {
        DB::table('sign_in_categories')
            ->where('kiosk_location_id', 1)
            ->whereIn('name', self::NAMES)
            ->delete();
    }
};
