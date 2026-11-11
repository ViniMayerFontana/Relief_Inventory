<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- InventoryReport.vue

	Stock-on-hand rollup — the ledger (item_ledgers) never gets aggregated
	anywhere else in the app, so this answers "what do we have" for the
	first time. Staff-only: shows exact quantities, which is fine here
	(unlike any future partner-facing surface).

	Rolled up per itemtype (matching the level orders are requested at), with
	an expandable row for the underlying items/SKUs. Defaults to hiding
	itemtypes with no activity at all (received nothing, ever) since the
	full catalog is 450+ entries and most of it isn't stocked by a given
	warehouse — a toggle reveals the full catalog for gap-checking.
-->

<script>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';
import { t } from '@/i18n';

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
			categoryFilter: '',
			showAll: false, // false = only itemtypes with any recorded activity
			newOnly: false, // only itemtypes with anything sorted as New
			expanded: {},
		};
	},
	computed: {
		categories() {
			return [...new Set(this.records.map((r) => r.category).filter(Boolean))].sort();
		},
		hasActivity() {
			return (r) => r.on_hand !== 0 || r.outdated !== 0 || r.trashed !== 0 || r.diverted !== 0;
		},
		filtered() {
			const q = this.search.trim().toLowerCase();
			return this.records.filter((r) => {
				if (!this.showAll && !this.hasActivity(r)) return false;
				if (this.newOnly && !r.received_new) return false;
				if (this.categoryFilter && r.category !== this.categoryFilter) return false;
				if (q && !(
					(r.display_number || '').toLowerCase().includes(q) ||
					(r.name || '').toLowerCase().includes(q)
				)) return false;
				return true;
			});
		},
		totals() {
			return this.filtered.reduce((acc, r) => ({
				on_hand: acc.on_hand + r.on_hand,
				received_new: acc.received_new + r.received_new,
				outdated: acc.outdated + r.outdated,
				trashed: acc.trashed + r.trashed,
				diverted: acc.diverted + r.diverted,
			}), { on_hand: 0, received_new: 0, outdated: 0, trashed: 0, diverted: 0 });
		},
	},
	methods: {
		async fetchReport() {
			this.loading = true;
			this.error = null;
			try {
				const response = await axios.get('/json/reports/inventory');
				this.records = response.data.records;
			} catch (error) {
				this.error = t('Pages.text.could_not_load_the_13');
			} finally {
				this.loading = false;
			}
		},
		toggleExpanded(id) {
			this.expanded = { ...this.expanded, [id]: !this.expanded[id] };
		},
	},
	created() {
		this.fetchReport();
	},
};
</script>

