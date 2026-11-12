<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- WarehouseDashboard.vue

	Internal, full-detail warehouse activity dashboard (view-dashboard —
	management/admins only, not general volunteer access). Built from the
	same modular card components as the external Situation Report
	(resources/js/Components/Dashboard/) so the two views can never drift
	apart visually — only the data each one is handed differs, and that
	restriction happens server-side in SitrepController, never here.

	This is the "nothing hidden" internal view: exact counts, full pipeline
	detail, and drill-down links into the underlying pages (Orders,
	Sorting, Receiving, Inventory Report).
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import PeriodStatCard from '@/Components/Dashboard/PeriodStatCard.vue';
import BarBreakdownCard from '@/Components/Dashboard/BarBreakdownCard.vue';
import axios from 'axios';
import { t } from '@/i18n';

const DONATION_STAGE_LABELS = { Received: 'Received', Sorting: t('Commons.text.sorting_2'), Complete: t('Commons.text.complete') };
const ORDER_STAGE_LABELS = { 'New Order': t('Commons.button.new_order'), Filling: t('Commons.heading.filling'), Filled: t('Commons.text.filled'), Shipped: t('Commons.text.shipped'), 'Delivered — Waiting on BOL': t('Pages.text.waiting_on_bol') };

export default {
	components: { AuthenticatedLayout, Head, Link, PeriodStatCard, BarBreakdownCard },
	props: {
		breadcrumb: { type: Array },
	},
	data() {
		return {
			data: null,
			loading: false,
			error: null,
		};
	},
	computed: {
		donationPipelineRows() {
			if (!this.data) return [];
			return Object.entries(DONATION_STAGE_LABELS).map(([key, label]) => ({
				label, value: this.data.pipeline.donations[key] || 0,
			}));
		},
		orderPipelineRows() {
			if (!this.data) return [];
			return Object.entries(ORDER_STAGE_LABELS).map(([key, label]) => ({
				label, value: this.data.pipeline.orders[key] || 0,
			}));
		},
		countyRows() {
			if (!this.data) return [];
			return this.data.county_breakdown.map((c) => ({ label: c.county, value: c.count }));
		},
		categoryRows() {
			if (!this.data) return [];
			return this.data.inventory_summary.top_categories.map((c) => ({ label: c.category, value: c.units }));
		},
	},
	methods: {
		async fetchDashboard() {
			this.loading = true;
			this.error = null;
			try {
				const response = await axios.get('/json/dashboard');
				this.data = response.data;
			} catch (error) {
				this.error = t('Pages.text.could_not_load_the_24');
			} finally {
				this.loading = false;
			}
		},
	},
	created() {
		this.fetchDashboard();
	},
};
</script>

