<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- SortingAreaReport.vue (/reports/sorting-area)
     End-of-day check: usable goods sorted in the chosen range vs. put on warehouse pallets, and what is still in the sorting
     area right now (on hand, not on any pallet) with how long it has been waiting. SortingAreaReportController. -->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import { computed, onMounted, ref } from 'vue';
import axios from 'axios';
import { withWarehouse } from '@/bootstrap';

defineProps({ breadcrumb: { type: Array } });

const today = new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().slice(0, 10);
const from = ref(today);
const to = ref(today);
const report = ref(null);
const loading = ref(false);
const error = ref(null);
const onlyWaiting = ref(false);

async function load() {
	loading.value = true;
	error.value = null;
	try {
		report.value = (await axios.get('/json/reports/sorting-area', { params: { from: from.value, to: to.value || from.value } })).data;
	} catch (e) {
		error.value = e.response?.data?.message || Object.values(e.response?.data?.errors || {}).flat().join(' ') || 'Não foi possível carregar o relatório.';
	} finally {
		loading.value = false;
	}
}

const rows = computed(() => (report.value?.items || []).filter((r) => !onlyWaiting.value || r.in_area > 0));
const csvHref = computed(() => withWarehouse('/report/sorting-area.csv?' + new URLSearchParams({ from: from.value, to: to.value || from.value })));
// Sorted in the range but not (yet) on a pallet: the "left behind" signal an end-of-day check is looking for.
const leftBehind = (r) => r.in_area > 0 && r.sorted > r.moved;

onMounted(load);
</script>

<template>
	<Head title="Relatório da área de triagem" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="sa_page">
			<h2 class="sa_title">
				Relatório da área de triagem
				<a :href="csvHref" class="ri_defaultbutton sa_csv">Baixar CSV</a>
			</h2>
			<p class="ri_hint">
				O que foi produzido na triagem em comparação ao que foi colocado em paletes. "Ainda na área de triagem" mostra o saldo atual —
				tudo que não está em um palete, inclusive de dias anteriores — para que qualquer sobra no fim do dia apareça aqui.
			</p>

			<form class="sa_toolbar" @submit.prevent="load">
				<label>De <input type="date" v-model="from" class="ri_forminput" /></label>
				<label>Até <input type="date" v-model="to" class="ri_forminput" /></label>
				<button type="submit" class="ri_formbutton" :disabled="loading">Executar</button>
				<label class="sa_toggle"><input type="checkbox" v-model="onlyWaiting" /> Apenas itens ainda na área de triagem</label>
			</form>

			<p v-if="error" class="ri_error">{{ error }}</p>
			<p v-else-if="!report">Carregando…</p>
			<div v-else class="sa_wrap">
				<table class="ri_datatable" border="1">
					<thead>
						<tr><th>Nº do item</th><th>Item</th><th>Triado</th><th>Colocado em paletes</th><th>Ainda na área de triagem</th><th>Aguardando desde</th></tr>
					</thead>
					<tbody>
						<tr v-for="r in rows" :key="r.item_id" :class="{ sa_flag: leftBehind(r) }">
							<td>{{ r.display_number }}</td>
							<td>{{ r.name }}</td>
							<td class="sa_num">{{ r.sorted || '' }}</td>
							<td class="sa_num">{{ r.moved || '' }}</td>
							<td class="sa_num">{{ r.in_area || '' }}</td>
							<td>{{ r.waiting_since || '' }}</td>
						</tr>
						<tr v-if="!rows.length"><td colspan="6">Nada triado, movido ou aguardando neste período.</td></tr>
					</tbody>
					<tfoot v-if="rows.length">
						<tr>
							<td></td><td><strong>Total</strong></td>
							<td class="sa_num"><strong>{{ report.totals.sorted }}</strong></td>
							<td class="sa_num"><strong>{{ report.totals.moved }}</strong></td>
							<td class="sa_num"><strong>{{ report.totals.in_area }}</strong></td>
							<td></td>
						</tr>
					</tfoot>
				</table>
				<p class="ri_hint">As linhas destacadas foram triadas neste período e parte dos itens ainda está na área de triagem.</p>
			</div>
		</div>
	</AuthenticatedLayout>
</template>

<style scoped>
.sa_page {
	padding: 1em;
}
.sa_title {
	display: flex;
	align-items: center;
	gap: 1em;
}
.sa_toolbar {
	display: flex;
	gap: 0.75em;
	align-items: center;
	flex-wrap: wrap;
	margin: 0.75em 0;
}
.sa_wrap {
	overflow-x: auto;
}
.sa_num {
	text-align: right;
}
.sa_flag {
	background: rgba(245, 158, 11, 0.18);
}
</style>
