<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- InstanceAdmin.vue

	Instance Admin (/setup/instance) — what belongs to the whole instance rather than one warehouse. Instance
	administrators only (route middleware `instance-admin`; the JSON half is /json/instance/*, which reuses
	SystemController's actions). Tabs:

	  Updates & Mode           Software version / update (Docker: through the host-side updater, see InstanceUpdate;
	                           systemd: the DEPRECATED in-app updater) and Offline mode.
	  Full Instance Backups    One zip of every warehouse plus the control and accounts schemas: the schedule (off until turned
	                           on), the list, Back up now and download (InstanceBackupController). The provisioner container
	                           makes them, since it alone holds the database administrator's password; this page only writes
	                           fixed requests for it. Each zip holds the warehouse keys sealed to the instance's recovery key
	                           (the panel at the top of the tab makes it and shows the private half once; see dev/notes/BACKUPS.md).
	  Warehouses               The warehouse:* commands as buttons (InstanceWarehouseController): list, create, edit, suspend /
	                           maintenance / activate / resume, archive, remove, setup codes, hostnames. Every change asks for
	                           the person's password again. Removal waits 30 days after archiving here (the artisan command
	                           removes at once).

	`runtime` ('systemd' | 'docker') comes from config('system.runtime'). During an update the site enters
	maintenance mode, so status polls start failing with 503 — expected, and shown as progress rather than an error.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue';
import { t } from '@/i18n';

const props = defineProps({
	breadcrumb: { type: Array },
	runtime: { type: String, default: 'systemd' },
});

const docker = computed(() => props.runtime === 'docker');

// ?tab=backups opens that tab directly (the recovery-key banner links there).
const tab = ref([t('Commons.text.updates'), 'warehouses', t('Commons.text.backups')].includes(new URLSearchParams(location.search).get('tab')) ? new URLSearchParams(location.search).get('tab') : t('Commons.text.updates'));
const status = ref(null);
const error = ref('');
const notice = ref('');
const checking = ref(false);
const updating = ref(false);
const confirmingUpdate = ref(false);
const inMaintenance = ref(false);
const savingOfflineMode = ref(false);

// Docker: the self-update flag the host-side updater works from (status.docker_update).
const dockerUpdate = computed(() => status.value?.docker_update ?? null);
const dockerBusy = computed(() => ['requested', 'checking', 'pulling', 'restarting'].includes(dockerUpdate.value?.state));
const requestingDocker = ref(false);
const confirmingDockerUpdate = ref(false);
const dockerStateText = {
	requested: t('Pages.text.waiting_for_the_updater'),
	checking: t('Pages.text.looking_for_a_new'),
	pulling: t('Pages.text.downloading_the_new_version'),
	restarting: t('Pages.text.installing_the_site_is'),
};
let dockerTimer = null;

let pollTimer = null;

async function fetchStatus() {
	const response = await axios.get('/json/instance/status');
	status.value = response.data;
	// An update left running (or just finished) when the page loaded
	if (response.data.update_status?.state === 'running' && !updating.value) {
		updating.value = true;
		startPolling();
	} else if (response.data.update_status?.state === 'stalled') {
		error.value = t('Pages.text.update_stalled_p0', { p0: response.data.update_status.message });
	}
	if (response.data.docker_update) {
		if (dockerBusy.value) startDockerPolling();
		else stopDockerPolling();
	}
	return response.data;
}

async function requestDockerUpdate(action) {
	if (action === 'update' && !confirmingDockerUpdate.value) {
		confirmingDockerUpdate.value = true;
		return;
	}
	confirmingDockerUpdate.value = false;
	requestingDocker.value = true;
	error.value = '';
	notice.value = '';
	try {
		const response = await axios.post(action === 'update' ? '/json/instance/update' : '/json/instance/check-updates');
		status.value.docker_update = response.data.docker_update;
		startDockerPolling();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_send_the_2');
	} finally {
		requestingDocker.value = false;
	}
}

// Poll while a request is open. The app is down while it restarts, so a failed poll is expected, not an error.
function startDockerPolling() {
	if (dockerTimer) return;
	let wasBusy = true;
	dockerTimer = setInterval(async () => {
		try {
			const data = await fetchStatus();
			const du = data.docker_update;
			if (du && !dockerBusy.value && wasBusy) {
				wasBusy = false;
				if (du.state === 'failed') error.value = t('Pages.text.update_failed_p0', { p0: du.message });
				else if (du.state === 'stalled') error.value = du.message;
				else notice.value = du.message || t('Pages.text.finished');
			}
		} catch (e) {
			// offline while restarting — keep polling
		}
	}, 4000);
}

function stopDockerPolling() {
	if (dockerTimer) {
		clearInterval(dockerTimer);
		dockerTimer = null;
	}
}

async function checkForUpdates() {
	checking.value = true;
	error.value = '';
	notice.value = '';
	try {
		const response = await axios.post('/json/instance/check-updates');
		status.value.version = response.data.version;
		notice.value = response.data.version.behind === 0
			? t('Pages.text.you_are_running_the')
			: `Update available: ${response.data.version.behind} new commit(s).`;
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.update_check_failed');
	} finally {
		checking.value = false;
	}
}

async function startUpdate() {
	if (!confirmingUpdate.value) {
		confirmingUpdate.value = true;
		return;
	}
	confirmingUpdate.value = false;
	updating.value = true;
	error.value = '';
	notice.value = '';
	try {
		await axios.post('/json/instance/update');
		startPolling();
	} catch (e) {
		updating.value = false;
		error.value = e.response?.data?.message || t('Pages.text.could_not_start_the_3');
	}
}

function startPolling() {
	stopPolling();
	pollTimer = setInterval(async () => {
		try {
			const data = await fetchStatus();
			inMaintenance.value = false;
			const state = data.update_status?.state;
			if (state === 'success' || state === 'failed' || state === 'stalled') {
				stopPolling();
				updating.value = false;
				if (state === 'success') {
					notice.value = t('Pages.text.update_finished_successfully');
				} else if (state === 'stalled') {
					error.value = t('Pages.text.update_stalled_p0', { p0: data.update_status.message });
				} else {
					error.value = t('Pages.text.update_failed_p0_the', { p0: data.update_status.message });
				}
			}
		} catch (e) {
			// 503 = maintenance mode = update in progress; keep polling
			inMaintenance.value = true;
		}
	}, 4000);
}

function stopPolling() {
	if (pollTimer) {
		clearInterval(pollTimer);
		pollTimer = null;
	}
}

async function toggleOfflineMode() {
	const desired = status.value.offline_mode;
	savingOfflineMode.value = true;
	error.value = '';
	notice.value = '';
	try {
		const response = await axios.put('/json/instance/offline-mode', { enabled: desired });
		status.value.offline_mode = response.data.offline_mode;
		notice.value = response.data.offline_mode ? t('Pages.text.offline_mode_enabled') : t('Pages.text.offline_mode_disabled');
	} catch (e) {
		status.value.offline_mode = !desired; // revert the checkbox — save failed
		error.value = e.response?.data?.message || t('Pages.text.could_not_save_offline');
	} finally {
		savingOfflineMode.value = false;
	}
}


// ---- Warehouses ----
// Every change goes through one dialog that asks for your password again (the server checks it on each request).
const warehouses = ref(null);
const removalWaitDays = ref(30);
const dialog = ref(null); // { title, text, danger, button, fields: [{ key, label, type, value, help }], run(values, password) }
const dialogPassword = ref('');
const dialogError = ref('');
const dialogBusy = ref(false);
const result = ref(null); // a setup code to show once
const statusNames = {
	provisioning: t('Commons.text.being_created'), awaiting_setup: t('Pages.text.waiting_for_setup'), active: t('Commons.button.active'), maintenance: 'Maintenance', restoring: t('Commons.text.restoring'),
	upgrading: t('Commons.text.upgrading'), held: t('Commons.text.held'), suspended: t('Commons.text.suspended'), archived: t('Commons.text.archived'),
};
const statusClass = (st) => ({
	active: 'bg-green-100 text-green-800',
	awaiting_setup: 'bg-blue-100 text-blue-800',
	archived: 'bg-gray-200 text-gray-700',
	suspended: 'bg-amber-100 text-amber-800',
	maintenance: 'bg-amber-100 text-amber-800',
}[st] || 'bg-red-100 text-red-800');
const shortDate = (iso) => (iso ? new Date(iso).toLocaleDateString() : '');

async function loadWarehouses() {
	try {
		const { data } = await axios.get('/json/instance/warehouses');
		warehouses.value = data.warehouses;
		removalWaitDays.value = data.removal_wait_days;
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_load_the_8');
	}
}

function openDialog(d) {
	dialog.value = { fields: [], ...d, values: Object.fromEntries((d.fields || []).map((f) => [f.key, f.value ?? (f.type === 'checkbox' ? false : '')])) };
	dialogPassword.value = '';
	dialogError.value = '';
	error.value = '';
	notice.value = '';
	result.value = null;
}

function closeDialog() {
	if (dialogBusy.value) return;
	dialog.value = null;
	dialogPassword.value = '';
}

async function submitDialog() {
	dialogBusy.value = true;
	dialogError.value = '';
	try {
		const { data } = await dialog.value.run(dialog.value.values, dialogPassword.value);
		notice.value = data.message || t('Pages.text.done');
		if (data.private_key) recoveryShown.value = data;   // the one time it exists outside the person's hands: shown in the dialog below
		else if (data.code && data.address) pairCode.value = data;
		else if (data.setup_code) result.value = { code: data.setup_code, url: data.setup_url, note: data.message };
		else if (data.backup !== undefined) result.value = { removed: data };
		else if (data.note) notice.value += ` ${data.note}`;
		dialog.value = null;
		await loadWarehouses();
		if (tab.value === 'backups') await loadInstanceBackups();
	} catch (e) {
		dialogError.value = e.response?.data?.errors
			? Object.values(e.response.data.errors).flat().join(' ')
			: e.response?.data?.message || t('Pages.text.that_did_not_work');
	} finally {
		dialogBusy.value = false;
		dialogPassword.value = '';
	}
}

const post = (id, action, body) => (password) => axios.post(`/json/instance/warehouses/${id}/${action}`, { ...body, password });

function newWarehouse() {
	openDialog({
		title: t('Commons.button.new_warehouse'), button: t('Commons.text.create_warehouse'),
		text: t('Pages.text.creates_an_empty_warehouse'),
		fields: [
			{ key: 'name', label: t('Commons.button.name'), type: 'text' },
			{ key: 'email', label: t('Pages.text.contact_email_optional'), type: 'email' },
			{ key: 'training', label: t('Pages.text.a_training_warehouse_class'), type: 'checkbox' },
		],
		run: (v, password) => axios.post('/json/instance/warehouses', { name: v.name, email: v.email || null, training: v.training, password }),
	});
}

function editWarehouse(w) {
	openDialog({
		title: t('Commons.text.edit_p0', { p0: w.name }), button: t('Commons.button.save'),
		fields: [
			{ key: 'name', label: t('Pages.text.name_the_login_page'), type: 'text', value: w.name },
			{ key: 'email', label: t('Commons.text.contact_email'), type: 'email', value: w.admin_email || '' },
			{ key: 'listed', label: t('Pages.text.listed_in_the_chooser'), type: 'checkbox', value: w.listed },
			{ key: 'notes', label: t('Pages.text.notes_only_instance_admins'), type: 'textarea', value: w.notes || '' },
		],
		run: (v, password) => axios.put(`/json/instance/warehouses/${w.id}`, { name: v.name, email: v.email || null, listed: v.listed, notes: v.notes || null, password }),
	});
}

function suspendWarehouse(w, maintenance) {
	openDialog({
		title: `${maintenance ? 'Put into maintenance' : t('Commons.button.suspend')} ${w.name}`, button: maintenance ? t('Commons.text.start_maintenance') : t('Commons.button.suspend'),
		text: t('Pages.text.p0_stops_answering_everyone', { p0: w.name })
			+ (w.is_default ? t('Pages.text.this_is_the_default') : ''),
		danger: true,
		fields: [{ key: 'reason', label: t('Pages.text.reason_kept_in_the'), type: 'text' }],
		run: (v, password) => post(w.id, 'suspend', { maintenance, reason: v.reason || null })(password),
	});
}

const simple = (w, action, title, text, button = title, danger = false) => openDialog({ title: `${title}: ${w.name}`, text, button, danger, run: (v, password) => post(w.id, action, {})(password) });
const activateWarehouse = (w) => simple(w, 'activate', t('Commons.button.activate'), t('Pages.text.p0_goes_back_into', { p0: w.name }));
const resumeWarehouse = (w) => simple(w, t('Commons.text.resume'), t('Commons.button.resume'), t('Pages.text.ends_a_restore_that', { p0: w.name }));

function archiveWarehouse(w, undo = false) {
	openDialog({
		title: `${undo ? t('Commons.button.bring_back') : t('Commons.button.archive')} ${w.name}`, button: undo ? t('Commons.button.bring_back') : t('Commons.button.archive'), danger: !undo,
		text: undo
			? t('Pages.text.p0_returns_to_the', { p0: w.name })
			: `${w.name} stops serving anyone, but nothing is deleted. After ${removalWaitDays.value} days it can be removed for good from here. You can bring it back at any time before that.`,
		run: (v, password) => post(w.id, 'archive', { undo })(password),
	});
}

function removeWarehouse(w) {
	openDialog({
		title: t('Pages.text.remove_p0_for_good', { p0: w.name }), button: t('Pages.button.remove_for_good'), danger: true,
		text: 'A final backup is taken first and kept in the removed-warehouses folder of the backup directory. Then the warehouse\'s database, files and the logins that belonged only to it are deleted. This cannot be undone. It can take several minutes.',
		fields: [{ key: 'confirm', label: t('Pages.text.type_the_warehouse_s', { p0: w.name }), type: 'text' }],
		run: (v, password) => axios.delete(`/json/instance/warehouses/${w.id}`, { data: { confirm: v.confirm, password } }),
	});
}

function newSetupCode(w) {
	simple(w, 'setup-code', t('Pages.button.new_setup_code'), t('Pages.text.issues_a_new_one'), t('Commons.text.issue_code'));
}

function revokeSetupCode(w) {
	openDialog({ title: t('Pages.text.revoke_the_setup_code', { p0: w.name }), button: t('Commons.button.revoke'), danger: true, text: t('Pages.text.the_waiting_code_stops'), run: (v, password) => post(w.id, 'setup-code', { revoke: true })(password) });
}

function addHostname(w) {
	openDialog({
		title: t('Pages.text.add_a_hostname_to', { p0: w.name }), button: t('Commons.button.add_hostname'),
		text: t('Pages.text.a_hostname_mapped_to'),
		fields: [
			{ key: 'hostname', label: t('Pages.text.hostname_for_example_warehouse2'), type: 'text' },
			{ key: 'primary', label: t('Pages.text.make_it_the_primary'), type: 'checkbox' },
		],
		run: (v, password) => post(w.id, 'domains', { hostname: v.hostname, primary: v.primary })(password),
	});
}

function removeHostname(w, hostname) {
	openDialog({
		title: t('Commons.text.remove_p0', { p0: hostname }), button: t('Commons.text.remove_hostname'), danger: true,
		text: `${hostname} will no longer reach ${w.name}.`,
		run: (v, password) => axios.delete(`/json/instance/warehouses/${w.id}/domains`, { data: { hostname, password } }),
	});
}

const copied = ref(false);
async function copyCode() {
	try {
		await navigator.clipboard.writeText(result.value.code);
		copied.value = true;
	} catch {
		copied.value = false;
	}
}

// ---- Full Instance Backups (Docker) ----
const instBackups = ref(null);   // the server's payload: { available, schedule, backups, activity, working }
const instForm = ref(null);
const weekdays = [t('Commons.text.sunday'), t('Commons.text.monday'), t('Commons.text.tuesday'), 'Wednesday', t('Commons.text.thursday'), t('Commons.text.friday'), t('Commons.text.saturday')];
let instTimer = null;

const instFormOf = (sc) => ({
	enabled: !!sc.enabled, daily_hour: sc.daily_hour, daily_keep: sc.daily_keep, daily_with_files: !!sc.daily_with_files,
	weekly_enabled: !!sc.weekly_enabled, weekly_dow: sc.weekly_dow, weekly_keep: sc.weekly_keep, weekly_with_files: !!sc.weekly_with_files,
});

async function loadInstanceBackups() {
	try {
		const { data } = await axios.get('/json/instance/backups');
		instBackups.value = data;
		// Filled once (and after a save): the poll must not overwrite what is being typed.
		if (data.available && !instForm.value) instForm.value = instFormOf(data.schedule);
	} catch (e) {
		/* a poll that fails (an update is restarting the site) is not worth showing */
		if (!instBackups.value) error.value = e.response?.data?.message || t('Pages.text.could_not_load_the_9');
	}
}

