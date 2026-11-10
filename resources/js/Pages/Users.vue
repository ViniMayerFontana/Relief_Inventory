<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Users.vue

	User Administration (permission: manage-users) —
	create/promote/deactivate login-capable accounts (anyone with an
	email). Distinct from /setup/people: that page manages party-tracking
	roles (Partner/Donor) plus the is_volunteer flag, with no permission
	overrides; this page manages the login-capable roles (Administrator,
	Sorting and Inventory, Office, Partner) and per-person permission
	overrides. Roles here are mutually exclusive presets, not a role
	hierarchy — see selectRole() below. Whether someone is a volunteer
	is tracked separately (is_volunteer) since it's a fact about the
	person, not their permission role — a volunteer can be the office
	manager or an administrator.

	Built to the admin-page-style conventions (see SystemAdmin.vue), not
	RIForm — this is an account-administration panel (create/promote/
	deactivate actions, not a plain field-editing CRUD form), so it needs
	its own list/detail flow rather than RIForm's generic one.

	Warehouse Users / Partners is a display-only filter over the same
	list+datasource — not a workflow split; search, status, role and
	last-login filters and column sorting narrow it further, all
	client-side (the list is every account with an email, small enough not
	to need server paging). Each record's status comes from the server
	(UserAdminController::status) so this page and the CSV export can't
	disagree. Bulk actions and Export CSV act on exactly the rows showing.

	A password can be set by the admin when creating an account or later
	(Set Password) — optionally forcing the person to pick their own at next
	login (EnsurePasswordChanged) and optionally emailing them where to log
	in (never the password).
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import { ref, computed, onMounted, watch } from 'vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import Checkbox from '@/Components/Checkbox.vue';
import UserInvitations from '@/Components/UserInvitations.vue';
import axios from 'axios';
import { withWarehouse } from '@/bootstrap';

defineProps({
    breadcrumb: {
        type: Array,
    },
});

const STAFF_ROLE_NAMES = ['Administrator', 'Sorting and Inventory', 'Office'];

const users = ref([]);
// key → label, in the order the status filter lists them (from the server).
const statusLabels = ref({});
const allPermissions = ref([]);
// Each role's own permission bundle (id + key only) — a role is just a
// named preset over the flat permission list below, not a live grant
// mechanism of its own. Fetched with ?context=users so this page only
// ever offers the login-capable roles (Administrator, Partner,
// etc.), same restriction the roles picker used before.
const roles = ref([]);
const tab = ref('warehouse'); // 'warehouse' | 'partners'
const selected = ref(null); // the record being created/edited, or null for the list view
const loading = ref(true);
const saving = ref(false);
const error = ref('');
const notice = ref('');
const accountActionBusy = ref(false);
const confirmingDeactivate = ref(false);
const showPassword = ref(false);

// List filters + sort
const search = ref('');
const statusFilter = ref('');
const roleFilter = ref(''); // '' | 'none' | a role id
const loginFilter = ref(''); // '' | 'never' | '30' | '90'
const sortKey = ref('name');
const sortDir = ref(1); // 1 ascending, -1 descending

// Bulk selection (ids); only the ones still showing are acted on.
const checkedIds = ref([]);
const bulkBusy = ref(false);
const confirmingBulkDeactivate = ref(false);
const bulkSkipped = ref([]);

// Set Password panel on an existing account
const passwordForm = ref(null);
const passwordSaving = ref(false);

function fetchUsers() {
    loading.value = true;
    return axios.get('/json/users')
        .then((response) => {
            users.value = response.data.records || [];
            statusLabels.value = response.data.status_labels || {};
        })
        .finally(() => {
            loading.value = false;
        });
}

onMounted(() => {
    fetchUsers();
    axios.get('/json/permissions').then((response) => {
        allPermissions.value = response.data.records || [];
    });
    axios.get('/json/roles?context=users').then((response) => {
        roles.value = response.data.records || [];
    });
});

function statusLabel(record) {
    return statusLabels.value[record.status] || record.status;
}

function formatDateTime(value) {
    return value ? new Date(value).toLocaleString() : '';
}

function inTab(record) {
    const roleNames = (record.roles || []).map((r) => r.name);
    const isStaff = roleNames.some((name) => STAFF_ROLE_NAMES.includes(name));
    return tab.value === 'warehouse' ? isStaff : !isStaff;
}

