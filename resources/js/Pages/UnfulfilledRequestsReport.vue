<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- UnfulfilledRequestsReport.vue

	Requested but not fulfilled (UnfulfilledRequestsReportController): every
	finished request line that got less than was asked for, rolled up per
	item with an expandable county/zip breakdown, plus totals by county and
	by zip. Optional order-date range, carried into the CSV and PDF/print.
	Same expandable-row pattern as OutstandingOrdersReport.vue.
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
			report: null,
			loading: false,
			error: null,
			from: '',
			to: '',
			search: '',
			expanded: {},
		};
	},
	computed: {
		// The range the loaded report was built for — so the exports always
		// match what's on screen, even if the date inputs were edited since.
		appliedParams() {
			const f = this.report?.filters || {};
			const params = {};
			if (f.from) params.from = f.from;
			if (f.to) params.to = f.to;
			return params;
		},
		query() {
			const q = new URLSearchParams(this.appliedParams).toString();
			return q ? '?' + q : '';
		},
		items() {
			const q = this.search.trim().toLowerCase();
			return (this.report?.items || []).filter((i) => !q
				|| (i.name || '').toLowerCase().includes(q)
				|| (i.display_number || '').toLowerCase().includes(q)
				|| (i.category || '').toLowerCase().includes(q));
		},
		totals() {
			return this.report?.totals;
		},
	},
	methods: {
		async fetchReport() {
			this.loading = true;
			this.error = null;
			const params = {};
			if (this.from) params.from = this.from;
			if (this.to) params.to = this.to;
			try {
				const response = await axios.get('/json/reports/unfulfilled', { params });
				this.report = response.data;
				this.expanded = {};
			} catch (error) {
				this.error = error.response?.status === 422
					? 'Check the dates: the "to" date can\'t be before the "from" date.'
					: 'Não foi possível carregar o relatório de pedidos não atendidos.';
			} finally {
				this.loading = false;
			}
		},
		clearDates() {
			this.from = '';
			this.to = '';
			this.fetchReport();
		},
		toggleExpanded(id) {
			this.expanded = { ...this.expanded, [id]: !this.expanded[id] };
		},
		n(value) {
			return Number(value || 0).toLocaleString();
		},
	},
	created() {
		this.fetchReport();
	},
};
</script>

