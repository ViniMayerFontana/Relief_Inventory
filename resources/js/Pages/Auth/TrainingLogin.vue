<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details

	A training warehouse's tap-your-name login (TrainingLoginController). Only reached on an approved
	device. Tap your name, confirm your team, and you're in — no
	password; the session can only do station work (App\Services\TrainingMode). "Add New" puts a
	new trainee on the list. Staff use the PIN / email links at the bottom.
	A successful login does a real page navigation so the new session's shared props load cleanly.
-->

<script setup>
import { ref, computed, nextTick } from 'vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import axios from 'axios';
import { t } from '@/i18n';

const props = defineProps({
	trainees: { type: Array, default: () => [] },
	teams: { type: Array, required: true },
	staffPinAvailable: { type: Boolean, default: false },
});

const search = ref('');
const selected = ref(null);
const team = ref(null);
const adding = ref(false);
const firstName = ref('');
const lastName = ref('');
const firstEl = ref(null);
const error = ref(null);
const busy = ref(false);

const filtered = computed(() => {
	const q = search.value.trim().toLowerCase();
	return q ? props.trainees.filter((t) => t.full_name.toLowerCase().includes(q)) : props.trainees;
});

// Tiles grouped by team (unassigned last), so a team can find its own names quickly.
const groups = computed(() => {
	const byTeam = new Map();
	for (const t of filtered.value) {
		const key = t.team || 0;
		if (!byTeam.has(key)) byTeam.set(key, []);
		byTeam.get(key).push(t);
	}
	return [...byTeam.entries()]
		.sort(([a], [b]) => (a || 99) - (b || 99))
		.map(([key, people]) => ({ label: key ? t('Commons.text.team') + key : 'No team yet', people }));
});

function pick(trainee) {
	selected.value = trainee;
	team.value = trainee.team || null;
	error.value = null;
}

function startAdd() {
	adding.value = true;
	selected.value = null;
	team.value = null;
	firstName.value = search.value.trim().split(/\s+/)[0] || '';
	lastName.value = search.value.trim().split(/\s+/).slice(1).join(' ');
	error.value = null;
	nextTick(() => firstEl.value?.focus());
}

function back() {
	selected.value = null;
	adding.value = false;
	error.value = null;
}

async function submit() {
	if (!team.value) {
		error.value = t('Pages.Auth.text.choose_your_team');
		return;
	}
	busy.value = true;
	error.value = null;
	try {
		const response = adding.value
			? await axios.post('/training-login/trainees', { first_name: firstName.value, last_name: lastName.value, team: team.value })
			: await axios.post('/training-login', { person_id: selected.value.id, team: team.value });
		window.location.href = response.data.redirect || '/dashboard';
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Auth.text.could_not_log_in');
	} finally {
		busy.value = false;
	}
}
</script>

<template>
	<Head :title="$t('Commons.title.training_login')" />
	<GuestLayout>
		<div class="text-center mb-4">
			<h1 class="text-xl font-bold text-gray-800">{{ $t('Commons.heading.training_login', {}) }}</h1>
			<p class="text-sm text-gray-600">{{ $t('Pages.Auth.text.tap_your_name_to', {}) }}</p>
		</div>

		<!-- ======================= PICK A NAME ======================= -->
		<div v-if="!selected && !adding" class="space-y-4">
			<div class="flex gap-2">
				<input v-model="search" type="text" :placeholder="$t('Pages.Auth.placeholder.find_your_name')"
					class="flex-1 border-gray-300 rounded-md shadow-sm" />
				<button type="button" @click="startAdd"
					class="px-3 py-2 bg-gray-800 text-white rounded-md text-sm font-semibold hover:bg-gray-700">
					{{ $t('Commons.button.add_new', {}) }}
				</button>
			</div>

			<p v-if="!trainees.length" class="text-sm text-gray-500 text-center">
				{{ $t('Pages.Auth.text.no_one_is_on', {}) }}
			</p>
			<p v-else-if="!filtered.length" class="text-sm text-gray-500 text-center">
				{{ $t('Pages.Auth.text.no_name_matches_tap', {}) }}
			</p>

			<div v-for="group in groups" :key="group.label" class="space-y-2">
				<p class="text-xs font-semibold text-gray-500 uppercase">{{ group.label }}</p>
				<div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
					<button v-for="t in group.people" :key="t.id" type="button" @click="pick(t)"
						class="border rounded-lg py-3 px-2 text-sm font-medium text-gray-700 hover:bg-gray-50 hover:border-gray-400">
						{{ t.full_name }}
					</button>
				</div>
			</div>
		</div>

		<!-- ======================= CONFIRM TEAM (and name, when adding) ======================= -->
		<form v-else class="space-y-4" @submit.prevent="submit">
			<button type="button" @click="back" class="text-sm text-gray-500">&larr; Back</button>

			<p v-if="selected" class="text-center font-medium text-gray-800">{{ selected.full_name }}</p>
			<div v-else class="grid grid-cols-2 gap-2">
				<input ref="firstEl" v-model="firstName" type="text" :placeholder="$t('Commons.placeholder.first_name')" required
					class="border-gray-300 rounded-md shadow-sm" />
				<input v-model="lastName" type="text" :placeholder="$t('Commons.placeholder.last_name')" required
					class="border-gray-300 rounded-md shadow-sm" />
			</div>

			<div>
				<p class="text-sm text-gray-600 text-center mb-2">{{ $t('Commons.text.your_team', {}) }}</p>
				<div class="flex justify-center gap-2">
					<button v-for="n in teams" :key="n" type="button" @click="team = n"
						:class="['w-12 h-12 rounded-md border text-lg font-semibold',
							team === n ? 'bg-blue-600 text-white border-blue-600' : 'text-gray-700 hover:bg-gray-50']">
						{{ n }}
					</button>
				</div>
			</div>

			<p v-if="error" class="text-sm text-red-600 text-center">{{ error }}</p>

			<button type="submit" :disabled="busy"
				class="w-full py-3 bg-blue-600 text-white rounded-md font-semibold hover:bg-blue-700 disabled:opacity-50">
				{{ busy ? $t('Commons.button.logging_in') : $t('Commons.button.start') }}
			</button>
		</form>

		<div class="text-center pt-4 mt-4 border-t space-x-4">
			<span class="text-xs text-gray-500">{{ $t('Commons.text.staff', {}) }}</span>
			<Link v-if="staffPinAvailable" :href="route('unlock')" class="text-sm text-gray-500 underline">{{ $t('Pages.Auth.link.log_in_with_pin', {}) }}</Link>
			<Link :href="route('login', { email: 1 })" class="text-sm text-gray-500 underline">{{ $t('Pages.Auth.link.log_in_with_email', {}) }}</Link>
		</div>
	</GuestLayout>
</template>
