<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// pt-BR mirror of lang/en/updates.php: server-side strings of the update flow
// that reach the UI as JSON message fields (SystemController endpoints,
// InstanceUpdate::payload() — shown by InstanceAdmin.vue). Translated at
// response/write time (APP_LOCALE strategy, same approach as notifications.php);
// dynamic process output is passed as Laravel :placeholders. "updater" stays
// in English (I18N_GLOSSARY.md).

return [
    'not_available_docker' => 'Não disponível em uma instalação Docker: ela é atualizada pelo updater no host.',
    'could_not_reach_update_server' => 'Não foi possível contatar o servidor de atualização: :output',
    'already_running' => 'Já existe uma atualização em execução.',
    'requested_waiting_start' => 'Atualização solicitada; aguardando o updater iniciar',
    'only_instance_admin' => 'Apenas um administrador de instância pode verificar ou instalar atualizações.',
    'automatic_updates_not_set_up' => 'Atualizações automáticas não estão configuradas: defina RI_UPDATE_SECRET no compose.yaml e execute o updater no host (docker/updater/).',
    'already_in_progress' => 'Já há uma atualização em andamento.',
    'could_not_start_unit' => 'Não foi possível iniciar :unit — a regra do sudoers de scripts/systemd/reliefinventory-sudoers está instalada? :output',
    'started' => 'iniciado',
    'no_progress_stalled' => 'Sem progresso há mais de :minutes minutos (último status: ":last"). O mais provável é que a atualização nunca tenha começado — verifique SYSTEM_UPDATE_UNIT no .env e a regra do sudoers no servidor, depois tente novamente.',
    'updater_stopped_reporting' => 'O updater parou de reportar. Ele está em execução no host?',
];
