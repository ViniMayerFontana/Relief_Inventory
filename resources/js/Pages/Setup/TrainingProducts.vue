<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Setup/TrainingProducts.vue

	Setup > Training Warehouse > Scan Training Products (TrainingProductController, manage-training): the trainer scans
	the real goods that start out "already in the warehouse" — Stations 3–5 (sorting area, table-spot trays, loads to
	ship) — one unit per scan. Receiving's goods are the trainer's own and are not scanned. A barcode the catalog already knows just counts; an
	unknown one opens the shared Add New Item box (NewItemModal) and counts once saved. The list is not stock —
	Prepare Training spreads it over the stations (App\Services\TrainingPreparer) and the progress line shows how
	many items that needs. The scan bar keeps focus (see SCANNING_INTERFACE_NOTES.md).
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import NewItemModal from '@/Components/NewItemModal.vue';
import ScanButton from '@/Components/ScanButton.vue';
import SearchSelect from '@/Components/SearchSelect.vue';
import { Head, Link } from '@inertiajs/vue3';
import { ref, computed, nextTick, onMounted, onBeforeUnmount } from 'vue';
import axios from 'axios';
import { playScanCarton, playScanError, playScanMatched, playScanUnknown, scanSoundsEnabled, setScanSoundsEnabled } from '@/scanSounds';

defineProps({
	breadcrumb: { type: Array },
});

const STATION_NAMES = { 1: 'Recebimento', 2: 'Triagem', 3: 'Estoque', 4: 'Separação', 5: 'Expedição', 6: 'Entrega / Pedidos' };

const data = ref(null);
const error = ref(null);
const scanText = ref('');
const scanInput = ref(null);
const scanMessage = ref(null);
const busy = ref(false);
const sounds = ref(scanSoundsEnabled());
const lastId = ref(null);
const modalInit = ref(null);
const manual = ref({ item_id: null, qty: 1 });
const manualSelect = ref(null);
const confirmingClear = ref(false);

const plan = computed(() => data.value?.plan);
const percent = computed(() => (plan.value ? Math.min(100, Math.round((data.value.units / plan.value.target) * 100)) : 0));

async function load() {
	try {
		data.value = (await axios.get('/json/training/products')).data;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar a lista de produtos.';
	}
}

function focusScan() {
	nextTick(() => scanInput.value?.focus());
}

// After any click, put focus back on the scan bar — unless they are typing in a field or the Add New Item box is open.
function onPageClick() {
	setTimeout(() => {
		if (modalInit.value) return;
		const el = document.activeElement;
		if (el === scanInput.value || ['INPUT', 'TEXTAREA', 'SELECT'].includes(el?.tagName)) return;
		scanInput.value?.focus();
	}, 0);
}

function counted(name, added, total) {
	scanMessage.value = { ok: true, text: `Contabilizado: ${name}${added > 1 ? ' (+' + added + ')' : ''} — total escaneado: ${total}.` };
}

async function submitScan() {
	const code = scanText.value.trim();
	scanText.value = '';
	if (!code || busy.value) return;
	error.value = null;
	busy.value = true;
	try {
		const response = (await axios.post('/json/training/products/scan', { code })).data;
		const scan = response.scan;
		if (scan.status === 'matched') {
			data.value = response;
			lastId.value = response.product_id;
			const record = response.records.find((r) => r.id === response.product_id);
			counted(record?.name || 'item', scan.qty || 1, record?.qty);
			scan.kind === 'carton' ? playScanCarton() : playScanMatched();
		} else if (scan.kind === 'carton') {
			playScanUnknown();
			scanMessage.value = { ok: false, text: 'Este é o código de barras de uma caixa que o sistema ainda não reconhece. Escaneie um dos itens avulsos que estão dentro e conte os demais usando Adicionar manualmente abaixo.' };
		} else {
			playScanUnknown();
			scanMessage.value = { ok: false, text: 'Novo código de barras — adicione o item para contabilizá-lo.' };
			modalInit.value = { scan: { code: scan.code, online: scan.online, suggestion: scan.suggestion } };
		}
	} catch (e) {
		playScanError();
		scanMessage.value = { ok: false, text: e.response?.data?.message || 'Não foi possível consultar esse código de barras.' };
	} finally {
		busy.value = false;
		if (!modalInit.value) focusScan();
	}
}

