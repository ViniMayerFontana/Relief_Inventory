<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- FlowReport.vue

	Inventory Flow Report (FlowReportController): usable goods received vs.
	picked per day/week/month, a running on-hand line, goods lost at sorting
	(outdated/trashed/diverted — not stock), adjustments by reason and a
	per-item opening → closing table. Date range, bucket size and
	category/item-type filters are carried into the CSV and PDF/print.
	Two charts rather than one dual-axis chart: flow (bars) and on-hand (line).
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import ChartCanvas from '@/Components/ChartCanvas.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';
import { t } from '@/i18n';

const BLUE = '#2a78d6';
const ORANGE = '#eb6834';

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
			bucket: 'week',
			categoryId: '',
			itemtypeId: '',
			search: '',
		};
	},
	computed: {
		// The filters the loaded report was built for, so exports match what's on screen.
		appliedParams() {
			const f = this.report?.filters || {};
			const params = {};
			for (const k of ['from', 'to', 'bucket', 'category_id', 'itemtype_id']) {
				if (f[k]) params[k] = f[k];
			}
			return params;
		},
		query() {
			const q = new URLSearchParams(this.appliedParams).toString();
			return q ? '?' + q : '';
		},
		itemtypeOptions() {
			const all = this.report?.options?.itemtypes || [];
			return this.categoryId ? all.filter((t) => String(t.category_id) === String(this.categoryId)) : all;
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
		labels() {
			return (this.report?.buckets || []).map((b) => this.bucketLabel(b.start));
		},
		flowChart() {
			const b = this.report?.buckets || [];
			return {
				type: 'bar',
				data: {
					labels: this.labels,
					datasets: [
						{ label: 'Received', data: b.map((x) => x.received), backgroundColor: BLUE, borderRadius: 4 },
						{ label: t('Commons.text.picked'), data: b.map((x) => x.picked), backgroundColor: ORANGE, borderRadius: 4 },
					],
				},
				options: {
					scales: { y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.06)' } }, x: { grid: { display: false } } },
					plugins: { legend: { position: 'top', align: t('Commons.text.start') } },
				},
			};
		},
		onHandChart() {
			const b = this.report?.buckets || [];
			return {
				type: 'line',
				data: {
					labels: this.labels,
					datasets: [{
						label: t('Pages.text.on_hand_end_of'), data: b.map((x) => x.on_hand),
						borderColor: BLUE, backgroundColor: BLUE, borderWidth: 2, pointRadius: b.length > 60 ? 0 : 4,
						pointBorderColor: '#fff', pointBorderWidth: 2, tension: 0,
					}],
				},
				options: {
					scales: { y: { grid: { color: 'rgba(0,0,0,0.06)' } }, x: { grid: { display: false } } },
					plugins: { legend: { position: 'top', align: t('Commons.text.start') } },
				},
			};
		},
	},
	methods: {
		async fetchReport() {
			this.loading = true;
			this.error = null;
			const params = {};
			if (this.from) params.from = this.from;
			if (this.to) params.to = this.to;
			params.bucket = this.bucket;
			if (this.categoryId) params.category_id = this.categoryId;
			if (this.itemtypeId) params.itemtype_id = this.itemtypeId;
			try {
				const response = await axios.get('/json/reports/flow', { params });
				this.report = response.data;
				// Show the defaults the server filled in, so the inputs match the report.
				this.from = this.report.filters.from;
				this.to = this.report.filters.to;
			} catch (error) {
				this.error = error.response?.status === 422
					? (error.response.data?.message || t('Pages.text.check_the_dates_the'))
					: t('Pages.text.could_not_load_the_11');
			} finally {
				this.loading = false;
			}
		},
		onCategoryChange() {
			this.itemtypeId = '';
			this.fetchReport();
		},
		bucketLabel(start) {
			const d = new Date(start + 'T00:00:00');
			if (this.bucket === 'month') return d.toLocaleDateString(undefined, { month: 'short', year: 'numeric' });
			return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
		},
		n(value) {
			return Number(value || 0).toLocaleString();
		},
		signed(value) {
			return (value > 0 ? '+' : '') + this.n(value);
		},
	},
	created() {
		this.fetchReport();
	},
};
</script>

