<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- OutstandingOrdersReport.vue

	Every order not yet Shipped (New Order / Ready to Fill / Filling /
	Filled) — the "what's still owed to a partner" view Order Entry's own
	list doesn't provide (that page is an entry tool, not a report: no
	export, no line-level detail across orders at a glance).

	Rolled up per order, with an expandable row for its requested lines —
	same interaction pattern as InventoryReport.vue.
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';

export default {
	components: { AuthenticatedLayout, Head, PrintMenu },
	props: {
		breadcrumb: { type: Array },
	},
	data() {
		return {
			records: [],
			loading: false,
			error: null,
			search: '',
			statusFilter: '',
			expanded: {},
		};
	},
	computed: {
		statuses() {
			return [...new Set(this.records.map((r) => r.status).filter(Boolean))].sort();
		},
		filtered() {
			const q = this.search.trim().toLowerCase();
			return this.records.filter((r) => {
				if (this.statusFilter && r.status !== this.statusFilter) return false;
				if (q && !(
					String(r.id).includes(q) ||
					(r.partner || '').toLowerCase().includes(q)
				)) return false;
				return true;
			});
		},
		totals() {
			return this.filtered.reduce((acc, r) => ({
				line_count: acc.line_count + r.line_count,
				qty_requested: acc.qty_requested + r.qty_requested,
			}), { line_count: 0, qty_requested: 0 });
		},
	},
	methods: {
		async fetchReport() {
			this.loading = true;
			this.error = null;
			try {
				const response = await axios.get('/json/reports/orders');
				this.records = response.data.records;
			} catch (error) {
				this.error = 'Não foi possível carregar o relatório de pedidos em aberto.';
			} finally {
				this.loading = false;
			}
		},
		toggleExpanded(id) {
			this.expanded = { ...this.expanded, [id]: !this.expanded[id] };
		},
		statusLabel(status) {
			return ({
				'New Order': 'Novo pedido',
				'Ready to Fill': 'Pronto para separação',
				Filling: 'Em separação',
				Filled: 'Separado',
				Shipped: 'Enviado',
				Delivered: 'Entregue',
				Cancelled: 'Cancelado',
			})[status] || status;
		},
		fulfillmentLabel(method) {
			return ({ Pickup: 'Retirada', Delivery: 'Entrega', pickup: 'Retirada', delivery: 'Entrega' })[method] || method;
		},
	},
	created() {
		this.fetchReport();
	},
};
</script>

