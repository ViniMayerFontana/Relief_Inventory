<script setup>
import { computed } from 'vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import { t } from '@/i18n';

const props = defineProps({
	requested_track: {
		type: String,
		default: null,
	},
});

const trackMessages = {
	volunteer: t('Pages.Auth.text.your_volunteer_sign_up'),
	donor: t('Pages.Auth.text.your_donation_offer_is'),
	partner: t('Pages.Auth.text.your_request_to_receive'),
};

const message = computed(() => trackMessages[props.requested_track] || t('Pages.Auth.text.your_account_is_pending'));
</script>

<template>
	<GuestLayout>
		<Head :title="$t('Commons.title.registration_received')" />

		<div class="mb-4 text-lg font-medium text-gray-900">
			{{ $t('Pages.Auth.text.thanks_for_registering', {}) }}
		</div>

		<div class="mb-4 text-sm text-gray-600">
			{{ $t('Pages.Auth.text.your_email_address_has') }} {{ message }}
		</div>

		<div class="mt-4 flex items-center justify-between">
			<Link
				:href="route('logout')"
				method="post"
				as="button"
				class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
				>{{ $t('Commons.link.log_out', {}) }}</Link
			>
		</div>
	</GuestLayout>
</template>
