<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- CartonCodes.vue

	Carton Barcodes (/setup/carton-codes, manage-items) — review and remove the carton barcode -> item
	mappings sorters confirmed on the Sorting page ("New Carton Barcode"). A mapping is only ever
	created there; removing one here just means the next scan of that carton asks again. Panel-style
	page (see admin-page-style); data from GET /json/carton-codes, delete via DELETE /json/carton-codes/{id}.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';
import { computed, onMounted, ref } from 'vue';

defineProps({ breadcrumb: { type: Array } });

const records = ref(null);
const total = ref(0);
const search = ref('');
const error = ref(null);
const notice = ref(null);
const confirmingId = ref(null);
const busyId = ref(null);

function displayCode(code) {
	return code.startsWith('00') ? code.slice(2) : code.startsWith('0') ? code.slice(1) : code;
}

function contents(record) {
	if (record.inner_packs && record.items_per_pack) {
		return record.inner_packs + ' × ' + record.items_per_pack + ' = ' + record.qty_per_carton;
	}
	return String(record.qty_per_carton);
}

function dateOf(value) {
	const date = new Date(value);
	return isNaN(date) ? '' : date.toLocaleDateString('pt-BR');
}

const filtered = computed(() => {
	const text = search.value.trim().toLowerCase();
	if (!text) return records.value || [];
	return (records.value || []).filter((record) =>
		[record.code, record.item?.name, record.item?.upc, record.entered_by_name]
			.some((field) => field && String(field).toLowerCase().includes(text)));
});

async function load() {
	try {
		const response = await axios.get('/json/carton-codes');
		records.value = response.data.records;
		total.value = response.data.total;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar os códigos de barras das caixas.';
	}
}

async function remove(record) {
	error.value = null;
	notice.value = null;
	if (confirmingId.value !== record.id) {
		confirmingId.value = record.id; // first click arms it; the second removes
		return;
	}
	busyId.value = record.id;
	try {
		await axios.delete('/json/carton-codes/' + record.id);
		records.value = records.value.filter((entry) => entry.id !== record.id);
		total.value -= 1;
		notice.value = 'Caixa ' + displayCode(record.code) + ' removida. Na próxima leitura, será solicitado que você informe seu conteúdo.';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível remover esse código de barras da caixa.';
	} finally {
		busyId.value = null;
		confirmingId.value = null;
	}
}

onMounted(load);
</script>

<template>
	<Head title="Códigos de barras de caixas" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Códigos de barras de caixas</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">Caixas confirmadas</h2>

				<p v-if="records === null && !error" class="text-gray-500">Carregando códigos de barras das caixas&hellip;</p>

				<template v-else-if="records">
					<label class="block text-sm">
						<span class="text-gray-700">Buscar</span>
						<input v-model="search" type="text" placeholder="Código de barras, item ou pessoa que adicionou"
							class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>

					<p v-if="!records.length" class="text-gray-400">Nenhum registro ainda &mdash; eles são adicionados na página de triagem quando uma caixa é lida pela primeira vez.</p>
					<p v-else-if="!filtered.length" class="text-gray-400">Nenhuma caixa corresponde a essa busca.</p>

					<div v-else class="overflow-x-auto">
						<table class="w-full text-sm text-left">
							<thead class="text-gray-600 border-b">
								<tr>
									<th class="py-2 pr-3">Código de barras da caixa</th>
									<th class="py-2 pr-3">Contém</th>
									<th class="py-2 pr-3">Itens por caixa</th>
									<th class="py-2 pr-3">Adicionada em</th>
									<th class="py-2"></th>
								</tr>
							</thead>
							<tbody>
								<tr v-for="record in filtered" :key="record.id" class="border-b align-top">
									<td class="py-2 pr-3 font-mono">{{ displayCode(record.code) }}</td>
									<td class="py-2 pr-3">
										{{ record.item?.name }}
										<div v-if="record.item?.upc" class="text-xs text-gray-500 font-mono">{{ record.item.upc }}</div>
									</td>
									<td class="py-2 pr-3">{{ contents(record) }}</td>
									<td class="py-2 pr-3 text-gray-600">
										{{ dateOf(record.created_at) }}
										<div v-if="record.entered_by_name" class="text-xs text-gray-500">{{ record.entered_by_name }}</div>
									</td>
									<td class="py-2 text-right whitespace-nowrap">
										<template v-if="confirmingId === record.id">
											<button type="button" :disabled="busyId === record.id" @click="remove(record)"
												class="inline-flex items-center px-3 py-1.5 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500">
												{{ busyId === record.id ? 'Removendo…' : 'Confirmar remoção' }}
											</button>
											<button type="button" class="ml-2 text-xs underline text-gray-600" @click="confirmingId = null">Cancelar</button>
										</template>
										<button v-else type="button" @click="remove(record)"
											class="inline-flex items-center px-3 py-1.5 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-amber-600 hover:bg-amber-500">
											Remover
										</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>

					<p v-if="total > records.length" class="text-xs text-gray-500">Mostrando os {{ records.length }} registros mais recentes de {{ total }}.</p>
				</template>

				<p class="text-xs text-gray-500">
					Remover o código de barras de uma caixa não afeta nenhum item nem o que já foi triado. Na próxima leitura,
					a página de triagem solicitará novamente o conteúdo da caixa e as quantidades e salvará as novas informações.
					Para alterar um registro, remova-o e leia o código da caixa novamente.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
