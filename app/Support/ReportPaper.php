<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Support;

/**
 * Paper size for full-page PDF reports, driven by the instance locale
 * (spatie/laravel-pdf renders via WeasyPrint; @page size comes from each
 * report blade). A4 for pt-BR installs, US Letter otherwise.
 *
 * Deliberately NOT used by fixed-geometry print artifacts: Avery label grids
 * (mailing_labels) and exact-size outputs with zero margins (signs, pallet and
 * inventory labels) inherit Letter geometry, and changing their page size is a
 * redesign, not a translation (see FIRST_RUN.md "Interface language").
 */
class ReportPaper
{
    /** Page size keyword for @page CSS: 'A4' or 'letter'. */
    public static function size(): string
    {
        return app()->getLocale() === 'pt_BR' ? 'A4' : 'letter';
    }
}
