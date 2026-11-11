<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- EmailSettings.vue

	Outgoing email settings (permission: admin-system): which mail service to
	use, the From address/name, the Resend API key or SMTP server, and who is
	emailed about new feedback reports — plus a test-email button. A blank
	field falls back to the server's .env value, shown as the placeholder.
	Secrets are write-only: the server only says whether one is saved.
	Panel-style page per the admin-page-style skill.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, reactive, ref } from 'vue';
import { t } from '@/i18n';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

const MAILER_LABELS = { resend: 'Resend', smtp: 'SMTP server', log: 'Log only (no email is sent)' };

const error = ref('');
const notice = ref('');
const loaded = ref(false);
const saving = ref(false);
const savedAt = ref('');
const testing = ref(false);
const testTo = ref('');

const status = ref(null); // last server response: settings, defaults, mailers
const form = reactive({});
const clean = ref('');

function fill(data) {
	status.value = data;
	const s = data.settings;
	Object.assign(form, {
		mailer: s.mailer ?? '',
		from_address: s.from_address ?? '',
		from_name: s.from_name ?? '',
		resend_key: '',
		clear_resend_key: false,
		smtp_host: s.smtp_host ?? '',
		smtp_port: s.smtp_port ?? '',
		smtp_username: s.smtp_username ?? '',
		smtp_password: '',
		clear_smtp_password: false,
		feedback_notify_emails: s.feedback_notify_emails ?? '',
	});
	clean.value = JSON.stringify(form);
}

const dirty = computed(() => loaded.value && JSON.stringify(form) !== clean.value);
const defaults = computed(() => status.value?.defaults ?? {});
const activeMailer = computed(() => form.mailer || defaults.value.mailer);

function placeholder(key) {
	const value = defaults.value[key];
	return value ? `Server default: ${value}` : 'Not set';
}

// Where the key/password in use comes from, for the status line under each secret field.
function secretSource(key) {
	const s = status.value?.settings ?? {};
	if (form['clear_' + key]) return defaults.value[key + '_set'] ? 'Will use the one in the server .env' : 'Will be removed';
	if (form[key]) return t('Pages.text.a_new_one_will');
	if (s[key + '_set']) return t('Commons.text.saved_here');
	if (defaults.value[key + '_set']) return 'Using the one in the server .env';
	return t('Commons.text.none_set');
}

async function load() {
	try {
		const response = await axios.get('/json/mail-settings');
		fill(response.data);
		testTo.value = response.data.test_to ?? '';
		loaded.value = true;
	} catch (e) {
		error.value = e.response?.data?.message || 'Could not load the email settings.';
	}
}

async function save() {
	error.value = '';
	notice.value = '';
	saving.value = true;
	try {
		const payload = { ...form, smtp_port: form.smtp_port === '' ? null : Number(form.smtp_port) };
		const response = await axios.put('/json/mail-settings', payload);
		fill(response.data);
		savedAt.value = 'Saved ' + new Date().toLocaleTimeString();
	} catch (e) {
		error.value = e.response?.data?.message || 'Could not save the email settings.';
	} finally {
		saving.value = false;
	}
}

async function sendTest() {
	error.value = '';
	notice.value = '';
	testing.value = true;
	try {
		const response = await axios.post('/json/mail-settings/test', { to: testTo.value });
		notice.value = response.data.message;
	} catch (e) {
		error.value = e.response?.data?.message || 'The test email could not be sent.';
	} finally {
		testing.value = false;
	}
}

onMounted(load);
</script>

