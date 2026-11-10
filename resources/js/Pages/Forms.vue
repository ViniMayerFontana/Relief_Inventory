<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Forms.vue

	Generic admin form/survey builder (permission: manage-forms). Built on
	RIForm for the form-level metadata (name/slug/intro/status/access/
	approval/notifications), with a custom question-builder section below it
	once a record has a real id — same "RIForm for metadata, custom UI for
	the part RIForm can't express" split Receiving.vue uses for its wizard.
	Reordering is up/down buttons rather than drag-and-drop (persists via
	POST .../questions/reorder after every move); presets are a checkbox
	picker that copies editable FormQuestion rows onto the form.

	Submission review lives on a separate page (FormSubmissions.vue),
	reached via a link in #titleactions once a form is selected — same "no
	new nav item" choice as Donation Offers living inside Receiving.
-->

<script setup>
import { ref, onMounted, computed } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import RIForm from '@/Components/RIForm.vue';
import TextInput from '@/Components/TextInput.vue';
import TextArea from '@/Components/TextArea.vue';
import Checkbox from '@/Components/Checkbox.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import axios from 'axios';
import { t } from '@/i18n';

defineProps({
	breadcrumb: { type: Array },
});

const statusOptions = [
	{ value: 'draft', label: t('Commons.text.draft') },
	{ value: 'active', label: t('Commons.text.active') },
	{ value: 'archived', label: t('Commons.text.archived') },
];

const accessOptions = [
	{ value: 'staff_only', label: 'Staff only (must be logged in)' },
	{ value: 'public', label: 'Public link (no login required)' },
	{ value: 'both', label: 'Both — public link, or staff filling it out for someone' },
];

const approvalActionOptions = [
	{ value: 'none', label: t('Pages.text.none_just_collect_the') },
	{ value: 'create_or_link_partner', label: t('Pages.text.approving_creates_links_a') },
];

const typeOptions = [
	{ value: 'short_text', label: t('Commons.text.short_text') },
	{ value: 'long_text', label: t('Commons.text.long_text') },
	{ value: 'number', label: t('Commons.text.number') },
	{ value: 'date', label: t('Commons.text.date') },
	{ value: 'yes_no', label: t('Pages.text.yes_no') },
	{ value: 'single_choice', label: t('Commons.text.single_choice') },
	{ value: 'multiple_choice', label: t('Commons.text.multiple_choice') },
	{ value: 'section_header', label: 'Section Header (no answer)' },
];

const choiceTypes = ['single_choice', 'multiple_choice'];

const presets = ref([]);
const selectedPresetKeys = ref([]);

async function loadPresets() {
	const response = await axios.get('/json/forms/presets');
	presets.value = response.data.records;
}
onMounted(loadPresets);

const presetsByCategory = computed(() => {
	const groups = { basic_info: [], other: [] };
	for (const preset of presets.value) {
		(groups[preset.category] ??= []).push(preset);
	}
	return groups;
});

function existingPresetKeys(record) {
	return new Set((record.questions || []).map((q) => q.preset_key).filter(Boolean));
}

async function addSelectedPresets(record) {
	if (!selectedPresetKeys.value.length) return;
	const response = await axios.post(`/json/forms/${record.id}/questions/add-presets`, {
		keys: selectedPresetKeys.value,
	});
	record.questions = response.data.record.questions;
	selectedPresetKeys.value = [];
}

const newQuestion = ref(blankQuestion());
function blankQuestion() {
	return { label: '', help_text: '', type: 'short_text', options: [], required: false, optionsText: '' };
}

async function addQuestion(record) {
	if (!newQuestion.value.label.trim()) return;
	const payload = {
		label: newQuestion.value.label.trim(),
		help_text: newQuestion.value.help_text || null,
		type: newQuestion.value.type,
		required: newQuestion.value.required,
		options: choiceTypes.includes(newQuestion.value.type)
			? newQuestion.value.optionsText.split('\n').map((s) => s.trim()).filter(Boolean)
			: null,
	};
	const response = await axios.post(`/json/forms/${record.id}/questions`, payload);
	record.questions = [...(record.questions || []), response.data.record];
	newQuestion.value = blankQuestion();
}

