<?php

/**
 * BACKUP EN (não-executável) — legado em inglês extraído do migration
 * 2025_02_10_012600_modify_locations.php durante a migração pt-BR
 * (2026-11-19). A DDL da tabela `uses` e as alterações em `locations`
 * permanecem no arquivo original; os três usos pt-BR entram por
 * 2026_11_19_000002_seed_location_uses_pt_br.php.
 *
 * Este arquivo fica em database/migrations/disabled_en/ e nunca é
 * carregado pelo migrator (glob não-recursivo de `$path.'/*_*.php'`).
 */

DB::table('uses')->insert([
    ['use' => 'Staging', 'created_at' => now(), 'updated_at' => now()],
    ['use' => 'Long-Term Storage', 'created_at' => now(), 'updated_at' => now()],
    ['use' => 'Sorting', 'created_at' => now(), 'updated_at' => now()],
]);