<template>
	<Head :title="$t('Commons.title.email_settings')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.email_settings', {}) }}</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<p v-if="!loaded && !error" class="text-gray-500">{{ $t('Pages.text.loading_email_settings', {}) }}</p>

			<template v-if="loaded">
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.outgoing_email', {}) }}</h2>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">{{ $t('Pages.text.send_email_using', {}) }}</span>
							<select v-model="form.mailer" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="">Server default ({{ MAILER_LABELS[defaults.mailer] ?? defaults.mailer }})</option>
								<option v-for="m in status.mailers" :key="m" :value="m">{{ MAILER_LABELS[m] ?? m }}</option>
							</select>
						</label>
						<div class="hidden sm:block"></div>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.from_address', {}) }}</span>
							<input v-model="form.from_address" type="email" :placeholder="placeholder('from_address')"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.from_name', {}) }}</span>
							<input v-model="form.from_name" type="text" :placeholder="placeholder('from_name')"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>

						<label v-if="activeMailer === 'resend'" class="block sm:col-span-2">
							<span class="text-gray-700">{{ $t('Pages.text.resend_api_key', {}) }}</span>
							<input v-model="form.resend_key" type="password" autocomplete="new-password"
								:placeholder="$t('Pages.placeholder.leave_blank_to_keep')" :disabled="form.clear_resend_key"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm font-mono" />
							<span class="mt-1 flex flex-wrap items-center gap-x-4 text-xs text-gray-600">
								<span>{{ secretSource('resend_key') }}</span>
								<label v-if="status.settings.resend_key_set" class="inline-flex items-center gap-1">
									<input v-model="form.clear_resend_key" type="checkbox" class="rounded border-gray-300" />
									{{ $t('Pages.label.remove_the_saved_key', {}) }}
								</label>
							</span>
						</label>

						<template v-if="activeMailer === 'smtp'">
							<label class="block">
								<span class="text-gray-700">{{ $t('Commons.text.smtp_server', {}) }}</span>
								<input v-model="form.smtp_host" type="text" :placeholder="placeholder('smtp_host')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">{{ $t('Commons.text.port', {}) }}</span>
								<input v-model="form.smtp_port" type="number" min="1" max="65535" :placeholder="placeholder('smtp_port')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">{{ $t('Commons.text.username', {}) }}</span>
								<input v-model="form.smtp_username" type="text" autocomplete="off" :placeholder="placeholder('smtp_username')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">Password</span>
								<input v-model="form.smtp_password" type="password" autocomplete="new-password"
									:placeholder="$t('Pages.placeholder.leave_blank_to_keep_2')" :disabled="form.clear_smtp_password"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
								<span class="mt-1 flex flex-wrap items-center gap-x-4 text-xs text-gray-600">
									<span>{{ secretSource('smtp_password') }}</span>
									<label v-if="status.settings.smtp_password_set" class="inline-flex items-center gap-1">
										<input v-model="form.clear_smtp_password" type="checkbox" class="rounded border-gray-300" />
										{{ $t('Pages.label.remove_the_saved_password', {}) }}
									</label>
								</span>
							</label>
						</template>
					</div>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.text.a_blank_field_uses', {}) }} <span class="font-mono">.env</span> {{ $t('Pages.text.value_shown_in_grey', {}) }}
						<template v-if="activeMailer === 'resend'">
							{{ $t('Pages.text.the_from_address_must', {}) }}
						</template>
						<template v-if="activeMailer === 'smtp'">
							{{ $t('Pages.text.port_465_connects_over', {}) }}
						</template>
						{{ $t('Pages.text.keys_and_passwords_are', {}) }}
					</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Pages.heading.feedback_report_recipients', {}) }}</h2>
					<label class="block text-sm">
						<span class="text-gray-700">{{ $t('Pages.text.email_these_addresses_when', {}) }}</span>
						<input v-model="form.feedback_notify_emails" type="text" :placeholder="placeholder('feedback_notify_emails')"
							class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<p class="text-xs text-gray-500">{{ $t('Pages.text.separate_addresses_with_commas', {}) }}</p>
				</section>

				<div class="flex items-center gap-4">
					<PrimaryButton :disabled="saving || !dirty" @click="save">{{ saving ? 'Saving…' : $t('Commons.button.save') }}</PrimaryButton>
					<span v-if="savedAt && !dirty" class="text-sm text-gray-600">{{ savedAt }}</span>
					<span v-if="dirty" class="text-sm text-amber-700">{{ $t('Commons.text.unsaved_changes', {}) }}</span>
				</div>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Pages.heading.send_a_test_email', {}) }}</h2>
					<div class="flex flex-wrap items-end gap-4 text-sm">
						<label class="block grow">
							<span class="text-gray-700">{{ $t('Commons.text.send_to', {}) }}</span>
							<input v-model="testTo" type="email" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<PrimaryButton :disabled="testing || dirty || !testTo" @click="sendTest">
							{{ testing ? $t('Commons.button.sending') : $t('Commons.button.send_test') }}
						</PrimaryButton>
					</div>
					<p class="text-xs text-gray-500">
						Uses the saved settings{{ dirty ? $t('Pages.text.save_your_changes_first') : '' }}. If the mail service refuses
						the message, its own error is shown above.
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
