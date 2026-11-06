<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- SystemAdmin.vue

	Warehouse Backups (/setup/system) — backups and keys for the current warehouse. (Software updates, offline mode and
	whole-instance backups are on Instance Admin, /setup/instance, InstanceAdmin.vue.) Each section is shown only when
	the person holds its permission:

	  manage-backups   Create a backup zip (database, or database + uploaded files), list / download / delete them, and this
	                   warehouse's snapshot schedule: hourly / daily / weekly / monthly tiers and how many of each to keep
	                   (BackupController::schedule / updateSchedule, BackupSchedule). The same page and schedule serve a Docker
	                   install (the scheduler container asks every hour) and a bare-metal one (its systemd timer runs
	                   scripts/update.sh --scheduled, which asks the same command).
	  admin-system     Rolling the warehouse back to a listed backup (password re-entry; progress shows here, polled from
	                   /w/<id>/restore-status).
	  view-app-key     Reveal the warehouse key (password re-entry).

	Server half: BackupController (zips, schedule, rollback, key).
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { currentWarehouseId } from '@/bootstrap';
import axios from 'axios';
import { computed, onMounted, onUnmounted, ref } from 'vue';

const props = defineProps({
	breadcrumb: { type: Array },
	canAdminSystem: { type: Boolean, default: false },
	canManageBackups: { type: Boolean, default: false },
	canViewAppKey: { type: Boolean, default: false },
});

const error = ref('');
const notice = ref('');

function fail(e, fallback) {
	error.value = e.response?.data?.errors
		? Object.values(e.response.data.errors).flat().join(' ')
		: e.response?.data?.message || fallback;
}

// ---- Backup zips (manage-backups) ----
const records = ref(null);
const keepDays = ref(14);
const scope = ref('database');
const starting = ref(false);
const confirmingDelete = ref(null);
let backupTimer = null;

const active = computed(() => (records.value || []).find((r) => r.status === 'queued' || r.status === 'running'));
const scopeNames = { database: 'somente banco de dados', full: 'banco de dados + arquivos', storage: 'somente arquivos' };

// quiet: the background poll. It keeps running during an update, when every request gets the
// maintenance-mode 503 (or a 502 while PHP restarts) — that's expected, not something to show.
async function loadBackups({ quiet = false } = {}) {
	try {
		const { data } = await axios.get('/json/backups');
		records.value = data.records;
		keepDays.value = data.keep_days;
		schedule.value = data.schedule;
		// The form is filled once (and again after a save); the 4-second poll must not overwrite what is being typed.
		if (!form.value) form.value = scheduleForm(data.schedule);
	} catch (e) {
		if (!quiet) fail(e, 'Não foi possível carregar a lista de backups.');
	}
}

// ---- Snapshot schedule (manage-backups; Docker, where the scheduler container asks every hour) ----
const schedule = ref(null);
const form = ref(null);
const savingSchedule = ref(false);
const scheduleSaved = ref(false);
const tierNames = { hourly: 'Por hora', daily: 'Diário', weekly: 'Semanal', monthly: 'Mensal' };
const weekdays = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];

const scheduleForm = (s) => ({
	hourly_enabled: !!s.hourly_enabled, hourly_keep: s.hourly_keep,
	daily_enabled: !!s.daily_enabled, daily_hour: s.daily_hour, daily_keep: s.daily_keep, daily_with_files: !!s.daily_with_files,
	weekly_enabled: !!s.weekly_enabled, weekly_dow: s.weekly_dow, weekly_keep: s.weekly_keep, weekly_with_files: !!s.weekly_with_files,
	monthly_enabled: !!s.monthly_enabled, monthly_keep: s.monthly_keep, monthly_with_files: !!s.monthly_with_files,
});

// An upper bound: every kept snapshot as big as the latest backup. One zip often serves several tiers, so real use is usually lower.
const estimatedBytes = computed(() => {
	if (!form.value || !schedule.value?.last_size_bytes) return null;
	const kept = Object.keys(tierNames).reduce((n, t) => n + (form.value[`${t}_enabled`] ? Number(form.value[`${t}_keep`]) || 0 : 0), 0);
	return kept * schedule.value.last_size_bytes;
});

