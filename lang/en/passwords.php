<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Laravel password-broker status keys. The controllers pass the broker's
// status straight to __($status), so every status the broker can return
// needs a key here (English is the source/fallback locale).

return [
    'reset' => 'Your password has been reset.',
    'sent' => 'We have emailed your password reset link.',
    'throttled' => 'Please wait before retrying.',
    'token' => 'This password reset token is invalid.',
    'user' => "We can't find a user with that email address.",
];
