<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- FormSubmissions.vue

	Review queue for one form's submissions (permission: review-form-
	submissions, separate from manage-forms — see PermissionsSeeder). Same
	always-visible-history shape as FeedbackReports.vue: submission first,
	then every status_log entry. Approve/deny only show when the form
	requires approval; otherwise the only action is an optional
	acknowledge-with-note.
-->

<script setup>
import { ref, onMounted, computed } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import SearchSelect from '@/Components/SearchSelect.vue';
import axios from 'axios';
import { t } from '@/i18n';

const props = defineProps({
	breadcrumb: { type: Array },
	formId: { type: Number, required: true },
});

const form = ref(null);
const submissions = ref([]);
const loading = ref(true);
const composing = ref(null); // { submissionId, action: 'approve'|'deny'|'note' }
const notes = ref('');
const linkPersonId = ref(null);
const error = ref(null);

async function load() {
	loading.value = true;
	const [formResponse, submissionsResponse] = await Promise.all([
		axios.get(`/json/forms/${props.formId}`),
		axios.get(`/json/forms/${props.formId}/submissions`),
	]);
	form.value = formResponse.data.record;
	submissions.value = submissionsResponse.data.records;
	loading.value = false;
}
onMounted(load);

const statusLabels = { pending: t('Commons.text.pending_2'), approved: t('Commons.text.approved'), denied: t('Commons.text.denied') };
const statusClasses = {
	pending: 'bg-amber-100 text-amber-800',
	approved: 'bg-green-100 text-green-800',
	denied: 'bg-red-100 text-red-800',
};

function formatDateTime(value) {
	return value ? new Date(value).toLocaleString() : '';
}

function startAction(submission, action) {
	composing.value = { submissionId: submission.id, action };
	notes.value = '';
	linkPersonId.value = null;
	error.value = null;
}

function cancelCompose() {
	composing.value = null;
}

async function confirmCompose() {
	const { submissionId, action } = composing.value;
	const payload = { notes: notes.value.trim() || null };
	if (action === 'approve' && linkPersonId.value) {
		payload.link_person_id = linkPersonId.value;
	}

	try {
		const endpoint = { approve: 'approve', deny: 'deny', note: t('Commons.text.note') }[action];
		await axios.post(`/json/forms/${props.formId}/submissions/${submissionId}/${endpoint}`, payload);
		composing.value = null;
		await load();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_update_this');
	}
}
</script>

<template>
	<Head :title="$t('Commons.title.form_submissions')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<div class="flex items-center justify-between">
				<h1 class="text-2xl font-bold">{{ form?.name || $t('Commons.heading.submissions') }}</h1>
				<Link href="/setup/forms" class="text-sm text-blue-600 underline">&larr; Back to Forms</Link>
			</div>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<p v-if="loading" class="text-gray-500">{{ $t('Commons.text.loading_submissions', {}) }}</p>
				<div v-else-if="!submissions.length" class="text-gray-400">{{ $t('Pages.text.no_submissions_yet', {}) }}</div>

				<div v-else class="space-y-4">
					<div v-for="submission in submissions" :key="submission.id" class="border rounded-lg p-4">
						<div class="flex items-center gap-2 text-sm flex-wrap">
							<span class="font-semibold">{{ submission.submitter_name || submission.submitted_by?.full_name || $t('Commons.text.unknown') }}</span>
							<span v-if="submission.submitter_email" class="text-gray-500">{{ submission.submitter_email }}</span>
							<span v-if="submission.approval_status" class="px-2 py-0.5 rounded text-xs font-medium" :class="statusClasses[submission.approval_status]">
								{{ statusLabels[submission.approval_status] }}
							</span>
							<span v-else-if="submission.reviewed_at" class="px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-700">
								{{ $t('Commons.text.reviewed', {}) }}
							</span>
							<span class="text-gray-400 text-xs ml-auto">{{ formatDateTime(submission.created_at) }}</span>
						</div>

						<div class="mt-2 text-sm space-y-1">
							<div v-for="answer in submission.answers" :key="answer.id">
								<span class="font-medium">{{ answer.question_label_snapshot }}:</span>
								{{ answer.value_json ? answer.value_json.join(', ') : answer.value_text }}
							</div>
						</div>

						<div v-if="submission.linked_person" class="mt-2 text-xs text-green-700">
							{{ $t('Pages.text.linked_to_person') }}{{ submission.linked_person.id }} ({{ submission.linked_person.full_name || submission.linked_person.organization }})
						</div>

						<!-- History -->
						<div v-if="submission.status_logs?.length" class="mt-3 pl-4 border-l-2 border-gray-200 space-y-2">
							<div v-for="log in submission.status_logs" :key="log.id" class="rounded border bg-white shadow-sm px-3 py-2 text-xs">
								<span class="font-semibold">
									{{ log.from_status !== log.to_status ? `Moved to ${statusLabels[log.to_status] || log.to_status}` : $t('Commons.label.note') }}
								</span>
								by {{ log.changed_by?.full_name }}
								<span class="text-gray-400">— {{ formatDateTime(log.created_at) }}</span>
								<div v-if="log.notes" class="text-gray-700 mt-1">{{ log.notes }}</div>
							</div>
						</div>

						<!-- Compose -->
						<div v-if="composing?.submissionId === submission.id" class="mt-3 pl-4 space-y-2">
							<div v-if="composing.action === 'approve' && form?.on_approval_action === 'create_or_link_partner'" class="text-xs">
								<div class="text-gray-600 mb-1">{{ $t('Pages.text.link_to_an_existing', {}) }}</div>
								<SearchSelect v-model="linkPersonId" optionsource="/json/people" display="full_name" :placeholder="$t('Pages.placeholder.search_people')" />
							</div>
							<textarea v-model="notes" rows="2" class="block w-full border-gray-300 rounded-md shadow-sm text-sm" :placeholder="$t('Commons.placeholder.optional_note')"></textarea>
							<div v-if="error" class="text-red-700 text-xs">{{ error }}</div>
							<div class="flex gap-2">
								<PrimaryButton @click="confirmCompose">
									{{ { approve: $t('Commons.button.approve'), deny: $t('Commons.button.deny'), note: $t('Commons.button.save_note') }[composing.action] }}
								</PrimaryButton>
								<SecondaryButton @click="cancelCompose">{{ $t('Commons.button.cancel', {}) }}</SecondaryButton>
							</div>
						</div>

						<div v-else class="mt-3 pl-4 flex gap-4 text-xs">
							<template v-if="submission.approval_status === 'pending'">
								<button class="text-green-700 underline font-medium" @click="startAction(submission, 'approve')">{{ $t('Commons.button.approve', {}) }}</button>
								<button class="text-red-700 underline font-medium" @click="startAction(submission, 'deny')">{{ $t('Commons.button.deny', {}) }}</button>
							</template>
							<button v-else class="text-blue-600 underline" @click="startAction(submission, 'note')">{{ $t('Pages.button.add_note', {}) }}</button>
						</div>
					</div>
				</div>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