<template>
	<Head title="Relatório de pedidos em aberto" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="oor_container">
			<h2 class="ri_datatable_head oor_head">
				Relatório de pedidos em aberto
				<a :href="$withWarehouse('/report/orders.csv')" class="ri_defaultbutton">Baixar CSV</a>
				<PrintMenu document-key="outstanding-orders" media="report" label="Imprimir / PDF"
					download-href="/report/orders.pdf" />
			</h2>

			<p v-if="error" class="oor_error">{{ error }}</p>
			<p v-if="loading">Carregando...</p>

			<div class="oor_toolbar">
				<input
					type="text"
					v-model="search"
					class="ri_forminput oor_search"
					placeholder="Buscar por nº do pedido ou entidade parceira..."
				/>
				<select v-model="statusFilter" class="ri_forminput">
					<option value="">Todos os status</option>
					<option v-for="s in statuses" :key="s" :value="s">{{ statusLabel(s) }}</option>
				</select>
			</div>

			<div class="oor_tablewrap"><table class="ri_datatable" border="1">
				<thead>
					<tr>
						<th></th>
						<th>Pedido nº</th>
						<th>Entidade parceira</th>
						<th>Status</th>
						<th>Data do pedido</th>
						<th>Necessário até</th>
						<th>Forma de atendimento</th>
						<th>Itens</th>
						<th>Quantidade solicitada</th>
					</tr>
				</thead>
				<tbody>
					<template v-for="record in filtered" :key="record.id">
						<tr class="oor_rowlink" @click="toggleExpanded(record.id)">
							<td class="oor_expander">{{ expanded[record.id] ? '−' : '+' }}</td>
							<td>{{ record.id }}</td>
							<td>{{ record.partner || '(sem entidade parceira)' }}</td>
							<td><span class="oor_status_badge">{{ statusLabel(record.status) }}</span></td>
							<td>{{ record.order_date }}</td>
							<td>{{ record.needed_by_date || '—' }}</td>
							<td>{{ fulfillmentLabel(record.fulfillment_method) }}</td>
							<td class="oor_num">{{ record.line_count }}</td>
							<td class="oor_num">{{ record.qty_requested }}</td>
						</tr>
						<tr v-if="expanded[record.id]" class="oor_detailrow">
							<td></td>
							<td colspan="8">
								<p v-if="record.status === 'Filled'" class="oor_bollink">
									<PrintMenu document-key="bol" media="report" label="Gerar conhecimento de embarque" :params="{ id: record.id }"
										:download-href="'/report/bol/' + record.id + '.pdf'" />
									<PrintMenu document-key="shipping-label" media="label_large" label="Etiqueta de envio" :params="{ id: record.id }"
										:download-href="'/report/shipping-label/' + record.id + '.pdf'" />
								</p>
								<table class="oor_subtable" v-if="record.lines.length">
									<thead>
										<tr><th>Nº do item</th><th>Item</th><th>Quantidade solicitada</th><th>Unidade</th></tr>
									</thead>
									<tbody>
										<tr v-for="(line, idx) in record.lines" :key="idx">
											<td>{{ line.display_number || '(sem número)' }}</td>
											<td>{{ line.itemtype }}</td>
											<td class="oor_num">{{ line.qty_requested }}</td>
											<td>{{ line.unit }}</td>
										</tr>
									</tbody>
								</table>
								<p v-else class="oor_empty">Nenhum item neste pedido.</p>
							</td>
						</tr>
					</template>
					<tr v-if="!filtered.length && !loading">
						<td colspan="9" class="oor_empty">Nenhum pedido em aberto corresponde à busca.</td>
					</tr>
				</tbody>
				<tfoot v-if="filtered.length">
					<tr class="oor_totalsrow">
						<td colspan="7">Totais ({{ filtered.length }} {{ filtered.length === 1 ? 'pedido' : 'pedidos' }})</td>
						<td class="oor_num">{{ totals.line_count }}</td>
						<td class="oor_num">{{ totals.qty_requested }}</td>
					</tr>
				</tfoot>
			</table></div>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.oor_container {
	max-width: 1200px;
	margin: 0 auto;
	padding: 16px;
}
.oor_head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
}
.oor_toolbar {
	display: flex;
	align-items: center;
	gap: 14px;
	flex-wrap: wrap;
	margin-bottom: 12px;
}
.oor_search {
	min-width: 220px;
}
.oor_tablewrap {
	overflow-x: auto;
}
.oor_rowlink {
	cursor: pointer;
}
.oor_rowlink:hover {
	background-color: #eef2ff;
}
.oor_expander {
	width: 1.5em;
	text-align: center;
	font-weight: bold;
	color: #666;
}
.oor_num {
	text-align: right;
	font-variant-numeric: tabular-nums;
}
.oor_status_badge {
	background: #fef3c7;
	color: #92400e;
	font-size: 0.7rem;
	font-weight: bold;
	text-transform: uppercase;
	letter-spacing: 0.05em;
	padding: 2px 6px;
	border-radius: 8px;
}
.oor_bollink {
	margin: 0 0 10px 0;
}
.oor_detailrow td {
	background: #fafafa;
	padding: 8px 8px 12px 8px;
}
.oor_subtable {
	width: 100%;
	border-collapse: collapse;
}
.oor_subtable th, .oor_subtable td {
	padding: 4px 10px;
	font-size: 0.9rem;
	border-bottom: 1px solid #eee;
	text-align: left;
}
.oor_subtable th {
	color: #666;
	font-weight: normal;
}
.oor_empty {
	text-align: center;
	color: #777;
	padding: 1em;
}
.oor_totalsrow td {
	font-weight: bold;
	border-top: 2px solid #ccc;
}
.oor_error {
	color: #b91c1c;
	margin: 6px 0;
}
</style>
