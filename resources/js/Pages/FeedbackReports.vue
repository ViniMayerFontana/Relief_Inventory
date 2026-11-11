<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- FeedbackReports.vue

	Triage list for in-app bug/feature reports (permission: manage-feedback).
	Each report shows its full history (submission + every status_log entry)
	always visible, not behind a click — history entries are either a real
	status transition ("Moved to X") or a same-status note ("Note"),
	distinguished purely by comparing each entry's status to the one before
	it (historyEntries()), no extra DB column needed. Two actions share the
	same PATCH endpoint (FeedbackReportController@update): advancing to the
	next status (required comment only for Resolved), and leaving a note on
	the current status without advancing it (comment always required,
	available any time before Resolved).

	The site-banner editor used to live on this page too — split out to its
	own page/menu item, SiteBanner.vue, on 2026-08-22.

	Filter/search (2026-08-22): Type/Status/Reported by/Page filters plus a
	free-text search box, all applied client-side against the already-loaded
	`reports` list (same "no extra endpoint, derive options from what's
	loaded" approach as People.vue's donor search) — the report list isn't
	large enough to need server-side filtering.

	Centralized feedback aggregation (2026-09-06): on a 'remote' instance
	(instanceRole prop, initially from FeedbackAggregationSetting, kept in
	sync client-side once the settings panel below loads), each locally-
	created report shows a Submitted/Not Sent badge (FeedbackReportCard.vue),
	and "Send Unsent Reports" sends every not-yet-submitted report in one
	batch — the only retry mechanism; there's no background retry. Hidden
	entirely on a 'central' instance, where this concept doesn't apply. A
	report ingested from a remote instance instead shows a "from: <instance>"
	badge and falls back to a denormalized reporter name/email, since central
	has no Person record for it.

	Aggregation settings: instance role and, for a remote, which paired instance to send through — admin-editable here
	via /json/feedback-aggregation-settings (FeedbackAggregationSettingsController), stored in
	feedback_aggregation_settings (FeedbackAggregationSetting), same singleton-row pattern as
	PinLoginSetting/BannerSetting. Pairing with the central instance is done in the Trust Console (/setup/trust);
	reports travel signed through that trust (see dev/notes/FEDERATION.md). The old shared-secret fields and
	connection codes are gone.
-->

<script setup>
import { onMounted, computed, ref } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import FeedbackReportCard from '@/Components/FeedbackReportCard.vue';
import axios from 'axios';
import { t } from '@/i18n';

const props = defineProps({
	breadcrumb: { type: Array },
	instanceRole: { type: String, default: 'remote' },
});

// Local, mutable copy — the prop is just the page's initial render; once the
// settings panel loads/saves, this is what the rest of the page (the "Send
// Unsent Reports" button's visibility) actually follows.
const currentInstanceRole = ref(props.instanceRole);

const aggregationSettings = ref(null); // { instance_role, feedback_trust_id }
const aggregationForm = ref({ instance_role: 'remote', feedback_trust_id: '' });
const peerTrusts = ref([]); // instances this one is paired with (Trust Console)
const aggregationLoading = ref(true);
const aggregationSaving = ref(false);
const aggregationError = ref(null);
const aggregationSaved = ref(false);

function applySettings(data) {
	aggregationSettings.value = data.settings;
	aggregationForm.value = {
		instance_role: data.settings.instance_role,
		feedback_trust_id: data.settings.feedback_trust_id || '',
	};
	peerTrusts.value = data.trusts || [];
	currentInstanceRole.value = data.settings.instance_role;
}

async function fetchAggregationSettings() {
	aggregationLoading.value = true;
	try {
		applySettings((await axios.get('/json/feedback-aggregation-settings')).data);
	} finally {
		aggregationLoading.value = false;
	}
}

async function saveAggregationSettings() {
	aggregationSaving.value = true;
	aggregationError.value = null;
	aggregationSaved.value = false;
	try {
		const response = await axios.put('/json/feedback-aggregation-settings', {
			instance_role: aggregationForm.value.instance_role,
			feedback_trust_id: aggregationForm.value.feedback_trust_id || null,
		});
		applySettings(response.data);
		aggregationSaved.value = true;
		if (response.data.settings.instance_role === 'remote' && response.data.settings.feedback_trust_id) await testConnection();
	} catch (e) {
		aggregationError.value = e.response?.data?.message || t('Pages.text.could_not_save_these');
	} finally {
		aggregationSaving.value = false;
	}
}

const testingConnection = ref(false);
const connectionTest = ref(null); // { ok, message }

async function testConnection() {
	testingConnection.value = true;
	connectionTest.value = null;
	try {
		const response = await axios.post('/json/feedback-aggregation-settings/test');
		connectionTest.value = response.data;
	} catch (e) {
		connectionTest.value = { ok: false, message: e.response?.data?.message || t('Pages.text.could_not_run_the') };
	} finally {
		testingConnection.value = false;
	}
}

onMounted(fetchAggregationSettings);

const reports = ref([]);
const loading = ref(true);
const composing = ref(null); // { reportId, status, isNote }
const comment = ref('');
const error = ref(null);

// Filters + search
const filterType = ref('');
const filterStatus = ref('');
const filterReporter = ref('');
const filterPage = ref('');
const searchText = ref('');

const reporterOptions = computed(() => {
	const seen = new Map();
	for (const report of reports.value) {
		if (report.person) seen.set(report.person.id, report.person.full_name);
	}
	return [...seen.entries()].map(([id, full_name]) => ({ id, full_name })).sort((a, b) => a.full_name.localeCompare(b.full_name));
});

const pageOptions = computed(() => {
	const seen = new Set();
	for (const report of reports.value) {
		const label = report.page_title || report.page_url;
		if (label) seen.add(label);
	}
	return [...seen].sort((a, b) => a.localeCompare(b));
});

const hasActiveFilters = computed(() =>
	filterType.value || filterStatus.value || filterReporter.value || filterPage.value || searchText.value.trim()
);

function clearFilters() {
	filterType.value = '';
	filterStatus.value = '';
	filterReporter.value = '';
	filterPage.value = '';
	searchText.value = '';
}

const filteredReports = computed(() => {
	const text = searchText.value.trim().toLowerCase();

	return reports.value.filter((report) => {
		if (filterType.value && report.type !== filterType.value) return false;
		if (filterStatus.value && report.status !== filterStatus.value) return false;
		if (filterReporter.value && String(report.person?.id) !== filterReporter.value) return false;
		if (filterPage.value && (report.page_title || report.page_url) !== filterPage.value) return false;
		// "45" or "#45" finds report #45 itself, rather than every message that happens to contain "45".
		const number = text.match(/^#?(\d+)$/);
		if (number) return report.id === Number(number[1]);
		if (text) {
			const commentText = (report.status_logs || []).map((log) => log.comment).filter(Boolean);
			const haystack = [report.message, report.page_title, report.page_url, report.person?.full_name, report.reporter_name, report.instance_identifier, report.warehouse_id, ...commentText]
				.filter(Boolean)
				.join(' ')
				.toLowerCase();
			if (!haystack.includes(text)) return false;
		}
		return true;
	});
});

// Resolved reports fold into their own section, out of the way of active
// triage, unless the status filter is explicitly set to Resolved — at
// which point everything shown already is resolved, so there's nothing
// left to fold.
const activeReports = computed(() =>
	filterStatus.value === 'resolved' ? filteredReports.value : filteredReports.value.filter((r) => r.status !== 'resolved')
);
const resolvedReports = computed(() =>
	filterStatus.value === 'resolved' ? [] : filteredReports.value.filter((r) => r.status === 'resolved')
);

// Also duplicated in FeedbackReportCard.vue (the only other place status
// labels are shown) — kept here too since the Status filter dropdown below
// needs it and prop-drilling a label map for one <select> isn't worth it.
const statusLabels = {
	new: t('Commons.text.new'),
	seen: t('Commons.text.acknowledged'),
	in_development: t('Commons.text.in_development'),
	review: t('Commons.button.review'),
	resolved: t('Commons.text.resolved'),
};

async function fetchReports() {
	loading.value = true;
	const response = await axios.get('/json/feedback-reports');
	reports.value = response.data.records;
	loading.value = false;
}

onMounted(fetchReports);

// "Send Unsent Reports": the only retry mechanism for centralized feedback
// aggregation. Deliberately available even when Offline Mode is on — this
// button IS the explicit "I have a connectivity window right now" override,
// so it doesn't check that setting client-side either.
const sendingUnsent = ref(false);
const sendUnsentMessage = ref(null);

async function sendUnsentReports() {
	sendingUnsent.value = true;
	sendUnsentMessage.value = null;
	try {
		const response = await axios.post('/json/feedback-reports/send-unsent');
		const { attempted, total, sent, error: pushError } = response.data;
		if (!attempted) {
			sendUnsentMessage.value = t('Pages.text.central_push_isn_t');
		} else if (total === 0) {
			sendUnsentMessage.value = t('Pages.text.nothing_to_send_every');
		} else {
			sendUnsentMessage.value = `Sent ${sent} of ${total} report${total === 1 ? '' : 's'}.` + (pushError ? ` ${pushError}` : '');
		}
		await fetchReports();
	} catch (e) {
		sendUnsentMessage.value = e.response?.data?.message || t('Pages.text.could_not_reach_central');
	} finally {
		sendingUnsent.value = false;
	}
}

function startAdvance(reportId, status) {
	composing.value = { reportId, status, isNote: false };
	comment.value = '';
	error.value = null;
}

function startNote(report) {
	composing.value = { reportId: report.id, status: report.status, isNote: true };
	comment.value = '';
	error.value = null;
}

// Reopening is just another transition (the backend has no "resolved is
// final" enforcement — see FeedbackReportController::update), but it needs
// its own required-comment note (why this is being reopened) same as
// resolving needs one, so it's tracked separately from startAdvance.
function startReopen(report) {
	composing.value = { reportId: report.id, status: 'seen', isNote: false, reopening: true };
	comment.value = '';
	error.value = null;
}

function cancelCompose() {
	composing.value = null;
	comment.value = '';
}

async function confirmCompose() {
	const { reportId, status, isNote, reopening } = composing.value;

	if ((isNote || status === 'review' || status === 'resolved' || reopening) && !comment.value.trim()) {
		error.value = isNote ? t('Pages.text.enter_a_note_to') : reopening ? t('Pages.text.enter_why_this_is') : t('Pages.text.a_note_is_required');
		return;
	}

	try {
		await axios.patch(`/json/feedback-reports/${reportId}`, {
			status,
			comment: comment.value.trim() || null,
		});
		composing.value = null;
		comment.value = '';
		await fetchReports();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_update_status');
	}
}

</script>

<template>
	<Head :title="$t('Pages.title.feedback_bug_reports')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Pages.heading.feedback_bug_reports', {}) }}</h1>

			<details class="bg-white shadow rounded-lg p-6">
				<summary class="cursor-pointer text-lg font-semibold select-none">{{ $t('Pages.text.centralized_aggregation_settings', {}) }}</summary>

				<div class="mt-4 space-y-4">
					<p class="text-sm text-gray-500">
						{{ $t('Pages.text.every_instance_s_own', {}) }} <em>be</em> {{ $t('Pages.text.that_central_instance', {}) }}
					</p>

					<p v-if="aggregationLoading" class="text-gray-500 text-sm">{{ $t('Commons.text.loading_settings', {}) }}</p>

					<form v-else class="space-y-4" @submit.prevent="saveAggregationSettings">
						<label class="block text-sm">
							<span class="text-gray-700">{{ $t('Commons.text.role', {}) }}</span>
							<select v-model="aggregationForm.instance_role" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="remote">{{ $t('Pages.text.remote_sends_its_reports', {}) }}</option>
								<option value="central">{{ $t('Pages.text.central_receives_reports_from', {}) }}</option>
							</select>
						</label>

						<p v-if="aggregationForm.instance_role === 'central'" class="text-sm text-gray-600">
							{{ $t('Pages.text.remote_instances_connect_to', {}) }} <a href="/setup/trust" class="underline text-blue-700">{{ $t('Commons.link.trust_console', {}) }}</a>{{ $t('Pages.text.create_a_connection_code', {}) }}
						</p>

						<div v-if="aggregationForm.instance_role === 'remote'" class="rounded-md border border-gray-200 bg-gray-50 p-4 space-y-2 text-sm">
							<label class="block">
								<span class="font-medium text-gray-700">{{ $t('Pages.text.send_reports_to', {}) }}</span>
								<select v-model="aggregationForm.feedback_trust_id" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
									<option value="">{{ $t('Pages.text.choose_an_instance', {}) }}</option>
									<option v-for="t in peerTrusts" :key="t.id" :value="t.id">{{ t.name }} ({{ t.base_url }}){{ t.may_send_feedback ? '' : $t('Pages.text.has_not_allowed_feedback') }}</option>
								</select>
							</label>
							<p class="text-gray-500">
								{{ $t('Pages.text.only_instances_this_one', {}) }}
								<a href="/setup/trust" class="underline text-blue-700">{{ $t('Commons.link.trust_console', {}) }}</a> {{ $t('Pages.text.by_pasting_the_connection', {}) }}
							</p>
						</div>

						<div class="flex items-center gap-3 flex-wrap">
							<button
								type="submit"
								class="px-4 py-2 bg-blue-600 text-white text-sm rounded-md disabled:bg-gray-400"
								:disabled="aggregationSaving"
							>
								{{ aggregationSaving ? $t('Commons.button.saving') : $t('Commons.button.save_settings') }}
							</button>
							<button
								v-if="aggregationSettings?.instance_role === 'remote' && aggregationSettings?.feedback_trust_id"
								type="button"
								class="px-4 py-2 border border-gray-300 text-sm rounded-md disabled:text-gray-400"
								:disabled="testingConnection"
								@click="testConnection"
							>
								{{ testingConnection ? $t('Commons.button.testing') : $t('Commons.button.test_connection') }}
							</button>
							<span v-if="aggregationSaved" class="text-sm text-green-600">{{ $t('Pages.text.saved', {}) }}</span>
							<span v-if="aggregationError" class="text-sm text-red-600">{{ aggregationError }}</span>
						</div>
						<p v-if="connectionTest" class="text-sm" :class="connectionTest.ok ? 'text-green-700' : 'text-red-600'">
							{{ connectionTest.message }}
						</p>
					</form>
				</div>
			</details>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<div class="flex items-center justify-between gap-4 flex-wrap">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.reports', {}) }}</h2>
					<div v-if="currentInstanceRole === 'remote'" class="flex items-center gap-3">
						<button
							class="text-xs font-medium text-blue-600 underline disabled:text-gray-400 disabled:no-underline"
							:disabled="sendingUnsent"
							@click="sendUnsentReports"
						>
							{{ sendingUnsent ? $t('Commons.button.sending') : $t('Pages.button.send_unsent_reports') }}
						</button>
						<span v-if="sendUnsentMessage" class="text-xs text-gray-500">{{ sendUnsentMessage }}</span>
					</div>
				</div>

				<div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm items-end">
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.text.type_2', {}) }}</span>
						<select v-model="filterType" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">{{ $t('Commons.text.all', {}) }}</option>
							<option value="bug">{{ $t('Commons.text.bug', {}) }}</option>
							<option value="feature">{{ $t('Commons.text.feature', {}) }}</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.button.status', {}) }}</span>
						<select v-model="filterStatus" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">{{ $t('Commons.text.all', {}) }}</option>
							<option v-for="(label, key) in statusLabels" :key="key" :value="key">{{ label }}</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.text.reported_by', {}) }}</span>
						<select v-model="filterReporter" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">{{ $t('Commons.text.all', {}) }}</option>
							<option v-for="person in reporterOptions" :key="person.id" :value="String(person.id)">{{ person.full_name }}</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">Page</span>
						<select v-model="filterPage" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">{{ $t('Commons.text.all', {}) }}</option>
							<option v-for="pageLabel in pageOptions" :key="pageLabel" :value="pageLabel">{{ pageLabel }}</option>
						</select>
					</label>
				</div>

				<label class="block text-sm">
					<span class="text-gray-700">{{ $t('Commons.text.search', {}) }}</span>
					<input
						type="text"
						v-model="searchText"
						class="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
						:placeholder="$t('Pages.placeholder.search_message_comments_page')"
					/>
				</label>

				<button v-if="hasActiveFilters" class="text-xs text-blue-600 underline" @click="clearFilters">
					{{ $t('Commons.button.clear_filters', {}) }}
				</button>

				<p v-if="loading" class="text-gray-500">{{ $t('Commons.text.loading_reports', {}) }}</p>

				<div v-else-if="!reports.length" class="text-gray-400">{{ $t('Pages.text.no_reports_yet', {}) }}</div>

				<div v-else-if="!filteredReports.length" class="text-gray-400">{{ $t('Pages.text.no_reports_match_these', {}) }}</div>

				<div v-else class="space-y-4">
					<FeedbackReportCard
						v-for="report in activeReports"
						:key="report.id"
						:report="report"
						:instance-role="currentInstanceRole"
						:composing="composing"
						:comment="comment"
						:error="error"
						:on-start-note="startNote"
						:on-start-advance="startAdvance"
						:on-start-reopen="startReopen"
						:on-confirm-compose="confirmCompose"
						:on-cancel-compose="cancelCompose"
						@update:comment="comment = $event"
					/>

					<!-- Resolved reports fold out of the way of active triage by default
					     (feedback report #30) — collapsed, not hidden, so the count and
					     history are still one click away. Not shown when the Status filter
					     is already narrowed to Resolved, since activeReports covers that
					     case (see the computed above) and this section would just repeat it. -->
					<details v-if="resolvedReports.length" class="pt-2">
						<summary class="cursor-pointer text-sm text-gray-500 select-none">
							Resolved ({{ resolvedReports.length }})
						</summary>
						<div class="space-y-4 mt-4">
							<FeedbackReportCard
								v-for="report in resolvedReports"
								:key="report.id"
								:report="report"
								:instance-role="currentInstanceRole"
								:composing="composing"
								:comment="comment"
								:error="error"
								:on-start-note="startNote"
								:on-start-advance="startAdvance"
								:on-start-reopen="startReopen"
								:on-confirm-compose="confirmCompose"
								:on-cancel-compose="cancelCompose"
								@update:comment="comment = $event"
							/>
						</div>
					</details>
				</div>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
