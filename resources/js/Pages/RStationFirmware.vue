<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- RStationFirmware.vue

	R Station software releases (permission: manage-firmware — deliberately narrower than
	manage-devices, since a bad release reaches the whole fleet): where devices look for
	firmware (this server's own catalogue, or another Relief Inventory server), the catalogue
	of uploaded app/OS releases and the channels each is live on, and a chunked, resumable,
	progress-reporting uploader (a firmware image is ~1 GB, far over PHP's and a proxy's body
	limits). Server half: DeviceReleaseController. Panel-style page per the admin-page-style
	skill — not RIForm.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { useChunkedUpload } from '@/composables/chunkedUpload';
import axios from 'axios';
import { onMounted, reactive, ref, watch } from 'vue';
import { t } from '@/i18n';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

const CHANNELS = ['stable', 'testing', 'developer'];

const error = ref('');
const notice = ref('');
const releases = ref([]);
const platforms = ref({});

async function fetchAll() {
	const [r, s] = await Promise.all([axios.get('/json/device-releases'), axios.get('/json/firmware-source')]);
	releases.value = r.data.records;
	platforms.value = r.data.platforms || {};
	sourceUrl.value = s.data.source_url || '';
	savedSource.value = s.data.source_url || '';
}

function fail(e, fallback) {
	error.value = e.response?.data?.errors
		? Object.values(e.response.data.errors).flat().join(' ')
		: e.response?.data?.message || fallback;
}

// ---- Where devices look for firmware ----
const sourceUrl = ref('');
const savedSource = ref('');
const savingSource = ref(false);

async function saveSource() {
	savingSource.value = true;
	error.value = '';
	notice.value = '';
	try {
		const { data } = await axios.put('/json/firmware-source', { source_url: sourceUrl.value.trim() || null });
		savedSource.value = sourceUrl.value = data.source_url || '';
		notice.value = data.source_url
			? t('Pages.text.saved_devices_paired_here')
			: t('Pages.text.saved_this_server_offers');
	} catch (e) {
		fail(e, t('Pages.text.could_not_save_the_7'));
	} finally {
		savingSource.value = false;
	}
}

// ---- Releases ----
async function toggleTag(release, channel) {
	const action = release.channels?.includes(channel) ? 'untag' : 'tag';
	try {
		await axios.post(`/json/device-releases/${release.id}/${action}`, { channel });
		await fetchAll();
	} catch (e) {
		fail(e, t('Pages.text.could_not_change_that'));
	}
}

async function deleteRelease(release) {
	if (!window.confirm(t('Pages.text.delete_p0', { p0: release.filename }))) return;
	try {
		await axios.delete(`/json/device-releases/${release.id}`);
		await fetchAll();
	} catch (e) {
		fail(e, t('Pages.text.could_not_delete_that_2'));
	}
}

const IMAGE_LABELS = { disk_image: t('Pages.text.raspberry_pi_sd_card'), vm_image: t('Pages.text.virtual_machine_image') };

// Images and the print client are downloaded by people (anyone who can pair a device), never
// offered to devices — so they have no update channels.
const isDownloadOnly = (release) => release.kind === 'print_client' || release.release_type in IMAGE_LABELS;

function releaseLabel(release) {
	if (release.kind === 'print_client') return t('Pages.heading.ri_print_client');
	return IMAGE_LABELS[release.release_type] || release.kind;
}

function releaseDetail(release) {
	const platform = release.kind === 'print_client' ? platforms.value[release.architecture] || release.architecture : release.architecture;
	return IMAGE_LABELS[release.release_type] || release.kind === 'print_client' ? platform : `${release.release_type}, ${platform}`;
}

function formatSize(bytes) {
	if (bytes > 1073741824) return `${(bytes / 1073741824).toFixed(2)} GB`;
	return bytes > 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.ceil(bytes / 1024)} KB`;
}

// ---- Chunked upload ----
// start -> PUT consecutive raw chunks at explicit offsets -> complete. The server is the source
// of truth for how much it has: every response carries `received`, and a 409 (a chunk it
// already has, or one that skipped ahead) tells us where to carry on from, so a dropped
// connection or a double-sent chunk can never corrupt the file. A failed upload keeps its
// server-side progress and can be resumed with the same file.
const upload = reactive({ kind: 'app', version: '', architecture: 'aarch64', release_type: 'full', required_base_version: '', notes: '' });
// The print client has no type choices (always full) and picks a platform instead of typing an architecture.
watch(() => upload.kind, (kind) => {
	if (kind === 'print_client') {
		upload.release_type = 'full';
		upload.architecture = 'windows';
	} else if (upload.architecture in platforms.value) {
		upload.architecture = 'aarch64';
	}
	if (kind === 'app') upload.release_type = 'full';
});

const uploadFile = ref(null);
const fileInput = ref(null);
const { task, percent, start, resume, cancel, reset } = useChunkedUpload('/json/device-releases/uploads');

async function startUpload() {
	if (!uploadFile.value) return;
	error.value = '';
	notice.value = '';
	const metadata = Object.fromEntries(Object.entries(upload).filter(([, value]) => value !== ''));
	const name = uploadFile.value.name;
	try {
		await finished(await start(uploadFile.value, metadata), name);
	} catch (e) {
		// No upload id yet means the server refused to start it (validation); otherwise it was interrupted.
		fail(e, task.id ? t('Pages.text.the_upload_was_interrupted') : t('Pages.text.could_not_start_that'));
	}
}

async function resumeUpload() {
	error.value = '';
	const name = task.file?.name;
	try {
		await finished(await resume(), name);
	} catch (e) {
		fail(e, t('Pages.text.the_upload_was_interrupted'));
	}
}

async function finished(completed, name) {
	if (!completed) return;
	notice.value = t('Pages.text.uploaded_p0_it_is', { p0: name });
	reset(); // the server already holds the file; nothing to delete
	uploadFile.value = null;
	if (fileInput.value) fileInput.value.value = '';
	upload.version = upload.required_base_version = upload.notes = '';
	await fetchAll();
}

async function cancelUpload() {
	await cancel();
	notice.value = t('Pages.text.upload_cancelled');
}

onMounted(fetchAll);
</script>

<template>
	<Head :title="$t('Pages.title.r_station_firmware')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Pages.heading.r_station_firmware', {}) }}</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<!-- Where devices look -->
			<section class="bg-white shadow rounded-lg p-6 space-y-3">
				<h2 class="text-lg font-semibold">{{ $t('Pages.heading.where_devices_look_for', {}) }}</h2>
				<p class="text-sm text-gray-600">
					{{ $t('Pages.text.devices_always_check_in', {}) }}
				</p>
				<div class="flex gap-3 items-end text-sm">
					<label class="block grow">
						<span class="text-gray-700">{{ $t('Pages.text.firmware_source_server_leave', {}) }}</span>
						<input type="url" v-model="sourceUrl" placeholder="https://relief.example.org" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<PrimaryButton :disabled="savingSource || sourceUrl.trim() === savedSource" @click="saveSource">
						{{ savingSource ? $t('Commons.button.saving') : $t('Commons.button.save') }}
					</PrimaryButton>
				</div>
				<p v-if="savedSource" class="text-sm rounded bg-amber-50 border border-amber-300 px-3 py-2">
					{{ $t('Pages.text.devices_paired_here_currently', {}) }} <strong>{{ savedSource }}</strong>. The releases below are not
					offered to them (but remain available to any server pointed at this one).
				</p>
			</section>

			<!-- Releases -->
			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">{{ $t('Commons.heading.software_releases', {}) }}</h2>
				<table v-if="releases.length" class="w-full text-sm">
					<thead>
						<tr class="text-left text-gray-600">
							<th class="py-1">{{ $t('Commons.text.release', {}) }}</th>
							<th>{{ $t('Pages.text.live_on_channel', {}) }}</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="release in releases" :key="release.id" class="border-t">
							<td class="py-2">
								<div><strong>{{ releaseLabel(release) }}</strong> {{ release.version }}
									<span class="text-gray-500">({{ releaseDetail(release) }}, {{ formatSize(release.size_bytes) }})</span>
								</div>
								<div v-if="release.required_base_version" class="text-xs text-gray-500">{{ $t('Pages.text.applies_on_top_of') }} {{ release.required_base_version }}</div>
								<div class="text-xs text-gray-400">{{ release.filename }}</div>
							</td>
							<td v-if="isDownloadOnly(release)" class="text-gray-500">
								{{ $t('Pages.text.download_only_available_to', {}) }}
							</td>
							<td v-else>
								<label v-for="c in CHANNELS" :key="c" class="mr-3 whitespace-nowrap">
									<input type="checkbox" :checked="release.channels?.includes(c)" @change="toggleTag(release, c)" class="rounded border-gray-300" />
									{{ c }}
								</label>
							</td>
							<td class="text-right">
								<button type="button" class="text-red-700 underline" @click="deleteRelease(release)">{{ $t('Commons.button.delete', {}) }}</button>
							</td>
						</tr>
					</tbody>
				</table>
				<p v-else class="text-sm text-gray-400">{{ $t('Pages.text.no_releases_uploaded_yet', {}) }}</p>

				<h3 class="font-medium text-sm pt-2">{{ $t('Pages.heading.upload_a_release', {}) }}</h3>
				<fieldset :disabled="task.id !== null" class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.text.kind', {}) }}</span>
						<select v-model="upload.kind" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="app">{{ $t('Pages.text.app_tar_gz', {}) }}</option>
							<option value="os">{{ $t('Pages.text.os_bundle_raucb', {}) }}</option>
							<option value="print_client">{{ $t('Pages.text.ri_print_client_installer', {}) }}</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.text.type_2', {}) }}</span>
						<select v-model="upload.release_type" :disabled="upload.kind === 'print_client'" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="full">{{ $t('Commons.text.full', {}) }}</option>
							<option v-if="upload.kind === 'os'" value="hotfix">{{ $t('Pages.text.hotfix_small_on_top', {}) }}</option>
							<option v-if="upload.kind === 'os'" value="disk_image">{{ $t('Pages.text.raspberry_pi_sd_card_2', {}) }}</option>
							<option v-if="upload.kind === 'os'" value="vm_image">{{ $t('Pages.text.virtual_machine_image_img', {}) }}</option>
						</select>
					</label>
					<label class="block">
						<span class="text-gray-700">{{ $t('Commons.heading.version', {}) }}</span>
						<input type="text" v-model="upload.version" :placeholder="$t('Pages.placeholder.e_g_0_4')" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label class="block">
						<span class="text-gray-700">{{ upload.kind === 'print_client' ? $t('Commons.text.platform') : $t('Commons.text.architecture') }}</span>
						<select v-if="upload.kind === 'print_client'" v-model="upload.architecture" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option v-for="(label, key) in platforms" :key="key" :value="key">{{ label }}</option>
						</select>
						<input v-else type="text" v-model="upload.architecture" placeholder="aarch64" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label v-if="upload.release_type === 'hotfix'" class="block sm:col-span-2">
						<span class="text-gray-700">{{ $t('Pages.text.required_base_version_exact', {}) }}</span>
						<input type="text" v-model="upload.required_base_version" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<label class="block sm:col-span-2">
						<span class="text-gray-700">{{ $t('Commons.text.file', {}) }}</span>
						<input ref="fileInput" type="file" @change="uploadFile = $event.target.files[0]" class="mt-1 block w-full text-sm" />
					</label>
					<label class="block sm:col-span-2">
						<span class="text-gray-700">{{ $t('Commons.text.notes_optional', {}) }}</span>
						<input type="text" v-model="upload.notes" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
				</fieldset>

				<div v-if="task.id !== null" class="space-y-2">
					<div class="flex justify-between text-sm">
						<span>
							<strong>{{ task.file?.name }}</strong>
							<template v-if="task.running"> {{ $t('Commons.text.uploading', {}) }}</template>
							<template v-else-if="task.failed"> {{ $t('Commons.text.interrupted', {}) }}</template>
						</span>
						<span>{{ percent }}% · {{ formatSize(task.received) }} of {{ formatSize(task.size) }}</span>
					</div>
					<div class="h-3 w-full rounded bg-gray-200 overflow-hidden" role="progressbar" :aria-valuenow="percent" aria-valuemin="0" aria-valuemax="100">
						<div class="h-3 rounded" :class="task.failed ? 'bg-red-500' : 'bg-blue-600'" :style="{ width: percent + '%' }"></div>
					</div>
					<div class="flex gap-3 text-sm">
						<PrimaryButton v-if="task.failed && !task.running" @click="resumeUpload">{{ $t('Commons.button.resume', {}) }}</PrimaryButton>
						<button type="button" class="text-red-700 underline" @click="cancelUpload">{{ $t('Commons.button.cancel_upload', {}) }}</button>
					</div>
				</div>
				<PrimaryButton v-else :disabled="!uploadFile || !upload.version" @click="startUpload">{{ $t('Commons.button.upload', {}) }}</PrimaryButton>

				<p class="text-xs text-gray-500">
					{{ $t('Pages.text.large_files_are_sent', {}) }}
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
