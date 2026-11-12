<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

return [

    /*
    |--------------------------------------------------------------------------
    | Help guides
    |--------------------------------------------------------------------------
    | Titles of the in-app help guides (HelpReportController::GUIDES is the slug
    | registry) plus the shared strings of the printable PDF shells
    | (resources/views/reports/help/*.blade.php).
    */

    'guides' => [
        'receiving' => 'Receiving Guide',
        'donation-offers' => 'Donation Offers Guide',
        'sorting' => 'Donation Sorting Guide',
        'inventory-movement' => 'Inventory Movement Guide',
        'order-entry' => 'Order Entry Guide',
        'order-filling' => 'Order Filling Guide',
        'shipping' => 'Shipping Guide',
        'items' => 'Master Item List Guide',
        'people' => 'Partner & Donor Info Guide',
    ],

    'all_guides' => 'Help Guides',
    'contents' => 'Contents',
    'footer' => 'Questions or something not working the way this guide describes? Use Report an Issue from the profile menu in the app.',
];
