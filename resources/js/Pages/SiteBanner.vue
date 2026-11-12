<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- SiteBanner.vue

	Editor for the single site-wide banner slot (BannerSetting — see
	Banner.vue for how it's rendered). Split out of FeedbackReports.vue
	(2026-08-22) into its own page/menu item so banner editing isn't
	bundled under "Feedback & Bug Reports" — same permission (manage-feedback)
	and same /json/banner-settings endpoint, just its own screen.
-->

<script setup>
import { computed, ref, watch } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, usePage } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { t } from '@/i18n';

defineProps({
	breadcrumb: { type: Array },
});

const bannerType = ref('');
const bannerMessage = ref('');
const bannerSaving = ref(false);
const bannerSavedAt = ref(null);
const bannerError = ref(null);
const maintenanceStart = ref('');
const maintenanceEnd = ref('');

// The active banner is already available via the shared Inertia prop, so
// seed the form from it rather than a separate fetch. Start/stop time isn't
// stored separately (BannerSetting only persists the composed message text —
// scheduling display automatically was explicitly decided against, this is
// only for generating the wording), so it can't be re-populated on load.
const page = usePage();
bannerType.value = page.props.banner?.type || '';
bannerMessage.value = page.props.banner?.message || '';

const bannerNeedsMessage = computed(() => bannerType.value === 'maintenance' || bannerType.value === 'message');

function formatForMessage(datetimeLocal) {
	if (!datetimeLocal) return null;

	return new Date(datetimeLocal).toLocaleString([], {
		weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit',
	});
}

// Regenerates the maintenance banner's message text from the start/stop
// fields whenever either changes — still a plain editable textarea
// afterward, so an admin can hand-adjust the wording after generating it.
watch([maintenanceStart, maintenanceEnd], ([start, end]) => {
	if (bannerType.value !== 'maintenance') return;

	const startText = formatForMessage(start);
	const endText = formatForMessage(end);

	if (startText && endText) {
		bannerMessage.value = t('Pages.text.scheduled_maintenance_from_p0', { p0: startText, p1: endText });
	} else if (startText) {
		bannerMessage.value = t('Pages.text.scheduled_maintenance_starting_p0', { p0: startText });
	}
});

async function saveBanner() {
	bannerSaving.value = true;
	bannerError.value = null;
	try {
		await axios.put('/json/banner-settings', {
			type: bannerType.value || null,
			message: bannerNeedsMessage.value ? bannerMessage.value : null,
		});
		bannerSavedAt.value = new Date().toLocaleTimeString();
	} catch (e) {
		bannerError.value = e.response?.data?.message || t('Pages.text.could_not_save_banner');
	} finally {
		bannerSaving.value = false;
	}
}
</script>

<template>
	<Head :title="$t('Commons.title.site_banner')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.site_banner', {}) }}</h1>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<p class="text-sm text-gray-600">
					{{ $t('Pages.text.only_one_banner_shows', {}) }}
				</p>

				<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">Banner</span>
						<select v-model="bannerType" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">{{ $t('Commons.text.none', {}) }}</option>
							<option value="feedback">{{ $t('Pages.text.report_a_bug_feature', {}) }}</option>
							<option value="maintenance">{{ $t('Commons.text.maintenance_notice', {}) }}</option>
							<option value="message">{{ $t('Commons.text.general_message', {}) }}</option>
						</select>
					</label>
					<template v-if="bannerType === 'maintenance'">
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.starts', {}) }}</span>
							<input type="datetime-local" v-model="maintenanceStart" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.ends', {}) }}</span>
							<input type="datetime-local" v-model="maintenanceEnd" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</template>
					<label v-if="bannerNeedsMessage" class="block sm:col-span-2">
						<span class="text-gray-700">{{ $t('Commons.text.message', {}) }}</span>
						<textarea v-model="bannerMessage" rows="2" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm"></textarea>
						<span v-if="bannerType === 'maintenance'" class="text-xs text-gray-500">
							{{ $t('Pages.text.auto_filled_from_the', {}) }}
						</span>
					</label>
				</div>

				<div v-if="bannerError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
					{{ bannerError }}
				</div>

				<div class="flex items-center gap-3">
					<PrimaryButton :disabled="bannerSaving" @click="saveBanner">
						{{ bannerSaving ? $t('Commons.button.saving') : $t('Commons.button.save_banner') }}
					</PrimaryButton>
					<span v-if="bannerSavedAt" class="text-xs text-gray-500">{{ $t('Commons.text.saved') }} {{ bannerSavedAt }}</span>
				</div>

				<p class="text-xs text-gray-500">
					{{ $t('Pages.text.changing_the_message_resets', {}) }}
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
