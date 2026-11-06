<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- ThisDevice.vue

	PIN Login on This Device (profile menu; ThisDeviceController). Shows whether the device you're
	using is approved for PIN login, and lets you ask for it — with an optional station name and
	reason. Someone with manage-trusted-devices approves it right here; anyone else's request goes to
	Setup > PIN Login for an approver. The request records this device's IP address, browser and OS.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link } from '@inertiajs/vue3';
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

defineProps({
	breadcrumb: { type: Array },
});

const status = ref(null);
const error = ref(null);
const notice = ref(null);
const busy = ref(false);
const form = ref({ label: '', reason: '' });

const device = computed(() => status.value?.device);
// A request can be made (or re-made) unless the device is already approved.
const canAsk = computed(() => !device.value || device.value.status !== 'approved');

async function load() {
	try {
		status.value = (await axios.get('/json/this-device')).data;
		form.value.label = status.value.device?.label || '';
		form.value.reason = status.value.device?.status === 'pending' ? (status.value.device.request_reason || '') : '';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível verificar este dispositivo.';
	}
}

async function submit() {
	error.value = notice.value = null;
	busy.value = true;
	try {
		status.value = (await axios.post('/json/this-device', {
			label: form.value.label || null,
			reason: form.value.reason || null,
		})).data;
		notice.value = status.value.device.status === 'approved'
			? 'Este dispositivo está autorizado a entrar com PIN.'
			: 'Solicitação enviada. A administração poderá aprová-la ou recusá-la.';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível enviar a solicitação.';
	} finally {
		busy.value = false;
	}
}

function when(value) {
	return value ? new Date(value).toLocaleString() : '';
}

onMounted(load);
</script>

<template>
	<Head title="Acesso com PIN neste dispositivo" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-2xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Acesso com PIN neste dispositivo</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>
			<p v-if="!status && !error" class="text-gray-500">Verificando este dispositivo…</p>

			<template v-if="status">
				<section class="bg-white shadow rounded-lg p-6 space-y-3">
					<h2 class="text-lg font-semibold">Este dispositivo</h2>
					<div class="text-sm space-y-1">
						<div v-if="!device" class="text-gray-700">Não configurado para acesso com PIN.</div>
						<template v-else>
							<div>
								<span class="font-semibold">{{ device.label || 'Estação sem nome' }}</span> —
								<span v-if="device.status === 'approved'" class="text-green-700 font-semibold">aprovado</span>
								<span v-else-if="device.status === 'pending'" class="text-amber-700 font-semibold">aguardando aprovação</span>
								<span v-else-if="device.status === 'denied'" class="text-red-700 font-semibold">solicitação recusada</span>
								<span v-else class="text-gray-600 font-semibold">revogado</span>
							</div>
							<div v-if="device.status === 'pending'" class="text-gray-600">
								Solicitado em {{ when(device.requested_at) }}<template v-if="device.requester"> por {{ device.requester }}</template>.
							</div>
							<div v-if="device.status === 'approved' && device.approver" class="text-gray-600">
								Aprovado por {{ device.approver }} em {{ when(device.approved_at) }}.
							</div>
						</template>
						<div class="text-xs text-gray-500 pt-1">
							{{ [status.detected.browser, status.detected.os].filter(Boolean).join(' em ') || 'Navegador desconhecido' }}
							· Endereço IP <span class="font-mono">{{ status.detected.ip_address }}</span>
						</div>
					</div>

					<p v-if="!status.pin_login_enabled" class="text-sm text-amber-800 bg-amber-50 border border-amber-200 rounded px-3 py-2">
						O acesso com PIN está desativado em todo o sistema. Ainda é possível aprovar um dispositivo,
						mas o acesso com PIN não será oferecido até que a administração o ative.
					</p>
					<p v-if="device?.status === 'approved' && !status.has_pin" class="text-sm text-gray-700">
						Para usar esta opção, defina um PIN no seu <Link :href="route('profile.edit')" class="text-blue-600 underline">Perfil</Link>.
					</p>
				</section>

				<section v-if="canAsk" class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">
						{{ status.can_approve ? 'Aprovar este dispositivo' : (device?.status === 'pending' ? 'Atualizar sua solicitação' : 'Solicitar acesso com PIN aqui') }}
					</h2>
					<p class="text-sm text-gray-700">
						<template v-if="status.can_approve">Você pode aprovar dispositivos, então a alteração terá efeito imediatamente.</template>
						<template v-else>A administração verá sua solicitação em Configuração &gt; Acesso com PIN e poderá aprová-la ou recusá-la.</template>
						Os dois campos são opcionais.
					</p>
					<form class="space-y-4 text-sm" @submit.prevent="submit">
						<label class="block">
							<span class="text-gray-700">Nome da estação</span>
							<input v-model="form.label" maxlength="255" placeholder="ex.: Estação de triagem 1"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Motivo</span>
							<textarea v-model="form.reason" rows="2" maxlength="1000" placeholder="ex.: tablet compartilhado nas mesas de triagem"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm"></textarea>
						</label>
						<PrimaryButton :disabled="busy">
							{{ busy ? 'Enviando…' : (status.can_approve ? 'Aprovar este dispositivo' : (device?.status === 'pending' ? 'Atualizar solicitação' : 'Solicitar acesso com PIN')) }}
						</PrimaryButton>
					</form>
					<p class="text-xs text-gray-500">
						O endereço IP, o navegador e o sistema operacional exibidos acima serão registrados para que a
						administração saiba qual dispositivo fez a solicitação.
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