watch(tab, (t) => {
	clearInterval(instTimer);
	if (t === 'backups') {
		loadInstanceBackups();
		instTimer = setInterval(loadInstanceBackups, 4000);
	}
}, { immediate: true });   // ?tab=backups starts on this tab, so the value never "changes"

function saveInstanceSchedule() {
	openDialog({
		title: t('Pages.text.save_the_full_instance'), button: t('Commons.text.save_schedule'),
		text: instForm.value.enabled
			? t('Pages.text.the_provisioner_will_make')
			: t('Pages.text.automatic_full_instance_backups'),
		run: (v, password) => axios.put('/json/instance/backups/schedule', { ...instForm.value, password }).then((r) => {
			instForm.value = instFormOf(r.data.schedule);
			return r;
		}),
	});
}

function backUpInstanceNow(files) {
	openDialog({
		title: files ? t('Pages.text.back_up_the_whole') : t('Pages.text.back_up_the_whole_2'), button: t('Pages.text.back_up_now'),
		text: t('Pages.text.the_provisioner_makes_one'),
		run: (v, password) => axios.post('/json/instance/backups', { files, password }),
	});
}

const sizeOf = (bytes) => (bytes > 1073741824 ? `${(bytes / 1073741824).toFixed(2)} GB` : bytes > 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.ceil(bytes / 1024)} KB`);
const labelNames = { 'scheduled-daily': t('Commons.text.scheduled_daily'), 'scheduled-weekly': t('Commons.text.scheduled_weekly'), manual: t('Pages.text.made_by_hand'), premigrate: t('Pages.text.before_an_upgrade') };
const instWhen = (iso) => (iso ? new Date(iso).toLocaleString() : '');

// ---- Recovery key ----
// The server keeps only the public half. The private half arrives once, here, in the response to "Make a recovery key", and is gone from the
// server the moment it is sent. The person must print or save it before closing; if the page is closed first the key is lost and a new one is made.
const recoveryShown = ref(null);   // { private_key, fingerprint, instance, address, made_at } while the dialog is open
const recoveryStored = ref(false);
const recoveryCopied = ref(false);
const recoveryBusy = ref(false);
const recoveryState = computed(() => instBackups.value?.recovery_key ?? { state: t('Commons.text.none_2') });

function makeRecoveryKey(replace = false) {
	recoveryShown.value = null;
	openDialog({
		title: replace ? t('Pages.text.make_a_new_recovery') : t('Pages.text.make_the_recovery_key'), button: replace ? t('Pages.text.replace_the_key') : t('Pages.text.make_the_key'), danger: replace,
		text: replace
			? t('Pages.text.backups_made_from_now')
			: t('Pages.text.makes_the_key_that'),
		run: (v, password) => axios.post('/json/instance/backups/recovery-key', { replace, password }),
	});
}

function recoveryText() {
	const k = recoveryShown.value;
	return [
		t('Pages.text.relief_inventory_recovery_key', { p0: k.instance }),
		'',
		`Instance:     ${k.address}`,
		`Made:         ${new Date(k.made_at).toLocaleString()}`,
		`Fingerprint:  ${k.fingerprint}`,
		'',
		t('Commons.text.recovery_key_2'),
		`  ${k.private_key}`,
		'',
		t('Pages.text.what_this_is'),
		t('Pages.text.every_whole_instance_backup'),
		'can open it. After a disaster, restore with:  restore:instance <backup.zip> --recovery-key-file <a file containing the line above>',
		t('Pages.text.and_every_warehouse_s'),
		'',
		t('Pages.text.keep_it_safe'),
		t('Pages.text.store_this_away_from'),
		t('Pages.text.key_and_a_backup'),
		'Instance Admin > Full Instance Backups (backups made before then still need this one).',
		'',
	].join('\n');
}

function printRecoveryKey() {
	const k = recoveryShown.value;
	const w = window.open('', '_blank', 'width=720,height=900');
	if (!w) { error.value = t('Pages.text.your_browser_blocked_the'); return; }
	const esc = (t) => String(t).replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));
	w.document.write(`<!doctype html><title>{t('Commons.heading.recovery_key')}</title><style>body{font-family:sans-serif;margin:2rem;color:#000}h1{font-size:1.3rem}
		.key{font:700 1.25rem/1.6 monospace;letter-spacing:.05em;border:2px solid #000;padding:1rem;margin:1rem 0;word-break:break-all}
		pre{white-space:pre-wrap;font:0.85rem/1.5 sans-serif}</style>
		<h1>Relief Inventory &mdash; recovery key (${esc(k.instance)})</h1>
		<div>Instance: ${esc(k.address)}<br>Made: ${esc(new Date(k.made_at).toLocaleString())}<br>Fingerprint: <b>${esc(k.fingerprint)}</b></div>
		<div class="key">${esc(k.private_key)}</div>
		<pre>${esc(recoveryText().split('WHAT THIS IS')[1] ? t('Pages.text.what_this_is') + recoveryText().split('WHAT THIS IS')[1] : '')}</pre>`);
	w.document.close();
	w.focus();
	w.print();
}

function downloadRecoveryKey() {
	const k = recoveryShown.value;
	const url = URL.createObjectURL(new Blob([recoveryText()], { type: 'text/plain' }));
	const a = document.createElement('a');
	a.href = url;
	a.download = `recovery-key-${k.fingerprint}.txt`;
	a.click();
	URL.revokeObjectURL(url);
}

async function copyRecoveryKey() {
	try {
		await navigator.clipboard.writeText(recoveryShown.value.private_key);
		recoveryCopied.value = true;
	} catch {
		recoveryCopied.value = false;
	}
}

async function finishRecoveryKey() {
	recoveryBusy.value = true;
	try {
		await axios.post('/json/instance/backups/recovery-key/confirm');
		recoveryShown.value = null;
		recoveryStored.value = false;
		recoveryCopied.value = false;
		notice.value = t('Pages.text.recovery_key_confirmed_every');
		await loadInstanceBackups();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.text.could_not_confirm_the');
	} finally {
		recoveryBusy.value = false;
	}
}

// Computers (the RI Launcher) paired to the instance so they can take whole-instance backups. A new code is shown once.
const pairCode = ref(null);   // { code, expires_at, address }

function newBackupClient() {
	pairCode.value = null;
	openDialog({
		title: t('Pages.text.pair_a_computer_for'), button: t('Pages.text.make_a_code'),
		text: 'Makes a one-time code, good for 15 minutes. In the RI Launcher, choose Remote backups, then pair with this address and the code, as an instance backup. That computer can then make and download backups of the WHOLE instance (every warehouse and every person\'s information) until you revoke it here.',
		fields: [{ key: 'name', label: t('Pages.text.what_it_is_optional'), type: 'text' }],
		run: (v, password) => axios.post('/json/instance/backups/clients/code', { name_hint: v.name || null, password }),
	});
}

function revokeBackupClient(c) {
	openDialog({
		title: t('Commons.text.stop_p0', { p0: c.name }), button: t('Commons.button.revoke'), danger: true,
		text: t('Pages.text.p0_can_no_longer', { p0: c.name }),
		run: (v, password) => axios.delete(`/json/instance/backups/clients/${c.id}`, { data: { password } }),
	});
}

onMounted(() => {
	loadWarehouses();
	fetchStatus().catch(() => { error.value = t('Pages.text.could_not_load_system'); });
});
onUnmounted(() => {
	stopPolling();
	stopDockerPolling();
	clearInterval(instTimer);
});
</script>

<template>
	<Head :title="$t('Commons.title.instance_admin')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.instance_admin', {}) }}</h1>
			<p class="text-sm text-gray-600">
				{{ $t('Pages.text.these_settings_apply_to', {}) }}
				<a href="/setup/system" class="underline">{{ $t('Commons.heading.warehouse_backups', {}) }}</a>.
			</p>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<div class="flex gap-1 border-b border-gray-300">
				<button v-for="t in [['updates', 'Updates & Mode'], ['warehouses', 'Warehouses'], ['backups', 'Full Instance Backups']]" :key="t[0]"
					class="px-4 py-2 text-sm font-medium -mb-px border-b-2"
					:class="tab === t[0] ? 'border-indigo-600 text-indigo-700' : 'border-transparent text-gray-600 hover:text-gray-900'"
					@click="tab = t[0]">{{ t[1] }}</button>
			</div>

			<div v-if="tab === 'updates'" class="space-y-6">
				<div v-if="!status" class="text-gray-500">{{ $t('Pages.text.loading_system_status', {}) }}</div>
					<!-- Software update -->
					<section v-if="status" class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.software') }} {{ docker ? $t('Commons.heading.version') : $t('Commons.heading.update') }}</h2>
						<div class="text-sm text-gray-700">
							<p>
								{{ $t('Commons.text.current_version', {}) }}
								<span v-if="status.version.release" class="font-semibold">{{ status.version.release }}</span>
								<span v-else class="text-gray-500">unversioned</span>
								(commit <span class="font-mono">{{ status.version.current || 'unknown' }}</span>)
								<span v-if="status.version.current_date"> — {{ new Date(status.version.current_date).toLocaleString() }}</span>
							</p>
							<p v-if="status.version.current_subject" class="text-gray-500">“{{ status.version.current_subject }}”</p>
						</div>

						<!-- Docker / R Station: the host-side updater does the work; this page only asks it -->
						<template v-if="docker">
							<p v-if="!dockerUpdate?.enabled" class="text-sm text-gray-600">
								{{ $t('Pages.text.updating_from_this_page', {}) }} <span class="font-mono">RI_UPDATE_SECRET</span> {{ $t('Pages.text.in_compose_yaml_and', {}) }}
							</p>
							<template v-else>
								<p v-if="dockerUpdate.available_version" class="text-sm font-medium text-amber-700">
									{{ $t('Commons.heading.version') }} {{ dockerUpdate.available_version }} is available (checked {{ new Date(dockerUpdate.last_checked_at).toLocaleString() }}).
								</p>
								<p v-else-if="dockerUpdate.last_checked_at" class="text-sm text-gray-600">
									{{ $t('Commons.text.last_checked') }} {{ new Date(dockerUpdate.last_checked_at).toLocaleString() }}{{ $t('Pages.text.nothing_newer') }}
								</p>

								<div v-if="dockerBusy" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
									<p class="font-medium">{{ dockerStateText[dockerUpdate.state] }}</p>
									<p v-if="dockerUpdate.message">{{ dockerUpdate.message }}</p>
								</div>
								<div v-else-if="dockerUpdate.state === 'stalled'" class="rounded bg-amber-50 border border-amber-300 text-amber-800 px-4 py-3 text-sm">
									{{ dockerUpdate.message }}
								</div>

								<div v-if="dockerUpdate.can_request && !dockerBusy" class="flex gap-3 items-center">
									<PrimaryButton :disabled="requestingDocker" @click="requestDockerUpdate('check')">{{ $t('Pages.button.check_for_updates', {}) }}</PrimaryButton>
									<button
										v-if="dockerUpdate.available_version || confirmingDockerUpdate"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
										:class="confirmingDockerUpdate ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'"
										:disabled="requestingDocker"
										@click="requestDockerUpdate('update')"
									>
										{{ confirmingDockerUpdate ? $t('Pages.button.confirm_every_warehouse_goes') : $t('Commons.button.install_update') }}
									</button>
									<button v-if="confirmingDockerUpdate" class="text-sm text-gray-500 underline" @click="confirmingDockerUpdate = false">{{ $t('Commons.button.cancel', {}) }}</button>
								</div>
								<p v-else-if="!dockerUpdate.can_request" class="text-xs text-gray-500">
									{{ $t('Pages.text.only_an_instance_administrator', {}) }}
								</p>
								<p class="text-xs text-gray-500">
									{{ $t('Pages.text.the_updater_on_the', {}) }}
								</p>
							</template>
						</template>

						<template v-else>
							<div v-if="status.updater_deprecated" class="rounded bg-amber-50 border border-amber-300 text-amber-900 px-4 py-3 text-sm">
								<p class="font-medium">{{ $t('Pages.text.deprecated_updating_from_this', {}) }}</p>
								<p>
									{{ $t('Pages.text.it_pulls_the_code', {}) }} <span class="font-mono">scripts/update.sh</span> {{ $t('Pages.text.from_a_shell_on', {}) }}
								</p>
							</div>
							<div v-if="status.version.behind > 0" class="text-sm">
								<p class="font-medium text-amber-700">{{ status.version.behind }} {{ $t('Commons.text.update_s_available') }}</p>
								<ul class="font-mono text-xs text-gray-600 mt-1 space-y-0.5">
									<li v-for="commit in status.version.pending_commits" :key="commit">{{ commit }}</li>
								</ul>
							</div>

							<div v-if="updating" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
								<p class="font-medium">{{ $t('Pages.text.update_in_progress', {}) }}</p>
								<p v-if="inMaintenance">{{ $t('Pages.text.the_site_is_in', {}) }}</p>
								<p v-else-if="status.update_status?.message">{{ status.update_status.message }}</p>
							</div>

							<div class="flex gap-3 items-center" v-if="!updating">
								<PrimaryButton :disabled="checking" @click="checkForUpdates">
									{{ checking ? $t('Commons.button.checking') : $t('Pages.button.check_for_updates') }}
								</PrimaryButton>
								<button
									v-if="status.version.behind > 0 || confirmingUpdate"
									class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
									:class="confirmingUpdate ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'"
									@click="startUpdate"
								>
									{{ confirmingUpdate ? $t('Pages.button.confirm_site_will_briefly') : $t('Commons.button.install_update') }}
								</button>
								<button v-if="confirmingUpdate" class="text-sm text-gray-500 underline" @click="confirmingUpdate = false">{{ $t('Commons.button.cancel', {}) }}</button>
							</div>
							<p class="text-xs text-gray-500">
								{{ $t('Pages.text.installing_an_update_backs', {}) }}
							</p>
						</template>
					</section>

					<!-- Offline Mode -->
					<section v-if="status" class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.offline_mode', {}) }}</h2>
						<p class="text-sm text-gray-600">
							{{ $t('Pages.text.turn_this_on_when', {}) }}
						</p>
						<label class="flex items-center gap-3">
							<input type="checkbox" v-model="status.offline_mode" :disabled="savingOfflineMode"
								@change="toggleOfflineMode" class="h-5 w-5 rounded border-gray-300" />
							<span class="text-sm font-medium text-gray-700">
								{{ status.offline_mode ? $t('Pages.text.offline_mode_is_on') : $t('Pages.text.offline_mode_is_off') }}
							</span>
						</label>
					</section>

			</div>

			<div v-if="tab === 'warehouses'" class="space-y-6">
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<div class="flex items-center justify-between gap-3 flex-wrap">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.warehouses', {}) }}</h2>
						<PrimaryButton @click="newWarehouse">{{ $t('Commons.button.new_warehouse', {}) }}</PrimaryButton>
					</div>
					<p class="text-sm text-gray-600">
						{{ $t('Pages.text.each_warehouse_has_its') }} {{ removalWaitDays }} {{ $t('Pages.text.days') }} <span class="text-gray-500">(The command
						<span class="font-mono">{{ $t('Pages.text.php_artisan_warehouse_remove', {}) }}</span> removes an archived warehouse immediately, with no waiting period.)</span>
					</p>

					<div v-if="result?.code" class="rounded border-2 border-amber-400 bg-amber-50 p-4 text-sm space-y-2">
						<p class="font-semibold">{{ result.note }}</p>
						<p>{{ $t('Commons.text.setup_code', {}) }} <span class="font-mono text-lg font-bold">{{ result.code }}</span>
							<button class="ml-3 text-xs underline" @click="copyCode">{{ copied ? $t('Commons.button.copied') : $t('Commons.button.copy') }}</button></p>
						<p>{{ $t('Commons.label.address', {}) }} <span class="font-mono break-all">{{ result.url }}</span></p>
					</div>
					<div v-if="result?.removed" class="rounded border border-gray-300 bg-gray-50 p-4 text-sm space-y-1">
						<p>{{ $t('Commons.text.final_backup', {}) }} <span class="font-mono break-all">{{ result.removed.backup || $t('Commons.text.none_2') }}</span></p>
						<p>{{ $t('Pages.text.logins_removed_with_it') }} {{ result.removed.accounts_removed.length ? result.removed.accounts_removed.join(', ') : $t('Commons.text.none_2') }}; kept (they belong elsewhere): {{ result.removed.accounts_kept }}</p>
						<p v-for="n in result.removed.notes" :key="n" class="text-amber-800">{{ n }}</p>
					</div>

					<div v-if="!warehouses" class="text-gray-500">{{ $t('Commons.text.loading', {}) }}</div>
					<div v-for="w in warehouses" :key="w.id" class="border rounded-lg p-4 space-y-2" :class="w.status === 'archived' ? 'bg-gray-50' : ''">
						<div class="flex items-center gap-2 flex-wrap">
							<h3 class="font-semibold">{{ w.name }}</h3>
							<span class="text-xs rounded px-2 py-0.5" :class="statusClass(w.status)">{{ statusNames[w.status] || w.status }}</span>
							<span v-if="w.is_default" class="text-xs rounded px-2 py-0.5 bg-indigo-100 text-indigo-800">Default</span>
							<span v-if="w.is_training" class="text-xs rounded px-2 py-0.5 bg-yellow-100 text-yellow-800">{{ $t('Commons.text.training', {}) }}</span>
							<span v-if="!w.listed" class="text-xs text-gray-500">{{ $t('Pages.text.not_listed_in_the', {}) }}</span>
							<span class="ml-auto font-mono text-xs text-gray-500">{{ w.id }}</span>
						</div>
						<p v-if="w.admin_email" class="text-xs text-gray-600">{{ $t('Commons.text.contact_2') }} {{ w.admin_email }}</p>
						<p v-if="w.notes" class="text-xs text-gray-600 whitespace-pre-line">{{ w.notes }}</p>
						<p v-if="w.status === 'archived'" class="text-xs text-gray-600">
							{{ $t('Commons.text.archived') }} {{ shortDate(w.archived_at) }}.
							<template v-if="w.is_default">{{ $t('Pages.text.the_default_warehouse_cannot', {}) }}</template>
							<template v-else-if="w.can_remove_now">{{ $t('Pages.text.it_can_be_removed', {}) }}</template>
							<template v-else>{{ $t('Pages.text.it_can_be_removed_2') }} {{ shortDate(w.removable_on) }}.</template>
						</p>
						<p v-if="w.status === 'awaiting_setup'" class="text-xs text-gray-600">
							{{ $t('Commons.text.setup_address', {}) }} <span class="font-mono break-all">{{ w.setup_url }}</span> —
							{{ w.setup_code_until ? `a code is waiting, valid until ${shortDate(w.setup_code_until)}` : 'no setup code is waiting' }}.
						</p>

						<div class="flex gap-2 flex-wrap items-center text-xs">
							<span class="text-gray-500">{{ $t('Commons.text.hostnames', {}) }}</span>
							<span v-if="!w.domains.length" class="text-gray-400">none (reached by the shared address)</span>
							<span v-for="d in w.domains" :key="d.hostname" class="inline-flex items-center gap-1 rounded bg-gray-100 px-2 py-0.5 font-mono">
								{{ d.hostname }}<span v-if="d.primary" class="text-gray-500 font-sans">(primary)</span>
								<button class="text-red-600 font-sans" :title="`Remove ${d.hostname}`" @click="removeHostname(w, d.hostname)">×</button>
							</span>
							<button class="underline text-indigo-700" @click="addHostname(w)">{{ $t('Commons.button.add_hostname', {}) }}</button>
						</div>

						<div class="flex gap-3 flex-wrap text-sm pt-1">
							<button class="underline text-indigo-700" @click="editWarehouse(w)">{{ $t('Commons.button.edit', {}) }}</button>
							<template v-if="w.status === 'active'">
								<button class="underline text-amber-700" @click="suspendWarehouse(w, false)">{{ $t('Commons.button.suspend', {}) }}</button>
								<button class="underline text-amber-700" @click="suspendWarehouse(w, true)">Maintenance</button>
							</template>
							<button v-if="w.status === 'suspended' || w.status === 'maintenance'" class="underline text-green-700" @click="activateWarehouse(w)">{{ $t('Commons.button.activate', {}) }}</button>
							<button v-if="w.status === 'restoring'" class="underline text-green-700" @click="resumeWarehouse(w)">{{ $t('Commons.button.resume', {}) }}</button>
							<template v-if="w.status === 'awaiting_setup'">
								<button class="underline text-indigo-700" @click="newSetupCode(w)">{{ $t('Pages.button.new_setup_code', {}) }}</button>
								<button class="underline text-amber-700" @click="revokeSetupCode(w)">{{ $t('Commons.button.revoke_code', {}) }}</button>
							</template>
							<button v-if="w.status === 'archived'" class="underline text-indigo-700" @click="archiveWarehouse(w, true)">{{ $t('Commons.button.bring_back', {}) }}</button>
							<button v-else-if="!w.is_default && ['active', 'suspended', 'maintenance', 'awaiting_setup'].includes(w.status)" class="underline text-red-700" @click="archiveWarehouse(w)">{{ $t('Commons.button.archive', {}) }}</button>
							<button v-if="w.status === 'archived' && !w.is_default" class="underline" :class="w.can_remove_now ? 'text-red-700 font-semibold' : 'text-gray-400 cursor-not-allowed'"
								:disabled="!w.can_remove_now" :title="w.can_remove_now ? '' : `Available from ${shortDate(w.removable_on)}`" @click="removeWarehouse(w)">{{ $t('Pages.button.remove_for_good', {}) }}</button>
						</div>
					</div>
				</section>
			</div>

			<!-- The password dialog every change goes through -->
			<div v-if="dialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="closeDialog">
				<form class="bg-white rounded-lg shadow-xl w-full max-w-md p-6 space-y-4 max-h-full overflow-y-auto" @submit.prevent="submitDialog">
					<h2 class="text-lg font-semibold" :class="dialog.danger ? 'text-red-800' : ''">{{ dialog.title }}</h2>
					<p v-if="dialog.text" class="text-sm text-gray-700">{{ dialog.text }}</p>
					<div v-for="f in dialog.fields" :key="f.key">
						<label v-if="f.type === 'checkbox'" class="flex items-center gap-2 text-sm">
							<input type="checkbox" v-model="dialog.values[f.key]" class="h-4 w-4 rounded border-gray-300" /> {{ f.label }}
						</label>
						<label v-else class="block text-sm">
							<span class="text-gray-700">{{ f.label }}</span>
							<textarea v-if="f.type === 'textarea'" v-model="dialog.values[f.key]" rows="3" class="mt-1 block w-full rounded border-gray-300 text-sm"></textarea>
							<input v-else :type="f.type" v-model="dialog.values[f.key]" class="mt-1 block w-full rounded border-gray-300 text-sm" autocomplete="off" />
						</label>
					</div>
					<label class="block text-sm">
						<span class="text-gray-700 font-medium">{{ $t('Pages.text.your_password_to_confirm', {}) }}</span>
						<input type="password" v-model="dialogPassword" required autocomplete="current-password" class="mt-1 block w-full rounded border-gray-300 text-sm" />
					</label>
					<p v-if="dialogError" class="rounded bg-red-100 border border-red-400 text-red-800 px-3 py-2 text-sm">{{ dialogError }}</p>
					<div class="flex gap-3 justify-end items-center">
						<button type="button" class="text-sm text-gray-600 underline" :disabled="dialogBusy" @click="closeDialog">{{ $t('Commons.button.cancel', {}) }}</button>
						<PrimaryButton :disabled="dialogBusy || !dialogPassword" :class="dialog.danger ? 'bg-red-600 hover:bg-red-500' : ''">
							{{ dialogBusy ? $t('Commons.button.working') : dialog.button }}
						</PrimaryButton>
					</div>
				</form>
			</div>

			<div v-if="tab === 'backups'" class="space-y-6">
				<section class="bg-white shadow rounded-lg p-6 space-y-3">
					<h2 class="text-lg font-semibold">{{ $t('Pages.heading.full_instance_backups', {}) }}</h2>
					<p class="text-sm text-gray-700">
						{{ $t('Pages.text.a_full_instance_backup', {}) }} <strong>every</strong> {{ $t('Pages.text.warehouse_s_database_optionally', {}) }}
						<a href="/setup/system" class="underline">{{ $t('Commons.heading.warehouse_backups', {}) }}</a>. Each zip holds every warehouse's encryption key <strong>{{ $t('Pages.text.sealed_to_your_recovery', {}) }}</strong> {{ $t('Pages.text.below_so_an_automatic', {}) }}
					</p>
					<p v-if="instBackups && !instBackups.available" class="rounded bg-amber-100 border border-amber-400 text-amber-900 px-3 py-2 text-sm">
						{{ $t('Pages.text.this_needs_the_docker', {}) }} <span class="font-mono">provisioner</span> {{ $t('Pages.text.container_on_a_standard', {}) }}
					</p>
					<p v-else-if="!instBackups" class="text-gray-500 text-sm">{{ $t('Commons.text.loading', {}) }}</p>
				</section>

				<template v-if="instBackups?.available && instForm">
					<!-- The recovery key: public half on the server, private half on paper -->
					<section class="rounded-lg border-2 p-6 space-y-3"
						:class="recoveryState.state === 'ok' ? 'bg-white border-green-400' : 'bg-red-50 border-red-400'">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.recovery_key', {}) }}</h2>
						<template v-if="recoveryState.state === 'none'">
							<p class="text-sm text-red-900">
								<strong>{{ $t('Pages.text.this_instance_has_no', {}) }}</strong> Its backups hold everything except the warehouses' encryption keys, so after a disaster
								the mail passwords and the federation key could not be read and would have to be entered again, and every paired instance and client would have to approve this one again.
							</p>
						</template>
						<template v-else-if="recoveryState.state === 'unconfirmed'">
							<p class="text-sm text-red-900">
								<strong>{{ $t('Pages.text.nobody_confirmed_that_the') }} {{ recoveryState.fingerprint }} {{ $t('Pages.text.was_stored') }}</strong> {{ $t('Pages.text.the_private_half_was', {}) }}
							</p>
						</template>
						<template v-else>
							<p class="text-sm text-gray-700">
								{{ $t('Pages.text.every_instance_backup_contains', {}) }} <span class="font-mono font-semibold">{{ recoveryState.fingerprint }}</span>
								<span class="text-gray-500">(made by {{ recoveryState.created_by }}{{ recoveryState.source === 'generated' ? '' : `, ${recoveryState.source}` }})</span>.
								Keep the printout away from this server and away from your backups.
							</p>
						</template>
						<p class="text-xs text-gray-600">
							How it works: each backup locks the warehouses' keys with a <em>public</em> {{ $t('Pages.text.key_kept_here_so', {}) }} <em>private</em> {{ $t('Pages.text.key_which_you_print', {}) }}
							<span class="font-mono">restore:instance &lt;zip&gt; --recovery-key-file &lt;file&gt;</span>. Check a printout at any time with
							<span class="font-mono">{{ $t('Pages.text.instance_recovery_key_verify', {}) }}</span>.
						</p>
						<div class="flex flex-wrap gap-3">
							<PrimaryButton v-if="recoveryState.state === 'none'" type="button" @click="makeRecoveryKey(false)">{{ $t('Pages.button.make_the_recovery_key', {}) }}</PrimaryButton>
							<PrimaryButton v-else type="button" @click="makeRecoveryKey(true)" :class="recoveryState.state === 'ok' ? 'bg-gray-600 hover:bg-gray-500' : ''">
								{{ $t('Pages.button.make_a_new_recovery', {}) }}
							</PrimaryButton>
						</div>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.backup_now', {}) }}</h2>
						<div class="flex flex-wrap items-center gap-3">
							<PrimaryButton :disabled="instBackups.working" @click="backUpInstanceNow(false)">{{ instBackups.working ? $t('Pages.button.a_backup_is_being') : $t('Pages.button.back_up_databases') }}</PrimaryButton>
							<PrimaryButton :disabled="instBackups.working" @click="backUpInstanceNow(true)">{{ $t('Pages.button.back_up_databases_every', {}) }}</PrimaryButton>
						</div>
						<p v-if="instBackups.working" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-3 py-2 text-sm">{{ $t('Pages.text.working_this_page_updates', {}) }}</p>
						<p v-else-if="instBackups.activity" class="text-sm" :class="instBackups.activity.status === 'failed' ? 'text-red-700' : 'text-gray-600'">
							{{ $t('Commons.text.last_request_2') }} {{ instBackups.activity.status === 'failed' ? $t('Commons.text.failed_5') : $t('Commons.text.done') }}{{ instBackups.activity.message }}
							<span v-if="instBackups.activity.finished_at" class="text-xs text-gray-500">({{ instWhen(instBackups.activity.finished_at) }})</span>
						</p>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.schedule', {}) }}</h2>
						<form @submit.prevent="saveInstanceSchedule" class="space-y-3 text-sm">
							<label class="flex items-center gap-2 font-medium"><input type="checkbox" v-model="instForm.enabled" class="rounded border-gray-300" /> {{ $t('Pages.label.make_a_full_instance', {}) }}</label>
							<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2" :class="instForm.enabled ? '' : 'opacity-60'">
								<span class="w-28 font-medium">{{ $t('Commons.label.daily', {}) }}</span>
								<label class="flex items-center gap-2">{{ $t('Commons.label.after', {}) }} <select v-model.number="instForm.daily_hour" class="rounded-md border-gray-300 text-sm"><option v-for="h in 24" :key="h" :value="h - 1">{{ String(h - 1).padStart(2, '0') }}:00</option></select> {{ $t('Commons.label.server_time', {}) }}</label>
								<label class="flex items-center gap-2">{{ $t('Pages.label.keep_the_newest', {}) }} <input type="number" min="1" max="90" v-model.number="instForm.daily_keep" class="w-20 rounded-md border-gray-300 text-sm" /></label>
								<label class="flex items-center gap-2"><input type="checkbox" v-model="instForm.daily_with_files" class="rounded border-gray-300" /> {{ $t('Pages.label.include_every_warehouse_s', {}) }}</label>
							</div>
							<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2" :class="instForm.enabled ? '' : 'opacity-60'">
								<label class="flex items-center gap-2 w-28 font-medium"><input type="checkbox" v-model="instForm.weekly_enabled" class="rounded border-gray-300" /> {{ $t('Commons.label.weekly', {}) }}</label>
								<label class="flex items-center gap-2">{{ $t('Commons.label.on', {}) }} <select v-model.number="instForm.weekly_dow" class="rounded-md border-gray-300 text-sm"><option v-for="(d, i) in weekdays" :key="d" :value="i">{{ d }}</option></select></label>
								<label class="flex items-center gap-2">{{ $t('Pages.label.keep_the_newest', {}) }} <input type="number" min="1" max="52" v-model.number="instForm.weekly_keep" class="w-20 rounded-md border-gray-300 text-sm" /></label>
								<label class="flex items-center gap-2"><input type="checkbox" v-model="instForm.weekly_with_files" class="rounded border-gray-300" /> {{ $t('Pages.label.include_every_warehouse_s', {}) }}</label>
							</div>
							<div class="flex flex-wrap items-center gap-4">
								<PrimaryButton type="submit">{{ $t('Commons.button.save_schedule_2', {}) }}</PrimaryButton>
								<span v-if="instBackups.schedule.last_run_at" class="text-xs" :class="instBackups.schedule.last_status === 'failed' ? 'text-red-700' : 'text-gray-500'">
									{{ $t('Pages.text.last_scheduled_backup') }} {{ instWhen(instBackups.schedule.last_run_at) }} — {{ instBackups.schedule.last_status === 'failed' ? `FAILED: ${instBackups.schedule.last_message}` : 'made' }}
								</span>
							</div>
						</form>
						<p class="text-xs text-gray-500">
							{{ $t('Pages.text.a_weekly_backup_also', {}) }}
						</p>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-3">
						<h2 class="text-lg font-semibold">{{ $t('Pages.heading.computers_that_may_take', {}) }}</h2>
						<p class="text-sm text-gray-700">
							{{ $t('Pages.text.the_ri_launcher_on', {}) }} <strong>{{ $t('Commons.text.whole_instance', {}) }}</strong>{{ $t('Pages.text.so_pair_only_computers', {}) }}
						</p>
						<div v-if="pairCode" class="rounded border-2 border-green-500 bg-green-50 p-4 text-sm space-y-1">
							<div>{{ $t('Commons.text.server_address', {}) }} <span class="font-mono font-semibold">{{ pairCode.address }}</span></div>
							<div>{{ $t('Commons.text.code_3', {}) }} <span class="font-mono text-xl font-bold tracking-widest">{{ pairCode.code }}</span></div>
							<div class="text-xs text-gray-600">{{ $t('Pages.text.shown_once_expires') }} {{ instWhen(pairCode.expires_at) }}. In the Launcher: Remote backups → Pair → “Instance backup”.</div>
						</div>
						<div v-for="c in instBackups.clients" :key="c.id" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-3">
							<div>
								<span class="font-medium">{{ c.name }}</span>
								<span class="ml-2 rounded px-2 py-0.5 text-xs" :class="c.status === 'approved' ? 'bg-green-100 text-green-800' : 'bg-gray-200 text-gray-700'">{{ c.status === 'approved' ? 'Paired' : $t('Commons.text.revoked') }}</span>
								<div class="text-xs text-gray-500">
									Paired {{ instWhen(c.approved_at) }}<span v-if="c.last_seen_at"> {{ $t('Pages.text.last_seen') }} {{ instWhen(c.last_seen_at) }}<span v-if="c.last_seen_ip"> from {{ c.last_seen_ip }}</span></span><span v-else> {{ $t('Pages.text.never_connected', {}) }}</span>
								</div>
							</div>
							<button v-if="c.status === 'approved'" @click="revokeBackupClient(c)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500">{{ $t('Commons.button.revoke_2', {}) }}</button>
						</div>
						<p v-if="!instBackups.clients.length" class="text-gray-400 text-sm">{{ $t('Pages.text.no_computer_is_paired', {}) }}</p>
						<PrimaryButton type="button" @click="newBackupClient">{{ $t('Pages.button.pair_a_computer', {}) }}</PrimaryButton>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-3">
						<h2 class="text-lg font-semibold">{{ $t('Commons.heading.instance_backups', {}) }}</h2>
						<p v-if="!instBackups.backups.length" class="text-gray-400 text-sm">{{ $t('Commons.text.none_yet', {}) }}</p>
						<div v-for="z in instBackups.backups" :key="z.name" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-3">
							<div class="space-y-1">
								<div class="font-mono text-xs text-gray-600">{{ z.name }}</div>
								<div>
									{{ instWhen(z.made_at) }} — {{ sizeOf(z.size) }}, {{ z.scope === 'full' ? 'databases + files' : $t('Commons.text.databases_only') }}
									<span v-if="z.label" class="ml-1 rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-700">{{ labelNames[z.label] || z.label }}</span>
								</div>
							</div>
							<a v-if="z.downloadable" :href="$withWarehouse(`/json/instance/backups/${z.name}/download`)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-800 hover:bg-gray-700">{{ $t('Commons.button.download', {}) }}</a>
							<span v-else class="text-xs text-gray-500">Not readable here: copy it from the server's backup folder (<span class="font-mono">instance/</span>)</span>
						</div>
						<p class="text-xs text-gray-500">
							{{ $t('Pages.text.to_restore_one_onto', {}) }}
							<span class="font-mono">{{ $t('Pages.text.docker_compose_exec_provisioner', {}) }}</span>. Deleting one is done at the server.
						</p>
					</section>
				</template>
			</div>
		</div>

		<!-- The recovery key, shown once. No way to dismiss it until the person says it is stored. -->
		<div v-if="recoveryShown" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4" role="dialog" aria-modal="true" aria-labelledby="recovery-title">
			<div class="max-h-full w-full max-w-2xl overflow-y-auto rounded-lg bg-white p-6 shadow-xl space-y-4">
				<h2 id="recovery-title" class="text-xl font-bold text-red-800">{{ $t('Pages.heading.print_this_key_and', {}) }}</h2>
				<p class="text-sm text-gray-800">
					{{ $t('Pages.text.this_is_your_instance', {}) }} <strong>{{ $t('Commons.text.recovery_key', {}) }}</strong>. It is shown <strong>{{ $t('Commons.text.only_now', {}) }}</strong>{{ $t('Pages.text.the_server_does_not', {}) }}
				</p>
				<div class="rounded border-2 border-gray-800 bg-gray-50 p-4">
					<div class="text-xs text-gray-500">{{ $t('Commons.text.fingerprint') }} {{ recoveryShown.fingerprint }}</div>
					<div class="mt-1 break-all font-mono text-lg font-bold leading-relaxed tracking-wide" data-testid="recovery-key">{{ recoveryShown.private_key }}</div>
				</div>
				<div class="flex flex-wrap gap-3">
					<button type="button" class="rounded-md bg-gray-800 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white hover:bg-gray-700" @click="printRecoveryKey">{{ $t('Commons.button.print', {}) }}</button>
					<button type="button" class="rounded-md bg-gray-800 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white hover:bg-gray-700" @click="downloadRecoveryKey">{{ $t('Pages.button.download_as_a_file', {}) }}</button>
					<button type="button" class="rounded-md bg-gray-200 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-gray-800 hover:bg-gray-300" @click="copyRecoveryKey">{{ recoveryCopied ? $t('Commons.button.copied') : $t('Commons.button.copy') }}</button>
				</div>
				<ul class="list-disc space-y-1 pl-5 text-sm text-gray-700">
					<li>{{ $t('Commons.text.keep_it', {}) }} <strong>{{ $t('Pages.text.away_from_this_server', {}) }}</strong>: a safe, a sealed envelope, a password manager. Anyone with both this key and a backup can read the warehouses' encrypted settings.</li>
					<li>{{ $t('Pages.text.check_a_printout_later', {}) }} <span class="font-mono">{{ $t('Pages.text.instance_recovery_key_verify', {}) }}</span>. The key has check characters, so a typing mistake is caught.</li>
					<li>{{ $t('Pages.text.if_it_is_lost', {}) }}</li>
				</ul>
				<label class="flex items-start gap-2 text-sm font-medium text-gray-900">
					<input type="checkbox" v-model="recoveryStored" class="mt-1 rounded border-gray-400" />
					<span>{{ $t('Pages.text.i_have_printed_or', {}) }}</span>
				</label>
				<div class="flex justify-end">
					<PrimaryButton type="button" :disabled="!recoveryStored || recoveryBusy" @click="finishRecoveryKey">{{ recoveryBusy ? $t('Commons.button.saving') : $t('Commons.button.done') }}</PrimaryButton>
				</div>
			</div>
		</div>
	</AuthenticatedLayout>
</template>