function matchesSearch(record) {
    const terms = search.value.trim().toLowerCase().split(/\s+/).filter(Boolean);
    if (!terms.length) return true;
    const haystack = [record.first_name, record.last_name, record.email].filter(Boolean).join(' ').toLowerCase();
    return terms.every((term) => haystack.includes(term));
}

function matchesRole(record) {
    if (!roleFilter.value) return true;
    const roleIds = (record.roles || []).map((r) => r.id);
    if (roleFilter.value === 'none') return !roleIds.length;
    return roleIds.includes(roleFilter.value);
}

function matchesLogin(record) {
    if (!loginFilter.value) return true;
    if (loginFilter.value === 'never') return !record.last_login_at;
    const cutoff = Date.now() - Number(loginFilter.value) * 24 * 60 * 60 * 1000;
    return !record.last_login_at || new Date(record.last_login_at).getTime() < cutoff;
}

function sortValue(record) {
    switch (sortKey.value) {
        case 'email': return (record.email || '').toLowerCase();
        case 'roles': return (record.roles || []).map((r) => r.name).join(', ').toLowerCase();
        case 'status': return Object.keys(statusLabels.value).indexOf(record.status);
        // Never logged in sorts as the oldest.
        case 'last_login': return record.last_login_at ? new Date(record.last_login_at).getTime() : 0;
        default: return `${record.last_name || ''} ${record.first_name || ''}`.toLowerCase();
    }
}

const filteredUsers = computed(() => users.value
    .filter((record) => inTab(record)
        && matchesSearch(record)
        && (!statusFilter.value || record.status === statusFilter.value)
        && matchesRole(record)
        && matchesLogin(record))
    .sort((a, b) => {
        const av = sortValue(a);
        const bv = sortValue(b);
        return (av < bv ? -1 : av > bv ? 1 : 0) * sortDir.value;
    }));

// Per-status counts within the current tab, for the filter's option labels.
const statusCounts = computed(() => {
    const counts = {};
    users.value.filter(inTab).forEach((record) => {
        counts[record.status] = (counts[record.status] || 0) + 1;
    });
    return counts;
});

const anyFilter = computed(() => search.value || statusFilter.value || roleFilter.value || loginFilter.value);

function clearFilters() {
    search.value = '';
    statusFilter.value = '';
    roleFilter.value = '';
    loginFilter.value = '';
}

function sortBy(key) {
    if (sortKey.value === key) {
        sortDir.value = -sortDir.value;
    } else {
        sortKey.value = key;
        sortDir.value = 1;
    }
}

function sortArrow(key) {
    if (sortKey.value !== key) return '';
    return sortDir.value === 1 ? '▲' : '▼';
}

// --- Bulk selection ---------------------------------------------------------

const visibleCheckedIds = computed(() => {
    const visible = new Set(filteredUsers.value.map((r) => r.id));
    return checkedIds.value.filter((id) => visible.has(id));
});

const allVisibleChecked = computed(() => filteredUsers.value.length > 0
    && visibleCheckedIds.value.length === filteredUsers.value.length);

function toggleChecked(id) {
    checkedIds.value = checkedIds.value.includes(id)
        ? checkedIds.value.filter((x) => x !== id)
        : [...checkedIds.value, id];
}

function toggleAllVisible() {
    checkedIds.value = allVisibleChecked.value ? [] : filteredUsers.value.map((r) => r.id);
}

// A changed filter or tab could leave a confirm armed for a different set.
watch([search, statusFilter, roleFilter, loginFilter, tab], () => {
    confirmingBulkDeactivate.value = false;
});

function runBulk(action) {
    if (action === 'deactivate' && !confirmingBulkDeactivate.value) {
        confirmingBulkDeactivate.value = true;
        return;
    }
    confirmingBulkDeactivate.value = false;
    error.value = '';
    notice.value = '';
    bulkSkipped.value = [];
    bulkBusy.value = true;
    axios.post('/json/users/bulk', { action, ids: visibleCheckedIds.value })
        .then((response) => {
            notice.value = response.data.message;
            bulkSkipped.value = response.data.skipped || [];
            checkedIds.value = [];
            fetchUsers();
        })
        .catch((err) => {
            error.value = describeSaveError(err);
        })
        .finally(() => {
            bulkBusy.value = false;
        });
}

function exportCsv() {
    const ids = filteredUsers.value.map((r) => r.id).join(',');
    window.location.href = withWarehouse(`/json/users/export.csv?ids=${ids}`);
}

// --- Passwords --------------------------------------------------------------

