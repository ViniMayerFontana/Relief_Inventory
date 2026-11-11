<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Imports.vue

	Upload -> Preview -> Commit for external data imports (currently just
	Flowtrac). Preview (upload) never writes app data — it reports proposed
	creates/updates/skips and any ambiguous mappings ("decisions") that need
	review before Commit. Commit re-runs the same importer for real and is
	safe to call more than once (idempotent, matched via source_system/
	source_ref on the imported records) — Washington runs Flowtrac and
	reliefinventory in parallel for a while, not a one-time cutover.
-->

<script setup>
import { onMounted, ref } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';

defineProps({
	breadcrumb: { type: Array },
});

const fileTypes = ref({});
const selectedFileType = ref('');
const selectedFile = ref(null);
const uploading = ref(false);
const uploadError = ref(null);

const preview = ref(null); // the just-uploaded batch, pre-commit
const previewDecisions = ref([]);
const committing = ref(false);
const commitError = ref(null);

const batches = ref([]);
const loadingBatches = ref(true);

const expandedRows = ref(null); // batch id currently showing its row detail
const rows = ref([]);
const loadingRows = ref(false);

async function loadFileTypes() {
	const response = await axios.get('/json/imports/options');
	fileTypes.value = response.data.file_types;
}

async function loadBatches() {
	loadingBatches.value = true;
	try {
		const response = await axios.get('/json/imports');
		batches.value = response.data.records;
	} catch (error) {
		// Viewing/deleting batch history is gated admin-import, separately
		// from manage-import (upload/preview/commit) — a manage-import-only
		// grant can still use the form above even if this list 403s.
		batches.value = [];
	} finally {
		loadingBatches.value = false;
	}
}

function onFileChange(event) {
	selectedFile.value = event.target.files[0] || null;
}

async function upload() {
	uploadError.value = null;
	if (!selectedFile.value || !selectedFileType.value) {
		uploadError.value = 'Choose a file type and a file.';
		return;
	}
	uploading.value = true;
	preview.value = null;
	previewDecisions.value = [];
	try {
		const form = new FormData();
		form.append('file', selectedFile.value);
		form.append('file_type', selectedFileType.value);
		const response = await axios.post('/json/imports', form, {
			headers: { 'Content-Type': 'multipart/form-data' },
		});
		preview.value = response.data.record;
		previewDecisions.value = response.data.decisions || [];
		await loadBatches();
	} catch (error) {
		uploadError.value = error.response?.data?.message || 'Could not upload/preview this file.';
	} finally {
		uploading.value = false;
	}
}

async function commit(batchId) {
	commitError.value = null;
	committing.value = true;
	try {
		const response = await axios.post(`/json/imports/${batchId}/commit`);
		if (preview.value && preview.value.id === batchId) {
			preview.value = response.data.record;
			previewDecisions.value = response.data.decisions || [];
		}
		await loadBatches();
	} catch (error) {
		commitError.value = error.response?.data?.message || 'Commit failed.';
	} finally {
		committing.value = false;
	}
}

async function toggleRows(batch) {
	if (expandedRows.value === batch.id) {
		expandedRows.value = null;
		return;
	}
	expandedRows.value = batch.id;
	loadingRows.value = true;
	try {
		const response = await axios.get(`/json/imports/${batch.id}/rows`);
		rows.value = response.data.records;
	} finally {
		loadingRows.value = false;
	}
}

const statusClasses = {
	previewed: 'bg-gray-100 text-gray-800',
	committing: 'bg-blue-100 text-blue-800',
	completed: 'bg-green-100 text-green-800',
	failed: 'bg-red-100 text-red-800',
};

const outcomeClasses = {
	created: 'bg-green-100 text-green-800',
	updated: 'bg-blue-100 text-blue-800',
	skipped: 'bg-gray-100 text-gray-800',
	error: 'bg-red-100 text-red-800',
};

onMounted(() => {
	loadFileTypes();
	loadBatches();
});
</script>

