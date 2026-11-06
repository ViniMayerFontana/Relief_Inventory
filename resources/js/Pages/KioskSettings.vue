<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- KioskSettings.vue

	Admin settings for the volunteer kiosk (permission: admin-system):
	locations (each with its own header name + optional welcome banner),
	per-location Guest-type lists (sign_in_categories), global Agency/Task
	type-ahead suggestion lists, and the idle-reset timeout. Panel-style
	page per the admin-page-style skill/SystemAdmin.vue convention — not
	built on RIForm, since these are small admin lists + a settings form,
	not a single CRUD resource.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { onMounted, reactive, ref } from 'vue';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

const error = ref('');
const notice = ref('');

// ---- Locations ----
const locations = ref([]);
const newLocation = reactive({ name: '', welcome_message: '' });
const savingLocationId = ref(null);
const locationSavedAt = reactive({});
const addingLocation = ref(false);

async function fetchLocations() {
	const response = await axios.get('/json/kiosk-locations');
	locations.value = response.data.records;
	if (!selectedLocationId.value && locations.value.length) {
		selectedLocationId.value = locations.value[0].id;
	}
}

async function addLocation() {
	if (!newLocation.name.trim()) return;
	addingLocation.value = true;
	error.value = '';
	try {
		const response = await axios.post('/json/kiosk-locations', newLocation);
		locations.value.push(response.data.record);
		newLocation.name = '';
		newLocation.welcome_message = '';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível adicionar esse local.';
	} finally {
		addingLocation.value = false;
	}
}

async function saveLocation(location) {
	savingLocationId.value = location.id;
	error.value = '';
	try {
		const response = await axios.put(`/json/kiosk-locations/${location.id}`, location);
		Object.assign(location, response.data.record);
		locationSavedAt[location.id] = new Date();
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível salvar esse local.';
	} finally {
		savingLocationId.value = null;
	}
}

// ---- Guest types (per location) ----
const selectedLocationId = ref(null);
const guestTypes = ref([]);
const newGuestType = ref('');
const addingGuestType = ref(false);

async function fetchGuestTypes() {
	if (!selectedLocationId.value) {
		guestTypes.value = [];
		return;
	}
	const response = await axios.get(`/json/kiosk-locations/${selectedLocationId.value}/sign-in-categories`);
	guestTypes.value = response.data.records;
}

async function addGuestType() {
	if (!newGuestType.value.trim() || !selectedLocationId.value) return;
	addingGuestType.value = true;
	error.value = '';
	try {
		const response = await axios.post('/json/sign-in-categories', {
			kiosk_location_id: selectedLocationId.value,
			name: newGuestType.value,
		});
		guestTypes.value.push(response.data.record);
		newGuestType.value = '';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível adicionar esse tipo de visitante.';
	} finally {
		addingGuestType.value = false;
	}
}

// ---- Agency / Task suggestions ----
const agencySuggestions = ref([]);
const taskSuggestions = ref([]);
const newAgencySuggestion = ref('');
const newTaskSuggestion = ref('');
const addingAgencySuggestion = ref(false);
const addingTaskSuggestion = ref(false);

async function fetchSuggestions() {
	const [agencyResponse, taskResponse] = await Promise.all([
		axios.get('/json/kiosk-suggestions', { params: { kind: 'agency' } }),
		axios.get('/json/kiosk-suggestions', { params: { kind: 'task' } }),
	]);
	agencySuggestions.value = agencyResponse.data.records;
	taskSuggestions.value = taskResponse.data.records;
}

async function addSuggestion(kind) {
	const value = kind === 'agency' ? newAgencySuggestion.value : newTaskSuggestion.value;
	if (!value.trim()) return;
	const addingFlag = kind === 'agency' ? addingAgencySuggestion : addingTaskSuggestion;
	addingFlag.value = true;
	error.value = '';
	try {
		const response = await axios.post('/json/kiosk-suggestions', { kind, value });
		if (kind === 'agency') {
			agencySuggestions.value.push(response.data.record);
			newAgencySuggestion.value = '';
		} else {
			taskSuggestions.value.push(response.data.record);
			newTaskSuggestion.value = '';
		}
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível adicionar essa sugestão.';
	} finally {
		addingFlag.value = false;
	}
}

// ---- Kiosk behavior ----
const kioskSettings = reactive({ idle_reset_minutes: null });
const savingBehavior = ref(false);
const behaviorSavedAt = ref(null);

async function fetchKioskSettings() {
	const response = await axios.get('/json/kiosk-settings');
	Object.assign(kioskSettings, response.data.settings);
}

async function saveKioskSettings() {
	savingBehavior.value = true;
	error.value = '';
	try {
		const response = await axios.put('/json/kiosk-settings', kioskSettings);
		Object.assign(kioskSettings, response.data.settings);
		behaviorSavedAt.value = new Date();
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível salvar as configurações de comportamento do quiosque.';
	} finally {
		savingBehavior.value = false;
	}
}

onMounted(async () => {
	try {
		await fetchLocations();
		await fetchGuestTypes();
		await fetchSuggestions();
		await fetchKioskSettings();
	} catch (e) {
		error.value = 'Não foi possível carregar as configurações do quiosque.';
	}
});
</script>