const editingQuestionId = ref(null);
const editQuestionForm = ref(null);

function startEditQuestion(question) {
	editingQuestionId.value = question.id;
	editQuestionForm.value = {
		label: question.label,
		help_text: question.help_text,
		type: question.type,
		required: question.required,
		optionsText: (question.options || []).join('\n'),
	};
}

async function saveEditQuestion(record, question) {
	const payload = {
		label: editQuestionForm.value.label.trim(),
		help_text: editQuestionForm.value.help_text || null,
		type: editQuestionForm.value.type,
		required: editQuestionForm.value.required,
		options: choiceTypes.includes(editQuestionForm.value.type)
			? editQuestionForm.value.optionsText.split('\n').map((s) => s.trim()).filter(Boolean)
			: null,
	};
	const response = await axios.put(`/json/forms/${record.id}/questions/${question.id}`, payload);
	const index = record.questions.findIndex((q) => q.id === question.id);
	record.questions.splice(index, 1, response.data.record);
	editingQuestionId.value = null;
}

async function deleteQuestion(record, question) {
	if (!confirm(`Remove "${question.label}"?`)) return;
	await axios.delete(`/json/forms/${record.id}/questions/${question.id}`);
	record.questions = record.questions.filter((q) => q.id !== question.id);
}

// RIForm's own successMessage only fires on a non-keepOpen save (it returns
// to the list) — this page always keeps the form open (so the question
// builder below stays visible), so save() alone gives no visible feedback.
// This drives a local "Saved." flash instead, since save(true) still
// resolves true/false the same way the default button relies on.
const justSaved = ref(false);
let justSavedTimeout = null;

async function saveWithFeedback(save) {
	const ok = await save(true);
	if (ok) {
		justSaved.value = true;
		clearTimeout(justSavedTimeout);
		justSavedTimeout = setTimeout(() => (justSaved.value = false), 2500);
	}
}

async function moveQuestion(record, index, direction) {
	const questions = [...record.questions];
	const target = index + direction;
	if (target < 0 || target >= questions.length) return;
	[questions[index], questions[target]] = [questions[target], questions[index]];
	record.questions = questions;
	await axios.post(`/json/forms/${record.id}/questions/reorder`, {
		question_ids: questions.map((q) => q.id),
	});
}
</script>