<template>
	<Head title="Relatório de pedidos não atendidos" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="urr_container">
			<h2 class="ri_datatable_head urr_head">
				Relatório de pedidos não atendidos
				<span class="urr_exports">
					<a :href="$withWarehouse('/report/unfulfilled.csv' + query)" class="ri_defaultbutton">Baixar CSV</a>
					<PrintMenu document-key="unfulfilled-requests" media="report" label="Imprimir / PDF"
						:params="appliedParams" :download-href="'/report/unfulfilled.pdf' + query" />
				</span>
			</h2>

			<p class="urr_intro">
				O que as entidades parceiras solicitaram, mas não receberam, em pedidos cuja separação foi
				concluída. Pedidos ainda em preenchimento ou separação não são contabilizados.
			</p>

			<form class="urr_toolbar" @submit.prevent="fetchReport">
				<label>Pedidos de <input type="date" v-model="from" class="ri_forminput" /></label>
				<label>até <input type="date" v-model="to" class="ri_forminput" /></label>
				<button type="submit" class="ri_defaultbutton">Aplicar</button>
				<button v-if="from || to" type="button" class="ri_defaultbutton" @click="clearDates">Todas as datas</button>
				<input type="text" v-model="search" class="ri_forminput urr_search"
					placeholder="Buscar item, nº do item ou categoria..." />
			</form>

			<p v-if="error" class="urr_error">{{ error }}</p>
			<p v-if="loading">Carregando...</p>

			<template v-if="report && !loading">
				<div class="urr_cards">
					<div class="urr_card"><span>Tipos de item com falta</span><strong>{{ n(totals.item_types) }}</strong></div>
					<div class="urr_card"><span>Pedidos afetados</span><strong>{{ n(totals.requests) }}</strong></div>
					<div class="urr_card"><span>Solicitado</span><strong>{{ n(totals.requested) }}</strong></div>
					<div class="urr_card"><span>Atendido</span><strong>{{ n(totals.filled) }}</strong></div>
					<div class="urr_card urr_card_short">
						<span>Não atendido</span><strong>{{ n(totals.not_filled) }}</strong>
						<small>{{ n(totals.cut_at_allocation) }} reduzidos na alocação · {{ n(totals.short_at_picking) }} faltantes na separação</small>
					</div>
				</div>

				<p v-if="!report.items.length" class="urr_empty">
					Nenhum pedido não atendido{{ report.filters.from || report.filters.to ? ' neste período' : '' }}.
				</p>

				<template v-else>
					<div class="urr_places">
						<div v-for="place in [['county', 'Condado'], ['zip', 'CEP']]" :key="place[0]" class="urr_tablewrap">
							<h3>Não atendidos por {{ place[1] }}</h3>
							<table class="ri_datatable" border="1">
								<thead>
									<tr><th>{{ place[1] }}</th><th>Pedidos</th><th>Tipos de item</th><th>Não atendido</th></tr>
								</thead>
								<tbody>
									<tr v-for="row in report['by_' + place[0]]" :key="row[place[0]]">
										<td>{{ row[place[0]] }}</td>
										<td class="urr_num">{{ n(row.requests) }}</td>
										<td class="urr_num">{{ n(row.item_types) }}</td>
										<td class="urr_num">{{ n(row.not_filled) }}</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>

					<h3>Itens não atendidos</h3>
					<div class="urr_tablewrap"><table class="ri_datatable" border="1">
						<thead>
							<tr>
								<th></th>
								<th>Nº do item</th>
								<th>Item</th>
								<th>Unidade</th>
								<th>Pedidos</th>
								<th>Solicitado</th>
								<th>Atendido</th>
								<th>Não atendido</th>
								<th title="Quantidade aprovada menor que a solicitada em Revisar alocação">Reduzido na alocação</th>
								<th title="Aprovado, mas não separado">Faltante na separação</th>
							</tr>
						</thead>
						<tbody>
							<template v-for="item in items" :key="item.itemtype_id">
								<tr class="urr_rowlink" @click="toggleExpanded(item.itemtype_id)">
									<td class="urr_expander">{{ expanded[item.itemtype_id] ? '−' : '+' }}</td>
									<td>{{ item.display_number || '—' }}</td>
									<td>{{ item.name }}<span v-if="item.category" class="urr_category">{{ item.category }}</span></td>
									<td>{{ item.unit }}</td>
									<td class="urr_num">{{ n(item.requests) }}</td>
									<td class="urr_num">{{ n(item.requested) }}</td>
									<td class="urr_num">{{ n(item.filled) }}</td>
									<td class="urr_num urr_short">{{ n(item.not_filled) }}</td>
									<td class="urr_num">{{ n(item.cut_at_allocation) }}</td>
									<td class="urr_num">{{ n(item.short_at_picking) }}</td>
								</tr>
								<tr v-if="expanded[item.itemtype_id]" class="urr_detailrow">
									<td></td>
									<td colspan="9">
										<table class="urr_subtable">
											<thead>
												<tr>
													<th>Condado</th><th>CEP</th><th>Pedidos</th><th>Solicitado</th><th>Atendido</th>
													<th>Não atendido</th><th>Reduzido na alocação</th><th>Faltante na separação</th>
												</tr>
											</thead>
											<tbody>
												<tr v-for="loc in item.locations" :key="loc.county + '|' + loc.zip">
													<td>{{ loc.county }}</td>
													<td>{{ loc.zip }}</td>
													<td class="urr_num">{{ n(loc.requests) }}</td>
													<td class="urr_num">{{ n(loc.requested) }}</td>
													<td class="urr_num">{{ n(loc.filled) }}</td>
													<td class="urr_num">{{ n(loc.not_filled) }}</td>
													<td class="urr_num">{{ n(loc.cut_at_allocation) }}</td>
													<td class="urr_num">{{ n(loc.short_at_picking) }}</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
							</template>
							<tr v-if="!items.length">
								<td colspan="10" class="urr_empty">Nenhum item corresponde à busca.</td>
							</tr>
						</tbody>
					</table></div>
					<p class="urr_note">
						As quantidades usam a unidade de cada item. O condado e o CEP são da entidade parceira solicitante.
					</p>
				</template>
			</template>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.urr_container {
	max-width: 1200px;
	margin: 0 auto;
	padding: 16px;
}
.urr_head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 12px;
}
.urr_exports {
	display: flex;
	align-items: center;
	gap: 10px;
}
.urr_intro {
	color: #555;
	margin: 0 0 12px 0;
}
.urr_toolbar {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
	margin-bottom: 14px;
}
.urr_toolbar label {
	display: flex;
	align-items: center;
	gap: 6px;
}
.urr_search {
	min-width: 220px;
	margin-left: auto;
}
.urr_cards {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
	gap: 12px;
	margin-bottom: 18px;
}
.urr_card {
	border: 1px solid #ddd;
	border-radius: 6px;
	padding: 10px 12px;
	background: #fff;
	display: flex;
	flex-direction: column;
	gap: 2px;
}
.urr_card span {
	color: #666;
	font-size: 0.85rem;
}
.urr_card strong {
	font-size: 1.4rem;
}
.urr_card small {
	color: #666;
	font-size: 0.75rem;
}
.urr_card_short strong {
	color: #b91c1c;
}
.urr_places {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 18px;
	margin-bottom: 18px;
}
h3 {
	font-weight: bold;
	margin: 6px 0 8px 0;
}
.urr_tablewrap {
	overflow-x: auto;
}
.urr_rowlink {
	cursor: pointer;
}
.urr_rowlink:hover {
	background-color: #eef2ff;
}
.urr_expander {
	width: 1.5em;
	text-align: center;
	font-weight: bold;
	color: #666;
}
.urr_num {
	text-align: right;
	font-variant-numeric: tabular-nums;
}
.urr_short {
	color: #b91c1c;
	font-weight: bold;
}
.urr_category {
	display: block;
	color: #777;
	font-size: 0.8rem;
}
.urr_detailrow td {
	background: #fafafa;
	padding: 8px 8px 12px 8px;
}
.urr_subtable {
	width: 100%;
	border-collapse: collapse;
}
.urr_subtable th, .urr_subtable td {
	padding: 4px 10px;
	font-size: 0.9rem;
	border-bottom: 1px solid #eee;
	text-align: left;
}
.urr_subtable th {
	color: #666;
	font-weight: normal;
}
.urr_subtable td.urr_num {
	text-align: right;
}
.urr_empty {
	text-align: center;
	color: #777;
	padding: 1em;
}
.urr_note {
	color: #777;
	font-size: 0.85rem;
	margin-top: 8px;
}
.urr_error {
	color: #b91c1c;
	margin: 6px 0;
}
</style>
