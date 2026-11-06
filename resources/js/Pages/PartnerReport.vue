<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- PartnerReport.vue

	Partner Report (PartnerReportController): how much each partner has
	requested and received — requests, units requested vs. filled, fill
	rate on finished requests, shipped/delivered counts, last request —
	with a county roll-up and an expandable list of each partner's
	requests. Order-date range and county filter carry into the CSV and
	PDF/print. Shortfall detail lives in the Unfulfilled Requests Report.
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import ChartCanvas from '@/Components/ChartCanvas.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';
import { transactionStatusLabel } from '@/labels';

export default {
	components: { AuthenticatedLayout, Head, PrintMenu, ChartCanvas },
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
			countyId: '',
			search: '',
			expanded: {},
		};
	},
	computed: {
		appliedParams() {
			const f = this.report?.filters || {};
			const params = {};
			for (const k of ['from', 'to', 'county_id']) {
				if (f[k]) params[k] = f[k];
			}
			return params;
		},
		query() {
			const q = new URLSearchParams(this.appliedParams).toString();
			return q ? '?' + q : '';
		},
		partners() {
			const q = this.search.trim().toLowerCase();
			return (this.report?.partners || []).filter((p) => !q
				|| (p.name || '').toLowerCase().includes(q)
				|| (p.county || '').toLowerCase().includes(q)
				|| String(p.zip || '').includes(q));
		},
		totals() {
			return this.report?.totals;
		},
		countyChart() {
			const rows = (this.report?.by_county || []).slice(0, 15);
			return {
				type: 'bar',
				data: {
					labels: rows.map((r) => r.county),
					datasets: [
						{ label: 'Solicitados', data: rows.map((r) => r.requested), backgroundColor: '#2a78d6', borderRadius: 4 },
						{ label: 'Atendidos', data: rows.map((r) => r.filled), backgroundColor: '#eb6834', borderRadius: 4 },
					],
				},
				options: {
					indexAxis: 'y',
					scales: { x: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.06)' } }, y: { grid: { display: false } } },
					plugins: { legend: { position: 'top', align: 'start' } },
				},
			};
		},
		chartHeight() {
			return Math.max(160, Math.min(15, this.report?.by_county?.length || 0) * 44 + 60);
		},
	},
	methods: {
		async fetchReport() {
			this.loading = true;
			this.error = null;
			const params = {};
			if (this.from) params.from = this.from;
			if (this.to) params.to = this.to;
			if (this.countyId) params.county_id = this.countyId;
			try {
				const response = await axios.get('/json/reports/partners', { params });
				this.report = response.data;
				this.expanded = {};
			} catch (error) {
				this.error = error.response?.status === 422
					? 'Confira as datas: a data final não pode ser anterior à data inicial.'
					: 'Não foi possível carregar o relatório de entidades parceiras.';
			} finally {
				this.loading = false;
			}
		},
		clearFilters() {
			this.from = '';
			this.to = '';
			this.countyId = '';
			this.fetchReport();
		},
		toggleExpanded(key) {
			this.expanded = { ...this.expanded, [key]: !this.expanded[key] };
		},
		rate(value) {
			return value === null || value === undefined ? '—' : value + '%';
		},
		n(value) {
			return Number(value || 0).toLocaleString('pt-BR');
		},
	},
	created() {
		this.fetchReport();
	},
};
</script>

