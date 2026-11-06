<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- PalletLocation.vue (/inventory-movement)
     One scan-driven "Pallets" screen plus two look-up tabs (Locations, Recent Movements). A scan bar that is always
     focused on the Pallets tab takes a pallet barcode (shows where it is, what is on it, its history, and lets you
     move it / change its status / add items to it), or — once a pallet is showing — a location barcode, which records
     the move straight away. With no pallet showing, the same screen builds a new Warehouse pallet from the sorting
     area. Writes go to POST /json/palletstatus (append-only history) and POST /json/pallet-stock/fill.
     See SCANNING_INTERFACE_NOTES.md for the scanner conventions followed here. -->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head } from '@inertiajs/vue3';
import { computed, nextTick, onMounted, ref } from 'vue';
import axios from 'axios';
import PrintMenu from '@/Components/PrintMenu.vue';
import SearchSelect from '@/Components/SearchSelect.vue';
import ScanButton from '@/Components/ScanButton.vue';
import { playScanError, playScanMatched, scanSoundsEnabled, setScanSoundsEnabled } from '@/scanSounds';
import { palletStatusLabel } from '@/labels';

const props = defineProps({
	breadcrumb: { type: Array },
	canAdjust: { type: Boolean, default: false }, // the adjust-inventory permission
});

const tab = ref('pallet'); // 'pallet' (scan-driven, the default) | 'locations' | 'recent'

// ---------- locations summary ----------
const summary = ref(null);
const summaryError = ref(null);

async function loadSummary() {
	summaryError.value = null;
	try {
		summary.value = (await axios.get('/json/palletstatus/summary')).data;
	} catch (e) {
		summaryError.value = e.response?.data?.message || 'Não foi possível carregar os locais.';
	}
}

const statusColumns = computed(() => {
	const seen = new Set();
	const add = (b) => Object.keys(b?.by_status || {}).forEach((s) => seen.add(s));
	(summary.value?.locations || []).forEach(add);
	add(summary.value?.no_location);
	add(summary.value?.other_locations);
	return [...seen].sort();
});

// One flat list of table rows: each real location, then the "no location"/"archived" buckets when non-empty.
const locationRows = computed(() => {
	const rows = (summary.value?.locations || []).map((l) => ({ key: l.id, label: l.code, total: l.total, by_status: l.by_status || {}, zero: !l.total }));
	const s = summary.value;
	if (s?.no_location?.total) rows.push({ key: 'none', label: 'Nenhum local registrado', total: s.no_location.total, by_status: s.no_location.by_status || {}, special: true });
	if (s?.other_locations?.total) rows.push({ key: 'other', label: 'Arquivados / outros locais', total: s.other_locations.total, by_status: s.other_locations.by_status || {}, special: true });
	return rows;
});

const locationCodes = computed(() => (summary.value?.locations || []).map((l) => l.code));

function locationByCode(code) {
	const wanted = (code || '').trim().toLowerCase();
	return (summary.value?.locations || []).find((l) => l.code.toLowerCase() === wanted) || null;
}

// ---------- location drill-down ----------
const openLocation = ref(null); // { key, label, pallets|null, error }

async function toggleLocation(key, label) {
	if (openLocation.value?.key === key) {
		openLocation.value = null;
		return;
	}
	openLocation.value = { key, label, pallets: null, error: null };
	try {
		const pallets = (await axios.get(`/json/palletstatus/location/${key}`)).data.records;
		if (openLocation.value?.key === key) openLocation.value.pallets = pallets;
	} catch (e) {
		if (openLocation.value?.key === key) openLocation.value.error = e.response?.data?.message || 'Não foi possível carregar os paletes.';
	}
}

// ---------- the scan bar and the pallet on screen ----------
const scanInput = ref(null);
const scanText = ref('');
const scanMessage = ref(null); // { text, ok }
const scannedLabelId = ref(null); // the inventory label row to highlight, when the last scan was one
const sounds = ref(scanSoundsEnabled());
const current = ref(null); // the looked-up pallet being shown
const history = ref([]);

function toggleSounds() {
	sounds.value = !sounds.value;
	setScanSoundsEnabled(sounds.value);
	if (sounds.value) playScanMatched();
}

async function lookupPallet(tag) {
	const response = await axios.get('/json/palletstatus/lookup', { params: { tag } });
	return response.data.record;
}

function focusScan() {
	nextTick(() => scanInput.value?.focus());
}

// After any click, put focus back on the scan bar — unless they are typing in a field.
function onPageClick() {
	if (tab.value !== 'pallet') return;
	setTimeout(() => {
		const el = document.activeElement;
		if (el === scanInput.value || ['INPUT', 'TEXTAREA', 'SELECT'].includes(el?.tagName)) return;
		scanInput.value?.focus();
	}, 0);
}

async function submitScan() {
	const value = scanText.value.trim();
	scanText.value = '';
	if (value) await handleScan(value);
	focusScan();
}

// A scan (or typed tag): a location code when a pallet is showing, otherwise a pallet.
async function handleScan(value) {
	scanMessage.value = null;
	fillError.value = null;
	fillResult.value = null;
	if (current.value && locationByCode(value)) {
		await quickMove(locationByCode(value));
		return;
	}
	await showPallet(value);
}