<template>
	<Head :title="$t('Commons.title.data_import')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.data_import', {}) }}</h1>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">{{ $t('Pages.heading.upload_a_file', {}) }}</h2>
				<div v-if="uploadError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ uploadError }}</div>

				<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.text.file_type', {}) }}</span>
						<select v-model="selectedFileType" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">{{ $t('Pages.text.choose', {}) }}</option>
							<option v-for="(label, key) in fileTypes" :key="key" :value="key">{{ label }}</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.text.file', {}) }}</span>
						<input type="file" accept=".csv,text/csv" @change="onFileChange" class="mt-1 block w-full text-sm" />
					</label>
				</div>

				<div v-if="selectedFileType === 'mailing_list'" class="rounded bg-blue-50 border border-blue-200 text-blue-900 px-4 py-3 text-sm space-y-1">
					<p>
						{{ $t('Pages.text.the_first_row_must', {}) }}
						<strong>First Name, Last Name</strong> (or one <strong>{{ $t('Commons.button.name', {}) }}</strong> column), <strong>Organization,
						Address, Address 2, City, State, Zip, Tags</strong>.
					</p>
					<p>
						<strong>{{ $t('Commons.text.tags', {}) }}</strong>{{ $t('Pages.text.donor_partner_volunteer_or', {}) }}
					</p>
					<p>{{ $t('Pages.text.print_labels_for_them', {}) }} <a href="/reports/mailing-labels" class="underline">{{ $t('Commons.link.mailing_labels', {}) }}</a>.</p>
				</div>

				<PrimaryButton @click="upload" :disabled="uploading">
					{{ uploading ? $t('Pages.button.uploading_previewing') : $t('Pages.button.upload_preview') }}
				</PrimaryButton>
				<p class="text-xs text-gray-500">
					{{ $t('Pages.text.uploading_only_previews_what', {}) }}
				</p>
			</section>

			<section v-if="preview" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">
					{{ $t('Commons.heading.preview') }} {{ preview.original_filename }}
					<span class="text-xs font-normal px-2 py-1 rounded" :class="statusClasses[preview.status]">{{ preview.status }}</span>
				</h2>

				<div class="grid grid-cols-1 sm:grid-cols-4 gap-4 text-sm">
					<div class="border rounded p-3">
						<div class="text-gray-500 text-xs">{{ $t('Commons.text.would_create', {}) }}</div>
						<div class="text-lg font-mono">{{ preview.summary?.created ?? 0 }}</div>
					</div>
					<div class="border rounded p-3">
						<div class="text-gray-500 text-xs">{{ $t('Commons.text.would_update', {}) }}</div>
						<div class="text-lg font-mono">{{ preview.summary?.updated ?? 0 }}</div>
					</div>
					<div class="border rounded p-3">
						<div class="text-gray-500 text-xs">{{ $t('Commons.text.skipped', {}) }}</div>
						<div class="text-lg font-mono">{{ preview.summary?.skipped ?? 0 }}</div>
					</div>
					<div class="border rounded p-3">
						<div class="text-gray-500 text-xs">{{ $t('Commons.text.errors', {}) }}</div>
						<div class="text-lg font-mono">{{ preview.summary?.errored ?? 0 }}</div>
					</div>
				</div>

				<div v-if="previewDecisions.length" class="rounded bg-amber-50 border border-amber-300 text-amber-900 px-4 py-3 text-sm space-y-1">
					<p class="font-semibold">{{ $t('Pages.text.needs_review_before_committing', {}) }}</p>
					<ul class="list-disc list-inside">
						<li v-for="(decision, i) in previewDecisions" :key="i">{{ decision }}</li>
					</ul>
				</div>

				<div v-if="commitError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ commitError }}</div>

				<PrimaryButton v-if="preview.status === 'previewed'" @click="commit(preview.id)" :disabled="committing">
					{{ committing ? 'Committing…' : $t('Pages.button.commit_write_these_changes') }}
				</PrimaryButton>
				<p v-else-if="preview.status === 'completed'" class="text-sm text-green-700">{{ $t('Pages.text.committed', {}) }}</p>
			</section>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">{{ $t('Commons.heading.import_history', {}) }}</h2>
				<p v-if="loadingBatches" class="text-gray-500">{{ $t('Commons.text.loading', {}) }}</p>
				<table v-else class="w-full text-sm">
					<thead>
						<tr class="text-left text-gray-500 text-xs uppercase">
							<th class="pb-2">{{ $t('Commons.text.file', {}) }}</th>
							<th class="pb-2">{{ $t('Commons.button.status', {}) }}</th>
							<th class="pb-2">{{ $t('Pages.text.created_updated_skipped_errors', {}) }}</th>
							<th class="pb-2">{{ $t('Commons.text.by', {}) }}</th>
							<th class="pb-2"></th>
						</tr>
					</thead>
					<tbody>
						<template v-for="batch in batches" :key="batch.id">
							<tr class="border-t">
								<td class="py-2">{{ batch.original_filename }}</td>
								<td class="py-2">
									<span class="text-xs px-2 py-1 rounded" :class="statusClasses[batch.status]">{{ batch.status }}</span>
								</td>
								<td class="py-2 font-mono text-xs">
									{{ batch.summary?.created ?? 0 }} / {{ batch.summary?.updated ?? 0 }} /
									{{ batch.summary?.skipped ?? 0 }} / {{ batch.summary?.errored ?? 0 }}
								</td>
								<td class="py-2">{{ batch.creator ? batch.creator.full_name : '' }}</td>
								<td class="py-2 text-right">
									<button v-if="batch.status === 'previewed'" @click="commit(batch.id)" class="text-indigo-600 hover:underline mr-3">{{ $t('Commons.button.commit', {}) }}</button>
									<button @click="toggleRows(batch)" class="text-indigo-600 hover:underline">
										{{ expandedRows === batch.id ? $t('Commons.button.hide_rows') : $t('Commons.button.show_rows') }}
									</button>
								</td>
							</tr>
							<tr v-if="expandedRows === batch.id">
								<td colspan="5" class="pb-4">
									<p v-if="loadingRows" class="text-gray-500 text-xs">{{ $t('Commons.text.loading_rows', {}) }}</p>
									<div v-else class="border rounded max-h-64 overflow-y-auto">
										<table class="w-full text-xs">
											<thead>
												<tr class="text-left text-gray-500 bg-gray-50">
													<th class="p-2">#</th>
													<th class="p-2">{{ $t('Commons.text.key', {}) }}</th>
													<th class="p-2">{{ $t('Commons.text.outcome', {}) }}</th>
													<th class="p-2">{{ $t('Commons.text.detail', {}) }}</th>
												</tr>
											</thead>
											<tbody>
												<tr v-for="row in rows" :key="row.id" class="border-t">
													<td class="p-2">{{ row.row_number }}</td>
													<td class="p-2 font-mono">{{ row.source_key }}</td>
													<td class="p-2"><span class="px-2 py-0.5 rounded" :class="outcomeClasses[row.outcome]">{{ row.outcome }}</span></td>
													<td class="p-2">{{ row.error_message }}</td>
												</tr>
											</tbody>
										</table>
									</div>
								</td>
							</tr>
						</template>
						<tr v-if="!batches.length">
							<td colspan="5" class="py-4 text-gray-400">{{ $t('Pages.text.no_imports_yet', {}) }}</td>
						</tr>
					</tbody>
				</table>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
