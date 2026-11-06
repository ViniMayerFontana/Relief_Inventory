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

	return new Date(datetimeLocal).toLocaleString(document.documentElement.lang || 'pt-BR', {
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
		bannerMessage.value = `Manutenção programada de ${startText} a ${endText}. O sistema poderá ficar indisponível por alguns instantes nesse período.`;
	} else if (startText) {
		bannerMessage.value = `Manutenção programada a partir de ${startText}. O sistema poderá ficar indisponível por alguns instantes nesse período.`;
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
		bannerSavedAt.value = new Date().toLocaleTimeString(document.documentElement.lang || 'pt-BR');
	} catch (e) {
		bannerError.value = e.response?.data?.message || 'Não foi possível salvar as configurações do aviso.';
	} finally {
		bannerSaving.value = false;
	}
}
</script>

<template>
	<Head title="Aviso do sistema" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Aviso do sistema</h1>

			<section class="bg-white shadow rounded-lg p-6 space-y-4">
				<p class="text-sm text-gray-600">
					Apenas um aviso é exibido por vez. Escolha um tipo, inclua uma mensagem se necessário e salve.
					Todas as pessoas verão o aviso até dispensá-lo ou até que você o altere.
				</p>

				<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
					<label class="block">
						<span class="text-gray-700">Aviso</span>
						<select v-model="bannerType" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
							<option value="">Nenhum</option>
							<option value="feedback">Relatar erro/sugerir melhoria (mensagem padrão)</option>
							<option value="maintenance">Aviso de manutenção</option>
							<option value="message">Mensagem geral</option>
						</select>
					</label>
					<template v-if="bannerType === 'maintenance'">
						<label class="block">
							<span class="text-gray-700">Início</span>
							<input type="datetime-local" v-model="maintenanceStart" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Término</span>
							<input type="datetime-local" v-model="maintenanceEnd" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</template>
					<label v-if="bannerNeedsMessage" class="block sm:col-span-2">
						<span class="text-gray-700">Mensagem</span>
						<textarea v-model="bannerMessage" rows="2" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm"></textarea>
						<span v-if="bannerType === 'maintenance'" class="text-xs text-gray-500">
							Preenchida automaticamente com os horários acima. Você pode editá-la; ela só será gerada novamente se alterar esses horários.
						</span>
					</label>
				</div>

				<div v-if="bannerError" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
					{{ bannerError }}
				</div>

				<div class="flex items-center gap-3">
					<PrimaryButton :disabled="bannerSaving" @click="saveBanner">
						{{ bannerSaving ? 'Salvando…' : 'Salvar aviso' }}
					</PrimaryButton>
					<span v-if="bannerSavedAt" class="text-xs text-gray-500">Salvo {{ bannerSavedAt }}</span>
				</div>

				<p class="text-xs text-gray-500">
					Ao alterar a mensagem, o aviso volta a aparecer para todas as pessoas, inclusive para quem já o dispensou.
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
