BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2026_08_14_014950_add_receiving_menu_item.php
<?php

use App\Models\MenuItem;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        MenuItem::create([
            'page_id' => 1,
            'link_text' => 'Recebimento',
            'link_url' => '/receiving',
            'graphic_url' => '/img/donation-entry-icon.webp',
            'order' => 25,
        ]);
    }

    public function down(): void
    {
        MenuItem::where([
            'page_id' => 1,
            'link_url' => '/receiving',
        ])->delete();
    }
};