<template>
	<Head :title="$t('Commons.title.warehouse_dashboard')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="wd_container">
			<div class="wd_topbar">
				<h2 class="ri_datatable_head">{{ $t('Commons.heading.warehouse_dashboard', {}) }}</h2>
				<span v-if="data" class="wd_generated">
					{{ $t('Pages.text.live_as_of') }} {{ new Date(data.generated_at).toLocaleString() }}
					<button @click="fetchDashboard" class="ri_linkbutton">{{ $t('Commons.button.refresh', {}) }}</button>
				</span>
			</div>

			<p v-if="error" class="wd_error">{{ error }}</p>
			<p v-if="loading && !data">{{ $t('Pages.text.loading', {}) }}</p>

			<div v-if="data" class="wd_grid">
				<PeriodStatCard :title="$t('Commons.title.orders_fulfilled')" :counts="data.orders_fulfilled" :trend="data.orders_trend" />
				<PeriodStatCard :title="$t('Commons.title.donations_completed')" :counts="data.donations_completed" :trend="data.donations_trend" />

				<BarBreakdownCard :title="$t('Pages.title.donations_in_progress')" :rows="donationPipelineRows" />
				<BarBreakdownCard :title="$t('Pages.title.orders_in_progress')" :rows="orderPipelineRows" />

				<BarBreakdownCard :title="$t('Pages.title.orders_by_county')" :rows="countyRows" empty-text="No orders placed yet." />
				<BarBreakdownCard :title="$t('Pages.title.stock_by_category')" :rows="categoryRows" empty-text="No stock on hand yet." />

				<div class="wd_card wd_inventory">
					<h3>{{ $t('Commons.heading.inventory_summary', {}) }}</h3>
					<div class="wd_inv_stats">
						<div><span class="wd_inv_value">{{ data.inventory_summary.item_types_with_stock }}</span><span class="wd_inv_label">{{ $t('Pages.text.item_types_stocked', {}) }}</span></div>
						<div><span class="wd_inv_value">{{ data.inventory_summary.total_units_on_hand }}</span><span class="wd_inv_label">{{ $t('Pages.text.total_units_on_hand', {}) }}</span></div>
					</div>
					<Link href="/reports/inventory" class="ri_linkbutton">View full Inventory Report &rarr;</Link>
				</div>

				<div class="wd_card wd_donorquality">
					<h3>{{ $t('Pages.heading.donor_quality_last_30', {}) }}</h3>
					<div class="wd_dq_stats">
						<span class="wd_dq_usable">{{ data.donor_quality.usable }} usable</span>
						<span class="wd_dq_loss">{{ data.donor_quality.outdated }} outdated</span>
						<span class="wd_dq_loss">{{ data.donor_quality.trashed }} trashed</span>
						<span class="wd_dq_diverted">{{ data.donor_quality.diverted }} diverted</span>
					</div>
					<p v-if="data.donor_quality.loss_rate_percent !== null" class="wd_dq_rate">
						{{ $t('Commons.text.loss_rate', {}) }} <strong>{{ data.donor_quality.loss_rate_percent }}%</strong>
					</p>
				</div>
			</div>

			<div v-if="data" class="wd_links">
				<Link href="/order-entry" class="ri_formbutton">{{ $t('Commons.heading.order_entry', {}) }}</Link>
				<Link href="/donation-sorting" class="ri_formbutton">{{ $t('Commons.heading.donation_sorting', {}) }}</Link>
				<Link href="/receiving" class="ri_formbutton">Receiving</Link>
				<Link href="/reports/inventory" class="ri_formbutton">{{ $t('Commons.heading.inventory_report', {}) }}</Link>
				<Link href="/reports/sitrep" class="ri_formbutton">Situation Report &rarr;</Link>
			</div>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.wd_container {
	max-width: 1200px;
	margin: 0 auto;
	padding: 16px;
}
.wd_topbar {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 10px;
	margin-bottom: 12px;
}
.wd_generated {
	font-size: 0.85rem;
	color: #888;
}
.wd_grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
	gap: 16px;
}
.wd_card {
	background: #fff;
	border: 1px solid #e5e7eb;
	border-radius: 10px;
	padding: 16px 18px;
}
.wd_card h3 {
	font-size: 1rem;
	font-weight: bold;
	margin: 0 0 12px 0;
}
.wd_inv_stats {
	display: flex;
	gap: 24px;
	margin-bottom: 10px;
}
.wd_inv_value {
	display: block;
	font-size: 1.6rem;
	font-weight: bold;
	color: #1e3a8a;
}
.wd_inv_label {
	display: block;
	font-size: 0.75rem;
	color: #888;
}
.wd_dq_stats {
	display: flex;
	gap: 14px;
	flex-wrap: wrap;
	font-size: 0.9rem;
	margin-bottom: 8px;
}
.wd_dq_usable {
	color: #15803d;
	font-weight: bold;
}
.wd_dq_loss {
	color: #b91c1c;
}
.wd_dq_diverted {
	color: #4f46e5;
}
.wd_dq_rate {
	font-size: 0.9rem;
	color: #444;
}
.wd_links {
	display: flex;
	gap: 10px;
	flex-wrap: wrap;
	margin-top: 20px;
}
.wd_error {
	color: #b91c1c;
	margin: 6px 0;
}
</style>
