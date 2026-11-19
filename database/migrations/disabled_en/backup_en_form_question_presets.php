<?php

/**
 * BACKUP EN (não-executável) — legado em inglês extraído do migration
 * 2026_08_30_120002_create_form_question_presets_table.php durante a
 * migração pt-BR (2026-11-19). A DDL e o foreach permanecem no arquivo
 * original; os presets pt-BR entram por
 * 2026_11_19_000001_seed_form_question_presets_pt_br.php.
 *
 * Este arquivo fica em database/migrations/disabled_en/ e nunca é
 * carregado pelo migrator (glob não-recursivo de `$path.'/*_*.php'`).
 */

$PRESETS_EN = [
    ['key' => 'org_name', 'label' => 'Organization Name', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'organization', 'order' => 10],
    ['key' => 'address', 'label' => 'Street Address', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'address', 'order' => 20],
    ['key' => 'city', 'label' => 'City', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'city', 'order' => 30],
    ['key' => 'state', 'label' => 'State', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'state', 'order' => 40],
    ['key' => 'zip', 'label' => 'Zip Code', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'zip', 'order' => 50],
    ['key' => 'phone', 'label' => 'Phone Number', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'phone', 'order' => 60],
    ['key' => 'email', 'label' => 'Email Address', 'category' => 'basic_info', 'type' => 'short_text', 'target_field' => 'email', 'order' => 70],
    ['key' => 'website', 'label' => 'Website', 'category' => 'basic_info', 'type' => 'short_text', 'order' => 80],
    ['key' => 'nonprofit_status', 'label' => '501(c)(3) Status', 'category' => 'basic_info', 'type' => 'single_choice', 'options' => ['Yes', 'No', 'Applied'], 'order' => 90],
    ['key' => 'reference', 'label' => 'Reference Name or Organization', 'category' => 'basic_info', 'type' => 'short_text', 'order' => 100],
    ['key' => 'services_offered', 'label' => 'Services Offered', 'category' => 'other', 'type' => 'long_text', 'order' => 110],
    ['key' => 'locations_served', 'label' => 'Locations Served', 'category' => 'other', 'type' => 'long_text', 'order' => 120],
    ['key' => 'counties_served', 'label' => 'Counties Served', 'category' => 'other', 'type' => 'long_text', 'order' => 130],
    ['key' => 'families_per_week', 'label' => 'Estimated Number of Families Served per Week', 'category' => 'other', 'type' => 'number', 'help_text' => 'A rough estimate is fine.', 'order' => 140],
    ['key' => 'established', 'label' => 'When Was Your Organization Established?', 'category' => 'other', 'type' => 'short_text', 'order' => 150],
    ['key' => 'vision', 'label' => 'Organization Vision or Goal', 'category' => 'other', 'type' => 'long_text', 'order' => 160],
    ['key' => 'other_info', 'label' => 'Other Important Information', 'category' => 'other', 'type' => 'long_text', 'order' => 170],
];

