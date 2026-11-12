<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Server-side strings of the update flow that reach the UI as JSON message
// fields (SystemController endpoints, InstanceUpdate::payload() — shown by
// InstanceAdmin.vue). Translated at response/write time (APP_LOCALE strategy,
// same approach as notifications.php); dynamic process output is passed as
// Laravel :placeholders. "updater" stays in English (I18N_GLOSSARY.md).

return [
    'not_available_docker' => 'Not available in a Docker install: it is upgraded by the host-side updater.',
    'could_not_reach_update_server' => 'Could not reach the update server: :output',
    'already_running' => 'An update is already running.',
    'requested_waiting_start' => 'Update requested; waiting for the updater to start',
    'only_instance_admin' => 'Only an instance administrator can check for or install updates.',
    'automatic_updates_not_set_up' => 'Automatic updates are not set up: set RI_UPDATE_SECRET in compose.yaml and run the updater on the host (docker/updater/).',
    'already_in_progress' => 'An update is already in progress.',
    'could_not_start_unit' => 'Could not start :unit — is the sudoers rule from scripts/systemd/reliefinventory-sudoers installed? :output',
    'started' => 'started',
    'no_progress_stalled' => 'No progress in over :minutes minutes (last status: ":last"). The update most likely never started — check SYSTEM_UPDATE_UNIT in .env and the sudoers rule on the server, then try again.',
    'updater_stopped_reporting' => 'The updater stopped reporting. Is it running on the host?',
];
