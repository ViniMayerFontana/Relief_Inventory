BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2026_08_22_000000_rename_active_sessions_menu_item.php
<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use App\Models\MenuItem;
use Illuminate\Database\Migrations\Migration;

return new class extends Migration
{
    public function up(): void
    {
        MenuItem::where('link_url', '/setup/active-sessions')->update([
            'link_text' => 'User Activity',
        ]);
    }

    public function down(): void
    {
        MenuItem::where('link_url', '/setup/active-sessions')->update([
            'link_text' => "Who's Logged In",
        ]);
    }
};
