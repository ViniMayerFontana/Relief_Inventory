<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- RStationDevices.vue

	Fleet admin for R Station Raspberry Pi devices and PC/Mac print servers
	(permission: manage-devices): generate a pairing code, configure each
	device (name, site, what it does, update channel), set up the printers a
	print server reports (name, site, paper type, on/off) and revoke it. Each
	device is a collapsible tile (expand it for its settings and printers; a
	printer expands again for its own settings); R Stations and RI Print
	Servers are told apart by an icon, and firmware options only exist for
	R Stations. Software releases live on their own page, /setup/firmware
	(manage-firmware); all printers together, with drag-to-order and status,
	on /setup/printers. Server half of rstation/platform/docs/DEVICE_CONTRACT.md.
	Panel-style page per the admin-page-style skill — not RIForm.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import DeviceTypeIcon from '@/Components/DeviceTypeIcon.vue';
import axios from 'axios';
import { computed, onMounted, reactive, ref } from 'vue';

defineProps({
	breadcrumb: {
		type: Array,
	},
	canManageFirmware: {
		type: Boolean,
		default: false,
	},
});

const error = ref('');
const notice = ref('');

const devices = ref([]);
const functions = ref([]);
const channels = ref([]);
const media = ref([]);
const locations = ref([]);
const savingId = ref(null);
const downloads = ref([]);
const platforms = ref({});

async function fetchAll() {
	const [d, l, dl] = await Promise.all([
		axios.get('/json/managed-devices'),
		axios.get('/json/kiosk-locations'),
		axios.get('/json/device-downloads'),
	]);
	downloads.value = dl.data.records;
	platforms.value = dl.data.platforms;
	devices.value = d.data.records;
	functions.value = d.data.functions;
	channels.value = d.data.channels;
	media.value = d.data.media;
	locations.value = l.data.records.filter((loc) => loc.active);
	if (!pairLocationId.value && locations.value.length) pairLocationId.value = locations.value[0].id;
}

function fail(e, fallback) {
	error.value = e.response?.data?.message || fallback;
}

// ---- Downloads (images + print client; uploaded on the Firmware page) ----
const imageDownloads = computed(() => downloads.value.filter((r) => r.kind !== 'print_client'));
const printClientDownloads = computed(() => downloads.value.filter((r) => r.kind === 'print_client'));

function downloadLabel(release) {
	return release.kind === 'print_client'
		? platforms.value[release.architecture] || release.architecture
		: release.release_type === 'vm_image' ? 'Imagem de máquina virtual' : 'Imagem para cartão SD do Raspberry Pi';
}

