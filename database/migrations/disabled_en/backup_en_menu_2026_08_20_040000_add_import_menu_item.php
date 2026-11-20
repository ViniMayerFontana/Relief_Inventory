BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2026_08_20_040000_add_import_menu_item.php
<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use App\Models\MenuItem;
use App\Models\Page;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        $setupMenu = Page::where('hashtag', 'setup')->first();

        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Importação de dados',
            'link_url' => '/setup/import',
            'graphic_url' => '/img/settings-icon.webp',
            'order' => 72,
            'permission_key' => 'manage-import',
        ]);
    }

    public function down(): void
    {
        MenuItem::where('link_url', '/setup/import')->delete();
    }
};