async function saveSchedule() {
	error.value = '';
	notice.value = '';
	scheduleSaved.value = false;
	savingSchedule.value = true;
	try {
		const { data } = await axios.put('/json/backups/schedule', form.value);
		schedule.value = data;
		form.value = scheduleForm(data);
		scheduleSaved.value = true;
	} catch (e) {
		fail(e, 'Não foi possível salvar o agendamento.');
	} finally {
		savingSchedule.value = false;
	}
}

const tiersOf = (r) => (r.tiers ? r.tiers.split(',') : []);

// ---- Roll back to a listed backup (admin-system; the restore engine, so it asks for the password) ----
const rollbackTarget = ref(null);
const rollbackPassword = ref('');
const rollingBack = ref(false);

function askRollback(record) {
	error.value = '';
	rollbackPassword.value = '';
	rollbackTarget.value = rollbackTarget.value?.id === record.id ? null : record;
}

// The rollback replaces the database, and the sessions with it, so progress comes from the status page that needs no login
// (RestoreController::status), the same one the restore page polls. Failures while the database is swapped are expected: keep asking.
const rollback = ref(null);   // null, or the last status the server gave
let rollbackTimer = null;

async function confirmRollback() {
	error.value = '';
	rollingBack.value = true;
	try {
		await axios.post(`/json/backups/${rollbackTarget.value.id}/restore`, { password: rollbackPassword.value });
		rollbackTarget.value = null;
		rollback.value = { state: 'running', phase: 'Starting', percent: 1 };
		clearInterval(backupTimer);   // the list can't be read while the database is replaced
		pollRollback();
	} catch (e) {
		fail(e, 'Não foi possível iniciar a restauração.');
		rollingBack.value = false;
	} finally {
		rollbackPassword.value = '';
	}
}

function pollRollback() {
	const tick = async () => {
		try {
			const { data } = await axios.get(`/w/${currentWarehouseId() ?? ''}/restore-status`);
			if (data.state === 'running' || data.state === 'complete' || data.state === 'failed') rollback.value = data;
			if (data.state === 'complete' || data.state === 'failed') {
				clearInterval(rollbackTimer);
				rollingBack.value = false;
			}
		} catch {
			/* the database is being replaced; keep waiting */
		}
	};
	clearInterval(rollbackTimer);
	tick();
	rollbackTimer = setInterval(tick, 2000);
}

async function startBackup() {
	error.value = '';
	notice.value = '';
	starting.value = true;
	try {
		await axios.post('/json/backups', { scope: scope.value });
		notice.value = 'Backup iniciado. Você pode sair desta página; o processo continuará no servidor.';
		await loadBackups();
	} catch (e) {
		fail(e, 'Não foi possível iniciar o backup.');
	} finally {
		starting.value = false;
	}
}

async function deleteBackup(record) {
	error.value = '';
	notice.value = '';
	if (confirmingDelete.value !== record.id) {
		confirmingDelete.value = record.id;
		return;
	}
	confirmingDelete.value = null;
	try {
		await axios.delete(`/json/backups/${record.id}`);
		await loadBackups();
	} catch (e) {
		fail(e, 'Não foi possível excluir esse backup.');
	}
}