// A readable temporary password (no 0/O/1/l look-alikes) the admin can
// read out or write down.
function generatePassword(target) {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    const bytes = new Uint32Array(12);
    window.crypto.getRandomValues(bytes);
    target.password = Array.from(bytes, (n) => chars[n % chars.length]).join('');
    showPassword.value = true;
}

function openPasswordForm() {
    error.value = '';
    notice.value = '';
    showPassword.value = false;
    passwordForm.value = { password: '', require_password_change: true, send_login_email: false };
}

function savePassword() {
    error.value = '';
    notice.value = '';
    passwordSaving.value = true;
    axios.post(`/json/users/${selected.value.id}/set-password`, passwordForm.value)
        .then((response) => {
            notice.value = response.data.message;
            passwordForm.value = null;
            refreshSelected();
        })
        .catch((err) => {
            error.value = describeSaveError(err);
        })
        .finally(() => {
            passwordSaving.value = false;
        });
}

// --- Roles & permissions ----------------------------------------------------

// The permission ids granted by default just from the record's currently
// assigned roles — a role's own permission bundle, unioned. This is what
// "no override" (below) falls back to; it's also what a role preset
// button applies in one tap.
function roleDefaultPermissionIds(record) {
    const assignedRoleIds = new Set((record.people_roles || []).map((r) => r.role_id));
    const ids = new Set();
    roles.value
        .filter((role) => assignedRoleIds.has(role.id))
        .forEach((role) => (role.permissions || []).forEach((p) => ids.add(p.id)));
    return ids;
}

// Effective grant = an explicit override if one exists, else whatever the
// assigned roles' default bundle says. Mirrors HasPermissions::
// effectivePermissionKeys() on the backend so the checklist always shows
// what the person can *actually* do, not just what's been explicitly set.
function isGranted(record, permissionId) {
    const override = (record.person_permissions || []).find((o) => o.permission_id === permissionId);
    if (override) return override.granted;
    return roleDefaultPermissionIds(record).has(permissionId);
}

// Only stores an explicit override when the desired state differs from
// what the role default would already give — keeps person_permissions
// minimal (a role's bundle changing later still propagates to anyone who
// never customized that specific permission) instead of stamping every
// permission explicit on every save.
function setPermissionState(record, permissionId, desired) {
    const roleDefault = roleDefaultPermissionIds(record).has(permissionId);
    const overrides = (record.person_permissions || []).filter((o) => o.permission_id !== permissionId);
    if (desired !== roleDefault) overrides.push({ permission_id: permissionId, granted: desired });
    record.person_permissions = overrides;
}

function togglePermission(record, permissionId) {
    setPermissionState(record, permissionId, !isGranted(record, permissionId));
}

function grantAll(record) {
    allPermissions.value.forEach((p) => setPermissionState(record, p.id, true));
}
function revokeAll(record) {
    allPermissions.value.forEach((p) => setPermissionState(record, p.id, false));
}

function roleAssigned(record, roleId) {
    return (record.people_roles || []).some((r) => r.role_id === roleId);
}

// Roles here are mutually exclusive presets, not additive tags — tapping
// one is a full reset to exactly that role's bundle (matching Admin then
// Partner should leave nothing granted, not the union of both), the
// same "Any Day" pattern OrderEntry.vue's delivery-day chips use for a
// one-tap bulk-select, just applied as a replace instead of a merge.
// Tapping the already-active role clears the selection entirely (also a
// full reset, to nothing).
function selectRole(record, role) {
    const wasActive = roleAssigned(record, role.id);
    record.people_roles = wasActive ? [] : [{ role_id: role.id }];

    const grantedIds = new Set(wasActive ? [] : (role.permissions || []).map((p) => p.id));
    allPermissions.value.forEach((p) => setPermissionState(record, p.id, grantedIds.has(p.id)));
}

// --- List/detail ------------------------------------------------------------

function newUser() {
    error.value = '';
    notice.value = '';
    showPassword.value = false;
    passwordForm.value = null;
    selected.value = {
        first_name: '', last_name: '', email: '', is_volunteer: false,
        people_roles: [], person_permissions: [],
        password_mode: 'invite', // 'invite' | 'set'
        password: '', require_password_change: true, send_login_email: true,
    };
}

function selectUser(record) {
    error.value = '';
    notice.value = '';
    bulkSkipped.value = [];
    confirmingDeactivate.value = false;
    passwordForm.value = null;
    selected.value = JSON.parse(JSON.stringify(record));
}

function cancelEdit() {
    selected.value = null;
    error.value = '';
    confirmingDeactivate.value = false;
    passwordForm.value = null;
}