<template>
	<Head :title="$t('Commons.title.inventory_report')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="inv_container">
			<h2 class="ri_datatable_head inv_head">
				{{ $t('Commons.heading.inventory_report', {}) }}
				<a :href="$withWarehouse('/report/inventory.csv')" class="ri_defaultbutton">{{ $t('Commons.link.download_csv', {}) }}</a>
				<PrintMenu document-key="inventory-report" media="report" label="Print / PDF"
					download-href="/report/inventory.pdf" />
			</h2>

			<p v-if="error" class="inv_error">{{ error }}</p>
			<p v-if="loading">{{ $t('Pages.text.loading', {}) }}</p>

			<div class="inv_toolbar">
				<input
					type="text"
					v-model="search"
					class="ri_forminput inv_search"
					:placeholder="$t('Pages.placeholder.search_by_item_or')"
				/>
				<select v-model="categoryFilter" class="ri_forminput">
					<option value="">{{ $t('Commons.text.all_categories', {}) }}</option>
					<option v-for="c in categories" :key="c" :value="c">{{ c }}</option>
				</select>
				<label class="inv_toggle">
					<input type="checkbox" v-model="showAll" />
					{{ $t('Pages.label.show_full_catalog_including', {}) }}
				</label>
				<label class="inv_toggle" title="Usable goods recorded as New at sorting (all-time — stock is pooled once sorted, so this isn't a count of new items still on the shelf)">
					<input type="checkbox" v-model="newOnly" />
					{{ $t('Pages.label.only_items_received_new', {}) }}
				</label>
			</div>

			<div class="inv_tablewrap"><table class="ri_datatable" border="1">
				<thead>
					<tr>
						<th></th>
						<th>{{ $t('Commons.text.item', {}) }}</th>
						<th>{{ $t('Commons.button.name', {}) }}</th>
						<th>{{ $t('Commons.label.category_2', {}) }}</th>
						<th>{{ $t('Commons.text.unit', {}) }}</th>
						<th>{{ $t('Commons.text.on_hand', {}) }}</th>
						<th :title="$t('Pages.title.usable_goods_recorded_as_2')">{{ $t('Commons.text.received_new', {}) }}</th>
						<th>{{ $t('Commons.text.outdated', {}) }}</th>
						<th>{{ $t('Commons.text.trashed', {}) }}</th>
						<th>{{ $t('Commons.text.diverted', {}) }}</th>
					</tr>
				</thead>
				<tbody>
					<template v-for="record in filtered" :key="record.id">
						<tr class="inv_rowlink" @click="toggleExpanded(record.id)">
							<td class="inv_expander">{{ expanded[record.id] ? '−' : '+' }}</td>
							<td>{{ record.display_number || '(unnumbered)' }}</td>
							<td>
								{{ record.name }}
								<span v-if="record.status !== 'orderable'" class="inv_status_badge">{{ record.status }}</span>
							</td>
							<td>{{ record.category }}</td>
							<td>{{ record.unit }}</td>
							<td class="inv_num" :class="{ inv_zero: record.on_hand === 0 }">{{ record.on_hand }}</td>
							<td class="inv_num">{{ record.received_new || '' }}</td>
							<td class="inv_num">{{ record.outdated || '' }}</td>
							<td class="inv_num">{{ record.trashed || '' }}</td>
							<td class="inv_num">{{ record.diverted || '' }}</td>
						</tr>
						<tr v-if="expanded[record.id]" class="inv_detailrow">
							<td></td>
							<td colspan="9">
								<table class="inv_subtable" v-if="record.items.length">
									<thead>
										<tr><th>{{ $t('Pages.text.item_sku', {}) }}</th><th>{{ $t('Commons.placeholder.upc', {}) }}</th><th>{{ $t('Commons.text.on_hand', {}) }}</th><th>{{ $t('Commons.text.received_new', {}) }}</th><th>{{ $t('Commons.text.outdated', {}) }}</th><th>{{ $t('Commons.text.trashed', {}) }}</th><th>{{ $t('Commons.text.diverted', {}) }}</th></tr>
									</thead>
									<tbody>
										<tr v-for="item in record.items" :key="item.id">
											<td>{{ item.description }}</td>
											<td>{{ item.upc }}</td>
											<td class="inv_num">{{ item.on_hand }}</td>
											<td class="inv_num">{{ item.received_new || '' }}</td>
											<td class="inv_num">{{ item.outdated || '' }}</td>
											<td class="inv_num">{{ item.trashed || '' }}</td>
											<td class="inv_num">{{ item.diverted || '' }}</td>
										</tr>
									</tbody>
								</table>
								<p v-else class="inv_empty">{{ $t('Pages.text.no_items_defined_under', {}) }}</p>
								<table class="inv_subtable inv_locations" v-if="record.locations && (record.locations.length || record.unassigned)">
									<thead>
										<tr><th>{{ $t('Commons.text.location', {}) }}</th><th>{{ $t('Commons.text.pallets', {}) }}</th><th>{{ $t('Commons.text.quantity', {}) }}</th></tr>
									</thead>
									<tbody>
										<tr v-for="loc in record.locations" :key="loc.location_id ?? 'none'">
											<td>{{ loc.code || $t('Pages.text.no_location_recorded_2') }}</td>
											<td>
												<span v-for="(p, i) in loc.pallets" :key="p.id" class="inv_pallet">{{ p.tag }} ({{ p.qty }}, {{ p.status }})<span v-if="i < loc.pallets.length - 1">, </span></span>
											</td>
											<td class="inv_num">{{ loc.qty }}</td>
										</tr>
										<tr v-if="record.unassigned" class="inv_unassigned" :title="$t('Pages.title.on_hand_but_not')">
											<td>{{ $t('Pages.text.not_yet_on_a', {}) }}</td>
											<td></td>
											<td class="inv_num">{{ record.unassigned }}</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</template>
					<tr v-if="!filtered.length && !loading">
						<td colspan="10" class="inv_empty">{{ $t('Pages.text.no_item_types_match', {}) }}</td>
					</tr>
				</tbody>
				<tfoot v-if="filtered.length">
					<tr class="inv_totalsrow">
						<td colspan="5">Totals ({{ filtered.length }} item type{{ filtered.length === 1 ? '' : 's' }})</td>
						<td class="inv_num">{{ totals.on_hand }}</td>
						<td class="inv_num">{{ totals.received_new || '' }}</td>
						<td class="inv_num">{{ totals.outdated || '' }}</td>
						<td class="inv_num">{{ totals.trashed || '' }}</td>
						<td class="inv_num">{{ totals.diverted || '' }}</td>
					</tr>
				</tfoot>
			</table></div>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.inv_container {
	max-width: 1200px;
	margin: 0 auto;
	padding: 16px;
}
.inv_head {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
}
.inv_toolbar {
	display: flex;
	align-items: center;
	gap: 14px;
	flex-wrap: wrap;
	margin-bottom: 12px;
}
.inv_search {
	min-width: 220px;
}
.inv_toggle {
	display: flex;
	align-items: center;
	gap: 6px;
	font-size: 0.9rem;
	color: #444;
}
.inv_tablewrap {
	overflow-x: auto;
}
.inv_rowlink {
	cursor: pointer;
}
.inv_rowlink:hover {
	background-color: #eef2ff;
}
.inv_expander {
	width: 1.5em;
	text-align: center;
	font-weight: bold;
	color: #666;
}
.inv_num {
	text-align: right;
	font-variant-numeric: tabular-nums;
}
.inv_zero {
	color: #999;
}
.inv_status_badge {
	background: #fef3c7;
	color: #92400e;
	font-size: 0.7rem;
	font-weight: bold;
	text-transform: uppercase;
	letter-spacing: 0.05em;
	padding: 2px 6px;
	border-radius: 8px;
	margin-left: 6px;
	vertical-align: middle;
}
.inv_detailrow td {
	background: #fafafa;
	padding: 8px 8px 12px 8px;
}
.inv_subtable {
	width: 100%;
	border-collapse: collapse;
}
.inv_subtable th, .inv_subtable td {
	padding: 4px 10px;
	font-size: 0.9rem;
	border-bottom: 1px solid #eee;
	text-align: left;
}
.inv_subtable th {
	color: #666;
	font-weight: normal;
}
.inv_locations {
	margin-top: 0.75em;
}
.inv_unassigned {
	font-style: italic;
}
.inv_empty {
	text-align: center;
	color: #777;
	padding: 1em;
}
.inv_totalsrow td {
	font-weight: bold;
	border-top: 2px solid #ccc;
}
.inv_error {
	color: #b91c1c;
	margin: 6px 0;
}
</style>
