<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Http\Controllers;

use App\Support\HelpGuide;
use App\Support\ReportPaper;
use Spatie\LaravelPdf\Facades\Pdf;
use Spatie\LaravelPdf\PdfBuilder;

/**
 * Printable PDFs of the in-app Help guides. A guide's text is one Markdown file,
 * resources/help/en/<slug>.md (App\Support\HelpGuide); the screen page (Pages/Help/Guide.vue) and the PDF
 * (reports/help/guide.blade.php) both render it, so there is only one copy to edit.
 *
 * Adding a guide: add it to GUIDES, write resources/help/en/<slug>.md, then link it from its page with
 * <HelpLink guide="<slug>"> — the page, route, print-queue registry entry, Print button and its line on
 * the /help list (with "Print all guides") all follow from GUIDES.
 */
class HelpReportController extends Controller
{
    /** slug => PDF title. The slug is also the Markdown file name and the URL segment. */
    public const GUIDES = [
        'receiving' => 'Receiving Guide',
        'donation-offers' => 'Donation Offers Guide',
        'sorting' => 'Donation Sorting Guide',
        'inventory-movement' => 'Inventory Movement Guide',
        'order-entry' => 'Order Entry Guide',
        'order-filling' => 'Order Filling Guide',
        'shipping' => 'Shipping Guide',
        'items' => 'Master Item List Guide',
        'people' => 'Partner & Donor Info Guide',
    ];

    /** Translated title for a guide slug (lang/{en,pt_BR}/help.php; GUIDES stays the slug registry). */
    public static function title(string $guide): string
    {
        return __('help.guides.'.$guide);
    }

    public function show(string $guide)
    {
        return $this->builder($guide);
    }

    /** Unrendered PDF — shared by the download route and the print queue. */
    public function builder(string $guide): PdfBuilder
    {
        abort_unless(array_key_exists($guide, self::GUIDES), 404);

        return Pdf::view('reports.help.guide', ['title' => self::title($guide), 'guide' => HelpGuide::load($guide)])
            ->driver('weasyprint')
            ->format(ReportPaper::size())
            ->name($guide.'-guide.pdf');
    }

    public function showAll()
    {
        return $this->allBuilder();
    }

    /**
     * Every guide in one PDF, each starting on a new page, in GUIDES order. Each guide's own
     * view is rendered on its own first (renderSections) so its title/content sections can't
     * collide with the combined view's.
     */
    public function allBuilder(): PdfBuilder
    {
        $guides = [];
        foreach (array_keys(self::GUIDES) as $slug) {
            $guides[] = [
                'title' => self::title($slug),
                'content' => view('reports.help.guide', ['title' => self::title($slug), 'guide' => HelpGuide::load($slug)])
                    ->renderSections()['content'],
            ];
        }

        return Pdf::view('reports.help.all', ['guides' => $guides])
            ->driver('weasyprint')
            ->format(ReportPaper::size())
            ->name('help-guides.pdf');
    }
}