async function showPallet(tag) {
	try {
		const pallet = await lookupPallet(tag);
		await applyPallet(pallet);
		scannedLabelId.value = pallet.scanned_label?.id ?? null;
		if (pallet.scanned_label) {
			scanMessage.value = { ok: true, text: `Etiqueta de estoque: ${pallet.scanned_label.name} (${pallet.scanned_label.qty} adicionados) está no palete ${pallet.tag}.` };
		}
		playScanMatched();
	} catch (e) {
		scanMessage.value = { ok: false, text: e.response?.data?.message || 'Não foi possível localizar esse palete.' };
		playScanError();
	}
}

let lastShownTag = null;

async function applyPallet(pallet) {
	const samePallet = lastShownTag === pallet.tag;
	current.value = pallet;
	move.value = { locationCode: pallet.location?.code || '', status: pallet.status, notes: '' };
	fill.value.locationCode = pallet.location?.code || '';
	fill.value.expires = null;
	if (!samePallet) {
		mode.value = 'add';
		adj.value = { rows: [], reason: '', notes: '' };
	}
	lastShownTag = pallet.tag;
	history.value = [];
	try {
		history.value = (await axios.get('/json/palletstatus', { params: { pallet_id: pallet.id, limit: 20 } })).data.records;
	} catch (e) {
		// history is secondary; the pallet itself is already showing
	}
}

function clearPallet() {
	current.value = null;
	scannedLabelId.value = null;
	lastShownTag = null;
	mode.value = 'add';
	history.value = [];
	fill.value.locationCode = '';
	fill.value.expires = null;
	scanMessage.value = null;
	focusScan();
}

// ---------- move / change status ----------
const move = ref({ locationCode: '', status: '', notes: '' });
const saving = ref(false);

const chosenLocation = computed(() => locationByCode(move.value.locationCode));
const unknownLocationText = computed(() => move.value.locationCode.trim() !== '' && !chosenLocation.value);
const locationChanged = computed(() => {
	const pallet = current.value;
	if (!pallet) return false;
	return (chosenLocation.value?.id ?? null) !== (pallet.location_id ?? null) && move.value.locationCode.trim() !== '';
});
const saveLabel = computed(() => (locationChanged.value ? 'Registrar movimentação' : 'Registrar status'));

async function postStatus(pallet, locationId, status, notes) {
	await axios.post('/json/palletstatus', {
		pallet_id: pallet.id,
		location_id: locationId ?? pallet.location_id ?? null,
		status,
		notes: notes || null,
	});
	loadSummary();
	recent.value = null;
}

function errorText(e, fallback) {
	const errors = e.response?.data?.errors;
	return (errors && Object.values(errors).flat().join(' ')) || e.response?.data?.message || fallback;
}

async function recordMovement() {
	const pallet = current.value;
	if (!pallet) return;
	if (unknownLocationText.value) {
		scanMessage.value = { ok: false, text: `"${move.value.locationCode}" não é um local ativo conhecido.` };
		return;
	}
	saving.value = true;
	scanMessage.value = null;
	try {
		await postStatus(pallet, chosenLocation.value?.id, move.value.status, move.value.notes);
		scanMessage.value = { ok: true, text: `${pallet.tag}: ${locationChanged.value ? 'movido para ' + move.value.locationCode : 'situação registrada como ' + palletStatusLabel(move.value.status)}.` };
		await applyPallet(await lookupPallet(pallet.tag));
	} catch (e) {
		scanMessage.value = { ok: false, text: errorText(e, 'Não foi possível salvar.') };
		playScanError();
	} finally {
		saving.value = false;
		focusScan();
	}
}

// Scanning a location while a pallet is showing records the move immediately, keeping its status.
async function quickMove(location) {
	const pallet = current.value;
	if (location.id === pallet.location_id) {
		scanMessage.value = { ok: true, text: `${pallet.tag} já está em ${location.code}.` };
		playScanMatched();
		return;
	}
	try {
		await postStatus(pallet, location.id, pallet.status, null);
		playScanMatched();
		scanMessage.value = { ok: true, text: `${pallet.tag}: movido para ${location.code}.` };
		await applyPallet(await lookupPallet(pallet.tag));
	} catch (e) {
		scanMessage.value = { ok: false, text: errorText(e, 'Não foi possível registrar a movimentação.') };
		playScanError();
	}
}

// ---------- fill a warehouse pallet (leaving the sorting area) ----------
const staging = ref(null); // what's still in the sorting area, i.e. on hand but not on a pallet
// expires: null = use the suggestion (earliest date among the chosen items and what's already on the pallet);
// '' = the driver cleared it (no date); a date = the driver's own entry.
const fill = ref({ lines: [], locationCode: '', notes: '', expires: null });
const fillError = ref(null);
const fillResult = ref(null);
const fillResultBox = ref(null);
const filling = ref(false);

// item_id -> its item type, so SKUs of one ACS item type can be shown together. Best effort: without
// it (no permission, request failed) every SKU just shows as its own row.
const itemTypes = ref({});

async function loadItemTypes() {
	if (Object.keys(itemTypes.value).length) return;
	try {
		const records = (await axios.get('/json/items')).data.records;
		itemTypes.value = Object.fromEntries(
			records.filter((i) => i.itemtype).map((i) => [i.id, { id: i.itemtype.id, number: i.itemtype.display_number, name: i.itemtype.name }]),
		);
	} catch (e) {
		// leave ungrouped
	}
}

