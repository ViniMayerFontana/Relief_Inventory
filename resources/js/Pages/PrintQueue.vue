<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- PrintQueue.vue

	The print queue (permission: print-documents). Everyone who can print sees
	their own jobs read-only; manage-print-queue sees everyone's and can
	cancel, retry, divert to another printer of the same paper type, and clear
	a printer's waiting jobs. Printer health (online / error / offline) comes
	from each print server's heartbeat. With realtime (Reverb) on it updates the
	instant something happens and polls only as a minute-long safety net; with
	it off, or if the socket drops, it polls every few seconds — see
	rstation/PRINT_SERVER.md. Panel-style page per the admin-page-style
	skill, not RIForm.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import axios from 'axios';
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { onPrintEvent, realtime, startQueueRealtime } from '@/realtime';
import { t } from '@/i18n';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

const POLL_MS = 5000; // fallback cadence when there is no live socket
const SAFETY_POLL_MS = 60000; // belt-and-braces refresh while the socket is healthy

const error = ref('');
const notice = ref('');
const loaded = ref(false);

const view = ref('active'); // 'active' | 'history'
const printerFilter = ref('');
const jobs = ref([]);
const printers = ref([]);
const canManage = ref(false);
const updatedAt = ref(null);

const confirmingCancel = ref(null); // job id
const confirmingClear = ref(null); // printer id
const busyId = ref(null);

const expanded = ref(null); // job id whose history is open
const history = ref([]);

let pollTimer = null;
let reloadTimer = null;
let lastLoadAt = 0;
const unsubscribers = [];

async function load() {
	try {
		const { data } = await axios.get('/json/print-jobs', {
			params: { view: view.value, printer_id: printerFilter.value || undefined },
		});
		jobs.value = data.jobs;
		printers.value = data.printers;
		canManage.value = data.can_manage;
		updatedAt.value = new Date();
		lastLoadAt = Date.now();
		if (data.can_manage) startQueueRealtime();
		if (expanded.value) await loadHistory(expanded.value);
	} catch (e) {
		// A failed refresh shouldn't wipe the screen or nag every 5 seconds.
		if (!loaded.value) error.value = e.response?.data?.message || t('Pages.text.could_not_load_the_7');
	} finally {
		loaded.value = true;
	}
}

function resetFeedback() {
	error.value = '';
	notice.value = '';
}

async function setView(next) {
	view.value = next;
	expanded.value = null;
	await load();
}

const printerById = computed(() => Object.fromEntries(printers.value.map((p) => [p.id, p])));

// Other usable printers a job could move to: same paper, not where it is now.
function divertTargets(job) {
	return printers.value.filter((p) => p.media === job.media && p.id !== job.printer_id);
}

function canCancel(job) {
	return ['queued', 'claimed', t('Commons.heading.failed')].includes(job.status);
}

function canDivert(job) {
	return (job.status === 'queued' || job.status === 'failed') && job.has_file && divertTargets(job).length > 0;
}

async function mutate(job, request, done) {
	resetFeedback();
	busyId.value = job.id;
	try {
		await request();
		notice.value = done;
		await load();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.that_change_could_not');
	} finally {
		busyId.value = null;
	}
}

async function cancelJob(job) {
	if (confirmingCancel.value !== job.id) {
		confirmingCancel.value = job.id;
		return;
	}
	confirmingCancel.value = null;
	await mutate(job, () => axios.post(`/json/print-jobs/${job.id}/cancel`), t('Pages.text.cancelled_p0', { p0: job.title }));
}

async function retryJob(job) {
	await mutate(job, () => axios.post(`/json/print-jobs/${job.id}/retry`), t('Pages.text.p0_is_queued_again', { p0: job.title }));
}

async function divertJob(job, printerId) {
	if (!printerId) return;
	const target = printerById.value[printerId];
	await mutate(
		job,
		() => axios.post(`/json/print-jobs/${job.id}/divert`, { printer_id: printerId }),
		`Moved “${job.title}” to ${target?.name ?? 'the other printer'}.`
	);
}