<template>
	<Head :title="$t('Pages.title.inventory_flow_report')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="flr_container">
			<h2 class="ri_datatable_head flr_head">
				{{ $t('Pages.heading.inventory_flow_report', {}) }}
				<span class="flr_exports">
					<a :href="$withWarehouse('/report/flow.csv' + query)" class="ri_defaultbutton">{{ $t('Commons.link.download_csv', {}) }}</a>
					<PrintMenu document-key="inventory-flow" media="report" label="Print / PDF"
						:params="appliedParams" :download-href="'/report/flow.pdf' + query" />
				</span>
			</h2>

			<p class="flr_intro">
				{{ $t('Pages.text.usable_goods_in_out', {}) }}
			</p>

			<form class="flr_toolbar" @submit.prevent="fetchReport">
				<label>{{ $t('Commons.label.from', {}) }} <input type="date" v-model="from" class="ri_forminput" /></label>
				<label>to <input type="date" v-model="to" class="ri_forminput" /></label>
				<label>{{ $t('Commons.heading.by', {}) }}
					<select v-model="bucket" class="ri_forminput" @change="fetchReport">
						<option value="day">{{ $t('Commons.text.day', {}) }}</option>
						<option value="week">{{ $t('Commons.text.week', {}) }}</option>
						<option value="month">{{ $t('Commons.text.month', {}) }}</option>
					</select>
				</label>
				<label>{{ $t('Commons.label.category_2', {}) }}
					<select v-model="categoryId" class="ri_forminput" @change="onCategoryChange">
						<option value="">{{ $t('Commons.text.all', {}) }}</option>
						<option v-for="c in report?.options?.categories || []" :key="c.id" :value="c.id">{{ c.name }}</option>
					</select>
				</label>
				<label>{{ $t('Commons.label.item_type_2', {}) }}
					<select v-model="itemtypeId" class="ri_forminput" @change="fetchReport">
						<option value="">{{ $t('Commons.text.all', {}) }}</option>
						<option v-for="t in itemtypeOptions" :key="t.id" :value="t.id">{{ t.name }}</option>
					</select>
				</label>
				<button type="submit" class="ri_defaultbutton">{{ $t('Commons.button.apply', {}) }}</button>
			</form>

			<p v-if="error" class="flr_error">{{ error }}</p>
			<p v-if="loading">{{ $t('Pages.text.loading', {}) }}</p>

			<template v-if="report && !loading">
				<div class="flr_cards">
					<div class="flr_card"><span>{{ $t('Pages.text.opening_on_hand', {}) }}</span><strong>{{ n(totals.opening) }}</strong></div>
					<div class="flr_card"><span>Received</span><strong>{{ n(totals.received) }}</strong></div>
					<div class="flr_card"><span>{{ $t('Commons.text.picked', {}) }}</span><strong>{{ n(totals.picked) }}</strong></div>
					<div class="flr_card"><span>{{ $t('Commons.text.adjustments', {}) }}</span><strong>{{ signed(totals.adjustments) }}</strong></div>
					<div class="flr_card"><span>{{ $t('Pages.text.closing_on_hand', {}) }}</span><strong>{{ n(totals.closing) }}</strong></div>
					<div class="flr_card flr_card_lost">
						<span>{{ $t('Pages.text.lost_at_sorting', {}) }}</span>
						<strong>{{ n(totals.outdated + totals.trashed + totals.diverted) }}</strong>
						<small>{{ n(totals.outdated) }} outdated · {{ n(totals.trashed) }} trashed · {{ n(totals.diverted) }} diverted</small>
					</div>
				</div>

				<div class="flr_charts">
					<div class="flr_chartbox">
						<h3>{{ $t('Pages.heading.received_vs_picked', {}) }}</h3>
						<ChartCanvas :config="flowChart" :label="$t('Pages.label.units_received_and_picked')" />
					</div>
					<div class="flr_chartbox">
						<h3>{{ $t('Commons.heading.on_hand', {}) }}</h3>
						<ChartCanvas :config="onHandChart" :label="$t('Pages.label.units_on_hand_at')" />
					</div>
				</div>

				<h3>{{ $t('Commons.heading.by') }} {{ report.filters.bucket }}</h3>
				<div class="flr_tablewrap"><table class="ri_datatable" border="1">
					<thead>
						<tr>
							<th>{{ $t('Commons.text.period_starting', {}) }}</th><th>Received</th><th>{{ $t('Commons.text.picked', {}) }}</th><th>{{ $t('Commons.text.adjustments', {}) }}</th>
							<th>{{ $t('Pages.text.on_hand_end', {}) }}</th><th>{{ $t('Commons.text.outdated', {}) }}</th><th>{{ $t('Commons.text.trashed', {}) }}</th><th>{{ $t('Commons.text.diverted', {}) }}</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="b in report.buckets" :key="b.start">
							<td>{{ b.start }}</td>
							<td class="flr_num">{{ n(b.received) }}</td>
							<td class="flr_num">{{ n(b.picked) }}</td>
							<td class="flr_num">{{ signed(b.adjustments) }}</td>
							<td class="flr_num">{{ n(b.on_hand) }}</td>
							<td class="flr_num">{{ n(b.outdated) }}</td>
							<td class="flr_num">{{ n(b.trashed) }}</td>
							<td class="flr_num">{{ n(b.diverted) }}</td>
						</tr>
					</tbody>
				</table></div>

				<template v-if="report.adjustment_reasons.length">
					<h3>{{ $t('Pages.heading.adjustments_by_reason', {}) }}</h3>
					<div class="flr_tablewrap flr_narrow"><table class="ri_datatable" border="1">
						<thead><tr><th>{{ $t('Commons.text.reason', {}) }}</th><th>{{ $t('Commons.text.added', {}) }}</th><th>{{ $t('Commons.text.removed', {}) }}</th></tr></thead>
						<tbody>
							<tr v-for="r in report.adjustment_reasons" :key="r.reason">
								<td>{{ r.label }}</td>
								<td class="flr_num">{{ n(r.added) }}</td>
								<td class="flr_num">{{ n(r.removed) }}</td>
							</tr>
						</tbody>
					</table></div>
				</template>

				<h3>{{ $t('Commons.heading.by_item', {}) }}</h3>
				<input type="text" v-model="search" class="ri_forminput flr_search"
					:placeholder="$t('Pages.placeholder.search_item_item_or')" />
				<div class="flr_tablewrap"><table class="ri_datatable" border="1">
					<thead>
						<tr>
							<th>{{ $t('Commons.text.item', {}) }}</th><th>{{ $t('Commons.text.item_2', {}) }}</th><th>{{ $t('Commons.text.unit', {}) }}</th><th>{{ $t('Commons.text.opening', {}) }}</th><th>Received</th><th>{{ $t('Commons.text.picked', {}) }}</th>
							<th>{{ $t('Commons.text.adjustments', {}) }}</th><th>{{ $t('Commons.text.closing', {}) }}</th><th>{{ $t('Commons.text.outdated', {}) }}</th><th>{{ $t('Commons.text.trashed', {}) }}</th><th>{{ $t('Commons.text.diverted', {}) }}</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="i in items" :key="i.itemtype_id">
							<td>{{ i.display_number || '—' }}</td>
							<td>{{ i.name }}<span v-if="i.category" class="flr_category">{{ i.category }}</span></td>
							<td>{{ i.unit }}</td>
							<td class="flr_num">{{ n(i.opening) }}</td>
							<td class="flr_num">{{ n(i.received) }}</td>
							<td class="flr_num">{{ n(i.picked) }}</td>
							<td class="flr_num">{{ signed(i.adjustments) }}</td>
							<td class="flr_num flr_strong">{{ n(i.closing) }}</td>
							<td class="flr_num">{{ n(i.outdated) }}</td>
							<td class="flr_num">{{ n(i.trashed) }}</td>
							<td class="flr_num">{{ n(i.diverted) }}</td>
						</tr>
						<tr v-if="!items.length"><td colspan="11" class="flr_empty">{{ $t('Pages.text.no_item_movement_in', {}) }}</td></tr>
					</tbody>
				</table></div>
				<p class="flr_note">
					{{ $t('Pages.text.quantities_are_in_each', {}) }}
				</p>
			</template>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.flr_container { max-width: 1200px; margin: 0 auto; padding: 16px; }