async function addItem(itemId, qty) {
	const response = (await axios.post('/json/training/products', { item_id: itemId, qty })).data;
	data.value = response;
	lastId.value = response.product_id;
	const record = response.records.find((r) => r.id === response.product_id);
	counted(record?.name || 'item', qty, record?.qty);
}

async function onItemSaved(item) {
	modalInit.value = null;
	try {
		await addItem(item.id, 1);
		playScanMatched();
	} catch (e) {
		error.value = e.response?.data?.message || 'O item foi adicionado, mas não foi possível contabilizá-lo. Escaneie-o novamente.';
	}
	focusScan();
}

function onModalClose() {
	modalInit.value = null;
	scanMessage.value = null;
	focusScan();
}

async function addManual() {
	if (!manual.value.item_id) return;
	error.value = null;
	try {
		await addItem(manual.value.item_id, Math.max(1, parseInt(manual.value.qty, 10) || 1));
		manual.value = { item_id: null, qty: 1 };
		manualSelect.value?.clearSelection?.();
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível adicionar esse item.';
	}
	focusScan();
}

async function setQty(record, value) {
	const qty = Math.max(0, parseInt(value, 10) || 0);
	if (qty === record.qty) return;
	error.value = null;
	try {
		data.value = (await axios.patch('/json/training/products/' + record.id, { qty })).data;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível alterar essa quantidade.';
	}
}

async function remove(record) {
	error.value = null;
	try {
		data.value = (await axios.delete('/json/training/products/' + record.id)).data;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível remover esse produto.';
	}
	focusScan();
}

async function clearAll() {
	if (!confirmingClear.value) {
		confirmingClear.value = true;
		return;
	}
	confirmingClear.value = false;
	try {
		data.value = (await axios.delete('/json/training/products')).data;
		scanMessage.value = null;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível limpar a lista.';
	}
	focusScan();
}

function toggleSounds() {
	sounds.value = !sounds.value;
	setScanSoundsEnabled(sounds.value);
	if (sounds.value) playScanMatched();
	focusScan();
}

onMounted(async () => {
	await load();
	focusScan();
	document.addEventListener('click', onPageClick);
});
onBeforeUnmount(() => document.removeEventListener('click', onPageClick));
</script>

