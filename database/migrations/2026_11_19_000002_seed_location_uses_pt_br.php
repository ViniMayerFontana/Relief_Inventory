<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): semeia os três usos de localização em português.
 * A coluna `use` é única e de exibição (UseController/UseModel); o legado
 * EN está em disabled_en/backup_en_uses.php. Roda DEPOIS da DDL de
 * 2025_02_10_012600_modify_locations.php (mesma chain).
 */
return new class extends Migration
{
    private const USES = ['Preparação', 'Armazenagem de longo prazo', 'Triagem'];

    public function up(): void
    {
        foreach (self::USES as $use) {
            DB::table('uses')->insertOrIgnore([
                ['use' => $use, 'created_at' => now(), 'updated_at' => now()],
            ]);
        }
    }

    public function down(): void
    {
        DB::table('uses')->whereIn('use', self::USES)->delete();
    }
};
