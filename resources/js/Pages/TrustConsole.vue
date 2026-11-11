<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- TrustConsole.vue

	Trust Console (/setup/trust, manage-trusts) — who this instance trusts and what each may do.
	Panel-style page (see the admin-page-style skill). One GET /json/trusts feeds everything: this instance's
	identity, the trusts with their grants, the permission catalog, locations (client apps belong to one), and
	the audit trail. Server half: TrustConsoleController; design: App\Services\Federation.

	A trust's grants are what the peer may do TO this instance (inbound). "How authenticated" is the pairing
	method plus the approver's name and date; a domain-verified badge appears once that check exists.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, reactive, ref } from 'vue';
import { t } from '@/i18n';

defineProps({ breadcrumb: { type: Array } });

const data = ref(null);
const error = ref('');
const notice = ref('');
const busy = ref(false);

const kindLabels = { instance: t('Commons.text.another_instance'), print_client: t('Commons.text.print_client'), rstation: t('Commons.aria_label.r_station'), backup_client: t('Pages.text.backup_client_ri_launcher') };
const methodLabels = { pairing_code: t('Pages.text.approved_by_admin_via'), domain_verified: t('Pages.text.approved_by_admin_domain') };
const riskClass = { low: 'bg-green-100 text-green-800', medium: 'bg-amber-100 text-amber-800', high: 'bg-red-100 text-red-800' };

const identityForm = reactive({ name: '', base_url: '' });
const codeForm = reactive({ kind: 'print_client', name: '', kiosk_location_id: '', grants: ['print.share'] });
const newCode = ref(null);
const inviteForm = reactive({ grants: [] });
const newInvite = ref(null);
const acceptForm = reactive({ connection_code: '', grants: [] });
const copied = ref(false);
const editing = reactive({}); // trust id -> array of inbound keys being edited
const confirmRevoke = ref(null);
const confirmRegenerate = ref(false);
const regenerateText = ref('');

// A device (print client, R Station) belongs to a location; a backup client and another instance don't.
const isClientKind = computed(() => ['print_client', 'rstation'].includes(codeForm.kind));

function describe(code) {
	return (data.value?.permissions ?? []).find((p) => p.key === code);
}

function fail(e, fallback) {
	error.value = e.response?.data?.message || fallback;
}

function apply(payload) {
	data.value = payload;
	identityForm.name = payload.identity.name;
	identityForm.base_url = payload.identity.base_url ?? '';
}

async function load() {
	try {
		apply((await axios.get('/json/trusts')).data);
	} catch (e) {
		fail(e, t('Pages.text.could_not_load_the_22'));
	}
}

async function run(fn, fallback) {
	error.value = '';
	notice.value = '';
	busy.value = true;
	try {
		await fn();
	} catch (e) {
		fail(e, fallback);
	} finally {
		busy.value = false;
	}
}

const saveIdentity = () => run(async () => {
	apply((await axios.put('/json/trusts/identity', { ...identityForm })).data);
	notice.value = t('Pages.text.identity_saved');
}, t('Pages.text.could_not_save'));

const regenerate = () => run(async () => {
	apply((await axios.post('/json/trusts/identity/regenerate', { confirm: regenerateText.value })).data);
	confirmRegenerate.value = false;
	regenerateText.value = '';
	notice.value = t('Pages.text.new_key_generated_every');
}, t('Pages.text.could_not_generate_a_2'));

function pickKind() {
	codeForm.grants = codeForm.kind === 'instance' ? [] : codeForm.kind === 'backup_client' ? ['operator.full_read'] : ['print.share'];
}

function toggle(list, key) {
	const i = list.indexOf(key);
	i === -1 ? list.push(key) : list.splice(i, 1);
}

const createCode = () => run(async () => {
	const body = { kind: codeForm.kind, name: codeForm.name || null, grants: codeForm.grants };
	if (isClientKind.value) body.kiosk_location_id = codeForm.kiosk_location_id || null;
	newCode.value = (await axios.post('/json/trusts/pairing-codes', body)).data;
	await load();
}, t('Pages.text.could_not_create_a'));

const createInvite = () => run(async () => {
	newInvite.value = (await axios.post('/json/trusts/invitations', { grants: inviteForm.grants })).data;
	copied.value = false;
	await load();
}, t('Pages.text.could_not_create_an'));

async function copyInvite() {
	try {
		await navigator.clipboard.writeText(newInvite.value.connection_code);
		copied.value = true;
	} catch {
		copied.value = false; // the code is selectable on screen as a fallback
	}
}

const acceptInvite = () => run(async () => {
	const res = (await axios.post('/json/trusts/accept-invitation', { ...acceptForm })).data;
	acceptForm.connection_code = '';
	acceptForm.grants = [];
	await load();
	notice.value = `Paired with ${res.record.name}.${res.warning ? ' ' + res.warning : ''}`;
}, t('Pages.text.could_not_use_that'));

