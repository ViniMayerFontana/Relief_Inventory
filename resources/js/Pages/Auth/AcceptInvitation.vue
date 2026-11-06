<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!--
	AcceptInvitation.vue — the page behind the link in an invitation email (/invitations/{token},
	MembershipInvitationController). The invited login proves it is theirs with its own password;
	accepting adds it to this warehouse and signs them in.
-->

<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, useForm } from '@inertiajs/vue3';

const props = defineProps({
	warehouseName: { type: String, required: true },
	email: { type: String, required: true },
	invitedBy: { type: String, default: null },
	token: { type: String, required: true },
});

const form = useForm({ password: '' });
const submit = () => form.post(route('invitations.accept', props.token), { onFinish: () => form.reset('password') });
</script>

<template>
	<GuestLayout>
		<Head :title="`Entrar em ${warehouseName}`" />

		<h1 class="text-lg font-semibold text-gray-900">Entrar em {{ warehouseName }}</h1>
		<p class="mt-1 text-sm text-gray-600">
			<template v-if="invitedBy">{{ invitedBy }} convidou</template><template v-else>Você foi convidado</template>
			a conta <strong>{{ email }}</strong> para entrar neste armazém. Nada muda até você aceitar.
			Informe a senha dessa conta para aceitar.
		</p>

		<form @submit.prevent="submit">
			<div class="mt-4">
				<InputLabel for="password" value="Senha" />
				<TextInput id="password" type="password" class="mt-1 block w-full" v-model="form.password" autofocus autocomplete="current-password" />
				<InputError class="mt-2" :message="form.errors.password" />
			</div>
			<div class="mt-6 flex justify-end">
				<PrimaryButton :class="{ 'opacity-25': form.processing }" :disabled="form.processing">Aceitar e entrar</PrimaryButton>
			</div>
		</form>
	</GuestLayout>
</template>
