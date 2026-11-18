<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Support;

use Illuminate\Support\Str;

/**
 * Presentation-layer translation of menu text that is seeded in English into
 * the database (`menu_items.link_text`, `pages.menu_title`). The database is
 * the upstream-compatible source of truth (migrations update these strings by
 * `link_text`), so it is never edited; instead every place that DISPLAYS one
 * of these strings passes it through here, which looks the text up by its
 * slug in `lang/<locale>/menu.php` and falls back to the raw (English) text
 * when no translation exists. Adding a new menu item in a migration needs no
 * code change: untranslated tiles simply render as before until a key is
 * added to the locale files.
 */
class MenuText
{
    public static function translate(string $text): string
    {
        $key = 'menu.'.Str::slug($text);
        $translated = trans($key);

        return $translated === $key ? $text : $translated;
    }
}
