<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * pt-BR (2026-11-19): semeia o catálogo de presets do builder de
 * formulários com rótulos em português. `key`/`category`/`type`/
 * `target_field`/`order` são técnicos e preservam o legado EN
 * (disabled_en/backup_en_form_question_presets.php). Roda DEPOIS da DDL de
 * 2026_08_30_120002_create_form_question_presets_table.php (mesma chain).
 */
return new class extends Migration
{
    private const PRESETS = [
        ['key' => 'org_name', 'label' => 'Nome da organização', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'organization', 'order' => 10],
        ['key' => 'address', 'label' => 'Endereço (rua)', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'address', 'order' => 20],
        ['key' => 'city', 'label' => 'Cidade', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'city', 'order' => 30],
        ['key' => 'state', 'label' => 'Estado', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'state', 'order' => 40],
        ['key' => 'zip', 'label' => 'CEP', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'zip', 'order' => 50],
        ['key' => 'phone', 'label' => 'Telefone', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'phone', 'order' => 60],
        ['key' => 'email', 'label' => 'E-mail', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'email', 'order' => 70],
        ['key' => 'website', 'label' => 'Site', 'category' => 'basic_info', 'type' => 'short_text', 'order' => 80],
        ['key' => 'nonprofit_status', 'label' => 'Status 501(c)(3)', 'category' => 'basic_info', 'type' => 'single_choice', 'options' => ['Sim', 'Não', 'Registro enviado'], 'order' => 90],
        ['key' => 'reference', 'label' => 'Nome ou organização de referência', 'category' => 'basic_info', 'type' => 'short_text', 'order' => 100],
        ['key' => 'services_offered', 'label' => 'Serviços oferecidos', 'category' => 'other', 'type' => 'long_text', 'order' => 110],
        ['key' => 'locations_served', 'label' => 'Localidades atendidas', 'category' => 'other', 'type' => 'long_text', 'order' => 120],
        ['key' => 'counties_served', 'label' => 'Condados atendidos', 'category' => 'other', 'type' => 'long_text', 'order' => 130],
        ['key' => 'families_per_week', 'label' => 'Número estimado de famílias atendidas por semana', 'category' => 'other', 'type' => 'number', 'help_text' => 'Uma estimativa aproximada é suficiente.', 'order' => 140],
        ['key' => 'established', 'label' => 'Quando sua organização foi fundada?', 'category' => 'other', 'type' => 'short_text', 'order' => 150],
        ['key' => 'vision', 'label' => 'Visão ou objetivo da organização', 'category' => 'other', 'type' => 'long_text', 'order' => 160],
        ['key' => 'other_info', 'label' => 'Outras informações importantes', 'category' => 'other', 'type' => 'long_text', 'order' => 170],
    ];

    public function up(): void
    {
        foreach (self::PRESETS as $preset) {
            // DB::table bypasses the model's JSON cast on `options`, so encode here.
            if (array_key_exists('options', $preset)) {
                $preset['options'] = json_encode($preset['options']);
            }
            DB::table('form_question_presets')->insert(array_merge($preset, [
                'created_at' => now(),
                'updated_at' => now(),
            ]));
        }
    }

    public function down(): void
    {
        DB::table('form_question_presets')->whereIn('key', array_column(self::PRESETS, 'key'))->delete();
    }
};