<template>
	<Head title="Escanear produtos para treinamento" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<div class="flex flex-wrap items-center justify-between gap-2">
				<h1 class="text-2xl font-bold">Escanear produtos para treinamento</h1>
				<Link href="/setup/training" class="ri_formbutton">Voltar ao armazém de treinamento</Link>
			</div>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<p v-if="!data && !error" class="text-gray-500">Carregando…</p>

			<template v-if="data">
				<!-- ======================= PROGRESS ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-3">
					<p class="text-sm text-gray-700">
						Escaneie os produtos que já estarão no armazém — na mesa da área de triagem, nas bandejas dos espaços de mesa e nas cargas
						aguardando expedição (estações 3 a 5) — um por vez; cada leitura conta um item.
						Escaneie uma variedade: pelo menos <strong>{{ plan.min_products }} produtos diferentes</strong>. Os produtos do
						Recebimento não são escaneados aqui: disponha-os você mesmo para que as equipes os recebam e façam a triagem. A preparação
						do treinamento define onde cada item escaneado ficará, e o pacote de configuração inicial informa onde colocar cada
						um. Os itens escaneados aqui não fazem parte do estoque até a preparação do treinamento.
					</p>
					<div class="flex flex-wrap items-baseline gap-x-6 gap-y-1">
						<div><span class="text-3xl font-bold">{{ data.units }}</span> <span class="text-gray-600">de {{ plan.target }} itens</span></div>
						<div><span class="text-3xl font-bold">{{ data.distinct }}</span> <span class="text-gray-600">de {{ plan.min_products }} produtos diferentes</span></div>
					</div>
					<div class="h-3 bg-gray-200 rounded">
						<div class="h-3 rounded" :class="data.units >= plan.target ? 'bg-green-600' : 'bg-blue-600'" :style="{ width: percent + '%' }"></div>
					</div>
					<table class="ri_datatable w-full text-sm" border="1">
						<thead><tr><th>Estação</th><th>Itens necessários</th></tr></thead>
						<tbody>
							<tr v-for="(n, station) in plan.stations" :key="station">
								<td>{{ station }} {{ STATION_NAMES[station] }}</td>
								<td>{{ n }}</td>
							</tr>
						</tbody>
					</table>
					<p class="text-xs text-gray-500">
						A preparação do treinamento precisa de pelo menos {{ plan.target }} itens. Você pode escanear mais: o excedente vai para
						as bandejas da estação 4, aumentando a quantidade disponível para separação.
					</p>
				</section>

				<!-- ======================= SCAN ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-3">
					<div class="flex flex-wrap items-center gap-2">
						<input ref="scanInput" v-model="scanText" type="text" autocomplete="off" inputmode="numeric"
							class="ri_forminput flex-1 min-w-[14rem] text-lg" placeholder="Escaneie o código de barras de um item"
							@keydown.enter.prevent="submitScan" />
						<button type="button" class="ri_defaultbutton" :disabled="busy" @click="submitScan">Contar</button>
						<ScanButton :target="() => scanInput" />
						<button type="button" class="ri_formbutton" @click="toggleSounds"
							:title="sounds ? 'Sons de leitura ativados. Clique para silenciar.' : 'Sons de leitura desativados. Clique para ativar.'">{{ sounds ? '🔊' : '🔇' }}</button>
					</div>
					<p v-if="scanMessage" :class="scanMessage.ok ? 'text-green-700 font-semibold' : 'text-amber-700 font-semibold'">{{ scanMessage.text }}</p>

					<details class="text-sm">
						<summary class="cursor-pointer text-gray-700">Adicionar manualmente (sem código de barras ou vários iguais de uma vez)</summary>
						<div class="flex flex-wrap items-center gap-2 mt-2">
							<div class="flex-1 min-w-[16rem]">
								<SearchSelect ref="manualSelect" v-model="manual.item_id" optionsource="/json/items" display="name"
									:searchfields="['name', 'upc']" placeholder="Buscar itens…" />
							</div>
							<input v-model="manual.qty" type="number" min="1" class="ri_forminput w-20" />
							<button type="button" class="ri_defaultbutton" :disabled="!manual.item_id" @click="addManual">Adicionar</button>
						</div>
					</details>
				</section>

				<!-- ======================= LIST ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-3">
					<div class="flex flex-wrap items-center justify-between gap-2">
						<h2 class="text-lg font-semibold">Produtos escaneados</h2>
						<div v-if="data.records.length" class="flex items-center gap-2">
							<button type="button" class="ri_formbutton" :class="{ 'text-red-700': confirmingClear }" @click="clearAll">
								{{ confirmingClear ? 'Confirmar — limpar a lista inteira' : 'Limpar lista' }}
							</button>
							<button v-if="confirmingClear" type="button" class="text-sm underline" @click="confirmingClear = false">Cancelar</button>
						</div>
					</div>
					<p v-if="!data.records.length" class="text-sm text-gray-400">Nada escaneado ainda.</p>
					<table v-else class="ri_datatable w-full text-sm" border="1">
						<thead><tr><th>Produto</th><th>Tipo de item ACS</th><th>UPC</th><th>Quantidade</th><th></th></tr></thead>
						<tbody>
							<tr v-for="r in data.records" :key="r.id" :class="{ 'bg-green-50': r.id === lastId }">
								<td>{{ r.name }}</td>
								<td>{{ r.number }} {{ r.type }}</td>
								<td class="font-mono text-xs">{{ r.upc }}</td>
								<td><input type="number" min="0" :value="r.qty" class="ri_forminput w-20" @change="setQty(r, $event.target.value)" /></td>
								<td><button type="button" class="text-sm underline" @click="remove(r)">Remover</button></td>
							</tr>
						</tbody>
					</table>
					<p class="text-xs text-gray-500">
						Remover um produto daqui apenas o tira desta lista; o item continua na lista principal de itens.
					</p>
				</section>
			</template>
		</div>

		<NewItemModal v-if="modalInit" :initial="modalInit" :allow-carton="false" @saved="onItemSaved" @close="onModalClose" />
	</AuthenticatedLayout>
</template>
