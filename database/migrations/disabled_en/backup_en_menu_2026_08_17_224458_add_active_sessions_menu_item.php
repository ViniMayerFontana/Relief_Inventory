BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2026_08_17_224458_add_active_sessions_menu_item.php
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
            'link_text' => 'Who\'s Logged In',
            'link_url' => '/setup/active-sessions',
            'graphic_url' => '/img/edit-users-icon.webp',
            'order' => 71,
            'permission_key' => 'admin-system',
        ]);
    }

    public function down(): void
    {
        MenuItem::where('link_url', '/setup/active-sessions')->delete();
    }
};
