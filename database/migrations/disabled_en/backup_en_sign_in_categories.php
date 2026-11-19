<?php

/**
 * BACKUP EN (não-executável) — legado em inglês extraído do migration
 * 2026_08_26_000003_add_kiosk_location_id_to_sign_in_categories_table.php
 * durante a migração pt-BR (2026-11-19). A DDL (coluna kiosk_location_id,
 * backfill, índices) permanece no arquivo original; os três Guest Types
 * pt-BR entram por 2026_11_19_000004_seed_sign_in_categories_pt_br.php.
 *
 * Este arquivo fica em database/migrations/disabled_en/ e nunca é
 * carregado pelo migrator (glob não-recursivo de `$path.'/*_*.php'`).
 */

foreach (['Maintenance/Repair', 'FEMA', 'State'] as $name) {
    DB::table('sign_in_categories')->insertOrIgnore([
        'kiosk_location_id' => 1,
        'name' => $name,
        'created_at' => now(),
        'updated_at' => now(),
    ]);
}