async function loadStaging() {
	try {
		const [records] = await Promise.all([axios.get('/json/pallet-stock/staging').then((r) => r.data.records), loadItemTypes()]);
		staging.value = records;
	} catch (e) {
		fillError.value = e.response?.data?.message || 'Não foi possível carregar a lista da área de triagem.';
	}
}

const stagingLeft = computed(() =>
	(staging.value || [])
		.map((row) => ({ ...row, left: row.qty - fill.value.lines.filter((l) => l.item_id === row.item_id).reduce((n, l) => n + (Number(l.qty) || 0), 0) }))
		.filter((row) => row.left > 0),
);

// Sorting-area rows grouped by item type (one group per ACS number); a type with a single SKU stays a plain row.
const stagingGroups = computed(() => {
	const groups = new Map();
	for (const row of stagingLeft.value) {
		const type = itemTypes.value[row.item_id];
		const key = type ? `t${type.id}` : `i${row.item_id}`;
		if (!groups.has(key)) groups.set(key, { key, type, rows: [], left: 0 });
		const g = groups.get(key);
		g.rows.push(row);
		g.left += row.left;
	}
	for (const g of groups.values()) {
		g.expires = g.rows.map((r) => r.expires_on).filter(Boolean).sort()[0] || '';
	}
	return [...groups.values()];
});

const expandedGroups = ref(new Set());

function toggleGroup(key) {
	const next = new Set(expandedGroups.value);
	if (!next.delete(key)) next.add(key);
	expandedGroups.value = next;
}

function addGroup(group) {
	group.rows.forEach(addFillLine);
}

function addFillLine(row) {
	const existing = fill.value.lines.find((l) => l.item_id === row.item_id);
	if (existing) existing.qty = row.qty;
	else fill.value.lines.push({ item_id: row.item_id, name: row.name, qty: row.left ?? row.qty, max: row.qty, expires_on: row.expires_on || null });
}

// The pallet the lines will go onto: the one on screen when it is an unsealed Warehouse pallet, else a new one.
const fillTarget = computed(() => {
	const p = current.value;
	return p && p.kind === 'W' && p.status === 'open' ? p : null;
});

// ---- sealed / open, and the two ways to change an open pallet (never both at once) ----
const isWarehouse = computed(() => current.value?.kind === 'W');
const canAdjust = computed(() => props.canAdjust && !!fillTarget.value && !!current.value.location_id); // permitted, open and already placed
const mode = ref('add'); // 'add' (from the sorting area) | 'adjust' (correct what is on the pallet)
const adj = ref({ rows: [], reason: '', notes: '' });
const adjError = ref(null);
const adjusting = ref(false);
const adjPick = ref(null);
const sealing = ref(false);
const ADJUST_REASONS = [
	['shrinkage', 'Perda'],
	['damaged', 'Itens danificados'],
	['correcting_count', 'Correção de quantidade'],
	['correcting_item_type', 'Correção do tipo de item'],
	['other', 'Outro'],
];
const adjPending = computed(() => adj.value.rows.some((r) => String(r.delta).trim() !== ''));
const adjChanges = computed(() => adj.value.rows.map((r) => ({ ...r, n: parseInt(r.delta, 10) })).filter((r) => Number.isInteger(r.n) && r.n !== 0));

function resetAdjust() {
	adj.value = { rows: (current.value?.contents || []).map((c) => ({ item_id: c.item_id, name: c.name, qty: c.qty, delta: '' })), reason: '', notes: '' };
	adjError.value = null;
}

function setMode(m) {
	mode.value = m;
	if (m === 'adjust') resetAdjust();
}

function addAdjustItem(item) {
	adjPick.value = null;
	if (!item || adj.value.rows.some((r) => r.item_id === item.id)) return;
	adj.value.rows.push({ item_id: item.id, name: item.name || item.description, qty: 0, delta: '' });
}

async function sealOrUnseal(action) {
	const pallet = current.value;
	sealing.value = true;
	scanMessage.value = null;
	try {
		await axios.post(`/json/pallet-stock/${pallet.id}/${action}`);
		scanMessage.value = { ok: true, text: `${pallet.tag}: ${action === 'open' ? 'deslacrado' : 'lacrado novamente'}.` };
		playScanMatched();
		await applyPallet(await lookupPallet(pallet.tag));
	} catch (e) {
		scanMessage.value = { ok: false, text: errorText(e, 'Não foi possível alterar o lacre.') };
		playScanError();
	} finally {
		sealing.value = false;
		focusScan();
	}
}

async function submitAdjust() {
	adjError.value = null;
	if (!adjChanges.value.length) {
		adjError.value = 'Informe pelo menos uma alteração (use o sinal de menos para remover).';
		return;
	}
	if (!adj.value.reason) {
		adjError.value = 'Escolha um motivo.';
		return;
	}
	if (adj.value.reason === 'other' && !adj.value.notes.trim()) {
		adjError.value = 'Informe o motivo nas observações.';
		return;
	}
	adjusting.value = true;
	try {
		const pallet = current.value;
		await axios.post(`/json/pallet-stock/${pallet.id}/adjust-inventory`, {
			reason: adj.value.reason,
			notes: adj.value.notes || null,
			lines: adjChanges.value.map((r) => ({ item_id: r.item_id, qty: r.n })),
		});
		scanMessage.value = { ok: true, text: `${pallet.tag}: estoque ajustado.` };
		playScanMatched();
		await applyPallet(await lookupPallet(pallet.tag));
		resetAdjust();
	} catch (e) {
		adjError.value = errorText(e, 'Não foi possível salvar o ajuste.');
		playScanError();
	} finally {
		adjusting.value = false;
		focusScan();
	}
}