async function clearPrinter(printer) {
	if (confirmingClear.value !== printer.id) {
		confirmingClear.value = printer.id;
		return;
	}
	confirmingClear.value = null;
	resetFeedback();
	try {
		const { data } = await axios.post('/json/print-jobs/clear', { printer_id: printer.id });
		notice.value = t('Pages.text.cleared_p0_job_p1', { p0: data.cleared, p1: data.cleared === 1 ? '' : 's', p2: printer.name });
		await load();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_clear_that_2');
	}
}

async function toggleHistory(job) {
	if (expanded.value === job.id) {
		expanded.value = null;
		return;
	}
	expanded.value = job.id;
	await loadHistory(job.id);
}

async function loadHistory(id) {
	try {
		const { data } = await axios.get(`/json/print-jobs/${id}`);
		history.value = data.history;
	} catch (e) {
		history.value = [];
	}
}

// ---- display helpers ----
const STATUS_LABELS = { queued: t('Commons.text.waiting'), claimed: t('Commons.text.printing'), failed: t('Commons.text.failed_4'), printed: t('Commons.text.printed'), cancelled: t('Commons.text.cancelled') };
const STATUS_CLASSES = {
	queued: 'bg-blue-100 text-blue-800',
	claimed: 'bg-indigo-100 text-indigo-800',
	failed: 'bg-red-100 text-red-800',
	printed: 'bg-green-100 text-green-800',
	cancelled: 'bg-gray-100 text-gray-600',
};

function statusLabel(status) {
	return STATUS_LABELS[status] || status;
}

function dotClass(printer) {
	if (printer.status === 'idle' || printer.status === 'printing') return 'bg-green-500';
	if (printer.status === 'error') return 'bg-red-500';
	return 'bg-amber-500';
}

function printerStateText(printer) {
	if (printer.status === 'idle') return t('Commons.text.ready');
	if (printer.status === 'printing') return 'printing';
	if (printer.status === 'unavailable') return printer.status_message || 'offline';
	return printer.status_message ? `${printer.status}: ${printer.status_message}` : printer.status;
}

// A waiting job's real situation: if its printer can't take it right now, say so.
function waitingNote(job) {
	if (job.status !== 'queued') return '';
	const printer = printerById.value[job.printer_id];
	if (!printer || printer.ready) return '';
	return t('Pages.text.waiting_printer_is_p0', { p0: printer.status === 'unavailable' ? 'offline' : printer.status });
}

function formatTime(iso) {
	return iso ? new Date(iso).toLocaleString() : '';
}

function age(iso) {
	if (!iso) return '';
	const seconds = Math.max(0, Math.floor((Date.now() - new Date(iso).getTime()) / 1000));
	if (seconds < 60) return t('Commons.text.just_now');
	const minutes = Math.floor(seconds / 60);
	if (minutes < 60) return t('Pages.text.p0_min_ago', { p0: minutes });
	const hours = Math.floor(minutes / 60);
	if (hours < 24) return `${hours} h ago`;
	return `${Math.floor(hours / 24)} d ago`;
}

// A burst of events (a batch printing) becomes one refresh.
function scheduleReload() {
	clearTimeout(reloadTimer);
	reloadTimer = setTimeout(load, 150);
}

onMounted(() => {
	load();
	unsubscribers.push(onPrintEvent('print-job.changed', scheduleReload));
	unsubscribers.push(onPrintEvent('printers.changed', scheduleReload));
	pollTimer = setInterval(() => {
		if (document.hidden) return;
		// Healthy socket: events do the work. Otherwise poll fast.
		if (realtime.connected && Date.now() - lastLoadAt < SAFETY_POLL_MS) return;
		load();
	}, POLL_MS);
});

onUnmounted(() => {
	clearInterval(pollTimer);
	clearTimeout(reloadTimer);
	unsubscribers.forEach((off) => off());
});
</script>

