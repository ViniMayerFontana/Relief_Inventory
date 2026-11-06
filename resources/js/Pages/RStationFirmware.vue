<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- RStationFirmware.vue

	R Station software releases (permission: manage-firmware — deliberately narrower than
	manage-devices, since a bad release reaches the whole fleet): where devices look for
	firmware (this server's own catalogue, or another Relief Inventory server), the catalogue
	of uploaded app/OS releases and the channels each is live on, and a chunked, resumable,
	progress-reporting uploader (a firmware image is ~1 GB, far over PHP's and a proxy's body
	limits). Server half: DeviceReleaseController. Panel-style page per the admin-page-style
	skill — not RIForm.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { useChunkedUpload } from '@/composables/chunkedUpload';
import axios from 'axios';
import { onMounted, reactive, ref, watch } from 'vue';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

const CHANNELS = ['stable', 'testing', 'developer'];

const error = ref('');
const notice = ref('');
const releases = ref([]);
const platforms = ref({});

async function fetchAll() {
	const [r, s] = await Promise.all([axios.get('/json/device-releases'), axios.get('/json/firmware-source')]);
	releases.value = r.data.records;
	platforms.value = r.data.platforms || {};
	sourceUrl.value = s.data.source_url || '';
	savedSource.value = s.data.source_url || '';
}

function fail(e, fallback) {
	error.value = e.response?.data?.errors
		? Object.values(e.response.data.errors).flat().join(' ')
		: e.response?.data?.message || fallback;
}

// ---- Where devices look for firmware ----
const sourceUrl = ref('');
const savedSource = ref('');
const savingSource = ref(false);

async function saveSource() {
	savingSource.value = true;
	error.value = '';
	notice.value = '';
	try {
		const { data } = await axios.put('/json/firmware-source', { source_url: sourceUrl.value.trim() || null });
		savedSource.value = sourceUrl.value = data.source_url || '';
		notice.value = data.source_url
			? 'Salvo. A partir da próxima comunicação, os dispositivos pareados aqui buscarão o software nesse servidor.'
			: 'Salvo. Este servidor voltou a disponibilizar suas próprias versões.';
	} catch (e) {
		fail(e, 'Não foi possível salvar a origem do firmware.');
	} finally {
		savingSource.value = false;
	}
}

// ---- Releases ----
async function toggleTag(release, channel) {
	const action = release.channels?.includes(channel) ? 'untag' : 'tag';
	try {
		await axios.post(`/json/device-releases/${release.id}/${action}`, { channel });
		await fetchAll();
	} catch (e) {
		fail(e, 'Não foi possível alterar os canais desta versão.');
	}
}

async function deleteRelease(release) {
	if (!window.confirm(`Excluir ${release.filename}?`)) return;
	try {
		await axios.delete(`/json/device-releases/${release.id}`);
		await fetchAll();
	} catch (e) {
		fail(e, 'Não foi possível excluir esta versão.');
	}
}

const IMAGE_LABELS = { disk_image: 'Imagem de cartão SD do Raspberry Pi', vm_image: 'Imagem de máquina virtual' };

// Images and the print client are downloaded by people (anyone who can pair a device), never
// offered to devices — so they have no update channels.
const isDownloadOnly = (release) => release.kind === 'print_client' || release.release_type in IMAGE_LABELS;

function releaseLabel(release) {
	if (release.kind === 'print_client') return 'Cliente RI Print';
	return IMAGE_LABELS[release.release_type] || ({ app: 'Aplicativo', os: 'Sistema operacional' })[release.kind] || release.kind;
}

function releaseDetail(release) {
	const platform = release.kind === 'print_client' ? platforms.value[release.architecture] || release.architecture : release.architecture;
	return IMAGE_LABELS[release.release_type] || release.kind === 'print_client' ? platform : `${release.release_type}, ${platform}`;
}

function formatSize(bytes) {
	if (bytes > 1073741824) return `${(bytes / 1073741824).toFixed(2)} GB`;
	return bytes > 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.ceil(bytes / 1024)} KB`;
}

// ---- Chunked upload ----
// start -> PUT consecutive raw chunks at explicit offsets -> complete. The server is the source
// of truth for how much it has: every response carries `received`, and a 409 (a chunk it
// already has, or one that skipped ahead) tells us where to carry on from, so a dropped
// connection or a double-sent chunk can never corrupt the file. A failed upload keeps its
// server-side progress and can be resumed with the same file.
const upload = reactive({ kind: 'app', version: '', architecture: 'aarch64', release_type: 'full', required_base_version: '', notes: '' });
// The print client has no type choices (always full) and picks a platform instead of typing an architecture.
watch(() => upload.kind, (kind) => {
	if (kind === 'print_client') {
		upload.release_type = 'full';
		upload.architecture = 'windows';
	} else if (upload.architecture in platforms.value) {
		upload.architecture = 'aarch64';
	}
	if (kind === 'app') upload.release_type = 'full';
});

const uploadFile = ref(null);
const fileInput = ref(null);
const { task, percent, start, resume, cancel, reset } = useChunkedUpload('/json/device-releases/uploads');

async function startUpload() {
	if (!uploadFile.value) return;
	error.value = '';
	notice.value = '';
	const metadata = Object.fromEntries(Object.entries(upload).filter(([, value]) => value !== ''));
	const name = uploadFile.value.name;
	try {
		await finished(await start(uploadFile.value, metadata), name);
	} catch (e) {
		// No upload id yet means the server refused to start it (validation); otherwise it was interrupted.
		fail(e, task.id ? 'O envio foi interrompido. Escolha Retomar para continuar de onde parou.' : 'Não foi possível iniciar o envio.');
	}
}

async function resumeUpload() {
	error.value = '';
	const name = task.file?.name;
	try {
		await finished(await resume(), name);
	} catch (e) {
		fail(e, 'O envio foi interrompido. Escolha Retomar para continuar de onde parou.');
	}
}

async function finished(completed, name) {
	if (!completed) return;
	notice.value = `${name} enviado. Ele não será disponibilizado até que você selecione um canal.`;
	reset(); // the server already holds the file; nothing to delete
	uploadFile.value = null;
	if (fileInput.value) fileInput.value.value = '';
	upload.version = upload.required_base_version = upload.notes = '';
	await fetchAll();
}

async function cancelUpload() {
	await cancel();
	notice.value = 'Envio cancelado.';
}

onMounted(fetchAll);
</script>

<template>
	<Head title="Firmware do R Station" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Firmware do R Station</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<!-- Where devices look -->
			<section class="bg-white shadow rounded-lg p-6 space-y-3">
				<h2 class="text-lg font-semibold">Origem do software dos dispositivos</h2>
				<p class="text-sm text-gray-600">
					Os dispositivos sempre se comunicam com o servidor ao qual estão pareados. Por padrão, esse servidor
					disponibiliza as versões listadas abaixo. Para usar as versões de outro servidor Relief Inventory
					(por exemplo, um servidor central que mantém o firmware de vários locais), informe o endereço:
					os dispositivos pareados aqui buscarão atualizações nele, usando o canal definido para cada dispositivo neste servidor.
				</p>
				<div class="flex gap-3 items-end text-sm">
					<label class="block grow">
						<span class="text-gray-700">Servidor de origem do firmware (deixe em branco para usar este servidor)</span>
						<input type="url" v-model="sourceUrl" placeholder="https://relief.example.org" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<PrimaryButton :disabled="savingSource || sourceUrl.trim() === savedSource" @click="saveSource">
						{{ savingSource ? 'Salvando…' : 'Salvar' }}
					</PrimaryButton>
				</div>
				<p v-if="savedSource" class="text-sm rounded bg-amber-50 border border-amber-300 px-3 py-2">
					Os dispositivos pareados aqui recebem o software de <strong>{{ savedSource }}</strong>. As versões abaixo não são
					disponibilizadas para eles (mas continuam acessíveis a qualquer servidor que use este como origem).
				</p>
			</section>

			<!-- Releases -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Versões de software</h2>
				<table v-if="releases.length" class="w-full text-sm">
					<thead>
						<tr class="text-left text-gray-600">
							<th class="py-1">Versão</th>
							<th>Disponível no canal</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="release in releases" :key="release.id" class="border-t">
							<td class="py-2">
								<div><strong>{{ releaseLabel(release) }}</strong> {{ release.version }}
									<span class="text-gray-500">({{ releaseDetail(release) }}, {{ formatSize(release.size_bytes) }})</span>
								</div>
								<div v-if="release.required_base_version" class="text-xs text-gray-500">aplicada sobre a versão {{ release.required_base_version }}</div>
								<div class="text-xs text-gray-400">{{ release.filename }}</div>
							</td>
							<td v-if="isDownloadOnly(release)" class="text-gray-500">
								Somente para download — disponível a quem puder parear dispositivos
							</td>
							<td v-else>
								<label v-for="c in CHANNELS" :key="c" class="mr-3 whitespace-nowrap">
									<input type="checkbox" :checked="release.channels?.includes(c)" @change="toggleTag(release, c)" class="rounded border-gray-300" />
									{{ ({ stable: 'Estável', testing: 'Teste', developer: 'Desenvolvimento' })[c] || c }}
								</label>
							</td>
							<td class="text-right">
								<button type="button" class="text-red-700 underline" @click="deleteRelease(release)">Excluir</button>
							</td>
						</tr>
					</tbody>
				</table>
				<p v-else class="text-sm text-gray-400">Nenhuma versão enviada ainda.</p>

				<h3 class="font-medium text-sm pt-2">Enviar uma versão</h3>
				<fieldset :disabled="task.id !== null" class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">Categoria</span>
						<select v-model="upload.kind" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="app">Aplicativo (.tar.gz)</option>
							<option value="os">Pacote do sistema operacional (.raucb)</option>
							<option value="print_client">Cliente RI Print (instalador)</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">Tipo</span>
						<select v-model="upload.release_type" :disabled="upload.kind === 'print_client'" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="full">Completa</option>
							<option v-if="upload.kind === 'os'" value="hotfix">Correção (pequena, aplicada sobre uma versão base)</option>
							<option v-if="upload.kind === 'os'" value="disk_image">Imagem de cartão SD do Raspberry Pi (regravação; nunca oferecida automaticamente)</option>
							<option v-if="upload.kind === 'os'" value="vm_image">Imagem de máquina virtual (.img.xz; nunca oferecida automaticamente)</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">Versão</span>
						<input type="text" v-model="upload.version" placeholder="ex.: 0.4.0_0.1.1" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label class="block">
						<span class="text-gray-700">{{ upload.kind === 'print_client' ? 'Plataforma' : 'Arquitetura' }}</span>
						<select v-if="upload.kind === 'print_client'" v-model="upload.architecture" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option v-for="(label, key) in platforms" :key="key" :value="key">{{ label }}</option>
						</select>
						<input v-else type="text" v-model="upload.architecture" placeholder="aarch64" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label v-if="upload.release_type === 'hotfix'" class="block sm:col-span-2">
						<span class="text-gray-700">Versão base exigida (exata)</span>
						<input type="text" v-model="upload.required_base_version" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label class="block sm:col-span-2">
						<span class="text-gray-700">Arquivo</span>
						<input ref="fileInput" type="file" @change="uploadFile = $event.target.files[0]" class="mt-1 block w-full text-sm" />
					</label>
					<label class="block sm:col-span-2">
						<span class="text-gray-700">Observações (opcional)</span>
						<input type="text" v-model="upload.notes" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
				</fieldset>

				<div v-if="task.id !== null" class="space-y-2">
					<div class="flex justify-between text-sm">
						<span>
							<strong>{{ task.file?.name }}</strong>
							<template v-if="task.running"> — enviando…</template>
							<template v-else-if="task.failed"> — interrompido</template>
						</span>
						<span>{{ percent }}% · {{ formatSize(task.received) }} of {{ formatSize(task.size) }}</span>
					</div>
					<div class="h-3 w-full rounded bg-gray-200 overflow-hidden" role="progressbar" :aria-valuenow="percent" aria-valuemin="0" aria-valuemax="100">
						<div class="h-3 rounded" :class="task.failed ? 'bg-red-500' : 'bg-blue-600'" :style="{ width: percent + '%' }"></div>
					</div>
					<div class="flex gap-3 text-sm">
						<PrimaryButton v-if="task.failed && !task.running" @click="resumeUpload">Retomar</PrimaryButton>
						<button type="button" class="text-red-700 underline" @click="cancelUpload">Cancelar envio</button>
					</div>
				</div>
				<PrimaryButton v-else :disabled="!uploadFile || !upload.version" @click="startUpload">Enviar</PrimaryButton>

				<p class="text-xs text-gray-500">
					Arquivos grandes são enviados em partes pequenas, sem limite prático de tamanho. Se a conexão cair, o envio continua
					de onde parou (mantenha esta página aberta durante o envio). Uma versão recém-enviada não será oferecida a ninguém
					até que você selecione um canal (imagens de cartão SD do Raspberry Pi, imagens de máquina virtual e o cliente de
					impressão nunca são enviados aos dispositivos; qualquer pessoa autorizada a parear um dispositivo pode baixá-los na
					página Dispositivos, e somente o envio mais recente de cada plataforma ou tipo de imagem é mantido — enviar uma nova
					versão exclui a anterior). Ao selecionar um canal, a versão que ocupava essa posição é substituída (uma versão
					completa por categoria e arquitetura, uma correção por versão base). Os dispositivos só recebem versões mais novas,
					nunca versões anteriores.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