function formatSize(bytes) {
	if (bytes > 1073741824) return `${(bytes / 1073741824).toFixed(2)} GB`;
	return bytes > 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.ceil(bytes / 1024)} KB`;
}

// ---- Pairing ----
const pairLocationId = ref(null);
const pairingCode = ref(null);

async function generateCode() {
	error.value = '';
	try {
		const response = await axios.post('/json/device-pairing-codes', { kiosk_location_id: pairLocationId.value });
		pairingCode.value = response.data.record;
	} catch (e) {
		fail(e, 'Não foi possível gerar um código de pareamento.');
	}
}

// ---- Devices ----
async function saveDevice(device) {
	savingId.value = device.id;
	error.value = '';
	notice.value = '';
	try {
		await axios.put(`/json/managed-devices/${device.id}`, device);
		notice.value = `${device.name} salvo. A alteração será aplicada na próxima comunicação do dispositivo (em até 5 minutos).`;
	} catch (e) {
		fail(e, 'Não foi possível salvar este dispositivo.');
	} finally {
		savingId.value = null;
	}
}

// ---- Printers (queues a print server reported) ----
const savingPrinterId = ref(null);
const confirmingPrinterRemove = ref(null);

function printerDot(printer) {
	if (printer.status === 'idle' || printer.status === 'printing') return 'bg-green-500';
	if (printer.status === 'error') return 'bg-red-500';
	return 'bg-amber-500';
}

function printerState(printer) {
	const labels = { idle: 'ociosa', printing: 'imprimindo', error: 'erro', unavailable: 'indisponível' };
	const status = labels[printer.status] || printer.status;
	if (printer.status === 'unavailable') return printer.status_message || status;
	return printer.status_message ? `${status}: ${printer.status_message}` : status;
}

async function savePrinter(printer) {
	savingPrinterId.value = printer.id;
	error.value = '';
	notice.value = '';
	try {
		const { data } = await axios.put(`/json/printers/${printer.id}`, printer);
		Object.assign(printer, data.record);
		notice.value = `${printer.name} salva.`;
	} catch (e) {
		fail(e, 'Não foi possível salvar esta impressora.');
	} finally {
		savingPrinterId.value = null;
	}
}

async function removePrinter(printer) {
	if (confirmingPrinterRemove.value !== printer.id) {
		confirmingPrinterRemove.value = printer.id;
		return;
	}
	confirmingPrinterRemove.value = null;
	error.value = '';
	notice.value = '';
	try {
		const { data } = await axios.delete(`/json/printers/${printer.id}`);
		notice.value = data.message;
		await fetchAll();
	} catch (e) {
		fail(e, 'Não foi possível remover esta impressora.');
	}
}

async function revokeDevice(device) {
	if (!window.confirm(`Revogar ${device.name}? O pareamento será apagado e o dispositivo voltará à configuração na próxima comunicação.`)) return;
	try {
		await axios.post(`/json/managed-devices/${device.id}/revoke`);
		await fetchAll();
	} catch (e) {
		fail(e, 'Não foi possível revogar este dispositivo.');
	}
}

async function removeDevice(device) {
	if (!window.confirm(`Remover ${device.name} da lista?`)) return;
	try {
		await axios.delete(`/json/managed-devices/${device.id}`);
		await fetchAll();
	} catch (e) {
		fail(e, 'Não foi possível remover este dispositivo.');
	}
}

function lastSeen(device) {
	return device.last_seen_at ? new Date(device.last_seen_at).toLocaleString('pt-BR') : 'nunca';
}

// ---- Collapsible tiles ----
// A device and each of its printers start collapsed so the whole fleet fits on one screen;
// the header row of either toggles it. Keys are namespaced so a device and a printer with
// the same numeric id don't share state.
const open = reactive({});
const isOpen = (key) => !!open[key];
const toggle = (key) => { open[key] = !open[key]; };
const allOpen = computed(() => devices.value.length > 0 && devices.value.every((d) => open[`d${d.id}`]));
function toggleAll() {
	const target = !allOpen.value;
	devices.value.forEach((d) => { open[`d${d.id}`] = target; });
}

const isPrintServer = (device) => device.device_type === 'print_server';
const deviceTypeLabel = (device) => (isPrintServer(device) ? 'Servidor RI Print' : 'R Station');
const channelLabel = (channel) => ({ stable: 'Estável', testing: 'Teste', developer: 'Desenvolvimento' })[channel] || channel;
function printerProblems(device) {
	return (device.printers || []).filter((p) => p.active && !['idle', 'printing'].includes(p.status)).length;
}
function functionLabel(device) {
	return functions.value.find((f) => f.key === device.kiosk_function)?.label || null;
}

onMounted(fetchAll);
</script>

<template>
	<Head title="Dispositivos R Station" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Dispositivos R Station</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<!-- Pairing -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Parear um novo dispositivo ou servidor de impressão</h2>
				<div class="flex gap-3 items-end text-sm">
					<label class="block">
						<span class="text-gray-700">Local</span>
						<select v-model.number="pairLocationId" class="mt-1 block border-gray-300 rounded-md shadow-sm">
							<option v-for="location in locations" :key="location.id" :value="location.id">{{ location.name }}</option>
						</select>
					</label>
					<PrimaryButton :disabled="!pairLocationId" @click="generateCode">Gerar código</PrimaryButton>
				</div>
				<div v-if="pairingCode" class="rounded bg-blue-50 border border-blue-300 px-4 py-3">
					<span class="text-3xl font-mono tracking-widest">{{ pairingCode.code }}</span>
					<span class="ml-3 text-sm text-gray-600">Digite este código na tela de configuração do dispositivo (ou servidor de impressão). Uso único; expira às {{ new Date(pairingCode.expires_at).toLocaleTimeString('pt-BR') }}.</span>
				</div>
			</section>

			<!-- Downloads -->
			<section class="bg-white shadow rounded-lg p-6 space-y-3">
				<h2 class="text-lg font-semibold">Downloads</h2>
				<p v-if="!downloads.length" class="text-sm text-gray-400">Nenhum arquivo foi enviado para download ainda.</p>
				<template v-if="imageDownloads.length">
					<h3 class="font-medium text-sm">Imagens</h3>
					<ul class="text-sm space-y-1">
						<li v-for="r in imageDownloads" :key="r.id">
							<a :href="$withWarehouse(r.download_url)" class="underline text-blue-700">{{ downloadLabel(r) }} {{ r.version }}</a>
							<span class="text-gray-500"> — {{ r.architecture }}, {{ formatSize(r.size_bytes) }}</span>
							<span v-if="r.notes" class="text-gray-500"> — {{ r.notes }}</span>
						</li>
					</ul>
				</template>
				<template v-if="printClientDownloads.length">
					<h3 class="font-medium text-sm pt-1">Cliente RI Print</h3>
					<ul class="text-sm space-y-1">
						<li v-for="r in printClientDownloads" :key="r.id">
							<a :href="$withWarehouse(r.download_url)" class="underline text-blue-700">{{ downloadLabel(r) }} {{ r.version }}</a>
							<span class="text-gray-500"> — {{ formatSize(r.size_bytes) }}</span>
							<span v-if="r.notes" class="text-gray-500"> — {{ r.notes }}</span>
						</li>
					</ul>
				</template>
			</section>

			<!-- Devices -->
			<section class="bg-white shadow rounded-lg p-6 space-y-3">
				<div class="flex items-center justify-between gap-3">
					<h2 class="text-lg font-semibold">Dispositivos</h2>
					<div class="flex items-center gap-4 text-sm">
						<a v-if="canManageFirmware" href="/setup/firmware" class="underline text-gray-700">Firmware</a>
						<a href="/setup/printers" class="underline text-gray-700">Todas as impressoras</a>
						<button v-if="devices.length" type="button" class="underline text-gray-700" @click="toggleAll">
							{{ allOpen ? 'Recolher todos' : 'Expandir todos' }}
						</button>
					</div>
				</div>
				<p v-if="!devices.length" class="text-sm text-gray-400">Nenhum dispositivo pareado ainda.</p>

				<div v-for="device in devices" :key="device.id" class="border rounded">
					<!-- Summary row: always visible, toggles the tile -->
					<button
						type="button"
						class="w-full flex items-center gap-3 p-3 text-left text-sm"
						:aria-expanded="isOpen(`d${device.id}`)"
						@click="toggle(`d${device.id}`)"
					>
						<span class="text-gray-400 w-3 shrink-0">{{ isOpen(`d${device.id}`) ? '▾' : '▸' }}</span>
						<DeviceTypeIcon :type="device.device_type" />
						<span class="inline-block w-3 h-3 rounded-full shrink-0" :class="device.revoked ? 'bg-red-500' : device.online ? 'bg-green-500' : 'bg-gray-400'"></span>
						<span class="min-w-0 grow">
							<strong>{{ device.name }}</strong>
							<span class="text-gray-500">
								· {{ deviceTypeLabel(device) }}<template v-if="device.location"> · {{ device.location.name }}</template><template v-if="functionLabel(device)"> · {{ functionLabel(device) }}</template>
							</span>
							<span class="block text-xs text-gray-500">
								{{ device.revoked ? 'revogado' : device.online ? 'online' : 'offline' }} · visto pela última vez {{ lastSeen(device) }}
								<template v-if="device.printers?.length"> · {{ device.printers.length }} {{ device.printers.length === 1 ? 'impressora' : 'impressoras' }}</template>
							</span>
						</span>
						<span v-if="printerProblems(device)" class="text-xs rounded bg-amber-100 text-amber-800 px-2 py-0.5 shrink-0">
							{{ printerProblems(device) }} {{ printerProblems(device) === 1 ? 'impressora precisa' : 'impressoras precisam' }} de atenção
						</span>
					</button>

					<div v-if="isOpen(`d${device.id}`)" class="border-t p-3 space-y-3">
						<div class="text-xs text-gray-500">
							<template v-if="isPrintServer(device)">
								{{ device.platform }} · software {{ device.app_version || '?' }} · {{ device.architecture || '?' }}
							</template>
							<template v-else>
								<template v-if="device.platform">{{ device.platform }} · </template>app {{ device.app_version || '?' }} · OS {{ device.os_version || '?' }} · {{ device.architecture || '?' }}
							</template>
							<template v-if="device.hostname"> · {{ device.hostname }}.local</template>
							<template v-if="device.cpu_temp_c != null"> · {{ device.cpu_temp_c }}°C</template>
						</div>
						<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
							<label class="block">
								<span class="text-gray-700">Nome</span>
								<input type="text" maxlength="255" v-model="device.name" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">Local</span>
								<select v-model="device.kiosk_location_id" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
									<option :value="null">— nenhum —</option>
									<option v-for="location in locations" :key="location.id" :value="location.id">{{ location.name }}</option>
								</select>
							</label>
							<!-- Firmware options: only R Stations take firmware; a print server has none of this. -->
							<template v-if="!isPrintServer(device)">
								<label class="block">
									<span class="text-gray-700">Função</span>
									<select v-model="device.kiosk_function" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
										<option :value="null">— não configurada —</option>
										<option v-for="f in functions" :key="f.key" :value="f.key">{{ f.label }}</option>
									</select>
								</label>
								<label class="block">
									<span class="text-gray-700">Canal de atualização</span>
									<select v-model="device.update_channel" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
										<option v-for="c in channels" :key="c" :value="c">{{ channelLabel(c) }}</option>
									</select>
								</label>
								<label class="flex items-center gap-2 sm:col-span-2">
									<input type="checkbox" v-model="device.os_auto_update_enabled" class="rounded border-gray-300" />
									<span class="text-gray-700">Permitir a instalação automática de atualizações do sistema operacional (durante a noite)</span>
								</label>
							</template>
						</div>
						<div class="flex gap-3 items-center">
							<PrimaryButton :disabled="savingId === device.id" @click="saveDevice(device)">
								{{ savingId === device.id ? 'Salvando…' : 'Salvar' }}
							</PrimaryButton>
							<button v-if="!device.revoked" type="button" class="text-sm text-red-700 underline" @click="revokeDevice(device)">Revogar</button>
							<button type="button" class="text-sm text-gray-600 underline" @click="removeDevice(device)">Remover</button>
						</div>

						<!-- Printers this print server reports -->
						<div v-if="device.kiosk_function === 'print_station' || device.printers?.length" class="border-t pt-3 space-y-2">
							<h3 class="font-medium text-sm">Impressoras</h3>
							<p v-if="!device.printers?.length" class="text-sm text-gray-400">
								Nenhuma impressora informada ainda. Quando o servidor de impressão estiver em execução, ele listará aqui as impressoras disponíveis na próxima comunicação.
							</p>
							<div v-for="printer in device.printers" :key="printer.id" class="border rounded bg-gray-50">
								<button
									type="button"
									class="w-full flex items-center gap-2 p-2 text-left text-sm"
									:aria-expanded="isOpen(`p${printer.id}`)"
									@click="toggle(`p${printer.id}`)"
								>
									<span class="text-gray-400 w-3 shrink-0">{{ isOpen(`p${printer.id}`) ? '▾' : '▸' }}</span>
									<span class="inline-block w-3 h-3 rounded-full shrink-0" :class="printerDot(printer)"></span>
									<strong>{{ printer.name || printer.queue_name }}</strong>
									<span class="text-gray-500 text-xs">{{ printerState(printer) }}</span>
									<span v-if="!printer.active" class="text-xs text-gray-400">· desativada</span>
								</button>
								<div v-if="isOpen(`p${printer.id}`)" class="border-t p-3 space-y-3">
									<div class="font-mono text-xs text-gray-600">{{ printer.queue_name }}</div>
									<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
										<label class="block">
											<span class="text-gray-700">Nome</span>
											<input type="text" maxlength="255" v-model="printer.name" placeholder="ex.: Área de expedição" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
										</label>
										<label class="block">
											<span class="text-gray-700">Local</span>
											<select v-model="printer.kiosk_location_id" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
												<option :value="null">— nenhum —</option>
												<option v-for="location in locations" :key="location.id" :value="location.id">{{ location.name }}</option>
											</select>
										</label>
										<label class="block">
											<span class="text-gray-700">Tipo de papel</span>
											<select v-model="printer.media" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
												<option :value="null">— não definido —</option>
												<option v-for="m in media" :key="m.key" :value="m.key">{{ m.label }}</option>
											</select>
										</label>
										<p class="text-xs text-gray-500 self-end">A ordem das impressoras nos menus de impressão é definida arrastando-as na página <a href="/setup/printers" class="underline">Todas as impressoras</a>.</p>
										<label class="flex items-center gap-2 sm:col-span-2">
											<input type="checkbox" v-model="printer.active" class="rounded border-gray-300" />
											<span class="text-gray-700">Disponibilizar esta impressora nos menus de impressão</span>
										</label>
									</div>
									<div class="flex gap-3 items-center">
										<PrimaryButton :disabled="savingPrinterId === printer.id" @click="savePrinter(printer)">
											{{ savingPrinterId === printer.id ? 'Salvando…' : 'Salvar impressora' }}
										</PrimaryButton>
										<button
											type="button"
											class="text-sm underline"
											:class="confirmingPrinterRemove === printer.id ? 'text-red-700 font-semibold' : 'text-gray-600'"
											@click="removePrinter(printer)"
										>
											{{ confirmingPrinterRemove === printer.id ? 'Confirmar — ela voltará se o servidor ainda a informar' : 'Remover' }}
										</button>
										<button v-if="confirmingPrinterRemove === printer.id" type="button" class="text-sm text-gray-600 underline" @click="confirmingPrinterRemove = null">Cancelar</button>
									</div>
								</div>
							</div>
							<p class="text-xs text-gray-500">
								Uma impressora só aparece nos menus de impressão quando tem um local e um tipo de papel definidos e está ativada.
								Para alterar o tipo de papel, a fila da impressora precisa estar vazia.
							</p>
						</div>
					</div>
				</div>
				<p class="text-xs text-gray-500">
					Os dispositivos se comunicam a cada 5 minutos; as alterações feitas aqui chegam no próximo contato.
					A revogação faz o dispositivo voltar à configuração. Um dispositivo sem contato há mais de 15 minutos aparece como offline.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