const fillLocation = computed(() => locationByCode(fill.value.locationCode));
const suggestedExpiry = computed(() => {
	const dates = fill.value.lines.map((l) => l.expires_on).concat(fillTarget.value?.expires_on || null).filter(Boolean);
	return dates.length ? dates.reduce((a, b) => (b < a ? b : a)) : '';
});
const fillExpiry = computed(() => (fill.value.expires === null ? suggestedExpiry.value : fill.value.expires));
const fillTotal = computed(() => fill.value.lines.reduce((n, l) => n + (Number(l.qty) || 0), 0));

async function submitFill() {
	fillError.value = null;
	fillResult.value = null;
	if (!fill.value.lines.length) {
		fillError.value = 'Adicione pelo menos um item.';
		return;
	}
	if (fill.value.locationCode.trim() && !fillLocation.value) {
		fillError.value = `"${fill.value.locationCode}" não é um local ativo conhecido.`;
		return;
	}
	filling.value = true;
	try {
		const response = await axios.post('/json/pallet-stock/fill', {
			pallet_id: fillTarget.value?.id ?? null,
			location_id: fillLocation.value?.id ?? null,
			notes: fill.value.notes || null,
			expires_on: fillExpiry.value || null,
			lines: fill.value.lines.map((l) => ({ item_id: l.item_id, qty: Number(l.qty), expires_on: l.expires_on || null })),
		});
		const wasNew = !fillTarget.value;
		const existingTag = current.value?.tag;
		fillResult.value = { ...response.data.record, isNew: wasNew, assignmentIds: response.data.assignment_ids || [] };
		fill.value = { lines: [], locationCode: '', notes: '', expires: null };
		if (wasNew) clearPallet();
		else await applyPallet(await lookupPallet(existingTag));
		loadStaging();
		loadSummary();
		if (sounds.value) playScanMatched();
		// The Seal & Place button sits far below the result line, so bring the result into view.
		nextTick(() => fillResultBox.value?.scrollIntoView({ behavior: 'smooth', block: 'center' }));
	} catch (e) {
		const errors = e.response?.data?.errors;
		fillError.value = (errors && Object.values(errors).flat().join(' ')) || e.response?.data?.message || 'Não foi possível salvar.';
		playScanError();
	} finally {
		filling.value = false;
	}
}

// A quantity box can catch a stray barcode; 8+ digits there is a scan, not a quantity.
function setLineQty(line, event) {
	const raw = event.target.value.trim();
	event.target.value = line.qty;
	if (/^\d{8,}$/.test(raw)) {
		handleScan(raw).then(focusScan);
		return;
	}
	const n = parseInt(raw, 10);
	if (n >= 1) line.qty = Math.min(n, line.max);
	event.target.value = line.qty;
}

// ---------- recent movements ----------
const recent = ref(null);

async function loadRecent() {
	if (recent.value) return;
	recent.value = (await axios.get('/json/palletstatus', { params: { limit: 100 } })).data.records;
}

function show(name) {
	tab.value = name;
	if (name === 'recent') loadRecent();
	if (name === 'locations') loadSummary();
	if (name === 'pallet') {
		loadStaging();
		focusScan();
	}
}

// From the Locations drill-down: show that pallet on the Pallets tab.
function openSearchFor(tag) {
	show('pallet');
	handleScan(tag).then(focusScan);
}

function formatDate(value) {
	return value ? new Date(value).toLocaleString('pt-BR') : '';
}

onMounted(() => {
	loadSummary();
	loadStaging();
	focusScan();
});
</script>

