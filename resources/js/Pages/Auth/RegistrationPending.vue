<script setup>
import { computed } from 'vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import { Head, Link } from '@inertiajs/vue3';

const props = defineProps({
	requested_track: {
		type: String,
		default: null,
	},
});

const trackMessages = {
	volunteer: 'Seu cadastro como voluntário está aguardando análise. Uma pessoa da equipe entrará em contato quando sua conta for aprovada.',
	donor: 'Sua oferta de doação está aguardando análise. Uma pessoa da equipe entrará em contato quando sua conta for aprovada.',
	partner: 'Sua solicitação para receber suprimentos está aguardando análise. Uma pessoa da equipe entrará em contato quando sua conta for aprovada.',
};

const message = computed(() => trackMessages[props.requested_track] || 'Sua conta está aguardando análise. Uma pessoa da equipe entrará em contato quando ela for aprovada.');
</script>

<template>
	<GuestLayout>
		<Head title="Cadastro recebido" />

		<div class="mb-4 text-lg font-medium text-gray-900">
			Agradecemos por se cadastrar!
		</div>

		<div class="mb-4 text-sm text-gray-600">
			Seu endereço de e-mail foi verificado. {{ message }}
		</div>

		<div class="mt-4 flex items-center justify-between">
			<Link
				:href="route('logout')"
				method="post"
				as="button"
				class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
				>Sair</Link
			>
		</div>
	</GuestLayout>
</template>
