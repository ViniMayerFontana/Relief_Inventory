<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

// The Pi device fleet page was first labelled "Kiosk Devices", which collided
// with the volunteer sign-in kiosk. Relabel the menu item (link stays /setup/devices).
return new class extends Migration
{
    public function up(): void
    {
        DB::table('menu_items')->where('link_url', '/setup/devices')
            ->update(['link_text' => 'Dispositivos R Station']);
    }

    public function down(): void
    {
        DB::table('menu_items')->where('link_url', '/setup/devices')
            ->update(['link_text' => 'Dispositivos R Station']);
    }
};