<template>
	<Head title="Movimentação do estoque" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="pm_page">
			<h2 class="pm_title">Movimentação do estoque <HelpLink guide="inventory-movement">Guia de movimentação do estoque</HelpLink></h2>

			<div class="pm_tabs">
				<button type="button" :class="['ri_formbutton', { pm_active: tab === 'pallet' }]" @click="show('pallet')">Paletes</button>
				<button type="button" :class="['ri_formbutton', { pm_active: tab === 'locations' }]" @click="show('locations')">Locais</button>
				<button type="button" :class="['ri_formbutton', { pm_active: tab === 'recent' }]" @click="show('recent')">Movimentações recentes</button>
			</div>

			<datalist id="pm_locations">
				<option v-for="code in locationCodes" :key="code" :value="code" />
			</datalist>

			<!-- Locations -->
			<div v-if="tab === 'locations'">
				<p v-if="summaryError" class="ri_error">{{ summaryError }}</p>
				<p v-else-if="!summary">Carregando…</p>
				<div v-else class="pm_tablewrap">
					<table class="ri_datatable" border="1">
						<thead>
							<tr>
								<th>Local</th>
								<th>Paletes</th>
								<th v-for="s in statusColumns" :key="s" class="pm_status_head">{{ palletStatusLabel(s) }}</th>
							</tr>
						</thead>
						<tbody>
							<template v-for="r in locationRows" :key="r.key">
								<tr :class="{ pm_zero: r.zero, pm_nolocation: r.special, pm_clickable: r.total }" @click="r.total && toggleLocation(r.key, r.label)">
									<td>{{ openLocation?.key === r.key ? '▾' : '▸' }} {{ r.label }}</td>
									<td>{{ r.total }}</td>
									<td v-for="s in statusColumns" :key="s">{{ r.by_status[s] || '' }}</td>
								</tr>
								<tr v-if="openLocation?.key === r.key" class="pm_drillrow">
									<td :colspan="2 + statusColumns.length">
										<p v-if="openLocation.error" class="ri_error">{{ openLocation.error }}</p>
										<p v-else-if="!openLocation.pallets">Carregando…</p>
										<table v-else class="ri_datatable" border="1">
											<thead>
												<tr><th>Palete</th><th>Tipo</th><th>Status</th><th>Última movimentação</th></tr>
											</thead>
											<tbody>
												<tr v-for="p in openLocation.pallets" :key="p.id">
													<td class="pm_mono"><a href="#" @click.prevent="openSearchFor(p.tag)">{{ p.tag }}</a></td>
													<td>{{ p.kind_label }}</td>
													<td>{{ palletStatusLabel(p.status) }}</td>
													<td>{{ formatDate(p.last_moved_at) }}</td>
												</tr>
												<tr v-if="!openLocation.pallets.length"><td colspan="4">Nenhum palete ativo neste local.</td></tr>
											</tbody>
										</table>
									</td>
								</tr>
							</template>
							<tr v-if="!summary.locations.length">
								<td :colspan="2 + statusColumns.length">Nenhum local ativo cadastrado ainda.</td>
							</tr>
						</tbody>
					</table>
				</div>
				<p class="ri_hint">Clique em um local para listar os paletes. Clique no número de um palete para ver seu histórico e conteúdo. As contagens incluem apenas paletes ativos — não incluem paletes vazios, enviados, coletados, liberados, condenados ou desaparecidos.</p>
			</div>

			<!-- Pallets: one scan-driven screen -->
			<div v-else-if="tab === 'pallet'" @click="onPageClick">
				<div class="pm_scanbar">
					<input
						ref="scanInput"
						v-model="scanText"
						type="text"
						autocomplete="off"
						class="ri_forminput pm_scaninput"
						:placeholder="current ? 'Leia outro palete — ou um local para mover ' + current.tag + ' para lá' : 'Leia o código de barras de um palete'"
						@keydown.enter.prevent="submitScan"
					/>
					<button type="button" class="ri_defaultbutton" @click="submitScan">Buscar</button>
					<ScanButton :target="() => scanInput" />
					<button type="button" class="pm_sound" @click="toggleSounds"
						:title="sounds ? 'Sons da leitura ativados. Clique para silenciar.' : 'Sons da leitura desativados. Clique para ativar.'">{{ sounds ? '🔊' : '🔇' }}</button>
				</div>
				<p v-if="scanMessage" :class="scanMessage.ok ? 'pm_ok' : 'ri_error'">{{ scanMessage.text }}</p>
				<p v-if="fillError" class="ri_error">{{ fillError }}</p>
				<div v-if="fillResult" ref="fillResultBox" class="pm_current">
					<strong>{{ fillResult.tag }}</strong> lacrado<span v-if="fillResult.location"> em <strong>{{ fillResult.location.code }}</strong></span>:
					<span v-for="(c, i) in fillResult.contents" :key="c.item_id">{{ c.qty }} × {{ c.name }}<span v-if="i < fillResult.contents.length - 1">, </span></span>.
					<PrintMenu v-if="fillResult.isNew" document-key="pallet-label" :media="$page.props.printing.palletLabelMedia" variant="form" label="Imprimir etiqueta do palete"
						:params="{ id: fillResult.id }" :download-href="'/report/pallet/' + fillResult.id" />
					<PrintMenu v-if="fillResult.assignmentIds?.length" document-key="inventory-labels" :media="$page.props.printing.inventoryLabelMedia" variant="form"
						:label="'Imprimir etiquetas dos itens (' + fillResult.assignmentIds.length + ')'"
						:params="{ ids: fillResult.assignmentIds }" :download-href="'/report/inventory-labels?ids=' + fillResult.assignmentIds.join(',')" />
				</div>

				<!-- the pallet on screen -->
				<div v-if="current" class="pm_card">
					<p class="pm_current">
						<strong class="pm_mono">{{ current.tag }}</strong> ({{ current.kind_label }}) —
						<strong>{{ current.location ? 'em ' + current.location.code : 'nenhum local registrado' }}</strong>,
						situação <strong>{{ palletStatusLabel(current.status) }}</strong><span v-if="current.last_moved_at">, última atualização {{ formatDate(current.last_moved_at) }}</span><span v-if="current.expires_on">, vencimento mais próximo <strong>{{ current.expires_on }}</strong></span>.
						<button type="button" class="ri_linkbutton" @click="clearPallet">Limpar / novo palete</button>
					</p>

					<div class="pm_fillrow">
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Local:</span>
							<input v-model="move.locationCode" class="ri_forminput" list="pm_locations" placeholder="Desconhecido — leia ou digite um local" />
						</label>
						<label v-if="!isWarehouse" class="pm_fillfield">
							<span class="ri_fieldlabel">Status:</span>
							<select v-model="move.status" class="ri_forminput">
								<option v-for="st in current.statuses" :key="st.id" :value="st.id">{{ palletStatusLabel(st.id) }}</option>
							</select>
						</label>
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Observações:</span>
							<input v-model="move.notes" class="ri_forminput" />
						</label>
						<button type="button" class="ri_defaultbutton" :disabled="saving" @click="recordMovement">{{ saveLabel }}</button>
						<button v-if="isWarehouse && current.status === 'sealed'" type="button" class="ri_formbutton" :disabled="sealing" @click="sealOrUnseal('open')">Deslacrar</button>
						<button v-if="isWarehouse && current.status === 'open'" type="button" class="ri_formbutton" :disabled="sealing" @click="sealOrUnseal('seal')">Lacrar novamente</button>
					</div>
					<p v-if="isWarehouse && current.status === 'sealed'" class="ri_hint">Este palete está lacrado. Remova o lacre para adicionar itens ou ajustar seu conteúdo.</p>

					<h3 class="pm_sub">Conteúdo do palete</h3>
					<template v-if="current.contents">
						<p v-if="!current.contents.length" class="ri_hint">Não há itens registrados neste palete.</p>
						<div v-else class="pm_tablewrap">
							<table class="ri_datatable" border="1">
								<thead><tr><th>Item</th><th>Quantidade</th></tr></thead>
								<tbody>
									<tr v-for="c in current.contents" :key="c.item_id"><td>{{ c.name }}</td><td>{{ c.qty }}</td></tr>
								</tbody>
							</table>
						</div>
						<template v-if="current.labels?.length">
							<h3 class="pm_sub">Etiquetas de estoque</h3>
							<p class="ri_hint">Uma etiqueta para cada conjunto de itens adicionado a este palete. As separações e correções posteriores não são refletidas. Reimprima as etiquetas aqui.</p>
							<div class="pm_tablewrap">
								<table class="ri_datatable" border="1">
									<thead><tr><th>Item</th><th>Adicionado</th><th>Vencimento</th><th></th></tr></thead>
									<tbody>
										<tr v-for="l in current.labels" :key="l.id" :style="l.id === scannedLabelId ? 'background: #fff3b0' : null">
											<td>{{ l.name }}</td><td>{{ l.qty }}</td><td>{{ l.expires_on || '' }}</td>
											<td><PrintMenu document-key="inventory-labels" :media="$page.props.printing.inventoryLabelMedia" variant="link" label="Imprimir"
												:params="{ ids: [l.id] }" :download-href="'/report/inventory-labels?ids=' + l.id" /></td>
										</tr>
									</tbody>
								</table>
							</div>
							<PrintMenu document-key="inventory-labels" :media="$page.props.printing.inventoryLabelMedia" variant="form" label="Imprimir todas as etiquetas dos itens"
								:params="{ ids: current.labels.map((l) => l.id) }" :download-href="'/report/inventory-labels?ids=' + current.labels.map((l) => l.id).join(',')" />
						</template>
					</template>
					<template v-else-if="current.sorted_from">
						<p class="ri_hint">Os paletes de recebimento não são rastreados item por item; este é o registro da triagem do que saiu dele.</p>
						<p v-if="!current.sorted_from.length" class="ri_hint">Nenhum item foi triado deste palete ainda.</p>
						<div v-else class="pm_tablewrap">
							<table class="ri_datatable" border="1">
								<thead><tr><th>Item</th><th>Destino</th><th>Quantidade</th></tr></thead>
								<tbody>
									<tr v-for="(c, i) in current.sorted_from" :key="i"><td>{{ c.name }}</td><td>{{ c.disposition }}</td><td>{{ c.qty }}</td></tr>
								</tbody>
							</table>
						</div>
					</template>
					<p v-else class="ri_hint">O conteúdo deste tipo de palete não é rastreado.</p>
				</div>
				<p v-else class="ri_hint">Leia um palete para ver sua localização e conteúdo e movimentá-lo — ou monte um novo palete do armazém abaixo.</p>

				<!-- put stock from the sorting area onto this (or a new) Warehouse pallet -->
				<div v-if="canAdjust" class="pm_modes">
					<button type="button" :class="['ri_formbutton', { pm_active: mode === 'add' }]" :disabled="adjPending" :title="adjPending ? 'Conclua ou limpe o ajuste primeiro' : ''" @click="setMode('add')">Adicionar da área de triagem</button>
					<button type="button" :class="['ri_formbutton', { pm_active: mode === 'adjust' }]" :disabled="fill.lines.length > 0" :title="fill.lines.length ? 'Conclua ou limpe os itens separados para adicionar primeiro' : ''" @click="setMode('adjust')">Ajustar estoque</button>
				</div>

				<!-- adjust what is on an unsealed, placed pallet -->
				<div v-if="canAdjust && mode === 'adjust'">
					<h3 class="pm_sub">Ajustar estoque no palete {{ current.tag }}</h3>
					<p class="ri_hint">Corrija o conteúdo deste palete. Use o sinal de menos para remover (-3) ou apenas o número para adicionar. Isso será registrado como um ajuste de estoque, separado da adição de itens da área de triagem.</p>
					<p v-if="adjError" class="ri_error">{{ adjError }}</p>
					<div class="pm_tablewrap">
						<table class="ri_datatable" border="1">
							<thead><tr><th>Item</th><th>Atual</th><th>Alteração</th><th>Depois</th></tr></thead>
							<tbody>
								<tr v-for="r in adj.rows" :key="r.item_id">
									<td>{{ r.name }}</td>
									<td>{{ r.qty }}</td>
									<td><input v-model="r.delta" type="text" inputmode="numeric" autocomplete="off" class="ri_forminput pm_qty" placeholder="0" @focus="$event.target.select()" /></td>
									<td>{{ Number.isInteger(parseInt(r.delta, 10)) ? r.qty + parseInt(r.delta, 10) : r.qty }}</td>
								</tr>
								<tr v-if="!adj.rows.length"><td colspan="4">Nenhum item registrado neste palete — adicione um item abaixo.</td></tr>
							</tbody>
						</table>
					</div>
					<div class="pm_fillrow">
						<span class="pm_fillfield">
							<span class="ri_fieldlabel">Outro item:</span>
							<SearchSelect v-model="adjPick" optionsource="/json/items" display="name" :searchfields="['name', 'upc', 'description']"
								placeholder="Buscar itens..." :smartOpen="true" :debounce="150" :openOnFocus="false" @selected="addAdjustItem" />
						</span>
					</div>
					<div class="pm_fillrow">
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Motivo:</span>
							<select v-model="adj.reason" class="ri_forminput">
								<option value="" disabled>Escolha um motivo…</option>
								<option v-for="[key, label] in ADJUST_REASONS" :key="key" :value="key">{{ label }}</option>
							</select>
						</label>
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Observações<span v-if="adj.reason === 'other'"> (obrigatório)</span>:</span>
							<input v-model="adj.notes" class="ri_forminput" />
						</label>
						<button type="button" class="ri_defaultbutton" :disabled="adjusting || !adjChanges.length" @click="submitAdjust">Registrar ajuste ({{ adjChanges.length }})</button>
						<button type="button" class="ri_formbutton" :disabled="!adjPending" @click="resetAdjust">Limpar</button>
					</div>
				</div>

				<div v-if="!current || (fillTarget && mode === 'add')">
					<h3 class="pm_sub">{{ fillTarget ? 'Adicionar itens a ' + fillTarget.tag : 'Montar um novo palete do armazém' }}</h3>
					<p v-if="!fillTarget" class="ri_hint">Toque nos itens da área de triagem abaixo, escolha o destino e depois sele Lacrar e posicionar. Leia um palete existente do armazém para adicionar os itens a ele.</p>

					<div class="pm_tablewrap" v-if="fill.lines.length">
						<table class="ri_datatable" border="1">
							<thead><tr><th>Item</th><th>Quantidade</th><th>Vencimento</th><th></th></tr></thead>
							<tbody>
								<tr v-for="(l, i) in fill.lines" :key="l.item_id">
									<td>{{ l.name }}</td>
									<td><input type="text" inputmode="numeric" autocomplete="off" :value="l.qty" class="ri_forminput pm_qty" @focus="$event.target.select()" @change="setLineQty(l, $event)" /></td>
									<td><input type="date" class="ri_forminput" v-model="l.expires_on" title="Vencimento mais próximo desta quantidade — impresso na etiqueta de estoque" /></td>
									<td><button type="button" class="ri_linkbutton" @click="fill.lines.splice(i, 1)">Remover</button></td>
								</tr>
							</tbody>
						</table>
					</div>
					<p v-else class="ri_hint">Toque nos itens abaixo para adicioná-los a este palete.</p>

					<div class="pm_fillrow">
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Local:</span>
							<input v-model="fill.locationCode" class="ri_forminput" list="pm_locations" placeholder="Destino" />
						</label>
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Vencimento:</span>
							<input type="date" class="ri_forminput" :value="fillExpiry" title="Data de vencimento mais próxima dos itens deste palete"
								@input="fill.expires = $event.target.value" />
							<button v-if="fill.expires !== null" type="button" class="ri_linkbutton" title="Voltar à data mais próxima dos itens" @click="fill.expires = null">Automático</button>
						</label>
						<label class="pm_fillfield">
							<span class="ri_fieldlabel">Observações:</span>
							<input v-model="fill.notes" class="ri_forminput" />
						</label>
						<button type="button" class="ri_defaultbutton" :disabled="filling || !fill.lines.length" @click="submitFill">
							{{ fillTarget ? 'Adicionar ao palete' : 'Lacrar e posicionar' }} ({{ fillTotal }})
						</button>
					</div>

					<h3 class="pm_sub">Na área de triagem</h3>
					<p v-if="!staging">Carregando…</p>
					<p v-else-if="!stagingLeft.length" class="ri_hint">Nada aguardando — todos os itens triados já estão em um palete.</p>
					<div v-else class="pm_tablewrap">
						<table class="ri_datatable" border="1">
							<thead><tr><th>Item</th><th>Aguardando</th><th>Vencimento</th><th></th></tr></thead>
							<tbody>
								<template v-for="g in stagingGroups" :key="g.key">
									<tr v-if="g.rows.length === 1">
										<td>{{ g.type?.number ? 'ACS #' + g.type.number + ' ' : '' }}{{ g.rows[0].name }}</td>
										<td>{{ g.left }}</td>
										<td>{{ g.expires }}</td>
										<td><button type="button" class="ri_formbutton" @click="addFillLine(g.rows[0])">Colocar {{ g.left }} no palete</button></td>
									</tr>
									<template v-else>
										<tr class="pm_group pm_clickable" @click="toggleGroup(g.key)">
											<td>{{ expandedGroups.has(g.key) ? '▾' : '▸' }} ACS #{{ g.type.number }} ({{ g.type.name }}) — {{ g.rows.length }} itens</td>
											<td>{{ g.left }}</td>
											<td>{{ g.expires }}</td>
											<td><button type="button" class="ri_formbutton" @click.stop="addGroup(g)">Colocar {{ g.left }} no palete</button></td>
										</tr>
										<tr v-for="row in expandedGroups.has(g.key) ? g.rows : []" :key="row.item_id" class="pm_sku">
											<td>{{ row.name }}</td>
											<td>{{ row.left }}</td>
											<td>{{ row.expires_on || '' }}</td>
											<td><button type="button" class="ri_formbutton" @click="addFillLine(row)">Colocar {{ row.left }} no palete</button></td>
										</tr>
									</template>
								</template>
							</tbody>
						</table>
					</div>
				</div>
				<p v-else-if="fill.lines.length && !(fillTarget && mode === 'adjust')" class="ri_hint">{{ fill.lines.length }} linha(s) de itens estão separadas para um palete do armazém — use "Limpar / novo palete" para voltar a elas.</p>

				<div v-if="current" class="pm_history">
					<h3 class="pm_sub">Histórico de movimentações</h3>
					<div class="pm_tablewrap">
						<table class="ri_datatable" border="1">
							<thead><tr><th>Data</th><th>Local</th><th>Status</th><th>Observações</th></tr></thead>
							<tbody>
								<tr v-for="h in history" :key="h.id">
									<td>{{ formatDate(h.created_at) }}</td>
									<td>{{ h.location ? h.location.code : 'Desconhecido' }}</td>
									<td>{{ palletStatusLabel(h.status) }}</td>
									<td>{{ h.notes }}</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>

			<!-- Recent movements -->
			<div v-else-if="tab === 'recent'">
				<p v-if="!recent">Carregando…</p>
				<div v-else class="pm_tablewrap">
					<table class="ri_datatable" border="1">
						<thead><tr><th>Data</th><th>Palete</th><th>Local</th><th>Status</th><th>Observações</th></tr></thead>
						<tbody>
							<tr v-for="r in recent" :key="r.id">
								<td>{{ formatDate(r.created_at) }}</td>
								<td class="pm_mono">{{ r.pallet ? r.pallet.tag : r.pallet_id }}</td>
								<td>{{ r.location ? r.location.code : 'Desconhecido' }}</td>
								<td>{{ palletStatusLabel(r.status) }}</td>
								<td>{{ r.notes }}</td>
							</tr>
							<tr v-if="!recent.length"><td colspan="5">Nenhuma movimentação registrada ainda.</td></tr>
						</tbody>
					</table>
				</div>
				<p class="ri_hint">Exibindo os 100 registros mais recentes.</p>
			</div>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.pm_page {
	padding: 1em;
}
.pm_title {
	margin-bottom: 0.5em;
}
.pm_tabs {
	display: flex;
	gap: 0.5em;
	flex-wrap: wrap;
	margin-bottom: 1em;
}
.pm_active {
	font-weight: bold;
	outline: 2px solid currentColor;
}
.pm_tablewrap {
	overflow-x: auto;
	margin: 0.5em 0;
}
.pm_status_head {
	text-transform: capitalize;
}
.pm_clickable {
	cursor: pointer;
}
.pm_drillrow > td {
	padding: 0.5em 0.75em 0.75em 2em;
}
.pm_zero {
	opacity: 0.55;
}
.pm_nolocation {
	font-style: italic;
}
.pm_current {
	margin: 0.75em 0;
}
.pm_sub {
	margin: 1em 0 0.25em;
	font-weight: bold;
}
.pm_fillrow {
	display: flex;
	flex-wrap: wrap;
	gap: 0.5em 1em;
	margin: 0.5em 0;
}
.pm_fillfield {
	display: flex;
	align-items: center;
	gap: 0.4em;
}
.pm_group {
	font-weight: bold;
}
.pm_sku > td:first-child {
	padding-left: 2em;
}
.pm_modes {
	display: flex;
	gap: 0.5em;
	margin: 0.75em 0 0.25em;
}
.pm_scanbar {
	display: flex;
	gap: 0.5em;
	align-items: center;
	margin-bottom: 0.5em;
}
.pm_scaninput {
	flex: 1;
	max-width: 32em;
	font-size: 1.2em;
}
.pm_sound {
	background: none;
	border: 0;
	font-size: 1.4em;
	cursor: pointer;
}
.pm_ok {
	color: #1b6e2d;
	font-weight: bold;
}
.pm_card {
	border: 1px solid #bbb;
	border-radius: 6px;
	padding: 0.5em 0.9em;
	margin: 0.5em 0;
}
.pm_qty {
	width: 6em;
}
.pm_mono {
	font-family: monospace;
}
</style>
