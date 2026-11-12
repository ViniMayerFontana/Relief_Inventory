<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!--
	RestoreBackup.vue — the "restore from a backup" path of the first-run wizard (FirstRun.vue).

	Upload the backup .zip in resumable chunks (composables/chunkedUpload.js, same protocol as the firmware
	upload) — plus, optionally, a second zip that supplies only the uploaded files (for recovering a damaged
	database with the best copy of the files; any database inside that second zip is ignored) — then ask the
	server to start (RestoreService, a detached process) and poll its status file until it finishes. The status poll tolerates failures on purpose: while the database is being replaced
	the server can briefly answer with errors, and that is progress, not a problem. Server half: RestoreController.
-->

<script setup>
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { useChunkedUpload } from '@/composables/chunkedUpload';
import axios from 'axios';
import { computed, onMounted, onUnmounted, ref } from 'vue';

const props = defineProps({
	codeRequired: { type: Boolean, default: false },
	// Where the restore endpoints are: the first-run wizard's, or a warehouse awaiting its setup code's (Activate.vue).
	base: { type: String, default: '/install/restore' },
	// Fields sent with the launch (the person who will run a new warehouse: login, name, email, password).
	identity: { type: Object, default: null },
	// A signed-in administrator restoring their own warehouse (WarehouseRestore.vue): progress is read from a URL that still answers
	// while the warehouse is out of service, and the words differ.
	statusUrl: { type: String, default: null },
	own: { type: Boolean, default: false },
});
defineEmits(['back']);

const BASE = props.base;
const STATUS = props.statusUrl || `${BASE}/status`;
// Two uploads: `main` (has the database) and, optionally, `extra` (the files). `stage` is the one in progress.
const main = useChunkedUpload(BASE);
const extra = useChunkedUpload(BASE);
const stage = ref('main');
const current = computed(() => (stage.value === 'main' ? main : extra));
const task = computed(() => current.value.task);
const percent = computed(() => current.value.percent.value);

// idle -> uploading -> restoring -> complete | failed
const phase = ref('idle');
const setupCode = ref('');
const warehouseKey = ref('');
const file = ref(null);
const filesFile = ref(null);
const error = ref('');
const codeError = ref('');
const status = ref({});
let timer = null;

const human = (bytes) => (bytes > 1073741824 ? `${(bytes / 1073741824).toFixed(2)} GB` : `${(bytes / 1048576).toFixed(1)} MB`);

function pick(event) {
	file.value = event.target.files[0] || null;
	error.value = '';
}

function pickFiles(event) {
	filesFile.value = event.target.files[0] || null;
	error.value = '';
}

function failWith(e, fallback) {
	codeError.value = e.response?.data?.errors?.setup_code?.[0] || '';
	error.value = codeError.value ? '' : e.response?.data?.message || fallback;
}

async function begin() {
	error.value = '';
	codeError.value = '';
	if (!file.value) return;
	phase.value = 'uploading';
	stage.value = 'main';
	try {
		await main.start(file.value, { setup_code: setupCode.value || undefined });
		await uploadFilesThenLaunch();
	} catch (e) {
		if (!current.value.task.id) phase.value = 'idle'; // never started (wrong code, not a fresh instance, ...)
		failWith(e, 'The upload was interrupted. Choose Resume to carry on from where it stopped.');
	}
}

// After the main file is up: the optional files backup, then start the restore.
async function uploadFilesThenLaunch() {
	if (filesFile.value && !extra.task.id) {
		stage.value = 'files';
		await extra.start(filesFile.value, { setup_code: setupCode.value || undefined });
	}
	await axios.post(`${BASE}/launch`, { upload_id: main.task.id, storage_upload_id: extra.task.id || undefined, warehouse_key: warehouseKey.value.trim() || undefined, ...(props.identity || {}) });
	phase.value = 'restoring';
	poll();
}

async function resumeUpload() {
	error.value = '';
	try {
		if (stage.value === 'main') {
			await main.resume();
			await uploadFilesThenLaunch();
		} else {
			await extra.resume();
			await uploadFilesThenLaunch();
		}
	} catch (e) {
		failWith(e, 'The upload was interrupted again. Choose Resume to try once more.');
	}
}

async function cancelUpload() {
	await Promise.all([main.cancel(), extra.cancel()]);
	phase.value = 'idle';
	stage.value = 'main';
	error.value = '';
}

