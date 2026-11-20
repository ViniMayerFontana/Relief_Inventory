<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

use App\Models\MenuItem;
use Illuminate\Database\Migrations\Migration;

/**
 * "Volunteer Kiosk" undersold what the tile actually opens — it's the shared
 * sign-in terminal for volunteers, guests, and drivers alike, not a
 * volunteers-only screen. Relabel only; link_url/permission_key untouched.
 */
return new class extends Migration
{
    public function up(): void
    {
        MenuItem::where('link_url', '/volunteers/kiosk?enable=1')
            ->where('link_text', 'Quiosque de voluntários')
            ->update(['link_text' => 'Quiosque de acesso']);
    }

    public function down(): void
    {
        MenuItem::where('link_url', '/volunteers/kiosk?enable=1')
            ->where('link_text', 'Quiosque de acesso')
            ->update(['link_text' => 'Quiosque de voluntários']);
    }
};