<template>
	<Head :title="$t('Pages.title.forms_surveys')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<RIForm :title="$t('Pages.title.forms_surveys')" datasource="/json/forms" :newrecordcaption="$t('Commons.text.new_form')">
			<template #thead>
				<th>{{ $t('Commons.text.name', {}) }}</th>
				<th>{{ $t('Commons.text.status_2', {}) }}</th>
				<th>{{ $t('Commons.text.access', {}) }}</th>
				<th>{{ $t('Commons.text.approval', {}) }}</th>
				<th>{{ $t('Commons.text.submissions', {}) }}</th>
			</template>
			<template #tbody="{ record }">
				<td>{{ record.name }}</td>
				<td>{{ record.status }}</td>
				<td>{{ record.access_mode }}</td>
				<td>{{ record.requires_approval ? 'Required' : $t('Commons.text.none') }}</td>
				<td>{{ record.submissions_count }}</td>
			</template>

			<template #default="{ record, editing }">
				<div class="ri_formtable">
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Commons.text.name_2', {}) }}</div>
						<TextInput v-model="record.name" :enabled="editing" required />
					</div>
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Pages.text.slug_public_url', {}) }}</div>
						<TextInput v-model="record.slug" :enabled="editing" :placeholder="$t('Pages.placeholder.auto_generated_from_name')" />
						<div v-if="record.slug" class="text-xs text-gray-500 mt-1">/forms/{{ record.slug }}</div>
					</div>
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Commons.text.intro_text', {}) }}</div>
						<TextArea v-model="record.intro_text" :enabled="editing" />
					</div>
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Commons.text.status_3', {}) }}</div>
						<select v-model="record.status" :disabled="!editing" class="rounded-md border-gray-300 shadow-sm">
							<option v-for="o in statusOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
						</select>
					</div>
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Pages.text.who_can_access', {}) }}</div>
						<select v-model="record.access_mode" :disabled="!editing" class="rounded-md border-gray-300 shadow-sm">
							<option v-for="o in accessOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
						</select>
					</div>
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Commons.text.requires_approval', {}) }}</div>
						<Checkbox v-model="record.requires_approval" :enabled="editing" />
						<span class="text-xs text-gray-500 ml-2">Off = just collect the answers, no decision needed.</span>
					</div>
					<div class="ri_fieldset" v-if="record.requires_approval">
						<div class="ri_fieldlabel">{{ $t('Commons.text.on_approval', {}) }}</div>
						<select v-model="record.on_approval_action" :disabled="!editing" class="rounded-md border-gray-300 shadow-sm">
							<option v-for="o in approvalActionOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
						</select>
					</div>
					<div class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Pages.text.notify_emails_comma_separated', {}) }}</div>
						<TextInput v-model="record.notify_emails" :enabled="editing" :placeholder="$t('Pages.placeholder.office_example_org_someone')" />
					</div>

					<div v-if="record.id" class="ri_fieldset">
						<div class="ri_fieldlabel">{{ $t('Commons.text.review_submissions', {}) }}</div>
						<Link :href="`/setup/forms/${record.id}/submissions`" class="text-blue-600 underline text-sm">
							{{ record.submissions_count ?? 0 }} submission(s) &rarr;
						</Link>
					</div>
				</div>

				<!-- Question builder — only once the form has a real id (adding a
				     question needs somewhere to attach it to), same gate as
				     Receiving's photo step. -->
				<div v-if="record.id" class="mt-6 border-t pt-4 space-y-4">
					<h3 class="font-semibold">{{ $t('Commons.heading.questions', {}) }}</h3>

					<div v-if="record.questions?.length" class="space-y-2">
						<div v-for="(question, index) in record.questions" :key="question.id" class="border rounded p-2 text-sm">
							<div v-if="editingQuestionId === question.id" class="space-y-2">
								<TextInput v-model="editQuestionForm.label" :placeholder="$t('Commons.placeholder.question_label')" />
								<TextInput v-model="editQuestionForm.help_text" placeholder="Help text (optional)" />
								<select v-model="editQuestionForm.type" class="rounded-md border-gray-300 shadow-sm text-sm">
									<option v-for="o in typeOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
								</select>
								<TextArea
									v-if="choiceTypes.includes(editQuestionForm.type)"
									v-model="editQuestionForm.optionsText"
									:placeholder="$t('Pages.placeholder.one_choice_per_line')"
								/>
								<label class="flex items-center gap-1 text-xs">
									<Checkbox v-model="editQuestionForm.required" enabled /> Required
								</label>
								<div class="flex gap-2">
									<PrimaryButton @click="saveEditQuestion(record, question)">{{ $t('Commons.button.save', {}) }}</PrimaryButton>
									<SecondaryButton @click="editingQuestionId = null">{{ $t('Commons.button.cancel', {}) }}</SecondaryButton>
								</div>
							</div>
							<div v-else class="flex items-start justify-between gap-2">
								<div>
									<span class="font-medium">{{ question.label }}</span>
									<span class="text-gray-400 text-xs ml-2">({{ question.type }}{{ question.required ? $t('Commons.text.required') : '' }})</span>
									<div v-if="question.help_text" class="text-xs text-gray-500">{{ question.help_text }}</div>
									<div v-if="question.options?.length" class="text-xs text-gray-500">
										{{ $t('Commons.text.options') }} {{ question.options.join(', ') }}
									</div>
								</div>
								<div class="flex gap-2 shrink-0 text-xs">
									<button @click="moveQuestion(record, index, -1)" :disabled="index === 0" class="text-gray-500">&uarr;</button>
									<button @click="moveQuestion(record, index, 1)" :disabled="index === record.questions.length - 1" class="text-gray-500">&darr;</button>
									<button @click="startEditQuestion(question)" class="text-blue-600 underline">{{ $t('Commons.button.edit', {}) }}</button>
									<button @click="deleteQuestion(record, question)" class="text-red-600 underline">{{ $t('Commons.button.remove', {}) }}</button>
								</div>
							</div>
						</div>
					</div>
					<p v-else class="text-gray-400 text-sm">{{ $t('Pages.text.no_questions_yet_add', {}) }}</p>

					<div class="border rounded p-3 space-y-2">
						<h4 class="font-medium text-sm">{{ $t('Pages.heading.add_preset_questions', {}) }}</h4>
						<div v-for="(group, category) in presetsByCategory" :key="category">
							<div class="text-xs uppercase text-gray-400 mt-2">{{ category === 'basic_info' ? 'Basic Information' : $t('Commons.text.other_2') }}</div>
							<label v-for="preset in group" :key="preset.key" class="flex items-center gap-2 text-sm py-0.5"
								:class="{ 'opacity-40': existingPresetKeys(record).has(preset.key) }">
								<input
									type="checkbox"
									:value="preset.key"
									v-model="selectedPresetKeys"
									:disabled="existingPresetKeys(record).has(preset.key)"
								/>
								{{ preset.label }}
								<span v-if="existingPresetKeys(record).has(preset.key)" class="text-xs text-gray-400">(added)</span>
							</label>
						</div>
						<PrimaryButton @click="addSelectedPresets(record)" :disabled="!selectedPresetKeys.length">
							{{ $t('Commons.button.add_selected', {}) }}
						</PrimaryButton>
					</div>

					<div class="border rounded p-3 space-y-2">
						<h4 class="font-medium text-sm">{{ $t('Pages.heading.add_a_custom_question', {}) }}</h4>
						<TextInput v-model="newQuestion.label" :placeholder="$t('Commons.placeholder.question_label')" />
						<TextInput v-model="newQuestion.help_text" placeholder="Help text (optional)" />
						<select v-model="newQuestion.type" class="rounded-md border-gray-300 shadow-sm text-sm">
							<option v-for="o in typeOptions" :key="o.value" :value="o.value">{{ o.label }}</option>
						</select>
						<TextArea
							v-if="choiceTypes.includes(newQuestion.type)"
							v-model="newQuestion.optionsText"
							:placeholder="$t('Pages.placeholder.one_choice_per_line')"
						/>
						<label class="flex items-center gap-1 text-xs">
							<Checkbox v-model="newQuestion.required" enabled /> Required
						</label>
						<PrimaryButton @click="addQuestion(record)">{{ $t('Commons.button.add_question', {}) }}</PrimaryButton>
					</div>
				</div>
			</template>

			<template #actions="{ editing, record, confirmingDelete, save, cancel, delete: doDelete, keepRecord }">
				<div class="ri_formactions">
					<button v-if="editing" @click="saveWithFeedback(save)" class="ri_defaultbutton">{{ $t('Commons.button.save', {}) }}</button>
					<span v-if="justSaved" class="ri_success" style="margin-left: 0.75em;">{{ $t('Pages.text.saved', {}) }}</span>
					<button v-if="editing" @click="cancel()" class="ri_formbutton">{{ $t('Commons.button.cancel_changes', {}) }}</button>
					<button v-if="editing" @click="doDelete()" class="ri_deletebutton" :class="{ ri_confirming: confirmingDelete }">
						{{ confirmingDelete ? $t('Pages.button.confirm_delete_cannot_be') : $t('Commons.button.delete') }}
					</button>
					<button v-if="editing && confirmingDelete" @click="keepRecord()" class="ri_linkbutton">{{ $t('Commons.button.keep_record', {}) }}</button>
					<button v-if="!editing" @click="cancel()" class="ri_defaultbutton">{{ $t('Pages.button.back_to_list', {}) }}</button>
				</div>
			</template>
		</RIForm>
	</AuthenticatedLayout>
</template>
