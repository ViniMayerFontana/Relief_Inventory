<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Presentation strings embedded in database-notification payloads
// (app/Notifications/*), translated at write time (APP_LOCALE strategy).
// The bell UI renders these values as-is; read-time translation via `kind`
// is a registered future improvement (task-5 follow-up).

return [
    'category_label_pin_login' => 'Solicitação de login por PIN',
    'category_label_new_volunteer' => 'Novo voluntário',
    'category_label_other' => 'Outro',
    'a_browser' => 'Um navegador',
    'on' => 'em',
    'an_unknown_system' => 'um sistema desconhecido',
    'someone' => 'alguém',
];
