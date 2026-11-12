<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!--
	UserInvitations.vue — invitations this warehouse has sent to logins that belong elsewhere and
	that nobody has answered yet (MULTI_WAREHOUSE.md §6), on the Users page. A person added with an
	email that already has a login lands here until its owner accepts; Resend sends the email again
	(and, for one that came from a restored backup, sends the first one); Withdraw takes it back.
	Hidden while the list is empty. Fetches itself when the Users list is shown.
-->

<script setup>
import SecondaryButton from '@/Components/SecondaryButton.vue';
import axios from 'axios';
import { onMounted, ref } from 'vue';
import { t } from '@/i18n';

const invitations = ref([]);
const message = ref(null);
const busy = ref(false);

async function load() {
	try {
		invitations.value = (await axios.get('/json/users/invitations')).data;
	} catch {
		invitations.value = [];
	}
}

async function act(request) {
	busy.value = true;
	message.value = null;
	try {
		message.value = (await request()).data.message;
	} catch (e) {
		message.value = e.response?.data?.message || t('Components.text.that_did_not_work');
	} finally {
		busy.value = false;
		await load();
	}
}

const resend = (i) => act(() => axios.post(`/json/users/invitations/${i.id}/resend`));
const withdraw = (i) => act(() => axios.delete(`/json/users/invitations/${i.id}`));
const when = (iso) => new Date(iso).toLocaleDateString();

onMounted(load);
</script>

<template>
	<section v-if="invitations.length" class="bg-white shadow rounded-lg p-6 space-y-3">
		<h2 class="text-lg font-semibold">{{ $t('Components.heading.waiting_for_an_answer', {}) }}</h2>
		<p class="text-sm text-gray-600">
			{{ $t('Components.text.these_people_s_emails', {}) }}
		</p>
		<p v-if="message" class="text-sm text-gray-800">{{ message }}</p>
		<ul class="divide-y">
			<li v-for="i in invitations" :key="i.id" class="flex flex-wrap items-center justify-between gap-2 py-2 text-sm">
				<span>
					<span class="font-medium">{{ i.person }}</span>
					<span class="text-gray-600"> &lt;{{ i.email }}&gt;</span>
					<span class="block text-xs text-gray-500">
						{{ i.source === 'restore' ? 'From a restored backup (never emailed)' : `Invited by ${i.invited_by || 'an administrator'}` }}
						· open until {{ when(i.expires_at) }}
					</span>
				</span>
				<span class="flex gap-2">
					<SecondaryButton :disabled="busy" @click="resend(i)">{{ i.source === 'restore' ? $t('Commons.button.email_invitation') : $t('Commons.button.resend') }}</SecondaryButton>
					<SecondaryButton :disabled="busy" @click="withdraw(i)">{{ $t('Commons.button.withdraw', {}) }}</SecondaryButton>
				</span>
			</li>
		</ul>
	</section>
</template>
