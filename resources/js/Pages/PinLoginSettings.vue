<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- PinLoginSettings.vue

	Admin panel for the shared-terminal PIN unlock feature. Two
	independently-permissioned sections (see routes/web/kiosk.php's comment on
	why there's no single OR-gated permission for the page): Settings
	(admin-system — the global on/off/trust-mode config) and Trusted
	Devices (manage-trusted-devices — which specific devices may use PIN
	unlock, deliberately delegable narrower than full admin-system).
-->

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { t } from '@/i18n';

const props = defineProps({
	breadcrumb: { type: Array },
	canManageSettings: { type: Boolean, default: false },
	canManageDevices: { type: Boolean, default: false },
});

// ---------- settings ----------
const settingsLoading = ref(false);
const settingsError = ref(null);
const settingsSaving = ref(false);
const settingsSavedAt = ref(null);
const form = reactive({
	enabled: false,
	trust_mode: 'session_duration',
	trust_time_of_day: '18:00',
	trust_session_minutes: 480,
	require_badge_and_pin: false,
	badge_login_enabled: false,
});

async function fetchSettings() {
	settingsLoading.value = true;
	settingsError.value = null;
	try {
		const response = await axios.get('/json/pin-login-settings');
		Object.assign(form, response.data.settings);
	} catch (error) {
		settingsError.value = t('Pages.text.could_not_load_pin');
	} finally {
		settingsLoading.value = false;
	}
}

async function saveSettings() {
	settingsError.value = null;
	settingsSaving.value = true;
	try {
		const response = await axios.put('/json/pin-login-settings', form);
		Object.assign(form, response.data.settings);
		settingsSavedAt.value = new Date().toLocaleTimeString();
	} catch (error) {
		settingsError.value = error.response?.data?.message
			|| Object.values(error.response?.data?.errors || {}).flat().join(' ')
			|| t('Pages.text.could_not_save_settings');
	} finally {
		settingsSaving.value = false;
	}
}

// ---------- trusted devices ----------
const devicesLoading = ref(false);
const devicesError = ref(null);
const devices = ref([]);
const labelDrafts = reactive({});
const confirmingRevoke = ref(null);
const showClosed = ref(false);

// Requests waiting for a decision, approved devices, and the denied/revoked record (hidden unless asked for).
const pendingDevices = computed(() => devices.value.filter((d) => d.status === 'pending'));
const approvedDevices = computed(() => devices.value.filter((d) => d.status === 'approved'));
const closedDevices = computed(() => devices.value.filter((d) => d.status === 'denied' || d.status === 'revoked'));

async function fetchDevices() {
	devicesLoading.value = true;
	devicesError.value = null;
	try {
		const response = await axios.get('/json/trusted-devices');
		devices.value = response.data.records;
		devices.value.forEach((d) => { labelDrafts[d.id] = d.label || ''; });
	} catch (error) {
		devicesError.value = t('Pages.text.could_not_load_trusted');
	} finally {
		devicesLoading.value = false;
	}
}

async function approveDevice(device) {
	devicesError.value = null;
	try {
		const response = await axios.post(`/json/trusted-devices/${device.id}/approve`, {
			label: labelDrafts[device.id] || null,
		});
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = t('Pages.text.could_not_approve_device');
	}
}

async function denyDevice(device) {
	devicesError.value = null;
	try {
		const response = await axios.post(`/json/trusted-devices/${device.id}/deny`);
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = t('Pages.text.could_not_deny_that');
	}
}

function describe(device) {
	return [device.browser, device.os].filter(Boolean).join(' on ') || t('Commons.text.unknown_browser');
}

async function saveLabel(device) {
	devicesError.value = null;
	try {
		const response = await axios.put(`/json/trusted-devices/${device.id}`, {
			label: labelDrafts[device.id] || null,
		});
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = t('Pages.text.could_not_save_label');
	}
}

async function revokeDevice(device) {
	if (confirmingRevoke.value !== device.id) {
		confirmingRevoke.value = device.id;
		return;
	}
	confirmingRevoke.value = null;
	devicesError.value = null;
	try {
		const response = await axios.post(`/json/trusted-devices/${device.id}/revoke`);
		Object.assign(device, response.data.record);
	} catch (error) {
		devicesError.value = t('Pages.text.could_not_revoke_device');
	}
}

function statusBadgeClass(status) {
	return {
		pending: 'bg-amber-100 text-amber-800',
		approved: 'bg-green-100 text-green-800',
		revoked: 'bg-gray-200 text-gray-600',
		denied: 'bg-red-100 text-red-800',
	}[status] || 'bg-gray-100 text-gray-600';
}

onMounted(() => {
	if (props.canManageSettings) fetchSettings();
	if (props.canManageDevices) fetchDevices();
});
</script>

<template>
	<Head :title="$t('Commons.title.pin_login')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.pin_login', {}) }}</h1>

			<p v-if="!canManageSettings && !canManageDevices" class="text-gray-500">
				{{ $t('Pages.text.you_don_t_have_2', {}) }}
			</p>

			<!-- ======================= SETTINGS ======================= -->
			<section v-if="canManageSettings" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">{{ $t('Commons.heading.settings', {}) }}</h2>
				<p class="text-sm text-gray-600">
					{{ $t('Pages.text.a_shared_terminal_quick', {}) }}
				</p>

				<div v-if="settingsError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ settingsError }}</div>
				<p v-if="settingsLoading" class="text-gray-500">{{ $t('Commons.text.loading_settings', {}) }}</p>

				<template v-else>
					<label class="flex items-center gap-2">
						<input type="checkbox" v-model="form.enabled" />
						<span class="text-gray-700 font-medium">{{ $t('Pages.text.enable_pin_login', {}) }}</span>
					</label>

					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.trust_expires', {}) }}</span>
							<select v-model="form.trust_mode" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="session_duration">{{ $t('Pages.text.after_a_fixed_duration', {}) }}</option>
								<option value="time_of_day">{{ $t('Pages.text.at_a_fixed_time', {}) }}</option>
								<option value="indefinite">{{ $t('Pages.text.never_until_explicit_logout', {}) }}</option>
							</select>
						</label>

						<label v-if="form.trust_mode === 'session_duration'" class="block">
							<span class="text-gray-700">{{ $t('Commons.text.duration_minutes', {}) }}</span>
							<input type="number" min="1" max="10080" v-model.number="form.trust_session_minutes"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>

						<label v-if="form.trust_mode === 'time_of_day'" class="block">
							<span class="text-gray-700">{{ $t('Pages.text.time_of_day', {}) }}</span>
							<input type="time" v-model="form.trust_time_of_day"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</div>

					<label class="flex items-center gap-2">
						<input type="checkbox" v-model="form.badge_login_enabled" @change="form.badge_login_enabled || (form.require_badge_and_pin = false)" />
						<span class="text-gray-700 font-medium">{{ $t('Pages.text.offer_badge_scanning_on', {}) }}</span>
					</label>
					<p class="text-xs text-gray-500">
						Off by default until badges are actually issued — with this off, the unlock screen only
						shows name tiles + PIN, no badge scan step. Turn on once physical badges exist.
					</p>

					<label class="flex items-center gap-2">
						<input type="checkbox" v-model="form.require_badge_and_pin" :disabled="!form.badge_login_enabled" />
						<span class="text-gray-700" :class="{ 'opacity-50': !form.badge_login_enabled }">{{ $t('Pages.text.require_a_badge_scan', {}) }}</span>
					</label>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.text.when_on_tapping_a', {}) }}
					</p>

					<div class="flex items-center gap-3">
						<PrimaryButton :disabled="settingsSaving" @click="saveSettings">
							{{ settingsSaving ? $t('Commons.button.saving') : $t('Commons.button.save_settings') }}
						</PrimaryButton>
						<span v-if="settingsSavedAt" class="text-sm text-gray-500">{{ $t('Commons.text.saved') }} {{ settingsSavedAt }}</span>
					</div>
				</template>
			</section>

			<!-- ======================= TRUSTED DEVICES ======================= -->
			<section v-if="canManageDevices" class="bg-white shadow rounded-lg p-6 space-y-4">
				<h2 class="text-lg font-semibold">{{ $t('Commons.heading.devices', {}) }}</h2>
				<p class="text-sm text-gray-600">
					PIN login is only offered on a device approved here. A device is added when someone
					logged in on it asks for PIN login there (profile menu &gt; <strong>{{ $t('Pages.heading.pin_login_on_this', {}) }}</strong>): you can approve your own device on the spot from that page, and anyone
					else's request waits here.
					<Link href="/this-device" class="text-blue-600 underline">{{ $t('Pages.link.approve_the_device_you', {}) }}</Link>
				</p>

				<div v-if="devicesError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ devicesError }}</div>
				<p v-if="devicesLoading" class="text-gray-500">{{ $t('Commons.text.loading_devices', {}) }}</p>

				<template v-else>
					<div v-for="group in [
						{ key: 'pending', title: 'Requests waiting for approval', list: pendingDevices, empty: 'No requests waiting.' },
						{ key: 'approved', title: 'Approved devices', list: approvedDevices, empty: 'No devices approved yet.' },
					]" :key="group.key" class="space-y-3">
						<h3 class="font-semibold text-gray-800">{{ group.title }} ({{ group.list.length }})</h3>
						<p v-if="!group.list.length" class="text-sm text-gray-400">{{ group.empty }}</p>

						<div v-for="device in group.list" :key="device.id" class="border rounded p-3 space-y-2">
							<div class="flex items-center justify-between flex-wrap gap-2">
								<div class="flex items-center gap-2">
									<span class="text-xs font-semibold uppercase tracking-widest px-2 py-1 rounded"
										:class="statusBadgeClass(device.status)">{{ device.status }}</span>
									<span class="font-medium">{{ device.label || describe(device) }}</span>
								</div>
								<span v-if="device.status === 'approved'" class="text-xs text-gray-500 font-mono">
									{{ device.grants_count }} active login{{ device.grants_count === 1 ? '' : 's' }}
								</span>
							</div>

							<div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
								<div class="space-y-1">
									<label class="block">
										<span class="text-gray-700">{{ $t('Commons.text.station_name', {}) }}</span>
										<input type="text" v-model="labelDrafts[device.id]" :placeholder="$t('Pages.placeholder.e_g_sorting_station')"
											class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
									</label>
									<p v-if="device.request_reason" class="text-gray-700"><span class="text-gray-500">{{ $t('Commons.text.reason_2', {}) }}</span> {{ device.request_reason }}</p>
								</div>
								<div class="text-xs text-gray-600 space-y-0.5">
									<div>{{ describe(device) }}</div>
									<div>{{ $t('Commons.text.ip_address', {}) }} <span class="font-mono">{{ device.ip_address || '—' }}</span>
										<template v-if="device.last_ip_address && device.last_ip_address !== device.ip_address">
											(last seen from <span class="font-mono">{{ device.last_ip_address }}</span>)</template>
									</div>
									<div>{{ $t('Commons.text.requested') }} {{ new Date(device.requested_at).toLocaleString() }}<template v-if="device.requester"> by {{ device.requester.full_name }}</template></div>
									<div v-if="device.last_seen_at">{{ $t('Commons.text.last_seen') }} {{ new Date(device.last_seen_at).toLocaleString() }}</div>
									<div v-if="device.approver && device.status === 'approved'">{{ $t('Commons.text.approved_by') }} {{ device.approver.full_name }}</div>
									<div v-if="device.kiosk_mode" class="text-amber-700">{{ $t('Pages.text.in_kiosk_mode', {}) }}</div>
									<div class="truncate text-gray-400" :title="device.user_agent">{{ device.user_agent }}</div>
								</div>
							</div>

							<div class="flex items-center gap-2 flex-wrap">
								<template v-if="device.status === 'pending'">
									<button @click="approveDevice(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-green-600 hover:bg-green-500">
										{{ $t('Commons.button.approve', {}) }}
									</button>
									<button @click="denyDevice(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-600 hover:bg-gray-500">
										{{ $t('Commons.button.deny', {}) }}
									</button>
								</template>
								<template v-else>
									<button @click="saveLabel(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-600 hover:bg-gray-500">
										{{ $t('Commons.button.save_name', {}) }}
									</button>
									<button @click="revokeDevice(device)"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
										:class="confirmingRevoke === device.id ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'">
										{{ confirmingRevoke === device.id ? $t('Pages.button.confirm_signs_everyone_out') : $t('Commons.button.revoke') }}
									</button>
									<button v-if="confirmingRevoke === device.id" @click="confirmingRevoke = null"
										class="text-sm text-gray-500 underline">{{ $t('Commons.button.cancel', {}) }}</button>
								</template>
							</div>
						</div>
					</div>

					<div v-if="closedDevices.length" class="space-y-2">
						<button type="button" class="text-sm underline text-gray-600" @click="showClosed = !showClosed">
							{{ showClosed ? $t('Commons.button.hide') : $t('Commons.button.show') }} denied and revoked ({{ closedDevices.length }})
						</button>
						<div v-if="showClosed" class="space-y-2">
							<div v-for="device in closedDevices" :key="device.id" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-2">
								<div>
									<span class="text-xs font-semibold uppercase tracking-widest px-2 py-1 rounded mr-2"
										:class="statusBadgeClass(device.status)">{{ device.status }}</span>
									{{ device.label || describe(device) }}
									<span class="text-xs text-gray-500">
										— {{ describe(device) }}, <span class="font-mono">{{ device.ip_address || '—' }}</span><template v-if="device.requester">, asked by {{ device.requester.full_name }}</template>
									</span>
								</div>
								<button @click="approveDevice(device)" class="text-sm underline text-green-700">{{ $t('Pages.button.approve_after_all', {}) }}</button>
							</div>
						</div>
					</div>
				</template>

				<p class="text-xs text-gray-500">
					{{ $t('Pages.text.revoking_a_device_immediately', {}) }}
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
