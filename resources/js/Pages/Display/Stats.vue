<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<script>
import DisplayLayout from '@/Layouts/DisplayLayout.vue';
import { Head } from '@inertiajs/vue3';
import PeriodStatCard from '@/Components/Dashboard/PeriodStatCard.vue';
import BarBreakdownCard from '@/Components/Dashboard/BarBreakdownCard.vue';
import axios from 'axios';
import { itemCategoryLabel } from '@/labels';

// An always-on stats sign for an R Station (or any screen): the Situation Report ('sitrep') or the
// warehouse dashboard ('dashboard') with no menus, refreshing itself. Data comes from
// /json/display/<mode>, open to a paired device with the matching Function — see EnsureDeviceAccess.
const REFRESH_MS = 60 * 1000;
const DONATION_STAGE_LABELS = { Received: 'Recebida', Sorting: 'Em triagem', Complete: 'Concluída' };
const ORDER_STAGE_LABELS = { 'New Order': 'Novo pedido', Filling: 'Em separação', Filled: 'Separado', Shipped: 'Enviado' };

export default {
	components: { DisplayLayout, Head, PeriodStatCard, BarBreakdownCard },
	props: {
		mode: { type: String, default: 'sitrep' },
	},
	data() {
		return { data: null, error: null, timer: null, clockTimer: null, now: new Date() };
	},
	computed: {
		title() {
			return this.mode === 'dashboard' ? 'Estatísticas do armazém' : 'Relatório de situação';
		},
		donationPipelineRows() {
			return Object.entries(DONATION_STAGE_LABELS).map(([key, label]) => ({ label, value: this.data.pipeline.donations[key] || 0 }));
		},
		orderPipelineRows() {
			return Object.entries(ORDER_STAGE_LABELS).map(([key, label]) => ({ label, value: this.data.pipeline.orders[key] || 0 }));
		},
		countyRows() {
			return this.data.county_breakdown.map((c) => ({ label: c.county, value: c.count }));
		},
		categoryRows() {
			return this.data.inventory_summary.top_categories.map((c) => ({ label: itemCategoryLabel(c.category), value: c.units }));
		},
	},
	methods: {
		async fetchData() {
			try {
				this.data = (await axios.get(`/json/display/${this.mode}`)).data;
				this.error = null;
			} catch (e) {
				// Keep showing the last good numbers across a Wi-Fi drop; only say so if there are none.
				// A 403 means the device's session ended (revoked, re-paired, Function changed): the
				// launcher gets a fresh one on the next restart, so just report it.
				this.error = e.response?.status === 403
					? 'Esta tela não está mais autorizada — reinicie o R Station ou entre novamente.'
					: 'Não foi possível acessar o servidor — tentando novamente.';
			}
		},
	},
	created() {
		this.fetchData();
		this.timer = setInterval(this.fetchData, REFRESH_MS);
		this.clockTimer = setInterval(() => (this.now = new Date()), 30 * 1000);
	},
	beforeUnmount() {
		clearInterval(this.timer);
		clearInterval(this.clockTimer);
	},
};
</script>

<template>
	<Head :title="title" />
	<DisplayLayout>
		<div class="ds_container">
			<div class="ds_topbar">
				<h1>{{ title }}</h1>
				<span class="ds_time">{{ now.toLocaleDateString('pt-BR') }} {{ now.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) }}</span>
			</div>

			<p v-if="error" class="ds_error">{{ error }}</p>
			<p v-if="!data && !error" class="ds_loading">Carregando...</p>

			<div v-if="data" class="ds_grid">
				<PeriodStatCard title="Pedidos atendidos" :counts="data.orders_fulfilled" :trend="data.orders_trend" />
				<PeriodStatCard title="Doações concluídas" :counts="data.donations_completed" :trend="data.donations_trend" />
				<BarBreakdownCard title="Doações em andamento" :rows="donationPipelineRows" />
				<BarBreakdownCard title="Pedidos em andamento" :rows="orderPipelineRows" />
				<BarBreakdownCard title="Pedidos por condado" :rows="countyRows" empty-text="Nenhum pedido registrado ainda." />
				<BarBreakdownCard title="Estoque por categoria" :rows="categoryRows" empty-text="Nenhum item em estoque ainda." />
				<div class="ds_card">
					<h3>Estoque disponível</h3>
					<div class="ds_inv">
						<div><span class="ds_inv_value">{{ data.inventory_summary.item_types_with_stock }}</span><span class="ds_inv_label">Tipos de item em estoque</span></div>
						<div><span class="ds_inv_value">{{ data.inventory_summary.total_units_on_hand }}</span><span class="ds_inv_label">Total de unidades disponíveis</span></div>
					</div>
				</div>
			</div>
		</div>
	</DisplayLayout>
</template>

<style scoped>
.ds_container {
	padding: 20px 24px 28px;
}
.ds_topbar {
	display: flex;
	align-items: baseline;
	justify-content: space-between;
	margin-bottom: 14px;
}
.ds_topbar h1 {
	font-size: 1.8rem;
	font-weight: bold;
	margin: 0;
}
.ds_time {
	font-size: 1.1rem;
	color: #6b7280;
}
.ds_grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
	gap: 18px;
}
.ds_card {
	background: #fff;
	border: 1px solid #e5e7eb;
	border-radius: 10px;
	padding: 16px 18px;
}
.ds_card h3 {
	font-size: 1rem;
	font-weight: bold;
	margin: 0 0 12px 0;
}
.ds_inv {
	display: flex;
	gap: 32px;
}
.ds_inv_value {
	display: block;
	font-size: 2.2rem;
	font-weight: bold;
	color: #1e3a8a;
}
.ds_inv_label {
	display: block;
	font-size: 0.85rem;
	color: #888;
}
.ds_error {
	color: #b91c1c;
	margin-bottom: 10px;
}
.ds_loading {
	color: #6b7280;
}
</style>
