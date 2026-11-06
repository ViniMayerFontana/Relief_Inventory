<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- TestingTools.vue

	Setup > Testing Tools (/setup/testing, admin-system). Two things for finding formatting and performance
	problems before real data exists:

	  Warehouse simulator   progress of a run (the first-run wizard's "Simulate a year" option lands here), and a
	                        Start button while the instance is still empty. The simulator itself is
	                        App\Services\Simulator\WarehouseSimulator; it runs detached, so this page only polls
	                        GET /json/testing/status.
	  Slow queries          the app-side slow-query log plus MariaDB's own slow log (when readable), grouped by
	                        statement shape (worst total time first) or listed newest first. Server half:
	                        TestingToolsController / App\Services\SlowQueryLog.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue';

defineProps({
	breadcrumb: { type: Array },
});

const status = ref(null);
const error = ref('');
const notice = ref('');
const starting = ref(false);
let timer = null;

const form = reactive({ days: 365, orders: 1200, errors: 4, seed: '' });

const sim = computed(() => status.value?.simulation || { state: 'none' });
const running = computed(() => sim.value.state === 'running');
const percent = computed(() => (sim.value.total ? Math.min(100, Math.round((100 * (sim.value.day || 0)) / sim.value.total)) : 0));
const summary = computed(() => sim.value.summary || null);

const slow = reactive({ view: 'requests', source: 'all', loading: false, loaded: false, entries: [], groups: [], requests: [], db: { available: null, message: null } });

async function loadStatus() {
	try {
		const { data } = await axios.get('/json/testing/status');
		const wasRunning = running.value;
		status.value = data;
		if (wasRunning && data.simulation?.state === 'done') {
			notice.value = 'A simulação terminou. O painel, os relatórios e as listas agora têm um ano de dados.';
		}
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar o status.';
	}
}

async function startSimulation() {
	error.value = '';
	notice.value = '';
	starting.value = true;
	try {
		await axios.post('/json/testing/simulation', {
			days: form.days,
			orders: form.orders,
			errors: form.errors,
			seed: form.seed === '' ? null : Number(form.seed),
		});
		await loadStatus();
	} catch (e) {
		error.value = e.response?.data?.message || Object.values(e.response?.data?.errors || {})[0]?.[0] || 'Não foi possível iniciar a simulação.';
	} finally {
		starting.value = false;
	}
}

async function loadSlow() {
	slow.loading = true;
	try {
		const { data } = await axios.get('/json/testing/slow-queries', { params: { source: slow.source } });
		Object.assign(slow, { entries: data.entries, groups: data.groups, requests: data.requests, db: data.db, loaded: true });
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar o log de consultas lentas.';
	} finally {
		slow.loading = false;
	}
}

async function clearSlow() {
	await axios.delete('/json/testing/slow-queries');
	await loadSlow();
}

const fmtMs = (ms) => (ms >= 1000 ? (ms / 1000).toFixed(2) + ' s' : Math.round(ms) + ' ms');
const fmtKb = (b) => (b >= 1048576 ? (b / 1048576).toFixed(1) + ' MB' : Math.round(b / 1024) + ' KB');
const fmtTime = (t) => (t ? t.replace('T', ' ').slice(0, 19) : '');
const labels = {
	donations: 'Doações', orders: 'Pedidos', order_lines: 'Linhas de pedido', ledger_rows: 'Movimentações de estoque',
	pallets: 'Paletes e contêineres', pallet_history_rows: 'Registros do histórico de paletes', people: 'Doadores, entidades parceiras e contatos',
	drivers: 'Motoristas', donation_offers: 'Ofertas de doação', locations: 'Locais', item_types_in_play: 'Tipos de item em uso',
};

onMounted(async () => {
	await loadStatus();
	loadSlow();
	// Poll faster while a run is going; the page costs one tiny request otherwise.
	timer = setInterval(() => {
		if (running.value || document.visibilityState === 'visible') loadStatus();
	}, 3000);
});
onUnmounted(() => clearInterval(timer));
</script>

<template>
	<Head title="Ferramentas de teste" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-5xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Ferramentas de teste</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<p v-if="!status" class="text-gray-500">Carregando…</p>

			<template v-else>
				<!-- Simulator -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Simulador de armazém</h2>
					<p class="text-sm text-gray-600">
						Preenche uma instância nova com atividades fictícias — doações, triagem, armazenamento, pedidos de entidades parceiras, separação,
						expedição e revisão de conhecimentos de embarque, dia a dia — para que telas, relatórios e cadastros possam ser testados com um volume realista.
						O estoque nunca fica negativo, exceto por algumas separações excedentes adicionadas intencionalmente para testar como o aplicativo reage.
					</p>

					<div v-if="running" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm space-y-2">
						<div>{{ sim.message || 'Em execução…' }} (dia {{ sim.day || 0 }} de {{ sim.total }})</div>
						<div class="h-2 bg-blue-100 rounded overflow-hidden"><div class="h-2 bg-blue-600 transition-all" :style="{ width: percent + '%' }"></div></div>
						<div class="text-xs">Isso leva um ou dois minutos. Você pode sair desta página; os dados aparecerão de uma só vez quando a execução terminar.</div>
					</div>

					<div v-else-if="sim.state === 'failed'" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
						A simulação falhou e nada foi salvo: {{ sim.error }}
					</div>

					<div v-else-if="sim.state === 'done' && summary" class="space-y-3">
						<div class="rounded bg-green-50 border border-green-300 text-green-800 px-4 py-3 text-sm">
							{{ summary.days }} dias simulados (de {{ summary.from }} a {{ summary.to }}) em {{ summary.seconds }} s. Semente: <span class="font-mono">{{ summary.seed }}</span>.
							{{ summary.fill_rate_percent }}% das unidades solicitadas foram separadas.
						</div>
						<div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
							<div v-for="(n, key) in summary.counts" :key="key" class="border rounded p-3">
								<div class="text-gray-500 text-xs">{{ labels[key] || key }}</div>
								<div class="text-lg font-semibold">{{ n.toLocaleString() }}</div>
							</div>
						</div>
						<div class="grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm">
							<div class="border rounded p-3">
								<div class="text-gray-500 text-xs mb-1">Doações por status</div>
								<div v-for="(n, name) in summary.donation_statuses" :key="name" class="flex justify-between"><span>{{ name }}</span><span class="font-mono">{{ n }}</span></div>
							</div>
							<div class="border rounded p-3">
								<div class="text-gray-500 text-xs mb-1">Pedidos por status</div>
								<div v-for="(n, name) in summary.order_statuses" :key="name" class="flex justify-between"><span>{{ name }}</span><span class="font-mono">{{ n }}</span></div>
							</div>
						</div>
						<div v-if="summary.injected_errors?.length">
							<h3 class="font-semibold text-sm mb-1">Erros de estoque negativo adicionados intencionalmente</h3>
							<div class="overflow-x-auto">
								<table class="min-w-full text-sm">
									<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">Data</th><th class="pr-4">Pedido</th><th class="pr-4">Item</th><th class="pr-4 text-right">Em estoque</th><th class="pr-4 text-right">Separado</th><th class="text-right">Restante</th></tr></thead>
									<tbody>
										<tr v-for="e in summary.injected_errors" :key="e.order_id + '-' + e.item_id" class="border-t">
											<td class="pr-4 py-1">{{ e.date }}</td><td class="pr-4">#{{ e.order_id }}</td><td class="pr-4">{{ e.item }}</td>
											<td class="pr-4 text-right font-mono">{{ e.on_hand_before }}</td><td class="pr-4 text-right font-mono">{{ e.picked }}</td><td class="text-right font-mono text-red-700">{{ e.on_hand_after }}</td>
										</tr>
									</tbody>
								</table>
							</div>
							<p class="text-xs text-gray-500 mt-1">Doações posteriores podem ter elevado o estoque desses itens acima de zero; confira o Relatório de estoque para ver como o aplicativo os exibe.</p>
						</div>
					</div>

					<div v-else-if="status.can_start" class="space-y-4">
						<div class="grid grid-cols-1 sm:grid-cols-4 gap-4 text-sm">
							<label class="block"><span class="text-gray-700">Dias simulados</span>
								<input v-model.number="form.days" type="number" min="7" max="1500" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
							<label class="block"><span class="text-gray-700">Pedidos (aprox.)</span>
								<input v-model.number="form.orders" type="number" min="1" max="20000" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
							<label class="block"><span class="text-gray-700">Erros de estoque negativo</span>
								<input v-model.number="form.errors" type="number" min="0" max="50" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
							<label class="block"><span class="text-gray-700">Semente (opcional)</span>
								<input v-model="form.seed" type="number" min="1" placeholder="aleatória" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" /></label>
						</div>
						<PrimaryButton :disabled="starting" @click="startSimulation">{{ starting ? 'Iniciando…' : 'Iniciar simulação' }}</PrimaryButton>
						<p class="text-xs text-gray-500">
							Os dados simulados não podem ser removidos pelo aplicativo. Um ano com {{ form.orders.toLocaleString() }} pedidos gera aproximadamente {{ (form.orders * 10).toLocaleString() }} movimentações de estoque e leva cerca de um minuto.
						</p>
					</div>

					<div v-else class="rounded bg-gray-50 border text-gray-700 px-4 py-3 text-sm">{{ status.blocked_reason }}</div>
				</section>

				<!-- Slow queries -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<div class="flex flex-wrap items-center justify-between gap-2">
						<h2 class="text-lg font-semibold">Consultas lentas</h2>
						<div class="flex flex-wrap items-center gap-3 text-sm">
							<select v-model="slow.view" class="border-gray-300 rounded-md shadow-sm text-sm">
								<option value="requests">Páginas lentas (solicitações completas)</option>
								<option value="grouped">Consultas agrupadas por instrução</option>
								<option value="recent">Consultas, mais recentes primeiro</option>
							</select>
							<select v-model="slow.source" @change="loadSlow" class="border-gray-300 rounded-md shadow-sm text-sm">
								<option value="all">Aplicativo + MariaDB</option>
								<option value="app">Somente log do aplicativo</option>
								<option value="db">Somente log do MariaDB</option>
							</select>
							<button type="button" class="underline text-blue-700" @click="loadSlow">{{ slow.loading ? 'Carregando…' : 'Atualizar' }}</button>
							<button type="button" class="underline text-gray-600" @click="clearSlow">Limpar log do aplicativo</button>
						</div>
					</div>

					<div v-if="!status.slow_log.enabled" class="rounded bg-amber-50 border border-amber-300 text-amber-900 px-4 py-3 text-sm">
						O registro no aplicativo está desativado. Defina <span class="font-mono">RI_SLOW_QUERY_MS=250</span> (milissegundos) no ambiente e reinicie para registrar todas as consultas mais lentas que esse limite,
						junto com a página ou o comando que as executou. A configuração Docker ativa isso por padrão.
					</div>
					<div v-else class="text-xs text-gray-500">Registrando consultas com duração superior a {{ status.slow_log.threshold_ms }} ms.</div>

					<div v-if="slow.db.available === false" class="rounded bg-gray-50 border text-gray-700 px-4 py-3 text-sm">MariaDB slow log: {{ slow.db.message }}</div>

					<p v-if="slow.loaded && slow.view === 'requests' && !slow.requests.length" class="text-gray-400 text-sm">Nenhuma página lenta, com muitas consultas ou pesada foi registrada. Use o aplicativo (ou execute relatórios) e atualize.</p>
					<p v-else-if="slow.loaded && slow.view !== 'requests' && !slow.entries.length" class="text-gray-400 text-sm">Nenhuma consulta lenta foi registrada. Use o aplicativo (ou execute relatórios) e atualize.</p>

					<div v-else-if="slow.view === 'requests'" class="overflow-x-auto">
						<table class="min-w-full text-sm">
							<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">Página / endpoint</th><th class="pr-4 text-right">Pior</th><th class="pr-4 text-right">Média</th><th class="pr-4 text-right">Vezes</th><th class="pr-4 text-right">No banco de dados</th><th class="pr-4 text-right">Consultas</th><th class="text-right">Resposta</th></tr></thead>
							<tbody>
								<tr v-for="r in slow.requests" :key="r.source" class="border-t align-top">
									<td class="pr-4 py-2 font-mono text-xs break-all">{{ r.source }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(r.max_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(r.avg_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono">{{ r.count }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(r.max_db_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono">{{ r.max_queries }}</td>
									<td class="py-2 text-right font-mono whitespace-nowrap">{{ fmtKb(r.max_bytes) }}</td>
								</tr>
							</tbody>
						</table>
						<p class="text-xs text-gray-500 mt-2">
							Páginas que levaram pelo menos {{ status.slow_log.request_ms }} ms, executaram {{ status.slow_log.request_queries }}+ consultas ou enviaram {{ fmtKb(status.slow_log.request_bytes) }}+.
							Uma "Resposta" grande com pouco tempo "No banco de dados" indica uma lista que envia muitos dados de uma vez; um número alto de "Consultas" significa que uma consulta foi repetida para cada linha.
						</p>
					</div>

					<div v-else-if="slow.view === 'grouped'" class="overflow-x-auto">
						<table class="min-w-full text-sm">
							<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">Total</th><th class="pr-4 text-right">Quantidade</th><th class="pr-4 text-right">Média</th><th class="pr-4 text-right">Máximo</th><th class="pr-4">Consulta e origem</th></tr></thead>
							<tbody>
								<tr v-for="g in slow.groups" :key="g.sql" class="border-t align-top">
									<td class="pr-4 py-2 font-mono whitespace-nowrap">{{ fmtMs(g.total_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono">{{ g.count }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(g.avg_ms) }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(g.max_ms) }}</td>
									<td class="py-2">
										<div class="font-mono text-xs break-all">{{ g.sql }}</div>
										<div class="text-xs text-gray-500 mt-1">{{ g.sources.join(' · ') }}<span v-if="g.rows_examined"> · até {{ g.rows_examined.toLocaleString() }} linhas examinadas</span></div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>

					<div v-else class="overflow-x-auto">
						<table class="min-w-full text-sm">
							<thead><tr class="text-left text-gray-500 text-xs"><th class="pr-4">Quando</th><th class="pr-4 text-right">Duração</th><th class="pr-4">Origem</th><th class="pr-4">Consulta</th></tr></thead>
							<tbody>
								<tr v-for="(e, i) in slow.entries.slice(0, 100)" :key="i" class="border-t align-top">
									<td class="pr-4 py-2 font-mono text-xs whitespace-nowrap">{{ fmtTime(e.time) }}</td>
									<td class="pr-4 py-2 text-right font-mono whitespace-nowrap">{{ fmtMs(e.ms) }}</td>
									<td class="pr-4 py-2 text-xs">{{ e.origin === 'app' ? e.source : 'MariaDB' + (e.rows_examined ? ' · ' + e.rows_examined.toLocaleString() + ' linhas' : '') }}</td>
									<td class="py-2 font-mono text-xs break-all">{{ e.sql }}</td>
								</tr>
							</tbody>
						</table>
					</div>

					<p class="text-xs text-gray-500">
						As instruções são agrupadas com números e valores entre aspas removidos, para que a mesma consulta com IDs diferentes seja contada como uma só. O log do aplicativo nunca registra valores de consulta.
						Linha de comando: <span class="font-mono">php artisan slowlog:show</span> (adicione <span class="font-mono">--recent</span> para ver primeiro as mais recentes).
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
