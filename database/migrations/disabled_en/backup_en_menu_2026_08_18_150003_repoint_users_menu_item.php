BACKUP EN integral (pré-tradução na fonte, 2026-11-19) de 2026_08_18_150003_repoint_users_menu_item.php
<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use App\Models\MenuItem;
use App\Models\Page;
use Illuminate\Database\Migrations\Migration;

/**
 * The original /setup/users menu item was deleted outright by
 * 2025_02_20_163441_delete_edit_users_menu_item.php (its up() deletes,
 * down() recreates — a forward-migrated install has no such row today,
 * despite a later migration's comment assuming one still existed). Create
 * it fresh if missing, otherwise just repoint an existing one — either
 * way it ends up pointed at the real User Administration page
 * (the User Administration build) instead of the ComingSoon placeholder.
 */
return new class extends Migration
{
    public function up(): void
    {
        $existing = MenuItem::where('link_url', '/setup/users')->first();

        if ($existing) {
            $existing->update([
                'link_text' => 'Administração de usuários',
                'permission_key' => 'manage-users',
            ]);

            return;
        }

        $setupMenu = Page::where('hashtag', 'setup')->first();

        MenuItem::create([
            'page_id' => $setupMenu->id,
            'link_text' => 'Administração de usuários',
            'link_url' => '/setup/users',
            'graphic_url' => '/img/edit-users-icon.webp',
            'order' => 50,
            'permission_key' => 'manage-users',
        ]);
    }

    public function down(): void
    {
        MenuItem::where('link_url', '/setup/users')->update([
            'link_text' => 'Editar usuários',
            'permission_key' => 'general-access',
        ]);
    }
};
