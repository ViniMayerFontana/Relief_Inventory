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
		message.value = e.response?.data?.message || 'Não foi possível concluir a operação.';
	} finally {
		busy.value = false;
		await load();
	}
}

const resend = (i) => act(() => axios.post(`/json/users/invitations/${i.id}/resend`));
const withdraw = (i) => act(() => axios.delete(`/json/users/invitations/${i.id}`));
const when = (iso) => new Date(iso).toLocaleDateString('pt-BR');

onMounted(load);
</script>

<template>
	<section v-if="invitations.length" class="bg-white shadow rounded-lg p-6 space-y-3">
		<h2 class="text-lg font-semibold">Aguardando resposta</h2>
		<p class="text-sm text-gray-600">
			Os endereços de e-mail destas pessoas já têm acesso a outro armazém, por isso elas receberam um convite
			em vez de serem adicionadas. Elas só poderão entrar neste armazém depois que a pessoa responsável pelo
			acesso aceitar o convite.
		</p>
		<p v-if="message" class="text-sm text-gray-800">{{ message }}</p>
		<ul class="divide-y">
			<li v-for="i in invitations" :key="i.id" class="flex flex-wrap items-center justify-between gap-2 py-2 text-sm">
				<span>
					<span class="font-medium">{{ i.person }}</span>
					<span class="text-gray-600"> &lt;{{ i.email }}&gt;</span>
					<span class="block text-xs text-gray-500">
						{{ i.source === 'restore' ? 'De um backup restaurado (o convite não foi enviado por e-mail)' : `Convidado por ${i.invited_by || 'um administrador'}` }}
						· válido até {{ when(i.expires_at) }}
					</span>
				</span>
				<span class="flex gap-2">
					<SecondaryButton :disabled="busy" @click="resend(i)">{{ i.source === 'restore' ? 'Enviar convite por e-mail' : 'Reenviar' }}</SecondaryButton>
					<SecondaryButton :disabled="busy" @click="withdraw(i)">Cancelar convite</SecondaryButton>
				</span>
			</li>
		</ul>
	</section>
</template>
