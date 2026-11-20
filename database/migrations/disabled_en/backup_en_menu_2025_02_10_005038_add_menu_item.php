BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2025_02_10_005038_add_menu_item.php
<?php

use App\Models\MenuItem;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        MenuItem::create([
            'page_id' => 3,
            'link_text' => 'Editar nomes de localizações',
            'link_url' => '/setup/locations',
            'graphic_url' => '/img/edit-statuses-icon.webp',
            'order' => 33,
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        MenuItem::where([
            'page_id' => 3,
            'link_url' => '/setup/locations',
        ])->delete();
    }
};
