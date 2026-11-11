<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- TestingTools.vue

	Setup > Testing Tools (/setup/testing, admin-system). Two things for finding formatting and performance
	problems before real data exists:

	  Warehouse simulator   progress of a run (the first-run wizard's "Simulate a year" option lands here), and a
	                        Start button while the instance is still empty. The simulator itself is
	                        App\Services\Simulator\WarehouseSimulator; it runs detached, so this page only polls
	                        GET /json/testing/status.
	  Slow queries          the app-side slow-query log plus MariaDB's own slow log (when readable), grouped by
	                        statement shape (worst total time first) or listed newest first. Server half:
	                        TestingToolsController / App\Services\SlowQueryLog.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue';
import { t } from '@/i18n';

defineProps({
	breadcrumb: { type: Array },
});

const status = ref(null);
const error = ref('');
const notice = ref('');
const starting = ref(false);
let timer = null;

const form = reactive({ days: 365, orders: 1200, errors: 4, seed: '' });

const sim = computed(() => status.value?.simulation || { state: t('Commons.button.none') });
const running = computed(() => sim.value.state === 'running');
const percent = computed(() => (sim.value.total ? Math.min(100, Math.round((100 * (sim.value.day || 0)) / sim.value.total)) : 0));
const summary = computed(() => sim.value.summary || null);

const slow = reactive({ view: 'requests', source: t('Commons.text.all_2'), loading: false, loaded: false, entries: [], groups: [], requests: [], db: { available: null, message: null } });

async function loadStatus() {
	try {
		const { data } = await axios.get('/json/testing/status');
		const wasRunning = running.value;
		status.value = data;
		if (wasRunning && data.simulation?.state === 'done') {
			notice.value = t('Pages.text.the_simulation_finished_the');
		}
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_load_status');
	}
}

async function startSimulation() {
	error.value = '';
	notice.value = '';
	starting.value = true;
	try {
		await axios.post('/json/testing/simulation', {
			days: form.days,
			orders: form.orders,
			errors: form.errors,
			seed: form.seed === '' ? null : Number(form.seed),
		});
		await loadStatus();
	} catch (e) {
		error.value = e.response?.data?.message || Object.values(e.response?.data?.errors || {})[0]?.[0] || t('Pages.text.could_not_start_the_5');
	} finally {
		starting.value = false;
	}
}

async function loadSlow() {
	slow.loading = true;
	try {
		const { data } = await axios.get('/json/testing/slow-queries', { params: { source: slow.source } });
		Object.assign(slow, { entries: data.entries, groups: data.groups, requests: data.requests, db: data.db, loaded: true });
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_load_the_20');
	} finally {
		slow.loading = false;
	}
}

async function clearSlow() {
	await axios.delete('/json/testing/slow-queries');
	await loadSlow();
}

const fmtMs = (ms) => (ms >= 1000 ? (ms / 1000).toFixed(2) + ' s' : Math.round(ms) + ' ms');
const fmtKb = (b) => (b >= 1048576 ? (b / 1048576).toFixed(1) + t('Commons.text.mb') : Math.round(b / 1024) + t('Commons.text.kb'));
const fmtTime = (t) => (t ? t.replace('T', ' ').slice(0, 19) : '');
const labels = {
	donations: t('Commons.heading.donations'), orders: t('Commons.text.requests_orders'), order_lines: t('Commons.text.request_lines'), ledger_rows: t('Commons.text.inventory_movements'),
	pallets: t('Pages.text.pallets_containers'), pallet_history_rows: t('Pages.text.pallet_history_rows'), people: t('Pages.text.donors_partners_contacts'),
	drivers: t('Commons.heading.drivers'), donation_offers: t('Commons.text.donation_offers'), locations: t('Commons.button.locations'), item_types_in_play: t('Pages.text.item_types_in_use'),
};

onMounted(async () => {
	await loadStatus();
	loadSlow();
	// Poll faster while a run is going; the page costs one tiny request otherwise.
	timer = setInterval(() => {
		if (running.value || document.visibilityState === 'visible') loadStatus();
	}, 3000);
});
onUnmounted(() => clearInterval(timer));
</script>

<template>
	<Head :title="$t('Commons.title.testing_tools')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-5xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.testing_tools', {}) }}</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<p v-if="!status" class="text-gray-500">{{ $t('Commons.button.loading', {}) }}</p>

			<template v-else>
				<!-- Simulator -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.warehouse_simulator', {}) }}</h2>
					<p class="text-sm text-gray-600">
						{{ $t('Pages.text.fills_a_brand_new', {}) }}
					</p>

					<div v-if="running" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm space-y-2">
						<div>{{ sim.message || $t('Commons.text.running') }} (day {{ sim.day || 0 }} of {{ sim.total }})</div>
						<div class="h-2 bg-blue-100 rounded overflow-hidden"><div class="h-2 bg-blue-600 transition-all" :style="{ width: percent + '%' }"></div></div>
						<div class="text-xs">{{ $t('Pages.text.this_takes_a_minute', {}) }}</div>
					</div>

					<div v-else-if="sim.state === 'failed'" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
						{{ $t('Pages.text.the_simulation_failed_and') }} {{ sim.error }}
					</div>

					<div v-else-if="sim.state === 'done' && summary" class="space-y-3">
						<div class="rounded bg-green-50 border border-green-300 text-green-800 px-4 py-3 text-sm">
							{{ $t('Commons.text.simulated') }} {{ summary.days }} days ({{ summary.from }} to {{ summary.to }}) in {{ summary.seconds }} {{ $t('Pages.text.s_seed') }} <span class="font-mono">{{ summary.seed }}</span>.
							{{ summary.fill_rate_percent }}{{ $t('Pages.text.of_requested_units_were') }}
						</div>
						<div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
							<div v-for="(n, key) in summary.counts" :key="key" class="border rounded p-3">
								<div class="text-gray-500 text-xs">{{ labels[key] || key }}</div>
								<div class="text-lg font-semibold">{{ n.toLocaleString() }}</div>
							</div>
						</div>
						<div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
							<div class="border rounded p-3">
								<div class="text-gray-500 text-xs mb-1">{{ $t('Pages.text.donations_by_status', {}) }}</div>
								<div v-for="(n, name) in summary.donation_statuses" :key="name" class="flex justify-between"><span>{{ name }}</span><span class="font-mono">{{ n }}</span></div>
							</div>
							<div class="border rounded p-3">
								<div class="text-gray-500 text-xs mb-1">{{ $t('Pages.text.requests_by_status', {}) }}</div>
								<div v-for="(n, name) in summary.order_statuses" :key="name" class="flex justify-between"><span>{{ name }}</span><span class="font-mono">{{ n }}</span></div>
							</div>
						</div>
						<div v-if="summary.injected_errors?.length">
							<h3 class="font-semibold text-sm mb-1">{{ $t('Pages.heading.negative_stock_errors_added', {}) }}</h3>
							<div class="overflow-x-auto">
								<table class="min-w-full text-sm">
									<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">{{ $t('Commons.text.date', {}) }}</th><th class="pr-4">{{ $t('Commons.text.request_2', {}) }}</th><th class="pr-4">{{ $t('Commons.text.item_2', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.heading.on_hand', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.picked', {}) }}</th><th class="text-right">{{ $t('Commons.text.left', {}) }}</th></tr></thead>
									<tbody>
										<tr v-for="e in summary.injected_errors" :key="e.order_id + '-' + e.item_id" class="border-t">
											<td class="pr-4 py-1">{{ e.date }}</td><td class="pr-4">#{{ e.order_id }}</td><td class="pr-4">{{ e.item }}</td>
											<td class="pr-4 text-right font-mono">{{ e.on_hand_before }}</td><td class="pr-4 text-right font-mono">{{ e.picked }}</td><td class="text-right font-mono text-red-700">{{ e.on_hand_after }}</td>
										</tr>
									</tbody>
								</table>
							</div>
							<p class="text-xs text-gray-500 mt-1">{{ $t('Pages.text.later_donations_may_have', {}) }}</p>
						</div>
					</div>

					<div v-else-if="status.can_start" class="space-y-4">
						<div class="grid grid-cols-1 sm:grid-cols-4 gap-4 text-sm">
							<label class="block"><span class="text-gray-700">{{ $t('Commons.text.days_back', {}) }}</span>
								<input v-model.number="form.days" type="number" min="7" max="1500" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
							<label class="block"><span class="text-gray-700">{{ $t('Pages.text.requests_approx', {}) }}</span>
								<input v-model.number="form.orders" type="number" min="1" max="20000" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
							<label class="block"><span class="text-gray-700">{{ $t('Commons.text.negative_stock_errors', {}) }}</span>
								<input v-model.number="form.errors" type="number" min="0" max="50" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
							<label class="block"><span class="text-gray-700">{{ $t('Commons.text.seed_optional', {}) }}</span>
								<input v-model="form.seed" type="number" min="1" placeholder="random" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
						</div>
						<PrimaryButton :disabled="starting" @click="startSimulation">{{ starting ? $t('Commons.button.starting') : $t('Commons.button.start_simulation') }}</PrimaryButton>
						<p class="text-xs text-gray-500">
							{{ $t('Pages.text.simulated_data_can_t') }} {{ form.orders.toLocaleString() }} requests makes roughly {{ (form.orders * 10).toLocaleString() }} {{ $t('Pages.text.inventory_movements_and_takes') }}
						</p>
					</div>

					<div v-else class="rounded bg-gray-50 border text-gray-700 px-4 py-3 text-sm">{{ status.blocked_reason }}</div>
				</section>

				<!-- Slow queries -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<div class="flex flex-wrap items-center justify-between gap-2">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.slow_queries', {}) }}</h2>
						<div class="flex flex-wrap items-center gap-3 text-sm">
							<select v-model="slow.view" class="border-gray-300 rounded-md shadow-sm text-sm">
								<option value="requests">{{ $t('Pages.text.slow_pages_whole_requests', {}) }}</option>
								<option value="grouped">{{ $t('Pages.text.queries_grouped_by_statement', {}) }}</option>
								<option value="recent">{{ $t('Pages.text.queries_newest_first', {}) }}</option>
							</select>
							<select v-model="slow.source" @change="loadSlow" class="border-gray-300 rounded-md shadow-sm text-sm">
								<option value="all">App + MariaDB</option>
								<option value="app">{{ $t('Pages.text.app_log_only', {}) }}</option>
								<option value="db">{{ $t('Pages.text.mariadb_log_only', {}) }}</option>
							</select>
							<button type="button" class="underline text-blue-700" @click="loadSlow">{{ slow.loading ? $t('Commons.button.loading') : $t('Commons.button.refresh') }}</button>
							<button type="button" class="underline text-gray-600" @click="clearSlow">{{ $t('Pages.button.clear_app_log', {}) }}</button>
						</div>
					</div>

					<div v-if="!status.slow_log.enabled" class="rounded bg-amber-50 border border-amber-300 text-amber-900 px-4 py-3 text-sm">
						{{ $t('Pages.text.app_side_recording_is', {}) }} <span class="font-mono">RI_SLOW_QUERY_MS=250</span> {{ $t('Pages.text.milliseconds_in_the_environment', {}) }}
					</div>
					<div v-else class="text-xs text-gray-500">{{ $t('Pages.text.recording_queries_slower_than') }} {{ status.slow_log.threshold_ms }} ms.</div>

					<div v-if="slow.db.available === false" class="rounded bg-gray-50 border text-gray-700 px-4 py-3 text-sm">{{ $t('Pages.text.mariadb_slow_log') }} {{ slow.db.message }}</div>

					<p v-if="slow.loaded && slow.view === 'requests' && !slow.requests.length" class="text-gray-400 text-sm">{{ $t('Pages.text.no_slow_chatty_or', {}) }}</p>
					<p v-else-if="slow.loaded && slow.view !== 'requests' && !slow.entries.length" class="text-gray-400 text-sm">{{ $t('Pages.text.no_slow_queries_recorded', {}) }}</p>

					<div v-else-if="slow.view === 'requests'" class="overflow-x-auto">
						<table class="min-w-full text-sm">
							<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">{{ $t('Pages.text.page_endpoint', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.worst', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.avg', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.times', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.in_database', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.queries', {}) }}</th><th class="text-right">{{ $t('Commons.text.response', {}) }}</th></tr></thead>
							<tbody>
								<tr v-for="r in slow.requests" :key="r.source" class="border-t align-top">
									<td class="pr-4 py-2 font-mono text-xs break-all">{{ r.source }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(r.max_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(r.avg_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono">{{ r.count }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(r.max_db_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono">{{ r.max_queries }}</td>
									<td class="py-2 text-right font-mono whitespace-nowrap">{{ fmtKb(r.max_bytes) }}</td>
								</tr>
							</tbody>
						</table>
						<p class="text-xs text-gray-500 mt-2">
							{{ $t('Pages.text.pages_that_took_at') }} {{ status.slow_log.request_ms }} ms, ran {{ status.slow_log.request_queries }}+ queries or sent {{ fmtKb(status.slow_log.request_bytes) }}{{ $t('Pages.text.a_big_response_with') }}
						</p>
					</div>

					<div v-else-if="slow.view === 'grouped'" class="overflow-x-auto">
						<table class="min-w-full text-sm">
							<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">{{ $t('Commons.text.total', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.button.count', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.avg', {}) }}</th><th class="pr-4 text-right">Max</th><th class="pr-4">{{ $t('Pages.text.query_and_where_it', {}) }}</th></tr></thead>
							<tbody>
								<tr v-for="g in slow.groups" :key="g.sql" class="border-t align-top">
									<td class="pr-4 py-2 font-mono whitespace-nowrap">{{ fmtMs(g.total_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono">{{ g.count }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(g.avg_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(g.max_ms) }}</td>
									<td class="py-2">
										<div class="font-mono text-xs break-all">{{ g.sql }}</div>
										<div class="text-xs text-gray-500 mt-1">{{ g.sources.join(' · ') }}<span v-if="g.rows_examined"> {{ $t('Pages.text.up_to') }} {{ g.rows_examined.toLocaleString() }} {{ $t('Commons.text.rows_examined') }}</span></div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>

					<div v-else class="overflow-x-auto">
						<table class="min-w-full text-sm">
							<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">{{ $t('Commons.text.when', {}) }}</th><th class="pr-4 text-right">{{ $t('Commons.text.time', {}) }}</th><th class="pr-4">{{ $t('Commons.label.from', {}) }}</th><th class="pr-4">{{ $t('Commons.text.query', {}) }}</th></tr></thead>
							<tbody>
								<tr v-for="(e, i) in slow.entries.slice(0, 100)" :key="i" class="border-t align-top">
									<td class="pr-4 py-2 font-mono text-xs whitespace-nowrap">{{ fmtTime(e.time) }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(e.ms) }}</td>
									<td class="pr-4 py-2 text-xs">{{ e.origin === 'app' ? e.source : 'MariaDB' + (e.rows_examined ? ' · ' + e.rows_examined.toLocaleString() + ' rows' : '') }}</td>
									<td class="py-2 font-mono text-xs break-all">{{ e.sql }}</td>
								</tr>
							</tbody>
						</table>
					</div>

					<p class="text-xs text-gray-500">
						{{ $t('Pages.text.statements_are_grouped_with', {}) }} <span class="font-mono">{{ $t('Pages.text.php_artisan_slowlog_show', {}) }}</span> (add <span class="font-mono">--recent</span> for newest first).
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