function describeSaveError(err) {
    const errors = err.response?.data?.errors;
    if (errors) return Object.values(errors).flat().join(' ');
    return err.response?.data?.message || 'Could not save. Please try again.';
}

function saveUser() {
    error.value = '';
    notice.value = '';
    saving.value = true;
    let payload = selected.value;
    if (!payload.id) {
        const { password_mode, ...rest } = payload;
        payload = password_mode === 'set'
            ? rest
            : { ...rest, password: null, require_password_change: false, send_login_email: false };
    }
    const request = payload.id
        ? axios.put(`/json/users/${payload.id}`, payload)
        : axios.post('/json/users', payload);

    request
        .then((response) => {
            notice.value = response.data.message || 'Saved.';
            cancelEdit();
            fetchUsers();
        })
        .catch((err) => {
            error.value = describeSaveError(err);
        })
        .finally(() => {
            saving.value = false;
        });
}

// Account fields an account action can change — copied from the refreshed
// list onto the open record, leaving any unsaved edits to the rest alone.
const ACCOUNT_FIELDS = ['status', 'disabled_at', 'approved_at', 'approved_by_name', 'email_verified_at',
    'has_password', 'password_change_required', 'last_login_at'];

function refreshSelected() {
    const id = selected.value?.id;
    return fetchUsers().then(() => {
        const fresh = users.value.find((r) => r.id === id);
        if (fresh && selected.value?.id === id) {
            ACCOUNT_FIELDS.forEach((field) => { selected.value[field] = fresh[field]; });
        }
    });
}

function runAccountAction(url, body = {}) {
    error.value = '';
    notice.value = '';
    accountActionBusy.value = true;
    return axios.post(`/json/users/${selected.value.id}/${url}`, body)
        .then((response) => {
            notice.value = response.data.message || 'Done.';
            refreshSelected();
        })
        .catch((err) => {
            error.value = describeSaveError(err);
        })
        .finally(() => {
            accountActionBusy.value = false;
        });
}

function deactivate() {
    if (!confirmingDeactivate.value) {
        confirmingDeactivate.value = true;
        return;
    }
    confirmingDeactivate.value = false;
    runAccountAction('deactivate');
}

function reactivate() {
    runAccountAction('reactivate');
}

function approve() {
    runAccountAction('approve');
}

function resendInvite() {
    runAccountAction('resend-invite');
}

function setPasswordChangeRequired(required) {
    runAccountAction('require-password-change', { required });
}
</script>