function formatSize(bytes) {
	if (bytes == null) return '';
	if (bytes > 1073741824) return `${(bytes / 1073741824).toFixed(2)} GB`;
	return bytes > 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.ceil(bytes / 1024)} KB`;
}

const when = (iso) =>(iso ? new Date(iso).toLocaleString() : '');

// ---- Application key (view-app-key) ----
const keyPassword = ref('');
const revealedKey = ref('');
const revealing = ref(false);
const copied = ref(false);

async function revealKey() {
	error.value = '';
	notice.value = '';
	revealing.value = true;
	try {
		const { data } = await axios.post('/json/backups/app-key', { password: keyPassword.value });
		revealedKey.value = data.key;
	} catch (e) {
		fail(e, 'Não foi possível exibir a chave.');
	} finally {
		keyPassword.value = '';
		revealing.value = false;
	}
}

function hideKey() {
	revealedKey.value = '';
	copied.value = false;
}

async function copyKey() {
	try {
		await navigator.clipboard.writeText(revealedKey.value);
		copied.value = true;
	} catch {
		copied.value = false;
	}
}

onMounted(async () => {
	if (props.canManageBackups) {
		await loadBackups();
		// Poll while a backup runs (and keep polling so a second admin's backup shows up).
		// Quiet: an update elsewhere puts the site in maintenance mode, and its 503s aren't worth showing.
		backupTimer = setInterval(() => {
			loadBackups({ quiet: true });
		}, 4000);
	}
});
onUnmounted(() => {
	clearInterval(backupTimer);
	clearInterval(rollbackTimer);
	hideKey();
});
</script>

<template>
	<Head title="Backups do armazém" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Backups do armazém</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<!-- A rollback in progress (everyone is signed out while the data is swapped) -->
			<section v-if="rollback" class="rounded-lg border-2 p-5 space-y-2 text-sm"
				:class="rollback.state === 'failed' ? 'border-red-400 bg-red-50 text-red-900' : rollback.state === 'complete' ? 'border-green-500 bg-green-50 text-green-900' : 'border-blue-400 bg-blue-50 text-blue-900'">
				<h2 class="text-base font-bold">
					{{ rollback.state === 'failed' ? 'A restauração não foi concluída' : rollback.state === 'complete' ? 'Restauração concluída' : 'Restaurando este armazém…' }}
				</h2>
				<p v-if="rollback.state === 'running'">
					{{ rollback.phase || 'Processando…' }} <span v-if="rollback.percent">({{ rollback.percent }}%)</span> —
					mantenha esta página aberta. Todos serão desconectados enquanto os dados são substituídos.
				</p>
				<p v-else-if="rollback.state === 'failed'">{{ rollback.error }}</p>
				<p v-else>
					Os dados foram restaurados para {{ rollback.backup_created_at ? when(rollback.backup_created_at) : 'aquele backup' }}.
					<a href="/login" class="underline font-semibold">Entre novamente</a>. Uma cópia dos dados anteriores à restauração é mantida na pasta de
					backups deste armazém (com o nome “before-rollback”) por {{ keepDays }} dias.
				</p>
			</section>

			<!-- The key is not in any backup: say so, loudly, wherever backups are made or listed -->
			<section v-if="canAdminSystem || canManageBackups" class="rounded-lg border-2 border-red-400 bg-red-50 p-5 space-y-2 text-sm text-red-900">
				<h2 class="text-base font-bold">Anote a chave deste armazém — os backups não a contêm</h2>
				<p>
					Para sua proteção, nenhum backup contém a chave do armazém. <strong>Você PRECISA guardar uma cópia em um local seguro,
					separado dos seus backups</strong> (em um gerenciador de senhas ou envelope lacrado): ela é necessária para restaurar as partes
					criptografadas de um backup — por exemplo, o segredo compartilhado para comentários centralizados. Sem a chave, esses valores não podem ser
					recuperados e precisam ser inseridos novamente; com ela, a restauração é completa.
				</p>
				<p v-if="canViewAppKey">
					<a href="#application-key" class="font-semibold underline">Exibir a chave do armazém (no fim desta página)</a>
					e anote-a agora — e novamente se ela for alterada.
				</p>
				<p v-else>Um administrador com permissão para exibir a chave do armazém precisa anotá-la. Peça que isso seja feito se não tiver certeza.</p>
			</section>

			<!-- Create a backup -->
			<section v-if="canManageBackups" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Criar backup</h2>
				<p class="text-sm text-gray-700">
					Um backup é um único arquivo .zip. Ele pode ser usado para configurar uma nova cópia vazia deste sistema. Apenas um backup
					pode ser executado por vez, e um backup grande pode demorar bastante.
				</p>
				<fieldset class="space-y-2 text-sm" :disabled="!!active">
					<label class="flex items-start gap-2">
						<input type="radio" value="database" v-model="scope" class="mt-1 border-gray-300" />
						<span>
							<span class="text-gray-800">Somente banco de dados</span>
							<span class="block text-xs text-gray-500">Tudo o que foi inserido no sistema. Pequeno e rápido.</span>
						</span>
					</label>
					<label class="flex items-start gap-2">
						<input type="radio" value="full" v-model="scope" class="mt-1 border-gray-300" />
						<span>
							<span class="text-gray-800">Banco de dados + arquivos enviados</span>
							<span class="block text-xs text-gray-500">Inclui também todos os arquivos enviados (fotos de recebimento, capturas de tela e importações) — maior e mais lento.</span>
						</span>
					</label>
				</fieldset>
				<div class="flex items-center gap-4">
					<PrimaryButton @click="startBackup" :disabled="starting || !!active">
						{{ starting ? 'Iniciando…' : active ? 'Backup em andamento…' : 'Fazer backup agora' }}
					</PrimaryButton>
				</div>
				<div v-if="active" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
					{{ active.status === 'queued' ? 'Iniciando…' : active.progress || 'Processando…' }}
					<span class="text-xs text-blue-700">(iniciado em {{ when(active.started_at || active.created_at) }})</span>
				</div>
				<p class="text-xs text-gray-500">
					Os backups feitos aqui são excluídos automaticamente {{ keepDays }} dias após sua criação, ou antes se você os excluir abaixo.
					Um backup <strong>nunca</strong> contém a chave do armazém — veja o painel no fim desta página.
				</p>
			</section>

			<!-- Backup zips -->
			<section v-if="canManageBackups" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Backups</h2>
				<p v-if="records === null" class="text-gray-500">Carregando…</p>
				<p v-else-if="!records.length" class="text-gray-400">nenhum ainda</p>
				<div v-else class="space-y-3">
					<div v-for="r in records" :key="r.id" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-3">
						<div class="space-y-1">
							<div class="font-mono text-xs text-gray-600">{{ r.filename || `backup #${r.id}` }}</div>
							<div v-if="tiersOf(r).length" class="flex gap-1">
								<span v-for="t in tiersOf(r)" :key="t" class="rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-700">{{ tierNames[t] || t }}</span>
							</div>
							<div>
								{{ when(r.finished_at || r.created_at) }}
								<span v-if="r.status === 'complete'" class="text-gray-600">
									— {{ formatSize(r.size_bytes) }}, {{ scopeNames[r.scope] || r.scope }}
								</span>
								<span v-else-if="r.status === 'failed'" class="text-red-700">— falhou: {{ r.error }}</span>
								<span v-else class="text-blue-700">— {{ r.progress || r.status }}</span>
							</div>
							<div v-if="r.expires_at" class="text-xs text-gray-500">Exclusão automática em {{ when(r.expires_at) }}</div>
							<div v-else-if="tiersOf(r).length" class="text-xs text-gray-500">Mantido pelo agendamento de snapshots abaixo, até ser substituído por backups mais recentes</div>
						</div>
						<div class="flex items-center gap-3">
							<a v-if="r.status === 'complete'" :href="$withWarehouse(`/json/backups/${r.id}/download`)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-800 hover:bg-gray-700">Baixar</a>
							<button v-if="canAdminSystem && r.status === 'complete' && r.scope !== 'storage' && !rollback" @click="askRollback(r)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-blue-700 hover:bg-blue-600">
								{{ rollbackTarget?.id === r.id ? 'Cancelar' : 'Restaurar para este ponto' }}
								</button>
							<button v-if="r.status !== 'queued' && r.status !== 'running'" @click="deleteBackup(r)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
								:class="confirmingDelete === r.id ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'">
								{{ confirmingDelete === r.id ? 'Confirmar — excluir este backup' : 'Excluir' }}
							</button>
							<button v-if="confirmingDelete === r.id" @click="confirmingDelete = null" class="text-xs underline text-gray-600">Cancelar</button>
						</div>
						<!-- Roll back: says what is lost, then asks for the password -->
						<div v-if="rollbackTarget?.id === r.id" class="basis-full rounded border border-blue-300 bg-blue-50 p-3 space-y-2 text-sm text-blue-900">
							<p>
								<strong>Tudo o que foi inserido após {{ when(r.finished_at || r.created_at) }} será perdido</strong> — recebimentos, separações, pedidos,
								pessoas e alterações de todos os tipos{{ r.scope === 'full' ? ', e os arquivos enviados voltarão ao estado daquela data' : '; os arquivos enviados permanecerão como estão' }}.
								Todos serão desconectados durante o processo. Primeiro, uma cópia dos dados atuais será salva na pasta de backups deste armazém,
								para que um administrador no servidor possa desfazer uma restauração feita por engano.
							</p>
							<form @submit.prevent="confirmRollback" class="flex flex-wrap items-center gap-3">
								<input type="password" v-model="rollbackPassword" autocomplete="current-password" placeholder="Sua senha"
									class="rounded-md border-gray-300 text-sm" />
								<button type="submit" :disabled="rollingBack || !rollbackPassword"
									class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500 disabled:opacity-50">
									{{ rollingBack ? 'Iniciando…' : 'Restaurar agora' }}
								</button>
							</form>
						</div>
					</div>
				</div>
				<p class="text-xs text-gray-500">
					Trate um backup baixado como os próprios dados: ele contém as informações de todas as pessoas. Guarde-o em um local privado.
					Para restaurá-lo neste <strong>armazém</strong>, um administrador pode usar
					<a href="/setup/restore" class="underline">Restaurar este armazém a partir de um backup</a>; em uma nova instalação, escolha “Restaurar de um backup”
					na tela de configuração. Para reparar um banco de dados danificado neste sistema, um administrador no servidor executa
					<span class="font-mono">php artisan backup:restore</span> com o backup válido mais recente e, se desejar, um backup separado dos arquivos.
				</p>
			</section>

			<!-- Snapshot schedule: the scheduler (Docker) or the systemd timer (bare metal) asks this warehouse every hour -->
			<section v-if="canManageBackups && form" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Agendamento de snapshots</h2>
				<p class="text-sm text-gray-700">
					Snapshots são backups comuns feitos automaticamente, para que este armazém possa ser restaurado ao estado de uma hora, um dia ou uma semana atrás
					(“Restaurar para este ponto” na lista acima). Um backup pode atender a vários períodos ao mesmo tempo, e os mais recentes de cada período são mantidos.
					<strong>Eles ficam nesta mesma máquina</strong>, então protegem contra erros, mas não contra a perda da máquina: copie os backups para outro local também
					(o RI Launcher pode fazer isso).
				</p>
				<p v-if="!schedule.scheduler_enabled" class="rounded bg-amber-100 border border-amber-400 text-amber-900 px-3 py-2 text-sm">
					Os backups agendados estão desativados para toda esta instalação (<span class="font-mono">RI_BACKUP_ENABLED=false</span> nas configurações), então nada abaixo será executado.
				</p>
				<form @submit.prevent="saveSchedule" class="space-y-3 text-sm">
					<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2">
						<label class="flex items-center gap-2 w-28 font-medium"><input type="checkbox" v-model="form.hourly_enabled" class="rounded border-gray-300" /> A cada hora</label>
						<label class="flex items-center gap-2">Manter os <input type="number" min="1" max="168" v-model.number="form.hourly_keep" class="w-20 rounded-md border-gray-300 text-sm" /> mais recentes</label>
						<span class="text-xs text-gray-500">Somente banco de dados.</span>
					</div>
					<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2">
						<label class="flex items-center gap-2 w-28 font-medium"><input type="checkbox" v-model="form.daily_enabled" class="rounded border-gray-300" /> Diário</label>
						<label class="flex items-center gap-2">Após <select v-model.number="form.daily_hour" class="rounded-md border-gray-300 text-sm"><option v-for="h in 24" :key="h" :value="h - 1">{{ String(h - 1).padStart(2, '0') }}:00</option></select> ({{ schedule.timezone }})</label>
						<label class="flex items-center gap-2">Manter os <input type="number" min="1" max="90" v-model.number="form.daily_keep" class="w-20 rounded-md border-gray-300 text-sm" /> mais recentes</label>
						<label class="flex items-center gap-2"><input type="checkbox" v-model="form.daily_with_files" class="rounded border-gray-300" /> incluir arquivos enviados</label>
					</div>
					<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2">
						<label class="flex items-center gap-2 w-28 font-medium"><input type="checkbox" v-model="form.weekly_enabled" class="rounded border-gray-300" /> Semanal</label>
						<label class="flex items-center gap-2">Às <select v-model.number="form.weekly_dow" class="rounded-md border-gray-300 text-sm"><option v-for="(d, i) in weekdays" :key="d" :value="i">{{ d }}</option></select></label>
						<label class="flex items-center gap-2">Manter os <input type="number" min="1" max="52" v-model.number="form.weekly_keep" class="w-20 rounded-md border-gray-300 text-sm" /> mais recentes</label>
						<label class="flex items-center gap-2"><input type="checkbox" v-model="form.weekly_with_files" class="rounded border-gray-300" /> incluir arquivos enviados</label>
					</div>
					<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2">
						<label class="flex items-center gap-2 w-28 font-medium"><input type="checkbox" v-model="form.monthly_enabled" class="rounded border-gray-300" /> Mensal</label>
						<span class="text-gray-600">Na primeira verificação do mês, após o horário diário.</span>
						<label class="flex items-center gap-2">Manter os <input type="number" min="1" max="36" v-model.number="form.monthly_keep" class="w-20 rounded-md border-gray-300 text-sm" /> mais recentes</label>
						<label class="flex items-center gap-2"><input type="checkbox" v-model="form.monthly_with_files" class="rounded border-gray-300" /> incluir arquivos enviados</label>
					</div>
					<div class="flex flex-wrap items-center gap-4">
						<PrimaryButton type="submit" :disabled="savingSchedule">{{ savingSchedule ? 'Salvando…' : 'Salvar agendamento' }}</PrimaryButton>
						<span v-if="scheduleSaved" class="text-green-700">Salvo.</span>
						<span v-if="schedule.last_run_at" class="text-xs text-gray-500">
							Último backup agendado: {{ when(schedule.last_run_at) }} — {{ schedule.last_status === 'complete' ? 'feito' : 'FALHOU' }}
						</span>
					</div>
				</form>
				<ul class="text-xs text-gray-500 space-y-1 list-disc pl-5">
					<li v-if="estimatedBytes">
						O uso de disco será de, no máximo, cerca de <strong>{{ formatSize(estimatedBytes) }}</strong> se cada snapshot mantido tiver o tamanho do backup mais recente
						({{ formatSize(schedule.last_size_bytes) }}); geralmente será menor, pois um backup costuma atender a vários períodos. Backups com arquivos são maiores.
					</li>
					<li>Desativar um período interrompe a criação de novos snapshots; os já feitos permanecem até serem substituídos por outros mais recentes do mesmo período ou até você excluí-los.</li>
					<li>
						Antes de uma atualização que altere o banco de dados, é feito automaticamente um backup de toda a instalação (configurado no arquivo compose). Os backups manuais
						acima são excluídos após {{ keepDays }} dias.
					</li>
				</ul>
			</section>

			<!-- Application key -->
			<section v-if="canViewAppKey" id="application-key" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Chave do armazém</h2>
				<div class="rounded bg-amber-50 border border-amber-300 text-amber-900 px-4 py-3 text-sm space-y-2">
					<p>
						Esta é a chave exclusiva deste armazém. Ela criptografa alguns valores secretos armazenados no banco de dados (por exemplo, a senha de e-mail
						e a chave de federação usada por unidades e dispositivos vinculados para identificá-lo). <strong>Os backups não a contêm intencionalmente</strong>,
						para que um arquivo de backup roubado não possa descriptografar nada.
					</p>
					<p>
						<strong>Anote esta chave agora e guarde-a em um local seguro, separado dos seus backups</strong> (em um gerenciador de senhas ou
						envelope lacrado). Ela é necessária para restaurar as partes criptografadas de um backup: restaurar em um novo sistema sem ela faz com que
						esses valores criptografados sejam perdidos (a restauração os apaga e você precisa inseri-los novamente). Para restaurar tudo em um novo sistema, cole esta chave
						em “Chave do sistema antigo” ao escolher o backup (na etapa de restauração da tela de configuração); um administrador da instância
						que restaura uma instância inteira pode, em vez disso, mantê-la junto ao backup (<span class="font-mono">instance:backup --with-keys</span>).
					</p>
				</div>

				<div v-if="!revealedKey" class="space-y-2">
					<label class="block text-sm max-w-sm">
						<span class="text-gray-700">Confirme sua senha para exibir a chave</span>
						<input type="password" v-model="keyPassword" autocomplete="current-password" @keyup.enter="revealKey"
							class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<PrimaryButton @click="revealKey" :disabled="revealing || !keyPassword">{{ revealing ? 'Verificando…' : 'Exibir chave' }}</PrimaryButton>
				</div>
				<div v-else class="space-y-2">
					<div class="font-mono text-sm break-all border rounded p-3 bg-gray-50 select-all">{{ revealedKey }}</div>
					<div class="flex items-center gap-4">
						<PrimaryButton @click="copyKey">{{ copied ? 'Copiado' : 'Copiar' }}</PrimaryButton>
						<button @click="hideKey" class="text-sm underline text-gray-600">Ocultar</button>
					</div>
				</div>
				<p class="text-xs text-gray-500">
					A exibição da chave é registrada. Ela será ocultada novamente quando você sair desta página. Qualquer pessoa com esta chave e um arquivo de backup
					poderá ler todos os dados nele contidos.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
