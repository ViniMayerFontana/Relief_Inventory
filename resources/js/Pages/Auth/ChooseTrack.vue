<script setup>
import { ref } from 'vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';
import { t } from '@/i18n';

const props = defineProps({
	requested_track: {
		type: String,
		default: null,
	},
});

const tracks = [
	{
		value: 'volunteer',
		icon: '🙋',
		label: t('Commons.button.volunteer'),
		description: t('Pages.Auth.text.i_want_to_help'),
	},
	{
		value: 'donor',
		icon: '📦',
		label: t('Pages.Auth.text.offer_a_donation'),
		description: t('Pages.Auth.text.i_have_goods_or'),
	},
	{
		value: 'partner',
		icon: '🏢',
		label: t('Commons.text.request_supplies'),
		description: t('Pages.Auth.text.get_approved_to_receive'),
	},
];

const form = useForm({
	requested_track: props.requested_track,
});

const submitting = ref(false);

const choose = (value) => {
	form.requested_track = value;
	submitting.value = true;
	form.post(route('registration.track.store'), {
		onFinish: () => {
			submitting.value = false;
		},
	});
};
</script>

<template>
	<GuestLayout>
		<Head :title="$t('Commons.title.welcome')" />

		<div class="mb-4 text-sm font-medium text-green-600">
			{{ $t('Pages.Auth.text.your_email_is_verified', {}) }}
		</div>

		<div class="mb-2 text-lg font-medium text-gray-900">
			{{ $t('Pages.Auth.text.what_brings_you_here', {}) }}
		</div>
		<div class="mb-6 text-sm text-gray-600">
			{{ $t('Pages.Auth.text.let_us_know_why', {}) }}
		</div>

		<div class="choosetrack_grid">
			<button
				v-for="track in tracks"
				:key="track.value"
				type="button"
				class="choosetrack_tile"
				:class="{ choosetrack_tile_active: form.requested_track === track.value }"
				:disabled="submitting"
				@click="choose(track.value)"
			>
				<span class="choosetrack_icon">{{ track.icon }}</span>
				<span class="choosetrack_label">{{ track.label }}</span>
				<span class="choosetrack_description">{{ track.description }}</span>
			</button>
		</div>

		<div class="mt-6 flex items-center justify-end">
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

<style scoped>
.choosetrack_grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
	gap: 1em;
}
.choosetrack_tile {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 0.5em;
	border: 2px solid #e5e7eb;
	border-radius: 12px;
	background: white;
	cursor: pointer;
	padding: 1.5em 1em;
	text-align: center;
}
.choosetrack_tile:disabled {
	cursor: default;
	opacity: 0.6;
}
.choosetrack_tile:hover:not(:disabled) {
	border-color: #007bff;
	background: #f3f9ff;
}
.choosetrack_icon {
	font-size: 2.75rem;
	line-height: 1;
}
.choosetrack_label {
	font-size: 1rem;
	font-weight: bold;
	color: #111827;
}
.choosetrack_description {
	font-size: 0.8rem;
	color: #6b7280;
}
.choosetrack_tile_active {
	border-color: #007bff;
	background: #eaf3ff;
}
</style>