<template>
	<Head title="Relatório de entidades parceiras" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="ptr_container">
			<h2 class="ri_datatable_head ptr_head">
				Relatório de entidades parceiras
				<span class="ptr_exports">
					<a :href="$withWarehouse('/report/partners.csv' + query)" class="ri_defaultbutton">Baixar CSV</a>
					<PrintMenu document-key="partner-report" media="report" label="Imprimir / PDF"
						:params="appliedParams" :download-href="'/report/partners.pdf' + query" />
				</span>
			</h2>

			<p class="ptr_intro">
				O que cada entidade parceira solicitou e recebeu. A taxa de atendimento considera apenas pedidos
				com separação concluída; para ver o que faltou e por quê, consulte o
				<a href="/reports/unfulfilled">Relatório de pedidos não atendidos</a>.
			</p>

			<form class="ptr_toolbar" @submit.prevent="fetchReport">
				<label>Pedidos de <input type="date" v-model="from" class="ri_forminput" /></label>
				<label>até <input type="date" v-model="to" class="ri_forminput" /></label>
				<label>Condado
					<select v-model="countyId" class="ri_forminput" @change="fetchReport">
						<option value="">Todos</option>
						<option v-for="c in report?.options?.counties || []" :key="c.id" :value="c.id">{{ c.county }}, {{ c.state }}</option>
					</select>
				</label>
				<button type="submit" class="ri_defaultbutton">Aplicar</button>
				<button v-if="from || to || countyId" type="button" class="ri_defaultbutton" @click="clearFilters">Limpar</button>
				<input type="text" v-model="search" class="ri_forminput ptr_search"
					placeholder="Buscar entidade parceira, condado ou CEP..." />
			</form>

			<p v-if="error" class="ptr_error">{{ error }}</p>
			<p v-if="loading">Carregando...</p>

			<template v-if="report && !loading">
				<div class="ptr_cards">
					<div class="ptr_card"><span>Entidades parceiras</span><strong>{{ n(totals.partners) }}</strong></div>
					<div class="ptr_card"><span>Pedidos</span><strong>{{ n(totals.requests) }}</strong></div>
					<div class="ptr_card"><span>Solicitado</span><strong>{{ n(totals.requested) }}</strong></div>
					<div class="ptr_card"><span>Atendido</span><strong>{{ n(totals.filled) }}</strong></div>
					<div class="ptr_card"><span>Taxa de atendimento (concluídos)</span><strong>{{ rate(totals.fill_rate) }}</strong></div>
					<div class="ptr_card">
						<span>Enviados / entregues</span><strong>{{ n(totals.shipped) }} / {{ n(totals.delivered) }}</strong>
						<small>pedidos</small>
					</div>
				</div>

				<p v-if="!report.partners.length" class="ptr_empty">
					Nenhum pedido{{ report.filters.from || report.filters.to || report.filters.county_id ? ' com estes filtros' : '' }}.
				</p>

				<template v-else>
					<div class="ptr_places">
						<div class="ptr_chartbox">
							<h3>Solicitados x atendidos por condado</h3>
							<ChartCanvas :config="countyChart" :height="chartHeight" label="Unidades solicitadas e atendidas por condado" />
						</div>
						<div class="ptr_tablewrap">
							<h3>Por condado</h3>
							<table class="ri_datatable" border="1">
								<thead><tr><th>Condado</th><th>Entidades parceiras</th><th>Pedidos</th><th>Solicitado</th><th>Atendido</th></tr></thead>
								<tbody>
									<tr v-for="row in report.by_county" :key="row.county">
										<td>{{ row.county }}</td>
										<td class="ptr_num">{{ n(row.partners) }}</td>
										<td class="ptr_num">{{ n(row.requests) }}</td>
										<td class="ptr_num">{{ n(row.requested) }}</td>
										<td class="ptr_num">{{ n(row.filled) }}</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>

					<h3>Entidades parceiras</h3>
					<div class="ptr_tablewrap"><table class="ri_datatable" border="1">
						<thead>
							<tr>
								<th></th><th>Entidade parceira</th><th>Condado</th><th>CEP</th><th>Pedidos</th><th>Solicitado</th>
								<th>Atendido</th><th title="Quantidade atendida ÷ solicitada, somente pedidos concluídos">Taxa de atendimento</th>
								<th>Enviado</th><th>Entregue</th><th>Último pedido</th>
							</tr>
						</thead>
						<tbody>
							<template v-for="p in partners" :key="p.person_id ?? 'none'">
								<tr class="ptr_rowlink" @click="toggleExpanded(p.person_id ?? 'none')">
									<td class="ptr_expander">{{ expanded[p.person_id ?? 'none'] ? '−' : '+' }}</td>
									<td>{{ p.name }}</td>
									<td>{{ p.county }}</td>
									<td>{{ p.zip }}</td>
									<td class="ptr_num">{{ n(p.requests) }}</td>
									<td class="ptr_num">{{ n(p.requested) }}</td>
									<td class="ptr_num">{{ n(p.filled) }}</td>
									<td class="ptr_num">{{ rate(p.fill_rate) }}</td>
									<td class="ptr_num">{{ n(p.shipped) }}</td>
									<td class="ptr_num">{{ n(p.delivered) }}</td>
									<td>{{ p.last_request }}</td>
								</tr>
								<tr v-if="expanded[p.person_id ?? 'none']" class="ptr_detailrow">
									<td></td>
									<td colspan="10">
										<table class="ptr_subtable">
											<thead><tr><th>Pedido nº</th><th>Data do pedido</th><th>Status</th><th>Solicitado</th><th>Atendido</th></tr></thead>
											<tbody>
												<tr v-for="o in p.orders" :key="o.id">
													<td>{{ o.id }}</td>
													<td>{{ o.order_date }}</td>
													<td>{{ transactionStatusLabel(o.status) }}</td>
													<td class="ptr_num">{{ n(o.requested) }}</td>
													<td class="ptr_num">{{ n(o.filled) }}</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
							</template>
							<tr v-if="!partners.length"><td colspan="11" class="ptr_empty">Nenhuma entidade parceira corresponde à busca.</td></tr>
						</tbody>
					</table></div>
					<p class="ptr_note">
						As quantidades usam a unidade de cada item, portanto o total é uma contagem de unidades, não de peso.
						O condado e o CEP são os da entidade parceira.
					</p>
				</template>
			</template>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.ptr_container { max-width: 1200px; margin: 0 auto; padding: 16px; }
