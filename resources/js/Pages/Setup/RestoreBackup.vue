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
		failWith(e, 'O envio foi interrompido. Selecione Retomar para continuar de onde parou.');
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
		failWith(e, 'O envio foi interrompido novamente. Selecione Retomar para tentar mais uma vez.');
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
				Selecione um arquivo de backup (.zip) deste <strong>armazém</strong>, criado em <strong>Atualizações e backups</strong>.
			</p>
			<p v-else class="text-sm text-gray-600">
				Selecione um arquivo de backup (.zip) criado em <strong>Atualizações e backups</strong> no Relief Inventory. O sistema inteiro — dados
				e, se incluídos no backup, fotos e documentos enviados — será restaurado nesta nova instalação.
			</p>

			<div v-if="codeRequired && !own">
				<InputLabel for="restore_code" value="Código de configuração" />
				<TextInput id="restore_code" type="password" class="mt-1 block w-full" v-model="setupCode" autocomplete="off" />
				<InputError class="mt-2" :message="codeError" />
			</div>

			<div>
				<InputLabel for="restore_file" value="Arquivo de backup" />
				<input id="restore_file" type="file" accept=".zip,application/zip" class="mt-1 block w-full text-sm" @change="pick" />
				<p v-if="file" class="mt-1 text-xs text-gray-500">{{ file.name }} — {{ human(file.size) }}</p>
			</div>

			<details class="rounded border border-gray-200 p-3 text-sm">
				<summary class="cursor-pointer text-gray-700">Recuperando um banco de dados danificado? Adicione um backup separado dos arquivos</summary>
				<p class="mt-2 text-xs text-gray-600">
					Se o backup acima contiver somente o banco de dados ou se você tiver uma cópia mais recente ou completa dos arquivos enviados
					(um backup “somente arquivos” ou “banco de dados + arquivos”), selecione-o aqui. Os arquivos enviados virão deste backup; se ele também
					contiver um banco de dados, essa parte será ignorada.
				</p>
				<input id="restore_files_file" type="file" accept=".zip,application/zip" class="mt-2 block w-full text-sm" @change="pickFiles" />
				<p v-if="filesFile" class="mt-1 text-xs text-gray-500">{{ filesFile.name }} — {{ human(filesFile.size) }}</p>
			</details>

			<details v-if="!own" class="rounded border border-gray-200 p-3 text-sm">
				<summary class="cursor-pointer text-gray-700">Chave do sistema antigo (para manter as configurações criptografadas)</summary>
				<p class="mt-2 text-xs text-gray-600">
					O backup nunca contém a chave do armazém. Se você a anotou (Atualizações e backups &gt; “Chave do armazém” no sistema antigo),
					cole-a aqui para também restaurar as configurações que ela criptografou — senha de e-mail e segredos compartilhados. Sem ela, essas configurações serão apagadas
					e listadas depois para que você possa informá-las novamente.
				</p>
				<input id="restore_key" type="text" v-model="warehouseKey" autocomplete="off" spellcheck="false" placeholder="base64:…" class="mt-2 block w-full rounded-md border-gray-300 font-mono text-xs shadow-sm" />
			</details>

			<div v-if="own" class="rounded border border-amber-300 bg-amber-50 p-3 text-xs text-amber-900 space-y-1">
				<p>Esta operação <strong>substitui tudo neste armazém</strong> (dados e arquivos enviados) pelo conteúdo do backup. O armazém ficará indisponível durante a operação e todos sairão do sistema.</p>
				<p>
					Você continuará como administrador. As demais pessoas do backup que já têm uma conta em outro lugar serão <em>convidadas</em> e só entrarão quando aceitarem;
					a página Usuários permite enviar esses convites. Algumas configurações criptografadas não podem ser mantidas e serão listadas depois.
				</p>
			</div>
			<div v-else class="rounded border border-amber-300 bg-amber-50 p-3 text-xs text-amber-900 space-y-1">
				<p>Esta instalação deve ser nova e vazia — um backup só pode ser restaurado em uma instalação que nunca foi configurada.</p>
				<p>
					O backup não contém a chave do armazém. Tudo funciona sem ela, mas algumas configurações criptografadas (por
					exemplo, o segredo compartilhado do feedback centralizado) não podem ser mantidas sem a chave antiga acima; elas serão apagadas
					e listadas depois para que você possa informá-las novamente, e todos precisarão entrar no sistema outra vez.
				</p>
				<p>O software instalado deve ser da mesma versão que criou o backup ou de uma versão mais recente — nunca mais antiga.</p>
			</div>

			<div v-if="error" class="rounded border border-red-300 bg-red-50 p-2 text-sm text-red-800">{{ error }}</div>

			<div class="flex items-center justify-between">
				<SecondaryButton type="button" @click="$emit('back')">Voltar</SecondaryButton>
				<PrimaryButton type="button" :disabled="!file" @click="begin">Enviar e restaurar</PrimaryButton>
			</div>
		</div>

		<!-- uploading -->
		<div v-else-if="phase === 'uploading'" class="mt-3 space-y-3">
			<p class="text-sm text-gray-700">
				Enviando {{ task.file?.name }}…
				<span v-if="filesFile" class="text-gray-500">(arquivo {{ stage === 'main' ? 1 : 2 }} de 2)</span>
			</p>
			<div class="h-3 w-full overflow-hidden rounded bg-gray-200"><div class="h-3 bg-blue-600" :style="{ width: percent + '%' }"></div></div>
			<p class="text-xs text-gray-500">{{ human(task.received) }} de {{ human(task.size) }} ({{ percent }}%). Mantenha esta página aberta.</p>
			<div v-if="error" class="rounded border border-red-300 bg-red-50 p-2 text-sm text-red-800">{{ error }}</div>
			<div class="flex items-center gap-3">
				<PrimaryButton v-if="task.failed && !task.running && task.id" type="button" @click="resumeUpload">Retomar</PrimaryButton>
				<SecondaryButton type="button" @click="cancelUpload">Cancelar</SecondaryButton>
			</div>
		</div>

		<!-- the server is restoring -->
		<div v-else-if="phase === 'restoring'" class="mt-3 space-y-3">
			<p class="text-sm text-gray-700">Restaurando… isso pode demorar se o backup for grande. Você pode deixar esta página aberta ou voltar a ela depois.</p>
			<div class="h-3 w-full overflow-hidden rounded bg-gray-200"><div class="h-3 bg-blue-600" :style="{ width: (status.percent || 1) + '%' }"></div></div>
			<p class="text-xs text-gray-500">{{ status.phase || 'Iniciando' }}</p>
		</div>

		<!-- done -->
		<div v-else-if="phase === 'complete'" class="mt-3 space-y-3">
			<div class="rounded border border-green-300 bg-green-50 p-3 text-sm text-green-900">
				O backup foi restaurado<span v-if="status.backup_created_at"> (criado em {{ new Date(status.backup_created_at).toLocaleString('pt-BR') }})</span>.
			</div>
			<div v-if="status.blanked?.length" class="rounded border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
				<p class="font-medium">Estas configurações foram criptografadas com a chave do sistema antigo e não puderam ser mantidas. Informe-as novamente depois de entrar:</p>
				<ul class="mt-1 list-disc pl-5"><li v-for="label in status.blanked" :key="label">{{ label }}</li></ul>
			</div>
			<div v-if="status.notes?.length" class="rounded border border-gray-300 bg-gray-50 p-3 text-sm text-gray-700">
				<p v-for="note in status.notes" :key="note">{{ note }}</p>
			</div>
			<div v-if="!status.includes_uploads" class="text-xs text-gray-600">Este backup não incluía fotos e documentos enviados.</div>
			<div v-else-if="status.files_created_at && status.files_created_at !== status.backup_created_at" class="text-xs text-gray-600">
				Os arquivos enviados são do backup criado em {{ new Date(status.files_created_at).toLocaleString('pt-BR') }}.
			</div>
			<div v-if="status.admin_missing" class="rounded border border-amber-300 bg-amber-50 p-3 text-sm text-amber-900">
				Os dados restaurados não têm uma conta de administrador. Prossiga para criar uma.
				<a href="/install" class="block mt-2 underline">Continuar para a configuração inicial</a>
			</div>
			<a v-else href="/login" class="inline-flex items-center rounded-md bg-gray-800 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white hover:bg-gray-700">Entrar</a>
		</div>

		<!-- failed -->
		<div v-else-if="phase === 'failed'" class="mt-3 space-y-3">
			<div class="rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800">
				<p class="font-medium">A restauração não foi concluída.</p>
				<p class="mt-1">{{ status.error }}</p>
			</div>
			<PrimaryButton type="button" @click="reset">Tentar novamente</PrimaryButton>
		</div>
	</div>
</template>
