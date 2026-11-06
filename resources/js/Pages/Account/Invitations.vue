<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!--
	Invitations.vue — warehouses that have invited this login to join them (/account/invitations,
	MembershipInvitationController). Accepting needs the login's own password: it adds this login to
	that warehouse, which changes who can manage it (a warehouse that is only yours stops being the
	only home). Reached from the profile menu, which shows a count only while something is waiting.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import InputError from '@/Components/InputError.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, router, useForm } from '@inertiajs/vue3';
import { ref } from 'vue';

defineProps({
	invitations: { type: Array, default: () => [] },
	joined: { type: Object, default: null },
	breadcrumb: { type: Array },
});

const open = ref(null);
const form = useForm({ password: '' });

function start(id) {
	open.value = id;
	form.reset();
	form.clearErrors();
}

function accept(id) {
	form.post(route('account.invitations.accept', id), {
		preserveScroll: true,
		onSuccess: () => (open.value = null),
		onFinish: () => form.reset('password'),
	});
}

function decline(id) {
	router.post(route('account.invitations.decline', id), {}, { preserveScroll: true });
}
</script>

<template>
	<Head title="Convites" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="mx-auto max-w-2xl space-y-4 p-4">
			<h1 class="text-2xl font-bold">Convites</h1>
			<p v-if="joined" class="rounded border border-green-300 bg-green-50 p-3 text-sm text-green-900">
				Você entrou em {{ joined.name }}. <a :href="joined.url" class="underline">Acessar</a> (entre lá com o mesmo usuário e senha).
			</p>

			<p v-if="!invitations.length" class="text-sm text-gray-600">Nenhum armazém enviou um convite no momento.</p>

			<div v-for="inv in invitations" :key="inv.id" class="rounded border border-gray-200 bg-white p-4">
				<div class="font-medium text-gray-900">{{ inv.warehouse }}</div>
				<p class="mt-1 text-sm text-gray-600">
					Você entrará como <strong>{{ inv.person }}</strong><template v-if="inv.invited_by"> (convidado por {{ inv.invited_by }})</template>.
					A administração desse armazém poderá gerenciar seu acesso. Sua senha e o acesso aos outros armazéns continuam sob seu controle.
					<template v-if="inv.source === 'restore'">Este convite veio de um backup restaurado, não de uma pessoa: aceite-o somente se espera fazer parte desse armazém.</template>
				</p>

				<div v-if="open === inv.id" class="mt-3 flex items-start gap-2">
					<div class="flex-1">
						<TextInput type="password" class="block w-full" v-model="form.password" placeholder="Sua senha" autofocus autocomplete="current-password" @keyup.enter="accept(inv.id)" />
						<InputError class="mt-1" :message="form.errors.password" />
					</div>
					<PrimaryButton :disabled="form.processing" @click="accept(inv.id)">Confirmar</PrimaryButton>
					<SecondaryButton @click="open = null">Cancelar</SecondaryButton>
				</div>
				<div v-else class="mt-3 flex gap-2">
					<PrimaryButton @click="start(inv.id)">Aceitar</PrimaryButton>
					<SecondaryButton @click="decline(inv.id)">Recusar</SecondaryButton>
				</div>
			</div>
		</div>
	</AuthenticatedLayout>
</template>