const verifyDomain = (trust) => run(async () => {
	const res = (await axios.post(`/json/trusts/${trust.id}/verify-domain`)).data;
	await load();
	res.ok ? (notice.value = `${trust.name}: ${res.message}`) : (error.value = `${trust.name}: ${res.message}`);
}, t('Pages.text.could_not_check_the'));

const refreshGrants = (trust) => run(async () => {
	await axios.post(`/json/trusts/${trust.id}/refresh-grants`);
	await load();
	notice.value = t('Pages.text.p0_asked_what_we', { p0: trust.name });
}, t('Pages.text.could_not_refresh'));

function startEdit(trust) {
	editing[trust.id] = [...trust.inbound];
}

const saveGrants = (trust) => run(async () => {
	await axios.put(`/json/trusts/${trust.id}/grants`, { inbound: editing[trust.id] });
	delete editing[trust.id];
	await load();
	notice.value = t('Pages.text.p0_permissions_saved', { p0: trust.name });
}, t('Pages.text.could_not_save_permissions'));

const revoke = (trust) => run(async () => {
	if (confirmRevoke.value !== trust.id) {
		confirmRevoke.value = trust.id;
		return;
	}
	await axios.post(`/json/trusts/${trust.id}/revoke`);
	confirmRevoke.value = null;
	await load();
	notice.value = t('Pages.text.p0_revoked', { p0: trust.name });
}, t('Pages.text.could_not_revoke'));

const when = (v) => (v ? new Date(v).toLocaleString() : null);

onMounted(load);
</script>