function poll() {
	clearInterval(timer);
	const tick = async () => {
		try {
			const { data } = await axios.get(STATUS);
			status.value = data;
			if (data.state === 'complete') phase.value = 'complete';
			else if (data.state === 'failed') phase.value = 'failed';
			else if (data.state === 'running') phase.value = 'restoring';
			else return;
			if (phase.value === 'complete' || phase.value === 'failed') clearInterval(timer);
		} catch {
			/* the database is being replaced; keep waiting */
		}
	};
	tick();
	timer = setInterval(tick, 2000);
}

function reset() {
	main.cancel();
	extra.cancel();
	phase.value = 'idle';
	stage.value = 'main';
	status.value = {};
	error.value = '';
	file.value = null;
	filesFile.value = null;
}

onMounted(async () => {
	// Page reloaded mid-restore (or the restore finished while away): pick up where the server is.
	try {
		const { data } = await axios.get(STATUS);
		if (data.state === 'running') {
			phase.value = 'restoring';
			poll();
		}
	} catch {
		/* nothing to resume */
	}
});
onUnmounted(() => clearInterval(timer));
</script>

<template>
	<div>
		<!-- choose a file -->
		<div v-if="phase === 'idle'" class="mt-3 space-y-4">
			<p v-if="own" class="text-sm text-gray-600">
				{{ $t('Pages.Setup.text.choose_a_backup_file', {}) }} <strong>{{ $t('Commons.heading.this_warehouse', {}) }}</strong>, made by <strong>{{ $t('Pages.Setup.text.updates_backups', {}) }}</strong>.
			</p>
			<p v-else class="text-sm text-gray-600">
				{{ $t('Pages.Setup.text.choose_a_backup_file_2', {}) }} <strong>{{ $t('Pages.Setup.text.updates_backups', {}) }}</strong> {{ $t('Pages.Setup.text.in_relief_inventory_the', {}) }}
			</p>

			<div v-if="codeRequired && !own">
				<InputLabel for="restore_code" value="Setup code" />
				<TextInput id="restore_code" type="password" class="mt-1 block w-full" v-model="setupCode" autocomplete="off" />
				<InputError class="mt-2" :message="codeError" />
			</div>

			<div>
				<InputLabel for="restore_file" value="Backup file" />
				<input id="restore_file" type="file" accept=".zip,application/zip" class="mt-1 block w-full text-sm" @change="pick" />
				<p v-if="file" class="mt-1 text-xs text-gray-500">{{ file.name }} — {{ human(file.size) }}</p>
			</div>

			<details class="rounded border border-gray-200 p-3 text-sm">
				<summary class="cursor-pointer text-gray-700">{{ $t('Pages.Setup.text.recovering_from_a_damaged', {}) }}</summary>
				<p class="mt-2 text-xs text-gray-600">
					{{ $t('Pages.Setup.text.if_the_backup_above', {}) }}
				</p>
				<input id="restore_files_file" type="file" accept=".zip,application/zip" class="mt-2 block w-full text-sm" @change="pickFiles" />
				<p v-if="filesFile" class="mt-1 text-xs text-gray-500">{{ filesFile.name }} — {{ human(filesFile.size) }}</p>
			</details>

			<details v-if="!own" class="rounded border border-gray-200 p-3 text-sm">
				<summary class="cursor-pointer text-gray-700">{{ $t('Pages.Setup.text.key_from_the_old', {}) }}</summary>
				<p class="mt-2 text-xs text-gray-600">
					{{ $t('Pages.Setup.text.a_backup_never_contains', {}) }}
				</p>
				<input id="restore_key" type="text" v-model="warehouseKey" autocomplete="off" spellcheck="false" placeholder="base64:…" class="mt-2 block w-full rounded-md border-gray-300 font-mono text-xs shadow-sm" />
			</details>

			<div v-if="own" class="rounded border border-amber-300 bg-amber-50 p-3 text-xs text-amber-900 space-y-1">
				<p>{{ $t('Commons.text.this', {}) }} <strong>{{ $t('Pages.Setup.text.replaces_everything_in_this', {}) }}</strong> {{ $t('Pages.Setup.text.its_data_and_its', {}) }}</p>
				<p>
					{{ $t('Pages.Setup.text.you_stay_administrator_everyone', {}) }} <em>invited</em> {{ $t('Pages.Setup.text.and_joins_only_when', {}) }}
				</p>
			</div>
			<div v-else class="rounded border border-amber-300 bg-amber-50 p-3 text-xs text-amber-900 space-y-1">
				<p>{{ $t('Pages.Setup.text.this_installation_must_be', {}) }}</p>
				<p>
					{{ $t('Pages.Setup.text.the_backup_does_not', {}) }}
				</p>
				<p>{{ $t('Pages.Setup.text.the_software_here_must', {}) }}</p>
			</div>

			<div v-if="error" class="rounded border border-red-300 bg-red-50 p-2 text-sm text-red-800">{{ error }}</div>

			<div class="flex items-center justify-between">
				<SecondaryButton type="button" @click="$emit('back')">{{ $t('Commons.button.back', {}) }}</SecondaryButton>
				<PrimaryButton type="button" :disabled="!file" @click="begin">{{ $t('Pages.Setup.button.upload_and_restore', {}) }}</PrimaryButton>
			</div>
		</div>

		<!-- uploading -->
		<div v-else-if="phase === 'uploading'" class="mt-3 space-y-3">
			<p class="text-sm text-gray-700">
				{{ $t('Commons.text.uploading_2') }} {{ task.file?.name }}…
				<span v-if="filesFile" class="text-gray-500">(file {{ stage === 'main' ? 1 : 2 }} of 2)</span>
			</p>
			<div class="h-3 w-full overflow-hidden rounded bg-gray-200"><div class="h-3 bg-blue-600" :style="{ width: percent + '%' }"></div></div>
			<p class="text-xs text-gray-500">{{ human(task.received) }} of {{ human(task.size) }} ({{ percent }}%). Keep this page open.</p>
			<div v-if="error" class="rounded border border-red-300 bg-red-50 p-2 text-sm text-red-800">{{ error }}</div>
			<div class="flex items-center gap-3">
				<PrimaryButton v-if="task.failed && !task.running && task.id" type="button" @click="resumeUpload">{{ $t('Commons.button.resume', {}) }}</PrimaryButton>
				<SecondaryButton type="button" @click="cancelUpload">{{ $t('Commons.button.cancel', {}) }}</SecondaryButton>
			</div>
		</div>

		<!-- the server is restoring -->
		<div v-else-if="phase === 'restoring'" class="mt-3 space-y-3">
			<p class="text-sm text-gray-700">{{ $t('Pages.Setup.text.restoring_this_can_take', {}) }}</p>
			<div class="h-3 w-full overflow-hidden rounded bg-gray-200"><div class="h-3 bg-blue-600" :style="{ width: (status.percent || 1) + '%' }"></div></div>
			<p class="text-xs text-gray-500">{{ status.phase || $t('Commons.text.starting_2') }}</p>
		</div>

		<!-- done -->
		<div v-else-if="phase === 'complete'" class="mt-3 space-y-3">
			<div class="rounded border border-green-300 bg-green-50 p-3 text-sm text-green-900">
				{{ $t('Pages.Setup.text.the_backup_was_restored', {}) }}<span v-if="status.backup_created_at"> (made {{ new Date(status.backup_created_at).toLocaleString() }})</span>.
			</div>
			<div v-if="status.blanked?.length" class="rounded border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
				<p class="font-medium">{{ $t('Pages.Setup.text.these_settings_were_encrypted', {}) }}</p>
				<ul class="mt-1 list-disc pl-5"><li v-for="label in status.blanked" :key="label">{{ label }}</li></ul>
			</div>
			<div v-if="status.notes?.length" class="rounded border border-gray-300 bg-gray-50 p-3 text-sm text-gray-700">
				<p v-for="note in status.notes" :key="note">{{ note }}</p>
			</div>
			<div v-if="!status.includes_uploads" class="text-xs text-gray-600">{{ $t('Pages.Setup.text.this_backup_did_not', {}) }}</div>
			<div v-else-if="status.files_created_at && status.files_created_at !== status.backup_created_at" class="text-xs text-gray-600">
				{{ $t('Pages.Setup.text.uploaded_files_are_from') }} {{ new Date(status.files_created_at).toLocaleString() }}.
			</div>
			<div v-if="status.admin_missing" class="rounded border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
				{{ $t('Pages.Setup.text.the_restored_data_has', {}) }}
				<a href="/install" class="block mt-2 underline">{{ $t('Pages.Setup.link.continue_to_setup', {}) }}</a>
			</div>
			<a v-else href="/login" class="inline-flex items-center rounded-md bg-gray-800 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white hover:bg-gray-700">{{ $t('Commons.link.sign_in', {}) }}</a>
		</div>

		<!-- failed -->
		<div v-else-if="phase === 'failed'" class="mt-3 space-y-3">
			<div class="rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800">
				<p class="font-medium">{{ $t('Pages.Setup.text.the_restore_did_not', {}) }}</p>
				<p class="mt-1">{{ status.error }}</p>
			</div>
			<PrimaryButton type="button" @click="reset">{{ $t('Commons.button.try_again', {}) }}</PrimaryButton>
		</div>
	</div>
</template>
