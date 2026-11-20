BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2026_08_14_120000_add_system_admin_menu_item.php
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

        // permission_key makes MenuController drop the tile entirely for
        // anyone without admin-system — hidden, not grayed out.
        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Administração do sistema',
            'link_url' => '/setup/system',
            'graphic_url' => '/img/settings-icon.webp',
            'order' => 60,
            'permission_key' => 'admin-system',
        ]);
    }

    public function down(): void
    {
        MenuItem::where('link_url', '/setup/system')->delete();
    }
};
