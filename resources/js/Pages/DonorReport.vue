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
import { t } from '@/i18n';

const STANDINGS = [
	{ value: 'preferred', label: 'Preferred' },
	{ value: 'normal', label: t('Commons.text.normal') },
	{ value: 'watch', label: t('Commons.text.watch') },
	{ value: 'decline', label: t('Commons.text.decline') },
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
						label: 'Loss % (outdated + trashed)', data: rows.map((d) => d.loss_percent),
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
					? t('Pages.text.check_the_dates_the')
					: t('Pages.text.could_not_load_the_12');
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
				e.error = error.response?.data?.errors?.note?.[0] || error.response?.data?.message || t('Pages.text.could_not_save_the_9');
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
			return Number(value || 0).toLocaleString();
		},
	},
	created() {
		this.fetchReport();
	},
};
</script>

<template>
	<Head :title="$t('Commons.title.donor_report')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="dnr_container">
			<h2 class="ri_datatable_head dnr_head">
				{{ $t('Commons.heading.donor_report', {}) }}
				<span class="dnr_exports">
					<a :href="$withWarehouse('/report/donors.csv' + query)" class="ri_defaultbutton">{{ $t('Commons.link.download_csv', {}) }}</a>
					<PrintMenu document-key="donor-report" media="report" label="Print / PDF"
						:params="appliedParams" :download-href="'/report/donors.pdf' + query" />
				</span>
			</h2>

			<p class="dnr_intro">
				What each donor sent and how much of it couldn't be used. Loss % is outdated + trashed over
				everything sorted (diverted goods aren't counted against a donor). A suggested standing needs
				at least {{ thresholds.min_donations }} sorted donations and {{ thresholds.min_units }} {{ $t('Pages.text.units_it_is_only') }}
			</p>

			<form class="dnr_toolbar" @submit.prevent="fetchReport">
				<label>{{ $t('Commons.label.donated_from', {}) }} <input type="date" v-model="from" class="ri_forminput" /></label>
				<label>to <input type="date" v-model="to" class="ri_forminput" /></label>
				<button type="submit" class="ri_defaultbutton">{{ $t('Commons.button.apply', {}) }}</button>
				<button v-if="from || to" type="button" class="ri_defaultbutton" @click="clearDates">{{ $t('Commons.button.all_dates', {}) }}</button>
				<label class="dnr_check"><input type="checkbox" v-model="flaggedOnly" /> {{ $t('Pages.label.suggestion_differs_from_standing', {}) }}</label>
				<input type="text" v-model="search" class="ri_forminput dnr_search" :placeholder="$t('Pages.placeholder.search_donor')" />
			</form>

			<p v-if="error" class="dnr_error">{{ error }}</p>
			<p v-if="loading">{{ $t('Pages.text.loading', {}) }}</p>

			<template v-if="report && !loading">
				<div class="dnr_cards">
					<div class="dnr_card"><span>{{ $t('Commons.heading.donors', {}) }}</span><strong>{{ n(totals.donors) }}</strong></div>
					<div class="dnr_card"><span>{{ $t('Commons.text.sorted_donations', {}) }}</span><strong>{{ n(totals.donations) }}</strong></div>
					<div class="dnr_card"><span>{{ $t('Commons.text.units_sorted', {}) }}</span><strong>{{ n(totals.units) }}</strong></div>
					<div class="dnr_card"><span>{{ $t('Commons.text.overall_loss', {}) }}</span><strong>{{ pct(totals.loss_percent) }}</strong></div>
					<div class="dnr_card"><span>{{ $t('Pages.text.on_watch_decline', {}) }}</span><strong>{{ n(totals.watch) }} / {{ n(totals.decline) }}</strong></div>
					<div class="dnr_card dnr_card_review">
						<span>{{ $t('Commons.text.suggestion_differs', {}) }}</span><strong>{{ n(totals.needs_review) }}</strong>
						<small>{{ $t('Pages.text.donors_worth_a_look', {}) }}</small>
					</div>
				</div>

				<p v-if="!report.donors.length" class="dnr_empty">
					{{ $t('Commons.text.no_donations') }}{{ report.filters.from || report.filters.to ? $t('Pages.text.in_this_date_range') : '' }}.
				</p>

				<template v-else>
					<div v-if="lossChart.count" class="dnr_chartbox">
						<h3>{{ $t('Pages.heading.loss_by_donor', {}) }}</h3>
						<ChartCanvas :config="lossChart" :height="chartHeight" :label="$t('Pages.label.percent_of_sorted_goods')" />
					</div>

					<h3>{{ $t('Commons.heading.donors', {}) }}</h3>
					<div class="dnr_tablewrap"><table class="ri_datatable" border="1">
						<thead>
							<tr>
								<th></th><th>{{ $t('Commons.text.donor', {}) }}</th><th>{{ $t('Commons.label.standing', {}) }}</th><th>{{ $t('Commons.text.suggested', {}) }}</th><th>{{ $t('Commons.heading.donations', {}) }}</th><th>{{ $t('Commons.text.units', {}) }}</th>
								<th>{{ $t('Commons.text.usable', {}) }}</th><th>{{ $t('Commons.text.outdated', {}) }}</th><th>{{ $t('Commons.text.trashed', {}) }}</th><th>{{ $t('Commons.text.diverted', {}) }}</th>
								<th>{{ $t('Commons.text.loss', {}) }}</th><th title="Loss % of the donor's last three sorted donations">{{ $t('Pages.text.recent_loss', {}) }}</th><th>{{ $t('Commons.text.last_donation', {}) }}</th>
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
										<span v-else-if="d.suggested === null" class="dnr_muted">{{ $t('Pages.text.not_enough_data', {}) }}</span>
										<span v-else :class="['dnr_badge', 'dnr_badge_' + d.suggested, needsReview(d) ? 'dnr_differs' : '']">{{ label(d.suggested) }}</span>
									</td>
									<td class="dnr_num">{{ n(d.donations) }}<span v-if="d.unsorted_donations" class="dnr_muted"> +{{ d.unsorted_donations }} unsorted</span></td>
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
											<label>{{ $t('Commons.label.standing', {}) }}
												<select v-model="edit[d.person_id].standing" class="ri_forminput">
													<option v-for="s in standings" :key="s.value" :value="s.value">{{ s.label }}</option>
												</select>
											</label>
											<label class="dnr_notefield">{{ $t('Commons.label.note', {}) }}
												<input type="text" v-model="edit[d.person_id].note" class="ri_forminput" maxlength="500"
													:placeholder="edit[d.person_id].standing === 'decline' ? 'Required: why decline?' : 'Optional'" />
											</label>
											<button type="button" class="ri_defaultbutton" :disabled="edit[d.person_id].saving" @click="saveStanding(d)">
												{{ edit[d.person_id].saving ? $t('Pages.button.saving') : $t('Commons.button.save_standing') }}
											</button>
											<span v-if="edit[d.person_id].error" class="dnr_error">{{ edit[d.person_id].error }}</span>
										</div>
										<p v-else-if="d.standing_note" class="dnr_reason">{{ $t('Commons.text.note_2') }} {{ d.standing_note }}</p>

										<table class="dnr_subtable">
											<thead>
												<tr><th>{{ $t('Commons.text.donation_2', {}) }}</th><th>{{ $t('Commons.text.date', {}) }}</th><th>{{ $t('Commons.button.status', {}) }}</th><th>{{ $t('Commons.text.usable', {}) }}</th><th>{{ $t('Commons.text.outdated', {}) }}</th><th>{{ $t('Commons.text.trashed', {}) }}</th><th>{{ $t('Commons.text.diverted', {}) }}</th><th>{{ $t('Commons.text.loss', {}) }}</th></tr>
											</thead>
											<tbody>
												<tr v-for="n2 in d.donation_list" :key="n2.id">
													<td>{{ n2.id }}</td>
													<td>{{ n2.date }}</td>
													<td>{{ n2.status }}</td>
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
							<tr v-if="!donors.length"><td colspan="13" class="dnr_empty">{{ $t('Pages.text.no_donors_match', {}) }}</td></tr>
						</tbody>
					</table></div>
					<p class="dnr_note">
						{{ $t('Pages.text.suggestions_watch_at') }} {{ thresholds.watch_loss_percent }}%+ loss; decline at
						{{ thresholds.decline_loss_percent }}%+ over {{ thresholds.decline_min_donations }}+ donations;
						preferred at {{ thresholds.preferred_loss_percent }}% or less over {{ thresholds.preferred_min_donations }}+
						donations and {{ thresholds.preferred_min_units }}{{ $t('Pages.text.units_quantities_are_in') }}
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