<template>
	<Head title="Configurações do quiosque" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Configurações do quiosque</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<!-- Locations -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Locais</h2>
				<div v-for="location in locations" :key="location.id" class="border rounded p-3 space-y-2">
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">Nome do local</span>
							<input type="text" maxlength="255" v-model="location.name" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Mensagem de boas-vindas (opcional)</span>
							<input type="text" maxlength="255" v-model="location.welcome_message" placeholder="Exibida somente se preenchida" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</div>
					<label class="flex items-center gap-2 text-sm">
						<input type="checkbox" v-model="location.active" />
						<span class="text-gray-700">Ativo</span>
					</label>
					<div class="flex gap-3 items-center">
						<PrimaryButton :disabled="savingLocationId === location.id" @click="saveLocation(location)">
							{{ savingLocationId === location.id ? 'Salvando…' : 'Salvar' }}
						</PrimaryButton>
						<span v-if="locationSavedAt[location.id]" class="text-sm text-green-700">Salvo {{ locationSavedAt[location.id].toLocaleTimeString() }}</span>
					</div>
				</div>

				<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">Nome do novo local</span>
						<input type="text" maxlength="255" v-model="newLocation.name" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label class="block">
						<span class="text-gray-700">Mensagem de boas-vindas (opcional)</span>
						<input type="text" maxlength="255" v-model="newLocation.welcome_message" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
				</div>
				<PrimaryButton :disabled="addingLocation" @click="addLocation">
					{{ addingLocation ? 'Adicionando…' : 'Adicionar local' }}
				</PrimaryButton>
				<p class="text-xs text-gray-500">
					Cada dispositivo de quiosque recebe um local quando o modo quiosque é ativado e exibe
					o nome desse local (e a mensagem de boas-vindas, se houver) na tela de entrada.
				</p>
			</section>

			<!-- Guest Types -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Tipos de visitante</h2>
				<label v-if="locations.length > 1" class="block text-sm">
					<span class="text-gray-700">Local</span>
					<select v-model.number="selectedLocationId" @change="fetchGuestTypes" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
						<option v-for="location in locations" :key="location.id" :value="location.id">{{ location.name }}</option>
					</select>
				</label>
				<ul class="text-sm space-y-1">
					<li v-for="type in guestTypes" :key="type.id" class="text-gray-700">{{ type.name }}</li>
					<li v-if="!guestTypes.length" class="text-gray-400">Nenhum ainda</li>
				</ul>
				<div class="flex gap-3 items-center">
					<input type="text" maxlength="255" v-model="newGuestType" placeholder="ex.: Manutenção/reparo" class="block w-full border-gray-300 rounded-md shadow-sm text-sm" />
					<PrimaryButton :disabled="addingGuestType" @click="addGuestType">
						{{ addingGuestType ? 'Adicionando…' : 'Adicionar' }}
					</PrimaryButton>
				</div>
				<p class="text-xs text-gray-500">
					Sempre oferecidos junto com a opção de texto livre "Outro" na tela de entrada de visitantes do quiosque —
					esta lista contém as sugestões exibidas primeiro em cada local.
				</p>
			</section>

			<!-- Suggestions -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Sugestões</h2>
				<div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
					<div class="space-y-2">
						<h3 class="font-medium text-sm">Entidade</h3>
						<ul class="text-sm space-y-1">
							<li v-for="s in agencySuggestions" :key="s.id" class="text-gray-700">{{ s.value }}</li>
							<li v-if="!agencySuggestions.length" class="text-gray-400">Nenhuma ainda</li>
						</ul>
						<div class="flex gap-2 items-center">
							<input type="text" maxlength="255" v-model="newAgencySuggestion" placeholder="ex.: Cruz Vermelha Brasileira" class="block w-full border-gray-300 rounded-md shadow-sm text-sm" />
							<PrimaryButton :disabled="addingAgencySuggestion" @click="addSuggestion('agency')">Adicionar</PrimaryButton>
						</div>
					</div>
					<div class="space-y-2">
						<h3 class="font-medium text-sm">Tarefa</h3>
						<ul class="text-sm space-y-1">
							<li v-for="s in taskSuggestions" :key="s.id" class="text-gray-700">{{ s.value }}</li>
							<li v-if="!taskSuggestions.length" class="text-gray-400">Nenhuma ainda</li>
						</ul>
						<div class="flex gap-2 items-center">
							<input type="text" maxlength="255" v-model="newTaskSuggestion" placeholder="ex.: Operador de empilhadeira" class="block w-full border-gray-300 rounded-md shadow-sm text-sm" />
							<PrimaryButton :disabled="addingTaskSuggestion" @click="addSuggestion('task')">Adicionar</PrimaryButton>
						</div>
					</div>
				</div>
				<p class="text-xs text-gray-500">
					Exibidas como sugestões nos campos Entidade e Cargo/Função do quiosque — ambos
					continuam aceitando texto livre; as sugestões apenas agilizam os registros frequentes.
				</p>
			</section>

			<!-- Kiosk Behavior -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Comportamento do quiosque</h2>
				<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">Reiniciar após inatividade (minutos)</span>
						<input type="number" min="1" max="1440" v-model.number="kioskSettings.idle_reset_minutes" placeholder="Nunca" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
				</div>
				<div class="flex gap-3 items-center">
					<PrimaryButton :disabled="savingBehavior" @click="saveKioskSettings">
						{{ savingBehavior ? 'Salvando…' : 'Salvar' }}
					</PrimaryButton>
					<span v-if="behaviorSavedAt" class="text-sm text-green-700">Salvo {{ behaviorSavedAt.toLocaleTimeString() }}</span>
				</div>
				<p class="text-xs text-gray-500">
					Por quanto tempo a tela do quiosque pode ficar inativa antes de voltar à tela de boas-vindas e busca. Deixe
					em branco para nunca reiniciar automaticamente.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
