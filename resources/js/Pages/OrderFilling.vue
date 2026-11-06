<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- OrderFilling.vue

	Order Filling/Picking: the first place item_ledgers.qty_subtracted ever
	becomes real (previously always 0 in production). One shared backend
	serves two capture modes, not two systems — a fill record is created the
	same way whether staff typed it live while scanning, or transcribed it
	afterward from a printed pick sheet. See OrderFillingController's doc
	comment for the full architecture.

	  - List view: two queues. "Ready to Fill" orders can either be started
	    individually (opens the fill screen directly — the live/manual path)
	    or all printed together as one batch of pick sheets (the paper path,
	    which also locks every included order into Filling). "Filling"
	    orders show per-order fill progress and link into the same fill
	    screen to continue or finish.
	  - Review Allocation is additive and non-blocking: a read-only panel
	    showing, for any itemtype where total requested across Ready-to-Fill
	    orders exceeds on-hand, a straight-proportional suggested split per
	    order line alongside that line's self-reported need level. It never
	    changes anything on its own — Print Pick Sheets and Start Filling
	    both work immediately without ever opening it. A warehouse that just
	    wants first-come-first-served can ignore this panel entirely.
	  - Fill screen: per requested line, an add-a-fill-record control (item
	    variant search/scan, matching Sorting's exact item-scan pattern,
	    auto-skipped when the itemtype has only one variant) plus qty. Fill
	    records are append-only (matches Sorting's ledger-row-per-scan model)
	    — "filled so far" is their sum, never an overwritten total. Complete
	    Filling requires every line to have at least one record (a
	    deliberate zero counts).
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head } from '@inertiajs/vue3';
import SearchSelect from '@/Components/SearchSelect.vue';
import ScanButton from '@/Components/ScanButton.vue';
import { playScanError, playScanMatched } from '@/scanSounds';
import PrintMenu from '@/Components/PrintMenu.vue';
import axios from 'axios';

const NEED_LEVEL_LABELS = { critical: 'Crítico', moderate: 'Moderado', low: 'Baixo' };

