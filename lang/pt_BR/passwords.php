<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Laravel password-broker status keys. The controllers pass the broker's
// status straight to __($status), so every status the broker can return
// needs a key here (pt-BR presentation strings).

return [
    'reset' => 'Sua senha foi redefinida.',
    'sent' => 'Enviamos por e-mail seu link de redefinição de senha.',
    'throttled' => 'Aguarde antes de tentar novamente.',
    'token' => 'Este token de redefinição de senha é inválido.',
    'user' => 'Não encontramos um usuário com esse endereço de e-mail.',
];
