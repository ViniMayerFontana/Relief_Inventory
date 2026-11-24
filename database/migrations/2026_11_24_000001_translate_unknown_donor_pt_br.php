<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-24, decisão do usuário): traduz a organização do registro
 * de sistema "Unknown Donor" para "Doador desconhecido" em instâncias que
 * já têm a linha EN semeada por
 * 2026_08_15_030000_add_unknown_donor_system_person.php. O casamento lógico
 * no código é SEMPRE por `system_key` (nunca por organization), então a
 * tradução não afeta imports/relatórios/simulator. down() restaura o EN
 * literal (padrão dos seeds pt-BR).
 */
return new class extends Migration
{
    private const SYSTEM_KEY = 'unknown-donor';

    public function up(): void
    {
        DB::table('people')->where('system_key', self::SYSTEM_KEY)->update([
            'organization' => 'Doador desconhecido',
            'comments' => 'Registro de sistema para doações cuja origem é genuinamente desconhecida no recebimento. Reatribua a doação ao doador real assim que identificado; não exclua este registro.',
        ]);
    }

    public function down(): void
    {
        DB::table('people')->where('system_key', self::SYSTEM_KEY)->update([
            'organization' => 'Unknown Donor',
            'comments' => 'System-provided placeholder for donations whose source is genuinely unknown at intake. Reassign the donation to the real donor once identified; do not delete this record.',
        ]);
    }
};