export default {
	components: { AuthenticatedLayout, HelpLink, Head, SearchSelect, ScanButton, PrintMenu },
	props: {
		breadcrumb: { type: Array },
	},
	data() {
		return {
			view: 'list', // 'list' | 'fill'
			readyToFill: [],
			filling: [],
			listLoading: false,
			listError: null,
			showAllocation: false,
			// Approve column drafts, keyed by order line id — '' means no
			// approval (picker gets the full request). Seeded from each line's
			// saved qty_approved, else the suggested proportional share.
			approvalDrafts: {},
			savingApprovals: false,
			approvalError: null,
			approvalSaved: false,

			// stock-on-hand per itemtype, reused from Order Entry's own endpoint
			stockHints: {},

			// fill screen
			order: null,
			fillError: null,
			confirmingFillKey: null,
			savingComplete: false,
			palletCount: null,

			// add-a-fill-record entry, per line (keyed by line id)
			entryByLine: {},
			// where each itemtype's stock is (sorting-area pool + warehouse pallets), keyed by itemtype id
			plans: {}, // suggested pick per line id (see PickPlanner): { steps, short, first_sequence }
			openingPalletId: null,

			// item catalog, fetched once and filtered client-side per line's
			// itemtype — same pattern DonationSorting.vue uses for /json/items
			items: [],

			needLevelLabels: NEED_LEVEL_LABELS,
		};
	},
	computed: {
		// Itemtypes where total requested across Ready-to-Fill orders
		// exceeds on-hand — the Allocation Review panel's contents.
		allocationRows() {
			const totals = {}; // itemtype_id -> { itemtype, lines: [{order, line}] }
			this.readyToFill.forEach((order) => {
				(order.order_lines || []).forEach((line) => {
					const key = line.itemtype_id;
					if (!totals[key]) totals[key] = { itemtype: line.itemtype, lines: [] };
					totals[key].lines.push({ order, line });
				});
			});

			return Object.values(totals)
				.map((group) => {
					const onHand = Number(this.stockHints[group.itemtype?.id] ?? 0);
					const totalRequested = group.lines.reduce((sum, { line }) => sum + Number(line.qty_requested || 0), 0);
					return { itemtype: group.itemtype, onHand, totalRequested, lines: group.lines };
				})
				.filter((row) => row.totalRequested > row.onHand)
				.map((row) => ({
					...row,
					lines: row.lines
						.map(({ order, line }) => ({
							order,
							line,
							suggested: row.totalRequested > 0
								? Math.floor(Number(line.qty_requested) * (row.onHand / row.totalRequested))
								: 0,
						}))
						.sort((a, b) => this.needLevelRank(a.line.need_level) - this.needLevelRank(b.line.need_level)),
				}));
		},
		orderLines() {
			return this.order?.order_lines || [];
		},
		// Lines a picker actually pulls — an approved quantity of 0 means
		// nothing to pick, so the line is left off the fill screen (and the
		// pick sheet) and needs no fill record.
		pickableLines() {
			// Walking order along the admin's pick path (sorting area first; lines with no known location last).
			const rank = (line) => {
				const seq = this.plans[line.id]?.first_sequence;
				return seq === null || seq === undefined ? Number.MAX_SAFE_INTEGER : seq;
			};
			return this.orderLines
				.filter((line) => Number(line.qty_to_pick) > 0)
				.map((line, index) => ({ line, index }))
				.sort((a, b) => rank(a.line) - rank(b.line) || a.index - b.index)
				.map(({ line }) => line);
		},
		// Every fill is 0 (or nothing is pickable): completing will close the
		// order as Closed - Unfulfilled instead of sending it to Shipping.
		nothingPicked() {
			return this.orderLines.every((line) => this.lineFilled(line) === 0);
		},
	},
	methods: {
		needLevelRank(level) {
			return { critical: 0, moderate: 1, low: 2 }[level] ?? 3;
		},
		personLabel(person) {
			if (!person) return '(sem parceiro)';
			const name = [person.first_name, person.last_name].filter(Boolean).join(' ');
			return person.organization ? person.organization + (name ? ' - ' + name : '') : name || '(sem nome)';
		},
		lineFilled(line) {
			return (line.item_ledgers || []).reduce((sum, fill) => sum + Number(fill.qty_subtracted || 0), 0);
		},
		orderProgress(order) {
			const lines = (order.order_lines || []).filter((line) => Number(line.qty_to_pick) > 0);
			const filledCount = lines.filter((line) => (line.item_ledgers || []).length > 0).length;
			return { filled: filledCount, total: lines.length };
		},

		// ---------- list / queues ----------
		async fetchQueue() {
			this.listLoading = true;
			this.listError = null;
			try {
				const response = await axios.get('/json/order-filling');
				this.readyToFill = response.data.ready_to_fill || [];
				this.filling = response.data.filling || [];
				this.seedApprovalDrafts();
			} catch (error) {
				this.listError = 'Não foi possível carregar a fila de separação.';
			} finally {
				this.listLoading = false;
			}
		},
		async fetchStockHints() {
			try {
				const response = await axios.get('/json/orders/stock-hints');
				this.stockHints = response.data.hints || {};
			} catch (error) {
				this.stockHints = {};
			}
			this.seedApprovalDrafts();
		},

		// ---------- where to pick from ----------
		async fetchPlan() {
			if (!this.order) return;
			try {
				this.plans = (await axios.get('/json/order-filling/' + this.order.id + '/plan')).data.lines || {};
			} catch (error) {
				this.plans = {};
			}
		},
		async openPallet(pallet) {
			this.openingPalletId = pallet.id;
			this.fillError = null;
			try {
				await axios.post('/json/order-filling/pallets/' + pallet.id + '/open');
				await this.fetchPlan();
			} catch (error) {
				this.fillError = error.response?.data?.message || 'Não foi possível abrir esse palete.';
			} finally {
				this.openingPalletId = null;
			}
		},
		// Fill the entry row from a plan step: its pallet (none for the sorting area), item and quantity.
		useStep(line, step) {
			const entry = this.entryByLine[line.id];
			entry.pallet_tag = step.kind === 'pool' ? '' : step.tag;
			entry.qty = step.qty;
			if (this.itemsForItemtype(line.itemtype_id).length > 1) {
				entry.item_id = step.item_id;
				entry.item = this.itemsForItemtype(line.itemtype_id).find((i) => i.id === step.item_id) || null;
			}
			this.$nextTick(() => this.$refs['qtyInput_' + line.id]?.[0]?.focus());
		},

		// ---------- allocation approval ----------
		seedApprovalDrafts() {
			const drafts = {};
			this.allocationRows.forEach((row) => row.lines.forEach(({ line, suggested }) => {
				drafts[line.id] = line.qty_approved ?? suggested;
			}));
			this.approvalDrafts = drafts;
			this.approvalSaved = false;
		},
		async saveApprovals() {
			this.approvalError = null;
			this.approvalSaved = false;
			const lines = this.allocationRows.flatMap((row) => row.lines.map(({ line }) => {
				const draft = this.approvalDrafts[line.id];
				return { id: line.id, qty_approved: draft === '' || draft === null || draft === undefined ? null : Number(draft) };
			}));
			if (!lines.length) return;
			this.savingApprovals = true;
			try {
				await axios.put('/json/order-filling/allocations', { lines });
				await this.fetchQueue();
				this.approvalSaved = true;
			} catch (error) {
				this.approvalError = error.response?.data?.message
					|| Object.values(error.response?.data?.errors || {}).flat().join(' ')
					|| 'Não foi possível salvar as quantidades aprovadas.';
			} finally {
				this.savingApprovals = false;
			}
		},
		async fetchItems() {
			try {
				const response = await axios.get('/json/items');
				this.items = response.data.records || [];
			} catch (error) {
				this.items = [];
			}
		},
		itemsForItemtype(itemtypeId) {
			return this.items.filter((item) => item.itemtype_id === itemtypeId);
		},

		async startFilling(order) {
			this.listError = null;
			try {
				const response = await axios.patch('/json/order-filling/' + order.id + '/start');
				await this.openFillScreen(response.data.record.id);
			} catch (error) {
				this.listError = error.response?.data?.message || 'Não foi possível iniciar a separação desse pedido.';
			}
		},
		// Run by PrintMenu on any choice (download or a printer): locks every
		// Ready-to-Fill order into Filling in one transaction, then hands back
		// the ids to render. PrintMenu opens the download tab itself before this
		// awaits, so the popup blocker doesn't eat it.
		async preparePickSheets() {
			this.listError = null;
			try {
				const response = await axios.post('/json/order-filling/print-pick-sheets');
				const ids = response.data.order_ids || [];
				await this.fetchQueue();
				if (!ids.length) return null;
				return { params: { ids }, downloadHref: this.pickSheetsHref(ids) };
			} catch (error) {
				this.listError = error.response?.data?.message || 'Não foi possível imprimir as listas de separação.';
				return null;
			}
		},
		pickSheetsHref(ids) {
			return '/report/pick-sheets.pdf?' + ids.map((id) => 'ids[]=' + id).join('&');
		},

		// ---------- fill screen ----------
		async openFillScreen(orderId) {
			this.fillError = null;
			this.confirmingFillKey = null;
			this.entryByLine = {};
			this.palletCount = null;
			try {
				const response = await axios.get('/json/order-filling');
				const found = [...(response.data.ready_to_fill || []), ...(response.data.filling || [])]
					.find((o) => o.id === orderId);
				this.order = found || null;
				if (!this.order) {
					this.listError = 'Não foi possível abrir esse pedido.';
					return;
				}
				this.orderLines.forEach((line) => {
					this.entryByLine[line.id] = { item_id: null, item: null, qty: null, pallet_tag: '' };
				});
				this.view = 'fill';
				await Promise.all([this.fetchStockHints(), this.fetchItems(), this.fetchPlan()]);
			} catch (error) {
				this.listError = 'Não foi possível abrir esse pedido.';
			}
		},
		async continueFilling(order) {
			await this.openFillScreen(order.id);
		},
		backToList() {
			this.view = 'list';
			this.order = null;
			this.fetchQueue();
		},
		fillKey(fill) {
			return fill.id;
		},
		lineOnHand(line) {
			return Number(this.stockHints[line.itemtype_id] ?? 0);
		},
		itemChosenForLine(line, item) {
			this.entryByLine[line.id].item = item;
			this.$nextTick(() => this.$refs['qtyInput_' + line.id]?.[0]?.focus());
		},
		scanMatchedLocally() {
			playScanMatched();
		},
		// A barcode in a line's item box (typed by a wedge scanner or by the camera button) that didn't exactly match a
		// variant's stored text: ask the server, which normalises UPC-A / EAN-13 / GTIN-14 spellings and maps cartons,
		// and accept it only if it is one of the variants offered for this line.
		async onItemScan(line, code) {
			this.fillError = null;
			try {
				const response = await axios.get('/json/upc/resolve', { params: { code, online: 0 } });
				const item = response.data.status === 'matched' ? response.data.item : null;
				const match = item && this.itemsForItemtype(line.itemtype_id).find((i) => i.id === item.id);
				if (!match) {
					playScanError();
					this.fillError = 'O código lido não corresponde a um item desta linha.';
					this.$refs['itemSelect_' + line.id]?.[0]?.clearSelection();
					return;
				}
				this.entryByLine[line.id].item_id = match.id;
				this.itemChosenForLine(line, match);
				if (response.data.kind === 'carton' && response.data.qty) this.entryByLine[line.id].qty = response.data.qty;
				playScanMatched();
			} catch (error) {
				playScanError();
				this.fillError = error.response?.data?.message || 'Não foi possível localizar esse código de barras. Busque o item.';
			}
		},
		async addFill(line) {
			this.fillError = null;
			const entry = this.entryByLine[line.id];
			const variants = this.itemsForItemtype(line.itemtype_id);
			const itemId = variants.length === 1 ? variants[0].id : entry.item_id;
			if (!itemId) {
				this.fillError = 'Escolha primeiro um item para esta linha.';
				return;
			}
			const qty = entry.qty === '' || entry.qty === null ? null : parseInt(entry.qty, 10);
			if (qty === null || isNaN(qty) || qty < 0) {
				this.fillError = 'Informe uma quantidade igual ou superior a 0.';
				return;
			}

			try {
				const response = await axios.post(
					'/json/order-filling/' + this.order.id + '/lines/' + line.id + '/fills',
					{ item_id: itemId, qty, pallet_tag: entry.pallet_tag?.trim() || null }
				);
				line.item_ledgers = [...(line.item_ledgers || []), ...(response.data.records || [response.data.record])];
				// keep the pallet: several picks in a row usually come off the same one
				this.entryByLine[line.id] = { item_id: null, item: null, qty: null, pallet_tag: entry.pallet_tag };
				if (response.data.warning) this.fillError = response.data.warning;
				// on-hand is a ledger sum the fill just changed — refresh it
				this.fetchStockHints();
				this.fetchPlan();
			} catch (error) {
				this.fillError = error.response?.data?.message
					|| Object.values(error.response?.data?.errors || {}).flat().join(' ')
					|| 'Não foi possível registrar essa separação.';
				this.fetchPlan();
			}
		},
		async deleteFill(line, fill) {
			if (this.confirmingFillKey !== this.fillKey(fill)) {
				this.confirmingFillKey = this.fillKey(fill);
				return;
			}
			this.confirmingFillKey = null;
			try {
				await axios.delete('/json/order-filling/' + this.order.id + '/lines/' + line.id + '/fills/' + fill.id);
				line.item_ledgers = (line.item_ledgers || []).filter((f) => f.id !== fill.id);
				this.fetchStockHints();
			} catch (error) {
				this.fillError = 'Não foi possível excluir esse registro de separação.';
			}
		},
		allLinesAccounted() {
			return this.pickableLines.every((line) => (line.item_ledgers || []).length > 0);
		},
		async completeFilling() {
			this.fillError = null;
			this.savingComplete = true;
			try {
				await axios.patch('/json/order-filling/' + this.order.id + '/complete', {
					pallet_count: this.palletCount || null,
				});
				this.backToList();
			} catch (error) {
				this.fillError = error.response?.data?.message || 'Não foi possível concluir a separação deste pedido.';
			} finally {
				this.savingComplete = false;
			}
		},
	},
	mounted() {
		this.fetchQueue();
		this.fetchStockHints();
	},
};
</script>

