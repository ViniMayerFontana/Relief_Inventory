<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- DonorReport.vue

	Donor Report (DonorReportController): per donor, what was sorted and how
	much of it was lost (outdated + trashed), the loss rate of the most
	recent donations as a trend, a SUGGESTED standing next to the standing
	staff have set, and each donation's own loss %. Setting a standing needs
	manage-donor-standing; the server tells the page whether to offer it.
	A donor under the minimum history shows "not enough data" instead of a
	score. Date range carries into the CSV and PDF/print.
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import ChartCanvas from '@/Components/ChartCanvas.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';
import { transactionStatusLabel } from '@/labels';

const STANDINGS = [
	{ value: 'preferred', label: 'Preferencial' },
	{ value: 'normal', label: 'Normal' },
	{ value: 'watch', label: 'Observar' },
	{ value: 'decline', label: 'Recusar' },
];

export default {
	components: { AuthenticatedLayout, Head, PrintMenu, ChartCanvas },
	props: {
		breadcrumb: { type: Array },
	},
	data() {
		return {
			report: null,
			canSetStanding: false,
			loading: false,
			error: null,
			from: '',
			to: '',
			search: '',
			flaggedOnly: false,
			expanded: {},
			edit: {}, // person_id → { standing, note, saving, error }
			standings: STANDINGS,
		};
	},
	computed: {
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
		donors() {
			const q = this.search.trim().toLowerCase();
			return (this.report?.donors || []).filter((d) => {
				if (this.flaggedOnly && !this.needsReview(d)) return false;
				return !q || (d.name || '').toLowerCase().includes(q);
			});
		},
		totals() {
			return this.report?.totals;
		},
		thresholds() {
			return this.report?.thresholds || {};
		},
		lossChart() {
			const rows = (this.report?.donors || [])
				.filter((d) => d.loss_percent !== null && !d.is_system && d.donations >= (this.thresholds.min_donations || 1))
				.slice(0, 15);
			return {
				type: 'bar',
				data: {
					labels: rows.map((d) => d.name),
					datasets: [{
						label: 'Perda % (vencidos + descartados)', data: rows.map((d) => d.loss_percent),
						backgroundColor: '#eb6834', borderRadius: 4,
					}],
				},
				options: {
					indexAxis: 'y',
					scales: {
						x: { beginAtZero: true, max: 100, grid: { color: 'rgba(0,0,0,0.06)' }, ticks: { callback: (v) => v + '%' } },
						y: { grid: { display: false } },
					},
					plugins: { legend: { display: false } },
				},
				count: rows.length,
			};
		},
		chartHeight() {
			return Math.max(160, this.lossChart.count * 34 + 60);
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
				const response = await axios.get('/json/reports/donors', { params });
				this.report = response.data;
				this.canSetStanding = !!response.data.can_set_standing;
				this.expanded = {};
				this.edit = {};
			} catch (error) {
				this.error = error.response?.status === 422
					? 'Confira as datas: a data final não pode ser anterior à data inicial.'
					: 'Não foi possível carregar o relatório de doadores.';
			} finally {
				this.loading = false;
			}
		},
		clearDates() {
			this.from = '';
			this.to = '';
			this.fetchReport();
		},
		// The suggestion differs from what's set (normal → normal isn't news).
		needsReview(d) {
			return !d.is_system && d.suggested !== null && d.suggested !== d.standing;
		},
		toggleExpanded(d) {
			const open = !this.expanded[d.person_id];
			this.expanded = { ...this.expanded, [d.person_id]: open };
			if (open && !this.edit[d.person_id]) {
				this.edit = { ...this.edit, [d.person_id]: { standing: d.suggested && this.needsReview(d) ? d.suggested : d.standing, note: d.standing_note || '', saving: false, error: null } };
			}
		},
		async saveStanding(d) {
			const e = this.edit[d.person_id];
			e.saving = true;
			e.error = null;
			try {
				await axios.put(`/json/people/${d.person_id}/donor-standing`, { standing: e.standing, note: e.note || null });
				d.standing = e.standing;
				d.standing_note = e.note || null;
				this.report.totals.watch = this.report.donors.filter((x) => !x.is_system && x.standing === 'watch').length;
				this.report.totals.decline = this.report.donors.filter((x) => !x.is_system && x.standing === 'decline').length;
				this.report.totals.needs_review = this.report.donors.filter((x) => this.needsReview(x)).length;
			} catch (error) {
				e.error = error.response?.data?.errors?.note?.[0] || error.response?.data?.message || 'Não foi possível salvar a classificação.';
			} finally {
				e.saving = false;
			}
		},
		label(value) {
			return this.standings.find((s) => s.value === value)?.label || value;
		},
		pct(value) {
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
	<Head title="Relatório de doadores" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="dnr_container">
			<h2 class="ri_datatable_head dnr_head">
				Relatório de doadores
				<span class="dnr_exports">
					<a :href="$withWarehouse('/report/donors.csv' + query)" class="ri_defaultbutton">Baixar CSV</a>
					<PrintMenu document-key="donor-report" media="report" label="Imprimir / PDF"
						:params="appliedParams" :download-href="'/report/donors.pdf' + query" />
				</span>
			</h2>

			<p class="dnr_intro">
				O que cada doador enviou e quanto não pôde ser aproveitado. O percentual de perda corresponde
				a itens vencidos e descartados em relação ao total triado (itens desviados não são contabilizados
				contra o doador). Uma recomendação de classificação exige pelo menos {{ thresholds.min_donations }}
				doações triadas e {{ thresholds.min_units }} unidades; é apenas uma sugestão — a classificação
				definida por você é a que aparece no Recebimento.
			</p>

			<form class="dnr_toolbar" @submit.prevent="fetchReport">
				<label>Doações a partir de <input type="date" v-model="from" class="ri_forminput" /></label>
				<label>até <input type="date" v-model="to" class="ri_forminput" /></label>
				<button type="submit" class="ri_defaultbutton">Aplicar</button>
				<button v-if="from || to" type="button" class="ri_defaultbutton" @click="clearDates">Todas as datas</button>
				<label class="dnr_check"><input type="checkbox" v-model="flaggedOnly" /> Sugestão diferente da classificação</label>
				<input type="text" v-model="search" class="ri_forminput dnr_search" placeholder="Buscar doador..." />
			</form>

			<p v-if="error" class="dnr_error">{{ error }}</p>
			<p v-if="loading">Carregando...</p>

			<template v-if="report && !loading">
				<div class="dnr_cards">
					<div class="dnr_card"><span>Doadores</span><strong>{{ n(totals.donors) }}</strong></div>
					<div class="dnr_card"><span>Doações triadas</span><strong>{{ n(totals.donations) }}</strong></div>
					<div class="dnr_card"><span>Unidades triadas</span><strong>{{ n(totals.units) }}</strong></div>
					<div class="dnr_card"><span>Perda geral</span><strong>{{ pct(totals.loss_percent) }}</strong></div>
					<div class="dnr_card"><span>Em observação / recusa</span><strong>{{ n(totals.watch) }} / {{ n(totals.decline) }}</strong></div>
					<div class="dnr_card dnr_card_review">
						<span>Sugestão diferente</span><strong>{{ n(totals.needs_review) }}</strong>
						<small>doadores para revisar</small>
					</div>
				</div>

				<p v-if="!report.donors.length" class="dnr_empty">
					Nenhuma doação{{ report.filters.from || report.filters.to ? ' neste período' : '' }}.
				</p>

				<template v-else>
					<div v-if="lossChart.count" class="dnr_chartbox">
						<h3>Perda % por doador</h3>
						<ChartCanvas :config="lossChart" :height="chartHeight" label="Percentual de itens triados perdidos por doador" />
					</div>

					<h3>Doadores</h3>
					<div class="dnr_tablewrap"><table class="ri_datatable" border="1">
						<thead>
							<tr>
								<th></th><th>Doador</th><th>Classificação</th><th>Sugerida</th><th>Doações</th><th>Unidades</th>
								<th>Aproveitáveis</th><th>Vencidos</th><th>Descartados</th><th>Desviados</th>
								<th>Perda %</th><th title="Percentual de perda nas três últimas doações triadas do doador">Perda recente %</th><th>Última doação</th>
							</tr>
						</thead>
						<tbody>
							<template v-for="d in donors" :key="d.person_id">
								<tr class="dnr_rowlink" @click="toggleExpanded(d)">
									<td class="dnr_expander">{{ expanded[d.person_id] ? '−' : '+' }}</td>
									<td>{{ d.name }}</td>
									<td><span v-if="!d.is_system" :class="['dnr_badge', 'dnr_badge_' + d.standing]">{{ label(d.standing) }}</span></td>
									<td>
										<span v-if="d.is_system">—</span>
										<span v-else-if="d.suggested === null" class="dnr_muted">dados insuficientes</span>
										<span v-else :class="['dnr_badge', 'dnr_badge_' + d.suggested, needsReview(d) ? 'dnr_differs' : '']">{{ label(d.suggested) }}</span>
									</td>
									<td class="dnr_num">{{ n(d.donations) }}<span v-if="d.unsorted_donations" class="dnr_muted"> +{{ d.unsorted_donations }} não triadas</span></td>
									<td class="dnr_num">{{ n(d.units) }}</td>
									<td class="dnr_num">{{ n(d.usable) }}</td>
									<td class="dnr_num">{{ n(d.outdated) }}</td>
									<td class="dnr_num">{{ n(d.trashed) }}</td>
									<td class="dnr_num">{{ n(d.diverted) }}</td>
									<td class="dnr_num dnr_strong">{{ pct(d.loss_percent) }}</td>
									<td class="dnr_num">{{ pct(d.recent_loss_percent) }}</td>
									<td>{{ d.last_donation }}</td>
								</tr>
								<tr v-if="expanded[d.person_id]" class="dnr_detailrow">
									<td></td>
									<td colspan="12">
										<p v-if="!d.is_system" class="dnr_reason">{{ d.suggestion_reason }}</p>

										<div v-if="canSetStanding && !d.is_system && edit[d.person_id]" class="dnr_standing" @click.stop>
											<label>Classificação
												<select v-model="edit[d.person_id].standing" class="ri_forminput">
													<option v-for="s in standings" :key="s.value" :value="s.value">{{ s.label }}</option>
												</select>
											</label>
											<label class="dnr_notefield">Observação
												<input type="text" v-model="edit[d.person_id].note" class="ri_forminput" maxlength="500"
													:placeholder="edit[d.person_id].standing === 'decline' ? 'Obrigatório: por que recusar?' : 'Opcional'" />
											</label>
											<button type="button" class="ri_defaultbutton" :disabled="edit[d.person_id].saving" @click="saveStanding(d)">
												{{ edit[d.person_id].saving ? 'Salvando...' : 'Salvar classificação' }}
											</button>
											<span v-if="edit[d.person_id].error" class="dnr_error">{{ edit[d.person_id].error }}</span>
										</div>
										<p v-else-if="d.standing_note" class="dnr_reason">Observação: {{ d.standing_note }}</p>

										<table class="dnr_subtable">
											<thead>
												<tr><th>Doação nº</th><th>Data</th><th>Status</th><th>Aproveitáveis</th><th>Vencidos</th><th>Descartados</th><th>Desviados</th><th>Perda %</th></tr>
											</thead>
											<tbody>
												<tr v-for="n2 in d.donation_list" :key="n2.id">
													<td>{{ n2.id }}</td>
													<td>{{ n2.date }}</td>
													<td>{{ transactionStatusLabel(n2.status) }}</td>
													<td class="dnr_num">{{ n(n2.usable) }}</td>
													<td class="dnr_num">{{ n(n2.outdated) }}</td>
													<td class="dnr_num">{{ n(n2.trashed) }}</td>
													<td class="dnr_num">{{ n(n2.diverted) }}</td>
													<td class="dnr_num">{{ pct(n2.loss_percent) }}</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
							</template>
							<tr v-if="!donors.length"><td colspan="13" class="dnr_empty">Nenhum doador corresponde à busca.</td></tr>
						</tbody>
					</table></div>
					<p class="dnr_note">
						Sugestões: observar a partir de {{ thresholds.watch_loss_percent }}% de perda; recusar a partir
						de {{ thresholds.decline_loss_percent }}% em {{ thresholds.decline_min_donations }} ou mais doações;
						preferir até {{ thresholds.preferred_loss_percent }}% em {{ thresholds.preferred_min_donations }} ou
						mais doações e {{ thresholds.preferred_min_units }} ou mais unidades. As quantidades usam a unidade de cada item.
					</p>
				</template>
			</template>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.dnr_container { max-width: 1300px; margin: 0 auto; padding: 16px; }
.dnr_head { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.dnr_exports { display: flex; align-items: center; gap: 10px; }
.dnr_intro { color: #555; margin: 0 0 12px 0; }
.dnr_toolbar { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 14px; }
.dnr_toolbar label { display: flex; align-items: center; gap: 6px; }
.dnr_search { min-width: 200px; margin-left: auto; }
.dnr_cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin-bottom: 18px; }
.dnr_card { border: 1px solid #ddd; border-radius: 6px; padding: 10px 12px; background: #fff; display: flex; flex-direction: column; gap: 2px; }
.dnr_card span { color: #666; font-size: 0.85rem; }
.dnr_card strong { font-size: 1.4rem; }
.dnr_card small { color: #666; font-size: 0.75rem; }
.dnr_card_review strong { color: #b45309; }
.dnr_chartbox { border: 1px solid #ddd; border-radius: 6px; padding: 10px 12px; background: #fff; margin-bottom: 18px; }
h3 { font-weight: bold; margin: 6px 0 8px 0; }
.dnr_tablewrap { overflow-x: auto; }
.dnr_rowlink { cursor: pointer; }
.dnr_rowlink:hover { background-color: #eef2ff; }
.dnr_expander { width: 1.5em; text-align: center; font-weight: bold; color: #666; }
.dnr_num { text-align: right; font-variant-numeric: tabular-nums; }
.dnr_strong { font-weight: bold; }
.dnr_muted { color: #888; font-size: 0.85rem; }
.dnr_badge { display: inline-block; padding: 1px 8px; border-radius: 10px; font-size: 0.8rem; border: 1px solid transparent; }
.dnr_badge_preferred { background: #dcfce7; color: #166534; border-color: #86efac; }
.dnr_badge_normal { background: #f3f4f6; color: #374151; border-color: #d1d5db; }
.dnr_badge_watch { background: #fef3c7; color: #92400e; border-color: #fcd34d; }
.dnr_badge_decline { background: #fee2e2; color: #991b1b; border-color: #fca5a5; }
.dnr_differs { outline: 2px dashed #b45309; outline-offset: 1px; }
.dnr_detailrow td { background: #fafafa; padding: 8px 8px 12px 8px; }
.dnr_reason { color: #555; margin: 0 0 8px 0; }
.dnr_standing { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 10px; }
.dnr_standing label { display: flex; align-items: center; gap: 6px; }
.dnr_notefield input { min-width: 280px; }
.dnr_subtable { width: 100%; border-collapse: collapse; }
.dnr_subtable th, .dnr_subtable td { padding: 4px 10px; font-size: 0.9rem; border-bottom: 1px solid #eee; text-align: left; }
.dnr_subtable th { color: #666; font-weight: normal; }
.dnr_subtable td.dnr_num { text-align: right; }
.dnr_empty { text-align: center; color: #777; padding: 1em; }
.dnr_note { color: #777; font-size: 0.85rem; margin-top: 8px; }
.dnr_error { color: #b91c1c; margin: 6px 0; }
</style>
