<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- PinLoginSettings.vue

	Admin panel for the shared-terminal PIN unlock feature. Two
	independently-permissioned sections (see routes/web/kiosk.php's comment on
	why there's no single OR-gated permission for the page): Settings
	(admin-system — the global on/off/trust-mode config) and Trusted
	Devices (manage-trusted-devices — which specific devices may use PIN
	unlock, deliberately delegable narrower than full admin-system).
-->

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';

const props = defineProps({
	breadcrumb: { type: Array },
	canManageSettings: { type: Boolean, default: false },
	canManageDevices: { type: Boolean, default: false },
});

// ---------- settings ----------
const settingsLoading = ref(false);
const settingsError = ref(null);
const settingsSaving = ref(false);
const settingsSavedAt = ref(null);
const form = reactive({
	enabled: false,
	trust_mode: 'session_duration',
	trust_time_of_day: '18:00',
	trust_session_minutes: 480,
	require_badge_and_pin: false,
	badge_login_enabled: false,
});

async function fetchSettings() {
	settingsLoading.value = true;
	settingsError.value = null;
	try {
		const response = await axios.get('/json/pin-login-settings');
		Object.assign(form, response.data.settings);
	} catch (error) {
		settingsError.value = 'Não foi possível carregar as configurações de acesso por PIN.';
	} finally {
		settingsLoading.value = false;
	}
}

async function saveSettings() {
	settingsError.value = null;
	settingsSaving.value = true;
	try {
		const response = await axios.put('/json/pin-login-settings', form);
		Object.assign(form, response.data.settings);
		settingsSavedAt.value = new Date().toLocaleTimeString();
	} catch (error) {
		settingsError.value = error.response?.data?.message
			|| Object.values(error.response?.data?.errors || {}).flat().join(' ')
			|| 'Não foi possível salvar as configurações.';
	} finally {
		settingsSaving.value = false;
	}
}

// ---------- trusted devices ----------
const devicesLoading = ref(false);
const devicesError = ref(null);
const devices = ref([]);
const labelDrafts = reactive({});
const confirmingRevoke = ref(null);
const showClosed = ref(false);

// Requests waiting for a decision, approved devices, and the denied/revoked record (hidden unless asked for).
const pendingDevices = computed(() => devices.value.filter((d) => d.status === 'pending'));
const approvedDevices = computed(() => devices.value.filter((d) => d.status === 'approved'));
const closedDevices = computed(() => devices.value.filter((d) => d.status === 'denied' || d.status === 'revoked'));

async function fetchDevices() {
	devicesLoading.value = true;
	devicesError.value = null;
	try {
		const response = await axios.get('/json/trusted-devices');
		devices.value = response.data.records;
		devices.value.forEach((d) => { labelDrafts[d.id] = d.label || ''; });
	} catch (error) {
		devicesError.value = 'Não foi possível carregar os dispositivos confiáveis.';
	} finally {
		devicesLoading.value = false;
	}
}

async function approveDevice(device) {
	devicesError.value = null;
	try {
		const response = await axios.post(`/json/trusted-devices/${device.id}/approve`, {
			label: labelDrafts[device.id] || null,
		});
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = 'Não foi possível aprovar o dispositivo.';
	}
}

async function denyDevice(device) {
	devicesError.value = null;
	try {
		const response = await axios.post(`/json/trusted-devices/${device.id}/deny`);
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = 'Não foi possível negar essa solicitação.';
	}
}

function describe(device) {
	return [device.browser, device.os].filter(Boolean).join(' em ') || 'Navegador desconhecido';
}

async function saveLabel(device) {
	devicesError.value = null;
	try {
		const response = await axios.put(`/json/trusted-devices/${device.id}`, {
			label: labelDrafts[device.id] || null,
		});
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = 'Não foi possível salvar o rótulo.';
	}
}

async function revokeDevice(device) {
	if (confirmingRevoke.value !== device.id) {
		confirmingRevoke.value = device.id;
		return;
	}
	confirmingRevoke.value = null;
	devicesError.value = null;
	try {
		const response = await axios.post(`/json/trusted-devices/${device.id}/revoke`);
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = 'Não foi possível revogar o dispositivo.';
	}
}

function statusBadgeClass(status) {
	return {
		pending: 'bg-amber-100 text-amber-800',
		approved: 'bg-green-100 text-green-800',
		revoked: 'bg-gray-200 text-gray-600',
		denied: 'bg-red-100 text-red-800',
	}[status] || 'bg-gray-100 text-gray-600';
}

onMounted(() => {
	if (props.canManageSettings) fetchSettings();
	if (props.canManageDevices) fetchDevices();
});
</script>

<template>
	<Head title="Acesso por PIN" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Acesso por PIN</h1>

			<p v-if="!canManageSettings && !canManageDevices" class="text-gray-500">
				Você não tem permissão para gerenciar as configurações de acesso por PIN nem os dispositivos confiáveis.
			</p>

			<!-- ======================= SETTINGS ======================= -->
			<section v-if="canManageSettings" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Configurações</h2>
				<p class="text-sm text-gray-600">
					Um desbloqueio rápido para terminais compartilhados, destinado a pessoas que já entraram
					neste dispositivo usando e-mail e senha. Desativado por padrão; os dispositivos aprovados são gerenciados separadamente abaixo.
				</p>

				<div v-if="settingsError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ settingsError }}</div>
				<p v-if="settingsLoading" class="text-gray-500">Carregando configurações…</p>

				<template v-else>
					<label class="flex items-center gap-2">
						<input type="checkbox" v-model="form.enabled" />
						<span class="text-gray-700 font-medium">Ativar acesso por PIN</span>
					</label>

					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">A confiança expira</span>
							<select v-model="form.trust_mode" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="session_duration">Após um período fixo a partir do acesso</option>
								<option value="time_of_day">Em um horário fixo do dia (reinício diário)</option>
								<option value="indefinite">Nunca (até sair explicitamente)</option>
							</select>
						</label>

						<label v-if="form.trust_mode === 'session_duration'" class="block">
							<span class="text-gray-700">Duração (minutos)</span>
							<input type="number" min="1" max="10080" v-model.number="form.trust_session_minutes"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>

						<label v-if="form.trust_mode === 'time_of_day'" class="block">
							<span class="text-gray-700">Horário</span>
							<input type="time" v-model="form.trust_time_of_day"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</div>

					<label class="flex items-center gap-2">
						<input type="checkbox" v-model="form.badge_login_enabled" @change="form.badge_login_enabled || (form.require_badge_and_pin = false)" />
						<span class="text-gray-700 font-medium">Oferecer leitura do crachá na tela de desbloqueio</span>
					</label>
					<p class="text-xs text-gray-500">
						Desativado por padrão até que os crachás sejam emitidos. Enquanto estiver desativado,
						a tela de desbloqueio mostrará apenas os nomes e o PIN, sem a leitura do crachá. Ative quando os crachás físicos estiverem disponíveis.
					</p>

					<label class="flex items-center gap-2">
						<input type="checkbox" v-model="form.require_badge_and_pin" :disabled="!form.badge_login_enabled" />
						<span class="text-gray-700" :class="{ 'opacity-50': !form.badge_login_enabled }">Exigir leitura do crachá além do PIN (autenticação de dois fatores)</span>
					</label>
					<p class="text-xs text-gray-500">
						Quando ativado, tocar no nome não será suficiente: para desbloquear, será necessário ler
						o crachá da pessoa e, em seguida, informar o PIN. É preciso oferecer a leitura de crachá acima.
					</p>

					<div class="flex items-center gap-3">
						<PrimaryButton :disabled="settingsSaving" @click="saveSettings">
							{{ settingsSaving ? 'Salvando…' : 'Salvar configurações' }}
						</PrimaryButton>
						<span v-if="settingsSavedAt" class="text-sm text-gray-500">Salvo {{ settingsSavedAt }}</span>
					</div>
				</template>
			</section>

			<!-- ======================= TRUSTED DEVICES ======================= -->
			<section v-if="canManageDevices" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Dispositivos</h2>
				<p class="text-sm text-gray-600">
					O acesso por PIN só é oferecido em dispositivos aprovados aqui. Um dispositivo é adicionado
					quando alguém que já entrou nele solicita o acesso por PIN (menu do perfil &gt; <strong>Acesso por PIN neste
					dispositivo</strong>): você pode aprovar seu próprio dispositivo nessa página; as solicitações de outras pessoas ficam aguardando aqui.
					<Link href="/this-device" class="text-blue-600 underline">Aprovar o dispositivo que você está usando</Link>
				</p>

				<div v-if="devicesError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ devicesError }}</div>
				<p v-if="devicesLoading" class="text-gray-500">Carregando dispositivos…</p>

				<template v-else>
					<div v-for="group in [
						{ key: 'pending', title: 'Solicitações aguardando aprovação', list: pendingDevices, empty: 'Nenhuma solicitação aguardando.' },
						{ key: 'approved', title: 'Dispositivos aprovados', list: approvedDevices, empty: 'Nenhum dispositivo aprovado ainda.' },
					]" :key="group.key" class="space-y-3">
						<h3 class="font-semibold text-gray-800">{{ group.title }} ({{ group.list.length }})</h3>
						<p v-if="!group.list.length" class="text-sm text-gray-400">{{ group.empty }}</p>

						<div v-for="device in group.list" :key="device.id" class="border rounded p-3 space-y-2">
							<div class="flex items-center justify-between flex-wrap gap-2">
								<div class="flex items-center gap-2">
									<span class="text-xs font-semibold uppercase tracking-widest px-2 py-1 rounded"
										:class="statusBadgeClass(device.status)">{{ device.status }}</span>
									<span class="font-medium">{{ device.label || describe(device) }}</span>
								</div>
								<span v-if="device.status === 'approved'" class="text-xs text-gray-500 font-mono">
									{{ device.grants_count }} acesso(s) ativo(s)
								</span>
							</div>

							<div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
								<div class="space-y-1">
									<label class="block">
										<span class="text-gray-700">Nome da estação</span>
										<input type="text" v-model="labelDrafts[device.id]" placeholder="ex.: Estação de triagem 1"
											class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
									</label>
									<p v-if="device.request_reason" class="text-gray-700"><span class="text-gray-500">Motivo:</span> {{ device.request_reason }}</p>
								</div>
								<div class="text-xs text-gray-600 space-y-0.5">
									<div>{{ describe(device) }}</div>
									<div>Endereço IP: <span class="font-mono">{{ device.ip_address || '—' }}</span>
										<template v-if="device.last_ip_address && device.last_ip_address !== device.ip_address">
											(visto pela última vez de <span class="font-mono">{{ device.last_ip_address }}</span>)</template>
									</div>
									<div>Solicitado em {{ new Date(device.requested_at).toLocaleString() }}<template v-if="device.requester"> por {{ device.requester.full_name }}</template></div>
									<div v-if="device.last_seen_at">Visto pela última vez: {{ new Date(device.last_seen_at).toLocaleString() }}</div>
									<div v-if="device.approver && device.status === 'approved'">Aprovado por {{ device.approver.full_name }}</div>
									<div v-if="device.kiosk_mode" class="text-amber-700">Em modo quiosque</div>
									<div class="truncate text-gray-400" :title="device.user_agent">{{ device.user_agent }}</div>
								</div>
							</div>

							<div class="flex items-center gap-2 flex-wrap">
								<template v-if="device.status === 'pending'">
									<button @click="approveDevice(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-green-600 hover:bg-green-500">
										Aprovar
									</button>
									<button @click="denyDevice(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-600 hover:bg-gray-500">
										Negar
									</button>
								</template>
								<template v-else>
									<button @click="saveLabel(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-600 hover:bg-gray-500">
										Salvar nome
									</button>
									<button @click="revokeDevice(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
										:class="confirmingRevoke === device.id ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'">
										{{ confirmingRevoke === device.id ? 'Confirmar — encerra o acesso por PIN de todos neste dispositivo' : 'Revogar' }}
									</button>
									<button v-if="confirmingRevoke === device.id" @click="confirmingRevoke = null"
										class="text-sm text-gray-500 underline">Cancelar</button>
								</template>
							</div>
						</div>
					</div>

					<div v-if="closedDevices.length" class="space-y-2">
						<button type="button" class="text-sm underline text-gray-600" @click="showClosed = !showClosed">
							{{ showClosed ? 'Ocultar' : 'Mostrar' }} recusados e revogados ({{ closedDevices.length }})
						</button>
						<div v-if="showClosed" class="space-y-2">
							<div v-for="device in closedDevices" :key="device.id" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-2">
								<div>
									<span class="text-xs font-semibold uppercase tracking-widest px-2 py-1 rounded mr-2"
										:class="statusBadgeClass(device.status)">{{ device.status }}</span>
									{{ device.label || describe(device) }}
									<span class="text-xs text-gray-500">
										— {{ describe(device) }}, <span class="font-mono">{{ device.ip_address || '—' }}</span><template v-if="device.requester">, solicitado por {{ device.requester.full_name }}</template>
									</span>
								</div>
								<button @click="approveDevice(device)" class="text-sm underline text-green-700">Aprovar de qualquer forma</button>
							</div>
						</div>
					</div>
				</template>

				<p class="text-xs text-gray-500">
					A revogação de um dispositivo remove imediatamente a confiança de acesso por PIN de todas as pessoas
					nele — ninguém poderá usar o PIN até que ele seja aprovado novamente. Dispositivos recusados ou revogados
					permanecem listados como registro de quem solicitou o acesso e de onde.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