<template>
	<Head title="Separação de pedidos" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<!-- ======================= QUEUE LIST ======================= -->
		<div v-if="view === 'list'" class="of_container">
			<h2 class="ri_datatable_head">
				Separação de pedidos
				<HelpLink guide="order-filling">Guia de separação de pedidos</HelpLink>
				<span class="of_headeractions">
					<button @click="showAllocation = !showAllocation" class="ri_formbutton">
						{{ showAllocation ? 'Ocultar' : 'Revisar' }} alocação
					</button>
					<PrintMenu document-key="pick-sheets" media="report" label="Imprimir listas de separação"
						:disabled="!readyToFill.length" :prepare="preparePickSheets" />
				</span>
			</h2>

			<p v-if="listError" class="of_error">{{ listError }}</p>
			<p v-if="listLoading">Carregando…</p>

			<!-- Allocation Review: optional — approving is what changes the picker's number -->
			<div v-if="showAllocation" class="of_card">
				<h3>Revisão da alocação</h3>
				<p class="of_hint">
					Itens cuja quantidade total solicitada nos pedidos prontos para separação excede o estoque disponível. As quantidades sugeridas
					são proporcionais; o nível de necessidade é uma informação autodeclarada. Ao salvar, você define a
					quantidade aprovada para cada linha — ela será exibida na lista de separação e na tela de separação (linhas
					aprovadas com quantidade 0 serão omitidas). Deixe o campo em branco para permitir a quantidade solicitada completa. Nada
					aqui é obrigatório antes de imprimir ou separar.
				</p>
				<p v-if="!allocationRows.length" class="of_hint">Nenhum item está em falta no momento.</p>
				<div v-for="row in allocationRows" :key="row.itemtype?.id" class="of_allocation_group">
					<h4>{{ row.itemtype?.name }} — {{ row.onHand }} em estoque, {{ row.totalRequested }} solicitados</h4>
					<table class="ri_datatable" border="1">
						<thead>
							<tr><th>Pedido</th><th>Entidade parceira</th><th>Solicitado</th><th>Sugerido</th><th>Aprovar</th><th>Necessidade</th></tr>
						</thead>
						<tbody>
							<tr v-for="entry in row.lines" :key="entry.order.id + '-' + entry.line.id">
								<td>#{{ entry.order.id }}</td>
								<td>{{ personLabel(entry.order.person) }}</td>
								<td>{{ entry.line.qty_requested }}</td>
								<td>{{ entry.suggested }}</td>
								<td>
									<input type="number" min="0" :max="entry.line.qty_requested" step="1"
										v-model="approvalDrafts[entry.line.id]" class="ri_forminput of_qty"
										@input="approvalSaved = false" />
									<span v-if="entry.line.qty_approved !== null && entry.line.qty_approved !== undefined"
										class="of_hint" title="Quantidade aprovada salva">&#10003; {{ entry.line.qty_approved }}</span>
								</td>
								<td>{{ needLevelLabels[entry.line.need_level] || '—' }}</td>
							</tr>
						</tbody>
					</table>
				</div>
				<div v-if="allocationRows.length" class="of_approvalactions">
					<button @click="saveApprovals" :disabled="savingApprovals" class="ri_defaultbutton">
						{{ savingApprovals ? 'Salvando…' : 'Salvar quantidades aprovadas' }}
					</button>
					<span v-if="approvalSaved" class="of_hint">Salvo — as quantidades aprovadas serão exibidas para quem faz a separação.</span>
					<span v-if="approvalError" class="of_error">{{ approvalError }}</span>
				</div>
			</div>

			<div class="of_section">
				<h3>Prontos para separação</h3>
				<p v-if="!readyToFill.length && !listLoading">Nenhum pedido aguardando separação.</p>
				<div v-else class="of_tablewrap"><table class="ri_datatable" border="1">
					<thead>
						<tr><th>Pedido</th><th>Entidade parceira</th><th>Linhas</th><th></th></tr>
					</thead>
					<tbody>
						<tr v-for="order in readyToFill" :key="order.id">
							<td>#{{ order.id }}</td>
							<td>{{ personLabel(order.person) }}</td>
							<td>{{ (order.order_lines || []).length }}</td>
							<td><button @click="startFilling(order)" class="ri_formbutton">Iniciar separação</button></td>
						</tr>
					</tbody>
				</table></div>
			</div>

			<div class="of_section">
				<h3>Em separação</h3>
				<p v-if="!filling.length && !listLoading">Nenhum pedido em separação no momento.</p>
				<div v-else class="of_tablewrap"><table class="ri_datatable" border="1">
					<thead>
						<tr><th>Pedido</th><th>Entidade parceira</th><th>Andamento</th><th></th></tr>
					</thead>
					<tbody>
						<tr v-for="order in filling" :key="order.id">
							<td>#{{ order.id }}</td>
							<td>{{ personLabel(order.person) }}</td>
							<td>{{ orderProgress(order).filled }} de {{ orderProgress(order).total }} linhas separadas</td>
							<td>
								<button @click="continueFilling(order)" class="ri_formbutton">Continuar</button>
								<PrintMenu document-key="pick-sheets" media="report" variant="form" label="Imprimir"
									:params="{ ids: [order.id] }" :download-href="pickSheetsHref([order.id])" />
							</td>
						</tr>
					</tbody>
				</table></div>
			</div>
		</div>

		<!-- ======================= FILL SCREEN ======================= -->
		<div v-else-if="view === 'fill' && order" class="of_container">
			<div class="of_topbar">
				<button @click="backToList" class="ri_formbutton">&larr; Voltar</button>
				<span class="of_title">Pedido nº {{ order.id }} — {{ personLabel(order.person) }}</span>
			</div>
			<p v-if="fillError" class="of_error">{{ fillError }}</p>

			<div class="of_tablewrap"><table class="ri_datatable" border="1">
				<thead>
					<tr><th>Item</th><th>Qtd. a separar</th><th>Separado</th><th>Em estoque</th><th>Adicionar separação</th></tr>
				</thead>
				<tbody>
					<tr v-for="line in pickableLines" :key="line.id">
						<td>{{ line.itemtype?.name }}</td>
						<td>{{ line.qty_to_pick }}</td>
						<td>{{ lineFilled(line) }}</td>
						<td>{{ lineOnHand(line) }}</td>
						<td>
							<div class="of_fillentry">
								<SearchSelect
									v-if="itemsForItemtype(line.itemtype_id).length > 1"
									:ref="'itemSelect_' + line.id"
									:scanDigits="true"
									@scan="(code) => onItemScan(line, code)"
									@scanmatch="scanMatchedLocally"
									v-model="entryByLine[line.id].item_id"
									:options="itemsForItemtype(line.itemtype_id)"
									display="name"
									:searchfields="['name', 'upc', 'description']"
									placeholder="Leia ou busque um item..."
									@selected="(item) => itemChosenForLine(line, item)"
								/>
								<ScanButton v-if="itemsForItemtype(line.itemtype_id).length > 1"
									:target="() => $refs['itemSelect_' + line.id]?.[0]" />
								<input
									:ref="'qtyInput_' + line.id"
									type="number" min="0"
									v-model="entryByLine[line.id].qty"
									class="ri_forminput of_qty"
									placeholder="Qtd."
									@keydown.enter.prevent="addFill(line)"
								/>
								<input
									type="text"
									v-model="entryByLine[line.id].pallet_tag"
									class="ri_forminput of_pallet"
									placeholder="Do palete aberto (opcional)"
									title="Deixe em branco para retirar da área de triagem e, depois, dos paletes abertos mais antigos. Um palete lacrado precisa ser aberto primeiro."
									@keydown.enter.prevent="addFill(line)"
								/>
								<button @click="addFill(line)" class="ri_defaultbutton">Adicionar</button>
							</div>
							<div v-if="plans[line.id]" class="of_where">
								<span class="of_where_title">Separar:</span>
								<span v-for="(step, i) in plans[line.id].steps" :key="i" class="of_where_chip"
									:class="{ of_pallet_sealed: step.needs_open }">
									<template v-if="true">
										<strong>{{ step.location || 'sem local' }}</strong> {{ step.tag }} &times;{{ step.qty }}<span v-if="step.expires_on"> (venc. {{ step.expires_on }})</span>
										<template v-if="step.status === 'sealed'">
											<em>{{ step.whole ? 'lacrado — retirar o palete inteiro' : 'lacrado — abrir primeiro' }}</em>
											<button v-if="!step.whole" type="button" class="ri_formbutton" :disabled="openingPalletId === step.pallet_id"
												@click="openPallet({ id: step.pallet_id })">Abrir palete</button>
										</template>
										<em v-else>aberto</em>
									</template>
									<button type="button" class="ri_formbutton of_use" :disabled="step.status === 'sealed' && !step.whole"
										:title="step.status === 'sealed' && !step.whole ? 'Abra o palete primeiro' : 'Preencher a linha usando esta etapa'"
										@click="useStep(line, step)">Usar</button>
								</span>
								<template v-if="plans[line.id].pallet_short > 0">
									<span class="of_hint">{{ plans[line.id].pallet_short }} não estão em um palete.</span>
									<span v-if="plans[line.id].others.length" class="of_hint">Procurar outros:</span>
									<span v-for="(step, i) in plans[line.id].others" :key="'o' + i" class="of_where_chip">
										Área de triagem &times;{{ step.qty }}
										<button type="button" class="ri_formbutton of_use" @click="useStep(line, step)">Usar</button>
									</span>
								</template>
								<span v-if="plans[line.id].short > 0" class="of_hint">{{ plans[line.id].short }} não encontrados no estoque</span>
								<span v-if="!plans[line.id].steps.length && !(plans[line.id].short > 0)" class="of_hint">separado integralmente</span>
							</div>
							<ul v-if="(line.item_ledgers || []).length" class="of_filllist">
								<li v-for="fill in line.item_ledgers" :key="fill.id">
									{{ fill.qty_subtracted }} &mdash; {{ fill.item?.name }}
									<template v-if="confirmingFillKey === fillKey(fill)">
										<button @click="deleteFill(line, fill)" class="of_confirm_delete">Excluir?</button>
										<button @click="confirmingFillKey = null" class="ri_linkbutton">Manter</button>
									</template>
									<img v-else src="/img/delete-icon.webp" class="of_delete" @click="deleteFill(line, fill)" />
								</li>
							</ul>
						</td>
					</tr>
					<tr v-if="!pickableLines.length">
						<td colspan="5">Não há itens para separar neste pedido.</td>
					</tr>
				</tbody>
			</table></div>

			<div class="of_actions">
				<label class="of_palletlabel">
					Paletes embalados
					<input type="number" min="1" step="1" v-model.number="palletCount" class="ri_forminput of_palletinput" placeholder="#" />
				</label>
				<button :disabled="!allLinesAccounted() || savingComplete" @click="completeFilling" class="ri_defaultbutton">
					{{ savingComplete ? 'Concluindo…' : 'Concluir separação' }}
				</button>
				<span v-if="!allLinesAccounted()" class="of_hint">
					Todas as linhas precisam de pelo menos um registro de separação (mesmo 0) antes que este pedido possa ser marcado como separado.
				</span>
				<span v-else-if="nothingPicked" class="of_hint">
					Nenhum item foi separado — ao concluir, este pedido será encerrado como não atendido em vez de
					ser enviado para expedição.
				</span>
			</div>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.of_container {
	max-width: 1100px;
	margin: 0 auto;
	padding: 16px;
}
.of_headeractions {
	float: right;
	display: flex;
	gap: 8px;
}
.of_section {
	margin-top: 1.5em;
}
.of_tablewrap {
	overflow-x: auto;
}
.of_error {
	color: #b91c1c;
	margin: 8px 0;
}
.of_hint {
	color: #666;
	font-size: 0.85rem;
}
.of_card {
	border: 1px solid #ddd;
	border-radius: 8px;
	background: #f9f9f9;
	padding: 14px 16px;
	margin-top: 14px;
}
.of_allocation_group {
	margin-top: 12px;
}
.of_approvalactions {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
	margin-top: 12px;
}
.of_allocation_group h4 {
	font-weight: bold;
	margin-bottom: 4px;
}
.of_topbar {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
	margin-bottom: 12px;
}
.of_title {
	font-weight: bold;
	font-size: 1.15rem;
	flex: 1;
}
.of_fillentry {
	display: flex;
	align-items: center;
	gap: 6px;
	flex-wrap: wrap;
}
.of_where {
	margin: 0.4em 0;
	display: flex;
	flex-wrap: wrap;
	gap: 0.4em;
	align-items: center;
	font-size: 0.9em;
}
.of_where_chip {
	border: 1px solid currentColor;
	border-radius: 4px;
	padding: 0.2em 0.5em;
	display: inline-flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 0.5em;
}
.of_where_chip .ri_formbutton {
	padding: 0.1em 0.7em;
	font-size: 0.95em;
}
.of_pallet_sealed {
	opacity: 0.85;
	border-style: dashed;
}
.of_pallet {
	width: 11em;
}
.of_qty {
	max-width: 6em;
}
.of_filllist {
	list-style: none;
	margin: 6px 0 0 0;
	padding: 0;
	font-size: 0.85rem;
}
.of_filllist li {
	display: flex;
	align-items: center;
	gap: 6px;
	padding: 2px 0;
}
.of_delete {
	width: 14px;
	height: 14px;
	cursor: pointer;
}
.of_confirm_delete {
	color: #b91c1c;
	background: none;
	border: none;
	cursor: pointer;
	font-size: 0.85rem;
	padding: 0;
}
.of_actions {
	margin-top: 16px;
	display: flex;
	align-items: center;
	gap: 12px;
}
.of_palletlabel {
	display: flex;
	align-items: center;
	gap: 6px;
	font-size: 0.9rem;
	color: #444;
}
.of_palletinput {
	width: 60px;
}
.of_modal_overlay {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.5);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 50;
}
.of_modal {
	background: white;
	padding: 20px;
	border-radius: 8px;
	max-width: 90vw;
}
</style>
