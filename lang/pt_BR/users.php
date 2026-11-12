<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// pt-BR mirror of lang/en/users.php: presentation labels for account status on
// the Users page (UserAdminController::statusLabels()). Translated at response
// time (APP_LOCALE strategy); the keys are the technical status values returned
// by status() and are never translated; only the values are.

return [
    'status_labels' => [
        'active' => 'Ativo',
        'must_change_password' => 'Ativo — deve trocar a senha',
        'invited' => 'Convidado — configuração pendente',
        'pending_approval' => 'Aprovação pendente',
        'unverified' => 'Pendente — e-mail não verificado',
        'deactivated' => 'Desativado',
    ],
];