<template>
	<Head :title="$t('Commons.title.trust_console')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.trust_console', {}) }}</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>
			<div v-if="!data && !error" class="text-gray-500">{{ $t('Commons.text.loading_trusts', {}) }}</div>

			<template v-if="data">
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.this_instance', {}) }}</h2>
					<div v-if="data.identity.lost" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
						{{ $t('Pages.text.this_instance_s_key', {}) }}
					</div>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">{{ $t('Pages.text.name_shown_to_peers', {}) }}</span>
							<input v-model="identityForm.name" type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.public_address', {}) }}</span>
							<input v-model="identityForm.base_url" type="url" placeholder="https://relief.example.org" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</div>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<div class="border rounded p-3">
							<div class="text-gray-500 text-xs">{{ $t('Commons.text.fingerprint', {}) }}</div>
							<div class="font-mono">{{ data.identity.fingerprint }}</div>
						</div>
						<div class="border rounded p-3">
							<div class="text-gray-500 text-xs">{{ $t('Commons.text.instance_id', {}) }}</div>
							<div class="font-mono text-xs break-all">{{ data.identity.uuid }}</div>
						</div>
					</div>
					<div class="text-xs text-gray-600">{{ $t('Commons.text.public_key', {}) }} <span class="font-mono break-all">{{ data.identity.public_key }}</span></div>
					<div class="flex items-center gap-4 flex-wrap">
						<PrimaryButton :disabled="busy" @click="saveIdentity">{{ busy ? $t('Commons.button.saving') : $t('Commons.button.save') }}</PrimaryButton>
						<template v-if="!confirmRegenerate">
							<button class="text-sm underline text-gray-600" @click="confirmRegenerate = true">{{ $t('Pages.button.generate_a_new_key', {}) }}</button>
						</template>
						<template v-else>
							<input v-model="regenerateText" type="text" :placeholder="$t('Commons.placeholder.type_regenerate')" class="border-gray-300 rounded-md shadow-sm text-sm" />
							<button :disabled="busy || regenerateText !== 'REGENERATE'" class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500 disabled:opacity-50" @click="regenerate">{{ $t('Pages.button.confirm_peers_must_re', {}) }}</button>
							<button class="text-sm underline text-gray-600" @click="confirmRegenerate = false; regenerateText = ''">{{ $t('Commons.button.cancel', {}) }}</button>
						</template>
					</div>
					<p class="text-xs text-gray-500">{{ $t('Pages.text.the_public_half_of', {}) }} <span class="font-mono">/.well-known/ri-instance.json</span>. The private key is stored encrypted with this server's application key and never leaves it.</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Pages.heading.pair_something_new', {}) }}</h2>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">{{ $t('Pages.text.what_is_being_paired', {}) }}</span>
							<select v-model="codeForm.kind" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" @change="pickKind">
								<option v-for="k in data.kinds" :key="k" :value="k">{{ kindLabels[k] ?? k }}</option>
							</select>
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.name_optional', {}) }}</span>
							<input v-model="codeForm.name" type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label v-if="isClientKind" class="block">
							<span class="text-gray-700">{{ $t('Commons.text.location', {}) }}</span>
							<select v-model="codeForm.kiosk_location_id" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="">{{ $t('Commons.text.choose', {}) }}</option>
								<option v-for="l in data.locations" :key="l.id" :value="l.id">{{ l.name }}</option>
							</select>
						</label>
					</div>
					<fieldset class="text-sm space-y-2">
						<legend class="text-gray-700">{{ $t('Commons.text.it_may', {}) }}</legend>
						<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
							<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="codeForm.grants.includes(p.key)" @change="toggle(codeForm.grants, p.key)" />
							<span>
								{{ p.label }}
								<span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ p.risk }}</span>
								<span v-if="!p.built" class="ml-1 text-xs text-gray-400">{{ $t('Pages.text.not_available_yet', {}) }}</span>
								<span class="block text-xs text-gray-500">{{ p.description }}</span>
							</span>
						</label>
					</fieldset>
					<PrimaryButton :disabled="busy" @click="createCode">{{ busy ? $t('Commons.button.working') : $t('Pages.button.create_pairing_code') }}</PrimaryButton>
					<div v-if="newCode" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm space-y-1">
						<div>{{ $t('Pages.text.enter_this_code_on') }} {{ Math.round((new Date(newCode.expires_at) - Date.now()) / 60000) }} {{ $t('Pages.text.minutes_it_works_once') }}</div>
						<div class="font-mono text-2xl tracking-widest">{{ newCode.code }}</div>
					</div>
					<p class="text-xs text-gray-500">{{ $t('Pages.text.the_client_generates_its', {}) }}</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Pages.heading.connect_to_another_instance', {}) }}</h2>
					<p class="text-sm text-gray-600">{{ $t('Pages.text.each_side_s_administrator', {}) }}</p>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
						<div class="space-y-3">
							<h3 class="font-medium text-sm">{{ $t('Commons.heading.invite_one', {}) }}</h3>
							<fieldset class="text-sm space-y-1">
								<legend class="text-gray-700">{{ $t('Pages.text.it_may_do_this', {}) }}</legend>
								<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
									<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="inviteForm.grants.includes(p.key)" @change="toggle(inviteForm.grants, p.key)" />
									<span>{{ p.label }} <span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ p.risk }}</span></span>
								</label>
							</fieldset>
							<PrimaryButton :disabled="busy" @click="createInvite">{{ busy ? $t('Commons.button.working') : $t('Pages.button.create_connection_code') }}</PrimaryButton>
							<div v-if="newInvite" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm space-y-2">
								<div>{{ $t('Pages.text.give_this_to_the') }} {{ Math.round((new Date(newInvite.expires_at) - Date.now()) / 60000) }} {{ $t('Pages.text.more_minutes') }}</div>
								<textarea readonly rows="3" class="w-full font-mono text-xs border-gray-300 rounded" :value="newInvite.connection_code" @focus="$event.target.select()"></textarea>
								<button class="text-sm underline" @click="copyInvite">{{ copied ? $t('Commons.button.copied') : $t('Commons.button.copy') }}</button>
							</div>
						</div>
						<div class="space-y-3">
							<h3 class="font-medium text-sm">{{ $t('Pages.heading.use_a_code_you', {}) }}</h3>
							<label class="block text-sm">
								<span class="text-gray-700">{{ $t('Commons.text.connection_code', {}) }}</span>
								<textarea v-model="acceptForm.connection_code" rows="3" placeholder="RIFED1-…" class="mt-1 block w-full font-mono text-xs border-gray-300 rounded-md shadow-sm"></textarea>
							</label>
							<fieldset class="text-sm space-y-1">
								<legend class="text-gray-700">{{ $t('Pages.text.it_may_do_this', {}) }}</legend>
								<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
									<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="acceptForm.grants.includes(p.key)" @change="toggle(acceptForm.grants, p.key)" />
									<span>{{ p.label }} <span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ p.risk }}</span></span>
								</label>
							</fieldset>
							<PrimaryButton :disabled="busy || !acceptForm.connection_code" @click="acceptInvite">{{ busy ? $t('Commons.button.connecting') : $t('Commons.button.connect') }}</PrimaryButton>
						</div>
					</div>
					<p class="text-xs text-gray-500">{{ $t('Pages.text.the_code_carries_the', {}) }}</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.trusts', {}) }}</h2>
					<p v-if="!data.trusts.length" class="text-gray-400 text-sm">{{ $t('Commons.text.none_yet', {}) }}</p>
					<div v-for="t in data.trusts" :key="t.id" class="border rounded p-3 space-y-2 text-sm" :class="t.status !== 'approved' ? 'opacity-60' : ''">
						<div class="flex items-center justify-between gap-2 flex-wrap">
							<div>
								<span class="font-semibold">{{ t.name }}</span>
								<span class="ml-2 text-xs text-gray-500">{{ kindLabels[t.kind] ?? t.kind }}</span>
								<span v-if="t.status !== 'approved'" class="ml-2 text-xs rounded px-1.5 py-0.5 bg-gray-200 text-gray-700">{{ t.status }}</span>
								<span v-if="t.domain_verified_at" class="ml-2 text-xs rounded px-1.5 py-0.5 bg-green-100 text-green-800">{{ $t('Commons.text.domain_verified', {}) }}</span>
							</div>
							<div v-if="t.status === 'approved'" class="flex items-center gap-3">
								<button class="inline-flex items-center px-3 py-1 rounded-md font-semibold text-xs uppercase tracking-widest text-white" :class="confirmRevoke === t.id ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'" :disabled="busy" @click="revoke(t)">
									{{ confirmRevoke === t.id ? $t('Pages.button.confirm_it_will_stop') : $t('Commons.button.revoke') }}
								</button>
								<button v-if="confirmRevoke === t.id" class="text-sm underline text-gray-600" @click="confirmRevoke = null">{{ $t('Commons.button.cancel', {}) }}</button>
							</div>
						</div>
						<div class="text-xs text-gray-600">
							{{ methodLabels[t.auth_method] ?? t.auth_method }}<template v-if="t.approved_by"> — {{ t.approved_by }}</template><template v-if="t.approved_at">, {{ when(t.approved_at) }}</template>
						</div>
						<div class="text-xs text-gray-600">
							{{ $t('Commons.text.fingerprint', {}) }} <span class="font-mono">{{ t.fingerprint }}</span>
							<template v-if="t.base_url"> · {{ t.base_url }}</template>
							{{ $t('Pages.text.last_seen_2', {}) }} <template v-if="t.last_seen_at">{{ when(t.last_seen_at) }}<template v-if="t.last_seen_ip"> from {{ t.last_seen_ip }}</template></template><span v-else class="text-gray-400">never</span>
						</div>

						<div v-if="editing[t.id]" class="space-y-2">
							<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
								<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="editing[t.id].includes(p.key)" @change="toggle(editing[t.id], p.key)" />
								<span>{{ p.label }} <span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ p.risk }}</span></span>
							</label>
							<div class="flex items-center gap-4">
								<PrimaryButton :disabled="busy" @click="saveGrants(t)">{{ $t('Commons.button.save_permissions', {}) }}</PrimaryButton>
								<button class="text-sm underline text-gray-600" @click="delete editing[t.id]">{{ $t('Commons.button.cancel', {}) }}</button>
							</div>
						</div>
						<div v-else class="flex items-center gap-2 flex-wrap">
							<span class="text-xs text-gray-500">{{ $t('Commons.text.may', {}) }}</span>
							<span v-for="k in t.inbound" :key="k" class="text-xs rounded px-1.5 py-0.5" :class="riskClass[describe(k)?.risk ?? 'low']">{{ describe(k)?.label ?? k }}</span>
							<span v-if="!t.inbound.length" class="text-xs text-gray-400">{{ $t('Commons.text.nothing', {}) }}</span>
							<button v-if="t.status === 'approved'" class="text-xs underline text-gray-600" @click="startEdit(t)">{{ $t('Commons.button.edit', {}) }}</button>
						</div>
						<div v-if="t.kind === 'instance'" class="flex items-center gap-2 flex-wrap">
							<span class="text-xs text-gray-500">{{ $t('Pages.text.we_may_do_to', {}) }}</span>
							<span v-for="k in t.outbound" :key="k" class="text-xs rounded px-1.5 py-0.5" :class="riskClass[describe(k)?.risk ?? 'low']">{{ describe(k)?.label ?? k }}</span>
							<span v-if="!t.outbound.length" class="text-xs text-gray-400">{{ $t('Commons.text.nothing_known', {}) }}</span>
							<template v-if="t.status === 'approved'">
								<button class="text-xs underline text-gray-600" :disabled="busy" @click="refreshGrants(t)">{{ $t('Commons.button.refresh', {}) }}</button>
								<button class="text-xs underline text-gray-600" :disabled="busy" @click="verifyDomain(t)">{{ $t('Commons.button.verify_domain', {}) }}</button>
							</template>
						</div>
					</div>
					<p class="text-xs text-gray-500">{{ $t('Pages.text.permission_changes_and_revoking', {}) }}</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-2">
					<h2 class="text-lg font-semibold">{{ $t('Pages.heading.recent_trust_events', {}) }}</h2>
					<p v-if="!data.audit.length" class="text-gray-400 text-sm">{{ $t('Commons.text.none_yet', {}) }}</p>
					<ul class="text-xs text-gray-600 space-y-1">
						<li v-for="a in data.audit" :key="a.id"><span class="font-mono">{{ when(a.created_at) }}</span> — {{ a.event.replace('_', ' ') }}</li>
					</ul>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
