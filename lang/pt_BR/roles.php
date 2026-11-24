<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

/*
 * Display labels for RBAC role names (which stay English in the database —
 * they are matched by `name` in code and migrations). Looked up by slug via
 * RoleController; a role without a key here displays its raw (English) name.
 */

return [
    'partner' => 'Parceiro',
    'donor' => 'Doador',
    'volunteer' => 'Voluntário',
    'customer' => 'Cliente',
    'administrator' => 'Administrador',
    'office' => 'Escritório',
    'sorting-and-inventory' => 'Triagem e estoque',
    'team-leader' => 'Líder de equipe',
    'trainee' => 'Treinando',
];
