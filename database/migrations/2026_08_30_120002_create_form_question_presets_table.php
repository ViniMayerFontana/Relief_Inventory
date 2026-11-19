<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Seeded catalog backing the admin builder's "add a preset question"
 * checkbox picker (org intake's usual basics, plus a couple generic
 * catch-alls) — checking a box copies an editable FormQuestion onto the
 * form; it's a starting template, not a live binding.
 *
 * pt-BR (2026-11-19): o catálogo de presets migrou para
 * 2026_11_19_000001_seed_form_question_presets_pt_br.php (rótulos em
 * português; `key` técnicos preservados). O bloco EN legado está em
 * disabled_en/backup_en_form_question_presets.php.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('form_question_presets', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->string('label');
            // basic_info groups the org-intake basics together in the
            // picker UI; other is everything else. Purely a UI grouping.
            $table->string('category')->default('other');
            $table->string('type');
            $table->json('options')->nullable();
            $table->text('help_text')->nullable();
            $table->string('target_field')->nullable();
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('form_question_presets');
    }
};