<template>
	<Head :title="$t('Commons.title.print_queue')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.print_queue', {}) }}</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<p v-if="!loaded" class="text-gray-500">{{ $t('Pages.text.loading_print_queue', {}) }}</p>

			<template v-else>
				<!-- Printers -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.printers', {}) }}</h2>
					<p v-if="!printers.length" class="text-sm text-gray-400">
						{{ $t('Pages.text.no_printers_are_set', {}) }}
					</p>
					<div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<div v-for="printer in printers" :key="printer.id" class="border rounded p-3 space-y-1">
							<div class="flex items-center gap-2">
								<span class="inline-block w-3 h-3 rounded-full" :class="dotClass(printer)"></span>
								<strong>{{ printer.name }}</strong>
								<span class="text-gray-500">· {{ printer.site }}</span>
							</div>
							<div class="text-xs text-gray-500">{{ printer.media_label }} — {{ printerStateText(printer) }}</div>
							<div class="flex items-center gap-3">
								<span class="text-xs" :class="printer.pending ? 'text-gray-800' : 'text-gray-400'">
									{{ printer.pending }} waiting
								</span>
								<template v-if="canManage && printer.pending">
									<button
										type="button"
										class="text-xs underline"
										:class="confirmingClear === printer.id ? 'text-red-700 font-semibold' : 'text-gray-600'"
										@click="clearPrinter(printer)"
									>
										{{ confirmingClear === printer.id ? $t('Pages.button.confirm_cancel_waiting_and') : $t('Commons.button.clear_queue') }}
									</button>
									<button v-if="confirmingClear === printer.id" type="button" class="text-xs text-gray-600 underline" @click="confirmingClear = null">{{ $t('Commons.button.cancel', {}) }}</button>
								</template>
							</div>
						</div>
					</div>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.text.a_printer_s_status', {}) }}
					</p>
				</section>

				<!-- Jobs -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<div class="flex flex-wrap items-center gap-3">
						<h2 class="text-lg font-semibold mr-auto">{{ canManage ? $t('Commons.heading.jobs') : $t('Commons.heading.my_jobs') }}</h2>
						<div class="inline-flex rounded-md shadow-sm text-sm" role="group">
							<button
								type="button"
								class="px-3 py-1 border border-gray-300 rounded-l-md"
								:class="view === 'active' ? 'bg-gray-800 text-white' : 'bg-white text-gray-700'"
								@click="setView('active')"
							>{{ $t('Commons.button.active', {}) }}</button>
							<button
								type="button"
								class="px-3 py-1 border border-gray-300 rounded-r-md -ml-px"
								:class="view === 'history' ? 'bg-gray-800 text-white' : 'bg-white text-gray-700'"
								@click="setView('history')"
							>{{ $t('Commons.button.history', {}) }}</button>
						</div>
						<select
							v-if="printers.length > 1"
							v-model="printerFilter"
							class="border-gray-300 rounded-md shadow-sm text-sm"
							@change="load"
						>
							<option value="">{{ $t('Commons.link.all_printers', {}) }}</option>
							<option v-for="printer in printers" :key="printer.id" :value="printer.id">{{ printer.name }}</option>
						</select>
					</div>

					<p v-if="!jobs.length" class="text-sm text-gray-400">
						{{ view === 'active' ? $t('Pages.text.nothing_is_waiting_to') : $t('Pages.text.no_finished_jobs_yet') }}
					</p>

					<div v-else class="overflow-x-auto">
						<table class="w-full text-sm">
							<thead>
								<tr class="text-left text-gray-600">
									<th class="py-1 pr-3">{{ $t('Commons.text.document', {}) }}</th>
									<th class="pr-3">{{ $t('Commons.text.printer', {}) }}</th>
									<th v-if="canManage" class="pr-3">{{ $t('Commons.heading.by', {}) }}</th>
									<th class="pr-3">{{ $t('Commons.text.sent', {}) }}</th>
									<th class="pr-3">{{ $t('Commons.button.status', {}) }}</th>
									<th v-if="canManage"></th>
								</tr>
							</thead>
							<tbody>
								<template v-for="job in jobs" :key="job.id">
									<tr class="border-t align-top">
										<td class="py-2 pr-3">
											<button type="button" class="text-left underline decoration-dotted" @click="toggleHistory(job)">
												{{ job.title }}
											</button>
											<span v-if="job.copies > 1" class="text-gray-500"> × {{ job.copies }}</span>
											<div class="text-xs text-gray-400 font-mono">#{{ job.id }}</div>
										</td>
										<td class="pr-3">
											{{ job.printer_name || '—' }}
											<div v-if="job.site" class="text-xs text-gray-500">{{ job.site }}</div>
										</td>
										<td v-if="canManage" class="pr-3">{{ job.requested_by || '—' }}</td>
										<td class="pr-3 whitespace-nowrap" :title="formatTime(job.created_at)">{{ age(job.created_at) }}</td>
										<td class="pr-3">
											<span class="inline-block rounded px-2 py-0.5 text-xs font-medium" :class="STATUS_CLASSES[job.status]">
												{{ statusLabel(job.status) }}
											</span>
											<div v-if="waitingNote(job)" class="text-xs text-amber-700 mt-1">{{ waitingNote(job) }}</div>
											<div v-if="job.error_message" class="text-xs text-red-700 mt-1">{{ job.error_message }}</div>
											<div v-if="job.status === 'failed' && !job.has_file" class="text-xs text-gray-500 mt-1">
												{{ $t('Pages.text.file_cleaned_up_print', {}) }}
											</div>
										</td>
										<td v-if="canManage" class="whitespace-nowrap space-y-1">
											<div v-if="job.status === 'failed' && job.has_file">
												<button type="button" class="text-xs text-blue-700 underline" :disabled="busyId === job.id" @click="retryJob(job)">{{ $t('Commons.button.retry', {}) }}</button>
											</div>
											<div v-if="canDivert(job)">
												<select
													class="border-gray-300 rounded-md shadow-sm text-xs py-0.5"
													:disabled="busyId === job.id"
													@change="divertJob(job, Number($event.target.value)); $event.target.value = ''"
												>
													<option value="">{{ $t('Commons.text.move_to', {}) }}</option>
													<option v-for="target in divertTargets(job)" :key="target.id" :value="target.id">
														{{ target.name }}{{ target.ready ? '' : ' (' + (target.status === 'unavailable' ? 'offline' : target.status) + ')' }}
													</option>
												</select>
											</div>
											<div v-if="canCancel(job)">
												<button
													type="button"
													class="text-xs underline"
													:class="confirmingCancel === job.id ? 'text-red-700 font-semibold' : 'text-gray-600'"
													:disabled="busyId === job.id"
													@click="cancelJob(job)"
												>
													{{ confirmingCancel === job.id ? $t('Commons.button.confirm_cancel') : $t('Commons.button.cancel') }}
												</button>
												<button v-if="confirmingCancel === job.id" type="button" class="text-xs text-gray-600 underline ml-2" @click="confirmingCancel = null">{{ $t('Commons.button.keep', {}) }}</button>
											</div>
										</td>
									</tr>
									<tr v-if="expanded === job.id" class="bg-gray-50">
										<td :colspan="canManage ? 6 : 4" class="py-2 px-3">
											<ul class="text-xs text-gray-600 space-y-0.5">
												<li v-for="(entry, i) in history" :key="i">
													<span class="font-mono text-gray-500">{{ formatTime(entry.at) }}</span>
													— {{ entry.from && entry.from !== entry.to ? statusLabel(entry.from) + ' → ' : '' }}{{ statusLabel(entry.to) }}
													<span v-if="entry.by"> by {{ entry.by }}</span>
													<span v-if="entry.notes" class="text-gray-500"> · {{ entry.notes }}</span>
												</li>
												<li v-if="!history.length" class="text-gray-400">{{ $t('Pages.text.no_history_recorded', {}) }}</li>
											</ul>
										</td>
									</tr>
								</template>
							</tbody>
						</table>
					</div>

					<p class="text-xs text-gray-500">
						<template v-if="updatedAt">{{ $t('Commons.text.updated') }} {{ updatedAt.toLocaleTimeString() }}. </template>
						{{ realtime.connected ? $t('Pages.text.updating_live') : $t('Pages.text.this_page_refreshes_every') }}
						<template v-if="canManage">{{ $t('Pages.text.cancelling_a_job_that', {}) }}</template>
						Finished jobs' files are removed after a couple of weeks; the record stays.
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
