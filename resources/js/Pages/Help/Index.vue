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
	<Head title="Ajuda" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<template #header></template>

		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<div class="flex items-start justify-between gap-4">
				<div>
					<h1 class="text-2xl font-bold">Guias de ajuda</h1>
					<p class="text-gray-600 mt-1">
						Guias passo a passo para cada etapa do fluxo de trabalho do armazém. As páginas
						com guia também têm um link "Ajuda: ..." perto do título para abri-lo.
					</p>
				</div>
				<PrintMenu
					document-key="help-all"
					media="report"
					variant="plain"
					label="Imprimir todos os guias"
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
					<h2 class="text-xl font-bold">Treinamento: fichas de atividades das equipes</h2>
					<p class="text-gray-600 mt-1">
						Para uma aula prática: a ficha de cada equipe lista suas seis estações na ordem de
						rodízio, com uma atividade da Rodada 1 e outra da Rodada 2 em cada estação.
					</p>
				</div>
				<PrintMenu
					document-key="training-all-teams"
					media="report"
					variant="plain"
					label="Imprimir fichas de todas as equipes"
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
					<span>Ficha de atividades da equipe {{ team }}</span>
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
