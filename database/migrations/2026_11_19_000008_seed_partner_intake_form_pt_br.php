<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use App\Models\Form;
use App\Models\FormQuestion;
use App\Models\FormQuestionPreset;
use Illuminate\Database\Migrations\Migration;

/**
 * pt-BR (2026-11-19): reimplementa o Partner Agency Intake (legado EN em
 * disabled_en/backup_en_partner_intake_form.php) com name/intro_text em
 * português. As perguntas são copiadas dos presets (já pt-BR via
 * 2026_11_19_000001), mantendo required/preset_key/target_field idênticos.
 * `slug` é técnico (casa o down) e preserva o valor EN — sem referência em
 * código fora da própria migration (verificado por grep em app/, tests/ e
 * resources/js).
 */
return new class extends Migration
{
    public function up(): void
    {
        $form = Form::create([
            'name' => 'Cadastro de organização parceira',
            'slug' => 'partner-agency-intake',
            'intro_text' => 'Obrigado pelo interesse em se tornar parceiro do nosso armazém. Este formulário '
                .'coleta as informações necessárias para avaliar a solicitação de uma nova organização parceira. '
                .'Preencha da forma mais completa possível — onde indicado, uma estimativa é suficiente.',
            'status' => 'active',
            'access_mode' => 'both',
            'requires_approval' => true,
            'on_approval_action' => 'create_or_link_partner',
        ]);

        $order = 0;
        foreach (FormQuestionPreset::orderBy('order')->get() as $preset) {
            FormQuestion::create([
                'form_id' => $form->id,
                'order' => $order++,
                'label' => $preset->label,
                'help_text' => $preset->help_text,
                'type' => $preset->type,
                'options' => $preset->options,
                'required' => in_array($preset->key, ['org_name', 'address', 'phone', 'email'], true),
                'preset_key' => $preset->key,
                'target_field' => $preset->target_field,
            ]);
        }
    }

    public function down(): void
    {
        Form::where('slug', 'partner-agency-intake')->delete();
    }
};