<template>
  <Head :title="$t('Commons.title.user_administration')" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
    <div class="max-w-4xl mx-auto p-4 space-y-6">
      <h1 class="text-2xl font-bold">{{ $t('Commons.heading.user_administration', {}) }}</h1>

      <div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
      <div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">
        {{ notice }}
        <ul v-if="bulkSkipped.length" class="mt-2 list-disc list-inside text-sm text-amber-900">
          <li v-for="item in bulkSkipped" :key="item.id">{{ item.name }} — {{ item.reason }}</li>
        </ul>
      </div>

      <UserInvitations v-if="!selected" />

      <!-- List view -->
      <section v-if="!selected" class="bg-white shadow rounded-lg p-6 space-y-4">
        <div class="flex items-center justify-between gap-2">
          <h2 class="text-lg font-semibold">{{ $t('Commons.heading.users', {}) }}</h2>
          <div class="flex gap-2">
            <SecondaryButton :disabled="!filteredUsers.length" @click="exportCsv">{{ $t('Commons.button.export_csv', {}) }}</SecondaryButton>
            <PrimaryButton @click="newUser">{{ $t('Commons.button.new_user', {}) }}</PrimaryButton>
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-4 gap-3 text-sm items-end">
          <label class="block sm:col-span-4">
            <span class="text-gray-700">{{ $t('Commons.text.search', {}) }}</span>
            <input
              v-model="search"
              type="search"
              :placeholder="$t('Pages.placeholder.name_or_email')"
              class="mt-1 block w-full border-gray-300 rounded-md shadow-sm"
            />
          </label>
          <label class="block">
            <span class="text-gray-700">{{ $t('Commons.text.status_2', {}) }}</span>
            <select v-model="statusFilter" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
              <option value="">{{ $t('Commons.text.all_statuses', {}) }}</option>
              <option v-for="(label, key) in statusLabels" :key="key" :value="key">
                {{ label }} ({{ statusCounts[key] || 0 }})
              </option>
            </select>
          </label>
          <label class="block">
            <span class="text-gray-700">{{ $t('Commons.text.role', {}) }}</span>
            <select v-model="roleFilter" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
              <option value="">{{ $t('Commons.text.all_roles', {}) }}</option>
              <option v-for="role in roles" :key="role.id" :value="role.id">{{ role.name }}</option>
              <option value="none">{{ $t('Commons.text.no_role', {}) }}</option>
            </select>
          </label>
          <label class="block">
            <span class="text-gray-700">{{ $t('Commons.text.last_login', {}) }}</span>
            <select v-model="loginFilter" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
              <option value="">{{ $t('Commons.text.any_time', {}) }}</option>
              <option value="never">{{ $t('Pages.text.never_logged_in', {}) }}</option>
              <option value="30">{{ $t('Pages.text.not_in_30_days', {}) }}</option>
              <option value="90">{{ $t('Pages.text.not_in_90_days', {}) }}</option>
            </select>
          </label>
          <div class="pb-2">
            <button
              v-if="anyFilter"
              type="button"
              class="text-sm text-gray-500 underline"
              @click="clearFilters"
            >{{ $t('Commons.button.clear_filters', {}) }}</button>
          </div>
        </div>

        <div class="flex gap-2 text-sm">
          <button
            type="button"
            class="px-3 py-1 rounded-md border"
            :class="tab === 'warehouse' ? 'bg-indigo-600 text-white border-indigo-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'"
            @click="tab = 'warehouse'"
          >{{ $t('Commons.button.warehouse_users', {}) }}</button>
          <button
            type="button"
            class="px-3 py-1 rounded-md border"
            :class="tab === 'partners' ? 'bg-indigo-600 text-white border-indigo-600' : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50'"
            @click="tab = 'partners'"
          >Partners</button>
        </div>

        <div
          v-if="visibleCheckedIds.length"
          class="flex flex-wrap items-center gap-2 rounded bg-indigo-50 border border-indigo-200 px-3 py-2 text-sm"
        >
          <span class="font-semibold">{{ visibleCheckedIds.length }} selected:</span>
          <SecondaryButton :disabled="bulkBusy" @click="runBulk('approve')">{{ $t('Commons.button.approve', {}) }}</SecondaryButton>
          <SecondaryButton :disabled="bulkBusy" @click="runBulk('resend_invite')">{{ $t('Pages.button.send_invite_reset_email', {}) }}</SecondaryButton>
          <SecondaryButton :disabled="bulkBusy" @click="runBulk('require_password_change')">{{ $t('Pages.button.require_password_change', {}) }}</SecondaryButton>
          <SecondaryButton :disabled="bulkBusy" @click="runBulk('reactivate')">Reactivate</SecondaryButton>
          <button
            type="button"
            class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
            :class="confirmingBulkDeactivate ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'"
            :disabled="bulkBusy"
            @click="runBulk('deactivate')"
          >{{ confirmingBulkDeactivate ? `Confirm — block ${visibleCheckedIds.length} from logging in` : $t('Commons.button.deactivate') }}</button>
          <button
            v-if="confirmingBulkDeactivate"
            type="button"
            class="text-sm text-gray-500 underline"
            @click="confirmingBulkDeactivate = false"
          >{{ $t('Commons.button.cancel', {}) }}</button>
          <button type="button" class="ml-auto text-sm text-gray-500 underline" @click="checkedIds = []">{{ $t('Commons.button.clear_selection', {}) }}</button>
        </div>

        <p v-if="loading" class="text-gray-500 text-sm">{{ $t('Commons.text.loading_users', {}) }}</p>

        <div v-else class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead>
              <tr class="text-left text-gray-600 border-b">
                <th class="py-1 pr-2 w-6">
                  <input
                    type="checkbox"
                    :checked="allVisibleChecked"
                    :disabled="!filteredUsers.length"
                    :title="$t('Pages.title.select_all_shown')"
                    @change="toggleAllVisible"
                  />
                </th>
                <th class="py-1 pr-2"><button type="button" class="sort-header" @click="sortBy('name')">{{ $t('Commons.button.name') }} {{ sortArrow('name') }}</button></th>
                <th class="py-1 pr-2"><button type="button" class="sort-header" @click="sortBy('email')">Email {{ sortArrow('email') }}</button></th>
                <th class="py-1 pr-2"><button type="button" class="sort-header" @click="sortBy('roles')">{{ $t('Commons.button.roles') }} {{ sortArrow('roles') }}</button></th>
                <th class="py-1 pr-2"><button type="button" class="sort-header" @click="sortBy('status')">{{ $t('Commons.button.status') }} {{ sortArrow('status') }}</button></th>
                <th class="py-1 pr-2"><button type="button" class="sort-header" @click="sortBy('last_login')">{{ $t('Commons.button.last_login') }} {{ sortArrow('last_login') }}</button></th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="record in filteredUsers"
                :key="record.id"
                class="border-b hover:bg-gray-50 cursor-pointer"
                @click="selectUser(record)"
              >
                <td class="py-1 pr-2" @click.stop>
                  <input type="checkbox" :checked="checkedIds.includes(record.id)" @change="toggleChecked(record.id)" />
                </td>
                <td class="py-1 pr-2">{{ record.first_name }} {{ record.last_name }}</td>
                <td class="py-1 pr-2">{{ record.email }}</td>
                <td class="py-1 pr-2">{{ (record.roles || []).map((r) => r.name).join(', ') }}</td>
                <td class="py-1 pr-2">{{ statusLabel(record) }}</td>
                <td class="py-1 pr-2 whitespace-nowrap" :class="{ 'text-gray-400': !record.last_login_at }">
                  {{ record.last_login_at ? formatDateTime(record.last_login_at) : $t('Commons.text.never') }}
                </td>
              </tr>
              <tr v-if="!filteredUsers.length">
                <td colspan="6" class="py-3 text-gray-400">
                  {{ anyFilter ? $t('Pages.text.no_users_match_these') : $t('Pages.text.no_users_in_this') }}
                </td>
              </tr>
            </tbody>
          </table>
          <p v-if="filteredUsers.length" class="text-xs text-gray-500 mt-2">
            Showing {{ filteredUsers.length }} {{ filteredUsers.length === 1 ? 'user' : 'users' }}.
          </p>
        </div>
      </section>

      <!-- Detail view -->
      <section v-else class="bg-white shadow rounded-lg p-6 space-y-4">
        <h2 class="text-lg font-semibold">{{ selected.id ? $t('Commons.heading.edit_user') : $t('Commons.button.new_user') }}</h2>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
          <label class="block">
            <span class="text-gray-700">{{ $t('Commons.text.first_name_2', {}) }}</span>
            <input v-model="selected.first_name" type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
          </label>
          <label class="block">
            <span class="text-gray-700">{{ $t('Commons.text.last_name_2', {}) }}</span>
            <input v-model="selected.last_name" type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
          </label>
          <label class="block sm:col-span-2">
            <span class="text-gray-700">Email</span>
            <input v-model="selected.email" type="email" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
          </label>
        </div>
        <div v-if="!selected.id" class="space-y-3 text-sm">
          <span class="text-gray-700">Password</span>
          <label class="flex items-start gap-2">
            <input v-model="selected.password_mode" type="radio" value="invite" class="mt-1" />
            <span>{{ $t('Pages.text.email_them_a_link', {}) }}</span>
          </label>
          <label class="flex items-start gap-2">
            <input v-model="selected.password_mode" type="radio" value="set" class="mt-1" />
            <span>{{ $t('Pages.text.set_a_password_now', {}) }}</span>
          </label>

          <div v-if="selected.password_mode === 'set'" class="ml-6 space-y-3">
            <div class="flex flex-wrap items-end gap-2">
              <label class="block flex-1 min-w-[12rem]">
                <span class="text-gray-700">Password</span>
                <input
                  v-model="selected.password"
                  :type="showPassword ? 'text' : 'password'"
                  autocomplete="new-password"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm font-mono"
                />
              </label>
              <SecondaryButton type="button" @click="showPassword = !showPassword">{{ showPassword ? $t('Commons.button.hide') : $t('Commons.button.show') }}</SecondaryButton>
              <SecondaryButton type="button" @click="generatePassword(selected)">{{ $t('Commons.button.generate', {}) }}</SecondaryButton>
            </div>
            <label class="flex items-center gap-2">
              <input v-model="selected.require_password_change" type="checkbox" />
              <span>{{ $t('Pages.text.ask_them_to_choose', {}) }}</span>
            </label>
            <label class="flex items-center gap-2">
              <input v-model="selected.send_login_email" type="checkbox" />
              <span>Email them their login details (the login address and their email — not the password)</span>
            </label>
            <p class="text-xs text-gray-500">
              {{ $t('Pages.text.you_ll_need_to', {}) }}
            </p>
          </div>
        </div>
        <div v-if="selected.id && !selected.approved_at" class="rounded bg-amber-100 border border-amber-400 text-amber-900 px-4 py-3 text-sm">
          {{ $t('Pages.text.this_is_a_self', {}) }}
          <span v-if="selected.requested_track"> {{ $t('Pages.text.they_said_they_re', {}) }} <strong>{{ selected.requested_track }}</strong>.</span>
        </div>

        <div class="ri_fieldset" style="display:flex; align-items:center; gap:0.5rem;">
          <Checkbox v-model="selected.is_volunteer" :enabled="true" />
          <span class="text-sm text-gray-700">Volunteer (unpaid) — independent of their role below</span>
        </div>

        <div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-700">{{ $t('Pages.text.role_pick_one_it', {}) }}</span>
          </div>
          <div class="flex flex-wrap gap-2 mt-1">
            <button
              v-for="role in roles"
              :key="role.id"
              type="button"
              class="role-chip"
              :class="{ 'role-chip-active': roleAssigned(selected, role.id) }"
              :title="(role.permissions || []).map((p) => p.key).join(', ')"
              @click="selectRole(selected, role)"
            >{{ role.name }} <span class="role-chip-count">({{ (role.permissions || []).length }})</span></button>
          </div>
          <p class="text-xs text-gray-500 mt-1">
            {{ $t('Pages.text.partner_accounts_can_log', {}) }}
          </p>
        </div>

        <div>
          <div class="flex items-center justify-between">
            <span class="text-sm text-gray-700">{{ $t('Commons.text.permissions', {}) }}</span>
            <div class="flex gap-2">
              <SecondaryButton type="button" @click="grantAll(selected)">{{ $t('Commons.button.grant_all', {}) }}</SecondaryButton>
              <SecondaryButton type="button" @click="revokeAll(selected)">{{ $t('Commons.button.revoke_all', {}) }}</SecondaryButton>
            </div>
          </div>
          <p class="text-xs text-gray-500 mb-2">
            Checked = this person can do it. Tapping a role above sets these to exactly that
            role's bundle — check/uncheck individual ones afterward to make an exception without
            changing their role.
          </p>
          <div class="overflow-x-auto">
            <table class="w-full text-sm border">
              <tbody>
                <tr v-for="permission in allPermissions" :key="permission.id" class="border-b">
                  <td class="py-1 px-2">
                    <label class="flex items-center gap-2">
                      <input
                        type="checkbox"
                        :checked="isGranted(selected, permission.id)"
                        @change="togglePermission(selected, permission.id)"
                      />
                      {{ permission.key }}
                    </label>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div v-if="selected.id" class="border-t pt-4 space-y-3">
          <h3 class="text-sm font-semibold text-gray-700">{{ $t('Commons.heading.account') }} {{ statusLabel(selected) }}</h3>

          <dl class="grid grid-cols-1 sm:grid-cols-3 gap-2 text-sm">
            <div>
              <dt class="text-gray-500">{{ $t('Commons.text.created', {}) }}</dt>
              <dd>
                {{ formatDateTime(selected.created_at) || $t('Commons.text.unknown') }}
                <span v-if="selected.created_by_name" class="text-gray-500">by {{ selected.created_by_name }}</span>
                <span v-else-if="selected.created_at" class="text-gray-500">(self-registered or before this was recorded)</span>
              </dd>
            </div>
            <div>
              <dt class="text-gray-500">{{ $t('Commons.text.approved', {}) }}</dt>
              <dd>
                <template v-if="selected.approved_at">
                  {{ formatDateTime(selected.approved_at) }}
                  <span v-if="selected.approved_by_name" class="text-gray-500">by {{ selected.approved_by_name }}</span>
                </template>
                <span v-else class="text-gray-400">{{ $t('Commons.text.not_yet', {}) }}</span>
              </dd>
            </div>
            <div>
              <dt class="text-gray-500">{{ $t('Commons.text.last_login', {}) }}</dt>
              <dd :class="{ 'text-gray-400': !selected.last_login_at }">
                {{ selected.last_login_at ? formatDateTime(selected.last_login_at) : $t('Commons.text.never') }}
              </dd>
            </div>
          </dl>

          <div class="flex flex-wrap gap-2">
            <PrimaryButton
              v-if="!selected.approved_at"
              :disabled="accountActionBusy"
              @click="approve"
            >{{ $t('Commons.button.approve', {}) }}</PrimaryButton>

            <SecondaryButton
              v-if="!selected.disabled_at"
              :disabled="accountActionBusy"
              @click="resendInvite"
            >{{ selected.has_password ? $t('Pages.button.send_password_reset') : $t('Pages.button.resend_invite_email') }}</SecondaryButton>

            <SecondaryButton
              v-if="!passwordForm"
              :disabled="accountActionBusy"
              @click="openPasswordForm"
            >{{ $t('Commons.button.set_password', {}) }}</SecondaryButton>

            <SecondaryButton
              v-if="selected.has_password && !selected.password_change_required"
              :disabled="accountActionBusy"
              @click="setPasswordChangeRequired(true)"
            >{{ $t('Pages.button.require_password_change', {}) }}</SecondaryButton>
            <SecondaryButton
              v-if="selected.password_change_required"
              :disabled="accountActionBusy"
              @click="setPasswordChangeRequired(false)"
            >{{ $t('Pages.button.don_t_require_password', {}) }}</SecondaryButton>

            <button
              v-if="!selected.disabled_at"
              type="button"
              class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
              :class="confirmingDeactivate ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'"
              :disabled="accountActionBusy"
              @click="deactivate"
            >{{ confirmingDeactivate ? $t('Pages.button.confirm_this_account_will') : $t('Commons.button.deactivate') }}</button>
            <button
              v-if="confirmingDeactivate"
              type="button"
              class="text-sm text-gray-500 underline"
              @click="confirmingDeactivate = false"
            >{{ $t('Commons.button.cancel', {}) }}</button>

            <PrimaryButton
              v-if="selected.disabled_at"
              :disabled="accountActionBusy"
              @click="reactivate"
            >Reactivate</PrimaryButton>
          </div>

          <div v-if="passwordForm" class="rounded border border-gray-300 p-4 space-y-3 text-sm">
            <h4 class="font-semibold text-gray-700">{{ $t('Commons.button.set_password', {}) }}</h4>
            <p class="text-xs text-gray-500">
              Replaces their current password straight away — for someone whose email isn't arriving.
              You'll need to give it to them yourself.
            </p>
            <div class="flex flex-wrap items-end gap-2">
              <label class="block flex-1 min-w-[12rem]">
                <span class="text-gray-700">{{ $t('Commons.text.new_password', {}) }}</span>
                <input
                  v-model="passwordForm.password"
                  :type="showPassword ? 'text' : 'password'"
                  autocomplete="new-password"
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm font-mono"
                />
              </label>
              <SecondaryButton type="button" @click="showPassword = !showPassword">{{ showPassword ? $t('Commons.button.hide') : $t('Commons.button.show') }}</SecondaryButton>
              <SecondaryButton type="button" @click="generatePassword(passwordForm)">{{ $t('Commons.button.generate', {}) }}</SecondaryButton>
            </div>
            <label class="flex items-center gap-2">
              <input v-model="passwordForm.require_password_change" type="checkbox" />
              <span>{{ $t('Pages.text.ask_them_to_choose_2', {}) }}</span>
            </label>
            <label class="flex items-center gap-2">
              <input v-model="passwordForm.send_login_email" type="checkbox" />
              <span>Email them their login details (not the password)</span>
            </label>
            <div class="flex gap-2">
              <PrimaryButton :disabled="passwordSaving || !passwordForm.password" @click="savePassword">
                {{ passwordSaving ? 'Saving…' : $t('Commons.button.save_password') }}
              </PrimaryButton>
              <button type="button" class="text-sm text-gray-500 underline" @click="passwordForm = null">{{ $t('Commons.button.cancel', {}) }}</button>
            </div>
          </div>
        </div>

        <div class="flex gap-2 pt-2">
          <PrimaryButton :disabled="saving" @click="saveUser">{{ saving ? 'Saving…' : $t('Commons.button.save') }}</PrimaryButton>
          <button type="button" class="text-sm text-gray-500 underline" @click="cancelEdit">{{ $t('Commons.button.cancel', {}) }}</button>
        </div>
      </section>
    </div>
  </AuthenticatedLayout>
</template>

<style scoped>
.role-chip {
  padding: 0.35rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 9999px;
  background: #fff;
  color: #374151;
  font-size: 0.875rem;
  cursor: pointer;
}

.role-chip-active {
  background: #4f46e5;
  color: #fff;
  border-color: #4f46e5;
}

.role-chip-count {
  opacity: 0.7;
  font-size: 0.75em;
}

.sort-header {
  font-weight: inherit;
  color: inherit;
  white-space: nowrap;
}

.sort-header:hover {
  text-decoration: underline;
}
</style>
