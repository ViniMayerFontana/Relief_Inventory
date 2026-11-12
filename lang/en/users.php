<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Presentation labels for account status on the Users page
// (UserAdminController::statusLabels()). The keys are the technical status
// values returned by status() and are never translated; only the values are.

return [
    'status_labels' => [
        'active' => 'Active',
        'must_change_password' => 'Active — must change password',
        'invited' => 'Invited — pending setup',
        'pending_approval' => 'Pending approval',
        'unverified' => 'Pending — email not verified',
        'deactivated' => 'Deactivated',
    ],
];