.flr_head { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
.flr_exports { display: flex; align-items: center; gap: 10px; }
.flr_intro { color: #555; margin: 0 0 12px 0; }
.flr_toolbar { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 14px; }
.flr_toolbar label { display: flex; align-items: center; gap: 6px; }
.flr_cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin-bottom: 18px; }
.flr_card { border: 1px solid #ddd; border-radius: 6px; padding: 10px 12px; background: #fff; display: flex; flex-direction: column; gap: 2px; }
.flr_card span { color: #666; font-size: 0.85rem; }
.flr_card strong { font-size: 1.4rem; }
.flr_card small { color: #666; font-size: 0.75rem; }
.flr_charts { display: grid; grid-template-columns: repeat(auto-fit, minmax(380px, 1fr)); gap: 18px; margin-bottom: 18px; }
.flr_chartbox { border: 1px solid #ddd; border-radius: 6px; padding: 10px 12px; background: #fff; }
h3 { font-weight: bold; margin: 6px 0 8px 0; }
.flr_tablewrap { overflow-x: auto; margin-bottom: 16px; }
.flr_narrow { max-width: 480px; }
.flr_num { text-align: right; font-variant-numeric: tabular-nums; }
.flr_strong { font-weight: bold; }
.flr_category { display: block; color: #777; font-size: 0.8rem; }
.flr_search { min-width: 240px; margin-bottom: 8px; }
.flr_empty { text-align: center; color: #777; padding: 1em; }
.flr_note { color: #777; font-size: 0.85rem; margin-top: 8px; }
.flr_error { color: #b91c1c; margin: 6px 0; }
</style>
