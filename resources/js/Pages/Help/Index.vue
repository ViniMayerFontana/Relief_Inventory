<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Help/Index.vue

	Every in-app Help guide (HelpReportController::GUIDES), reached from the
	main-menu Help tile. Each guide can be opened or printed on its own, and
	"Print all guides" prints them as one PDF (/report/help/all, print-queue
	document help-all). The Training section prints Training Mode's team
	activity sheets (App\Support\TrainingGuide).
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';
import PrintMenu from '@/Components/PrintMenu.vue';

defineProps({
	breadcrumb: { type: Array },
	guides: { type: Array, required: true },
	trainingTeams: { type: Array, default: () => [] },
});
</script>

<template>
	<Head :title="$t('Commons.title.help')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<div class="flex items-start justify-between gap-4">
				<div>
					<h1 class="text-2xl font-bold">{{ $t('Commons.heading.help_guides', {}) }}</h1>
					<p class="text-gray-600 mt-1">
						{{ $t('Pages.Help.text.step_by_step_guides', {}) }}
					</p>
				</div>
				<PrintMenu
					document-key="help-all"
					media="report"
					variant="plain"
					:label="$t('Pages.Help.label.print_all_guides')"
					download-href="/report/help/all"
					extra-class="shrink-0 px-3 py-2 text-sm rounded bg-blue-600 text-white hover:bg-blue-700"
				/>
			</div>

			<section class="bg-white shadow rounded-lg divide-y">
				<div
					v-for="guide in guides"
					:key="guide.slug"
					class="flex items-center justify-between gap-4 px-6 py-3"
				>
					<Link :href="'/help/' + guide.slug" class="text-blue-600 underline">
						{{ guide.title }}
					</Link>
					<PrintMenu
						:document-key="'help-' + guide.slug"
						media="report"
						variant="plain"
						:download-href="'/report/help/' + guide.slug"
						extra-class="shrink-0 px-3 py-1 text-sm rounded border border-gray-300 text-gray-700 hover:bg-gray-50"
					/>
				</div>
			</section>

			<div class="flex items-start justify-between gap-4 pt-2">
				<div>
					<h2 class="text-xl font-bold">{{ $t('Pages.Help.heading.training_team_activity_sheets', {}) }}</h2>
					<p class="text-gray-600 mt-1">
						{{ $t('Pages.Help.text.for_a_hands_on', {}) }}
					</p>
				</div>
				<PrintMenu
					document-key="training-all-teams"
					media="report"
					variant="plain"
					:label="$t('Pages.Help.label.print_all_team_sheets')"
					download-href="/report/training/team-sheets.pdf"
					extra-class="shrink-0 px-3 py-2 text-sm rounded bg-blue-600 text-white hover:bg-blue-700"
				/>
			</div>

			<section class="bg-white shadow rounded-lg divide-y">
				<div
					v-for="team in trainingTeams"
					:key="team"
					class="flex items-center justify-between gap-4 px-6 py-3"
				>
					<span>{{ $t('Commons.text.team') }} {{ team }} {{ $t('Commons.text.activity_sheet') }}</span>
					<PrintMenu
						:document-key="'training-team-' + team"
						media="report"
						variant="plain"
						:download-href="'/report/training/team-sheets.pdf?team=' + team"
						extra-class="shrink-0 px-3 py-1 text-sm rounded border border-gray-300 text-gray-700 hover:bg-gray-50"
					/>
				</div>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
