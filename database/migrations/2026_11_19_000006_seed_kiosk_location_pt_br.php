<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): traduz o cabeçalho do quiosque da localização padrão
 * semeada por 2026_08_26_000000_create_kiosk_locations_table.php ("Main
 * Location" permanece EN lá dentro; a linha é localizada por id=1, que é
 * estável). welcome_message volta intacto (update restrito ao name).
 */
return new class extends Migration
{
    public function up(): void
    {
        DB::table('kiosk_locations')->where('id', 1)->update(['name' => 'Localização principal']);
    }

    public function down(): void
    {
        DB::table('kiosk_locations')->where('id', 1)->update(['name' => 'Main Location']);
    }
};