.ptr_head { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.ptr_exports { display: flex; align-items: center; gap: 10px; }
.ptr_intro { color: #555; margin: 0 0 12px 0; }
.ptr_toolbar { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 14px; }
.ptr_toolbar label { display: flex; align-items: center; gap: 6px; }
.ptr_search { min-width: 220px; margin-left: auto; }
.ptr_cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin-bottom: 18px; }
.ptr_card { border: 1px solid #ddd; border-radius: 6px; padding: 10px 12px; background: #fff; display: flex; flex-direction: column; gap: 2px; }
.ptr_card span { color: #666; font-size: 0.85rem; }
.ptr_card strong { font-size: 1.4rem; }
.ptr_card small { color: #666; font-size: 0.75rem; }
.ptr_places { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 18px; margin-bottom: 18px; }
.ptr_chartbox { border: 1px solid #ddd; border-radius: 6px; padding: 10px 12px; background: #fff; }
h3 { font-weight: bold; margin: 6px 0 8px 0; }
.ptr_tablewrap { overflow-x: auto; }
.ptr_rowlink { cursor: pointer; }
.ptr_rowlink:hover { background-color: #eef2ff; }
.ptr_expander { width: 1.5em; text-align: center; font-weight: bold; color: #666; }
.ptr_num { text-align: right; font-variant-numeric: tabular-nums; }
.ptr_detailrow td { background: #fafafa; padding: 8px 8px 12px 8px; }
.ptr_subtable { width: 100%; border-collapse: collapse; }
.ptr_subtable th, .ptr_subtable td { padding: 4px 10px; font-size: 0.9rem; border-bottom: 1px solid #eee; text-align: left; }
.ptr_subtable th { color: #666; font-weight: normal; }
.ptr_subtable td.ptr_num { text-align: right; }
.ptr_empty { text-align: center; color: #777; padding: 1em; }
.ptr_note { color: #777; font-size: 0.85rem; margin-top: 8px; }
.ptr_error { color: #b91c1c; margin: 6px 0; }
</style>
