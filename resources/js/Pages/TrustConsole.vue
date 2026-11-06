<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- TrustConsole.vue

	Trust Console (/setup/trust, manage-trusts) — who this instance trusts and what each may do.
	Panel-style page (see the admin-page-style skill). One GET /json/trusts feeds everything: this instance's
	identity, the trusts with their grants, the permission catalog, locations (client apps belong to one), and
	the audit trail. Server half: TrustConsoleController; design: App\Services\Federation.

	A trust's grants are what the peer may do TO this instance (inbound). "How authenticated" is the pairing
	method plus the approver's name and date; a domain-verified badge appears once that check exists.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, reactive, ref } from 'vue';

defineProps({ breadcrumb: { type: Array } });

const data = ref(null);
const error = ref('');
const notice = ref('');
const busy = ref(false);

const kindLabels = { instance: 'Outra instância', print_client: 'Cliente de impressão', rstation: 'R Station', backup_client: 'Cliente de backup (RI Launcher)' };
const methodLabels = { pairing_code: 'Aprovado por administrador via código compartilhado', domain_verified: 'Aprovado por administrador, domínio verificado' };
const riskLabels = { low: 'baixo', medium: 'médio', high: 'alto' };
const trustStatusLabels = { approved: 'Aprovado', revoked: 'Revogado', pending: 'Pendente' };
const riskClass = { low: 'bg-green-100 text-green-800', medium: 'bg-amber-100 text-amber-800', high: 'bg-red-100 text-red-800' };

const identityForm = reactive({ name: '', base_url: '' });
const codeForm = reactive({ kind: 'print_client', name: '', kiosk_location_id: '', grants: ['print.share'] });
const newCode = ref(null);
const inviteForm = reactive({ grants: [] });
const newInvite = ref(null);
const acceptForm = reactive({ connection_code: '', grants: [] });
const copied = ref(false);
const editing = reactive({}); // trust id -> array of inbound keys being edited
const confirmRevoke = ref(null);
const confirmRegenerate = ref(false);
const regenerateText = ref('');

// A device (print client, R Station) belongs to a location; a backup client and another instance don't.
const isClientKind = computed(() => ['print_client', 'rstation'].includes(codeForm.kind));

function describe(code) {
	return (data.value?.permissions ?? []).find((p) => p.key === code);
}

function fail(e, fallback) {
	error.value = e.response?.data?.message || fallback;
}

function apply(payload) {
	data.value = payload;
	identityForm.name = payload.identity.name;
	identityForm.base_url = payload.identity.base_url ?? '';
}

async function load() {
	try {
		apply((await axios.get('/json/trusts')).data);
	} catch (e) {
		fail(e, 'Não foi possível carregar o Console de confiança.');
	}
}

async function run(fn, fallback) {
	error.value = '';
	notice.value = '';
	busy.value = true;
	try {
		await fn();
	} catch (e) {
		fail(e, fallback);
	} finally {
		busy.value = false;
	}
}

const saveIdentity = () => run(async () => {
	apply((await axios.put('/json/trusts/identity', { ...identityForm })).data);
	notice.value = 'Identidade salva.';
}, 'Não foi possível salvar.');

const regenerate = () => run(async () => {
	apply((await axios.post('/json/trusts/identity/regenerate', { confirm: regenerateText.value })).data);
	confirmRegenerate.value = false;
	regenerateText.value = '';
	notice.value = 'Nova chave gerada. Cada entidade confiável deverá aprovar esta instância novamente.';
}, 'Não foi possível gerar uma nova chave.');

function pickKind() {
	codeForm.grants = codeForm.kind === 'instance' ? [] : codeForm.kind === 'backup_client' ? ['operator.full_read'] : ['print.share'];
}

function toggle(list, key) {
	const i = list.indexOf(key);
	i === -1 ? list.push(key) : list.splice(i, 1);
}

const createCode = () => run(async () => {
	const body = { kind: codeForm.kind, name: codeForm.name || null, grants: codeForm.grants };
	if (isClientKind.value) body.kiosk_location_id = codeForm.kiosk_location_id || null;
	newCode.value = (await axios.post('/json/trusts/pairing-codes', body)).data;
	await load();
}, 'Não foi possível criar um código de vinculação.');

const createInvite = () => run(async () => {
	newInvite.value = (await axios.post('/json/trusts/invitations', { grants: inviteForm.grants })).data;
	copied.value = false;
	await load();
}, 'Não foi possível criar um convite.');

async function copyInvite() {
	try {
		await navigator.clipboard.writeText(newInvite.value.connection_code);
		copied.value = true;
	} catch {
		copied.value = false; // the code is selectable on screen as a fallback
	}
}

const acceptInvite = () => run(async () => {
	const res = (await axios.post('/json/trusts/accept-invitation', { ...acceptForm })).data;
	acceptForm.connection_code = '';
	acceptForm.grants = [];
	await load();
	notice.value = `Vinculado a ${res.record.name}.${res.warning ? ' ' + res.warning : ''}`;
}, 'Não foi possível usar esse código de conexão.');

const verifyDomain = (trust) => run(async () => {
	const res = (await axios.post(`/json/trusts/${trust.id}/verify-domain`)).data;
	await load();
	res.ok ? (notice.value = `${trust.name}: ${res.message}`) : (error.value = `${trust.name}: ${res.message}`);
}, 'Não foi possível verificar o endereço.');

const refreshGrants = (trust) => run(async () => {
	await axios.post(`/json/trusts/${trust.id}/refresh-grants`);
	await load();
	notice.value = `${trust.name}: solicitação enviada para atualizar as permissões disponíveis.`;
}, 'Não foi possível atualizar as permissões.');

function startEdit(trust) {
	editing[trust.id] = [...trust.inbound];
}

const saveGrants = (trust) => run(async () => {
	await axios.put(`/json/trusts/${trust.id}/grants`, { inbound: editing[trust.id] });
	delete editing[trust.id];
	await load();
	notice.value = `${trust.name}: permissões salvas.`;
}, 'Não foi possível salvar as permissões.');

const revoke = (trust) => run(async () => {
	if (confirmRevoke.value !== trust.id) {
		confirmRevoke.value = trust.id;
		return;
	}
	await axios.post(`/json/trusts/${trust.id}/revoke`);
	confirmRevoke.value = null;
	await load();
	notice.value = `A confiança com ${trust.name} foi revogada.`;
}, 'Não foi possível revogar.');

const when = (v) => (v ? new Date(v).toLocaleString() : null);

onMounted(load);
</script>

<template>
	<Head title="Console de confiança" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Console de confiança</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>
			<div v-if="!data && !error" class="text-gray-500">Carregando entidades confiáveis…</div>

			<template v-if="data">
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Esta instância</h2>
					<div v-if="data.identity.lost" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
						Não foi possível ler a chave desta instância — provavelmente ela foi restaurada em um servidor com uma chave de aplicação diferente.
						Nada poderá ser assinado ou aceito até que uma nova chave seja gerada; depois disso, cada entidade parceira deverá aprovar esta instância novamente.
					</div>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">Nome exibido para as entidades parceiras</span>
							<input v-model="identityForm.name" type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Endereço público</span>
							<input v-model="identityForm.base_url" type="url" placeholder="https://relief.example.org" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
					</div>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<div class="border rounded p-3">
							<div class="text-gray-500 text-xs">Impressão digital</div>
							<div class="font-mono">{{ data.identity.fingerprint }}</div>
						</div>
						<div class="border rounded p-3">
							<div class="text-gray-500 text-xs">ID da instância</div>
							<div class="font-mono text-xs break-all">{{ data.identity.uuid }}</div>
						</div>
					</div>
					<div class="text-xs text-gray-600">Chave pública <span class="font-mono break-all">{{ data.identity.public_key }}</span></div>
					<div class="flex items-center gap-4 flex-wrap">
						<PrimaryButton :disabled="busy" @click="saveIdentity">{{ busy ? 'Salvando…' : 'Salvar' }}</PrimaryButton>
						<template v-if="!confirmRegenerate">
							<button class="text-sm underline text-gray-600" @click="confirmRegenerate = true">Gerar nova chave…</button>
						</template>
						<template v-else>
							<input v-model="regenerateText" type="text" placeholder="Digite REGENERATE" class="border-gray-300 rounded-md shadow-sm text-sm" />
							<button :disabled="busy || regenerateText !== 'REGENERATE'" class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500 disabled:opacity-50" @click="regenerate">Confirmar — as entidades parceiras precisarão aprovar novamente</button>
							<button class="text-sm underline text-gray-600" @click="confirmRegenerate = false; regenerateText = ''">Cancelar</button>
						</template>
					</div>
					<p class="text-xs text-gray-500">A parte pública desta identidade é publicada em <span class="font-mono">/.well-known/ri-instance.json</span>. A chave privada é armazenada criptografada com a chave de aplicação deste servidor e nunca sai dele.</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Vincular novo dispositivo</h2>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">O que será vinculado</span>
							<select v-model="codeForm.kind" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" @change="pickKind">
								<option v-for="k in data.kinds" :key="k" :value="k">{{ kindLabels[k] ?? k }}</option>
							</select>
						</label>
						<label class="block">
							<span class="text-gray-700">Nome (opcional)</span>
							<input v-model="codeForm.name" type="text" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label v-if="isClientKind" class="block">
							<span class="text-gray-700">Local</span>
							<select v-model="codeForm.kiosk_location_id" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="">Escolha…</option>
								<option v-for="l in data.locations" :key="l.id" :value="l.id">{{ l.name }}</option>
							</select>
						</label>
					</div>
					<fieldset class="text-sm space-y-2">
						<legend class="text-gray-700">Permissões concedidas</legend>
						<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
							<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="codeForm.grants.includes(p.key)" @change="toggle(codeForm.grants, p.key)" />
							<span>
								{{ p.label }}
								<span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ riskLabels[p.risk] || p.risk }}</span>
								<span v-if="!p.built" class="ml-1 text-xs text-gray-400">(ainda não disponível)</span>
								<span class="block text-xs text-gray-500">{{ p.description }}</span>
							</span>
						</label>
					</fieldset>
					<PrimaryButton :disabled="busy" @click="createCode">{{ busy ? 'Processando…' : 'Criar código de vinculação' }}</PrimaryButton>
					<div v-if="newCode" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm space-y-1">
						<div>Insira este código no cliente em até {{ Math.round((new Date(newCode.expires_at) - Date.now()) / 60000) }} minutos. Ele só pode ser usado uma vez e não será exibido novamente.</div>
						<div class="font-mono text-2xl tracking-widest">{{ newCode.code }}</div>
					</div>
					<p class="text-xs text-gray-500">O cliente gera seu próprio par de chaves e envia somente a parte pública junto com este código. Quem tiver o código durante esses minutos poderá fazer a vinculação, então compartilhe-o somente com a pessoa que está usando o dispositivo.</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Conectar a outra instância</h2>
					<p class="text-sm text-gray-600">O administrador de cada lado aprova sua própria instância. Um deles cria um código de conexão; o outro o cola aqui ou em seu próprio Console de confiança.</p>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
						<div class="space-y-3">
							<h3 class="font-medium text-sm">Enviar convite</h3>
							<fieldset class="text-sm space-y-1">
								<legend class="text-gray-700">Permissões concedidas à outra instância</legend>
								<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
									<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="inviteForm.grants.includes(p.key)" @change="toggle(inviteForm.grants, p.key)" />
									<span>{{ p.label }} <span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ riskLabels[p.risk] || p.risk }}</span></span>
								</label>
							</fieldset>
							<PrimaryButton :disabled="busy" @click="createInvite">{{ busy ? 'Processando…' : 'Criar código de conexão' }}</PrimaryButton>
							<div v-if="newInvite" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm space-y-2">
								<div>Envie este código ao outro administrador. Ele só pode ser usado uma vez e expira em {{ Math.round((new Date(newInvite.expires_at) - Date.now()) / 60000) }} minutos.</div>
								<textarea readonly rows="3" class="w-full font-mono text-xs border-gray-300 rounded" :value="newInvite.connection_code" @focus="$event.target.select()"></textarea>
								<button class="text-sm underline" @click="copyInvite">{{ copied ? 'Copiado' : 'Copiar' }}</button>
							</div>
						</div>
						<div class="space-y-3">
							<h3 class="font-medium text-sm">Usar um código recebido</h3>
							<label class="block text-sm">
								<span class="text-gray-700">Código de conexão</span>
								<textarea v-model="acceptForm.connection_code" rows="3" placeholder="RIFED1-…" class="mt-1 block w-full font-mono text-xs border-gray-300 rounded-md shadow-sm"></textarea>
							</label>
							<fieldset class="text-sm space-y-1">
								<legend class="text-gray-700">Permissões concedidas à outra instância</legend>
								<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
									<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="acceptForm.grants.includes(p.key)" @change="toggle(acceptForm.grants, p.key)" />
									<span>{{ p.label }} <span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ riskLabels[p.risk] || p.risk }}</span></span>
								</label>
							</fieldset>
							<PrimaryButton :disabled="busy || !acceptForm.connection_code" @click="acceptInvite">{{ busy ? 'Conectando…' : 'Conectar' }}</PrimaryButton>
						</div>
					</div>
					<p class="text-xs text-gray-500">O código contém o endereço e a impressão digital da chave da instância que enviou o convite, para que você possa confirmar que chegou à instância correta. O endereço público desta instância precisa estar definido acima. Nada será compartilhado até que ambos os lados concedam permissões.</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Trusts</h2>
					<p v-if="!data.trusts.length" class="text-gray-400 text-sm">nenhuma ainda</p>
					<div v-for="t in data.trusts" :key="t.id" class="border rounded p-3 space-y-2 text-sm" :class="t.status !== 'approved' ? 'opacity-60' : ''">
						<div class="flex items-center justify-between gap-2 flex-wrap">
							<div>
								<span class="font-semibold">{{ t.name }}</span>
								<span class="ml-2 text-xs text-gray-500">{{ kindLabels[t.kind] ?? t.kind }}</span>
								<span v-if="t.status !== 'approved'" class="ml-2 text-xs rounded px-1.5 py-0.5 bg-gray-200 text-gray-700">{{ trustStatusLabels[t.status] || t.status }}</span>
								<span v-if="t.domain_verified_at" class="ml-2 text-xs rounded px-1.5 py-0.5 bg-green-100 text-green-800">domínio verificado</span>
							</div>
							<div v-if="t.status === 'approved'" class="flex items-center gap-3">
								<button class="inline-flex items-center px-3 py-1 rounded-md font-semibold text-xs uppercase tracking-widest text-white" :class="confirmRevoke === t.id ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'" :disabled="busy" @click="revoke(t)">
									{{ confirmRevoke === t.id ? 'Confirmar — deixará de funcionar imediatamente' : 'Revogar' }}
								</button>
								<button v-if="confirmRevoke === t.id" class="text-sm underline text-gray-600" @click="confirmRevoke = null">Cancelar</button>
							</div>
						</div>
						<div class="text-xs text-gray-600">
							{{ methodLabels[t.auth_method] ?? t.auth_method }}<template v-if="t.approved_by"> — {{ t.approved_by }}</template><template v-if="t.approved_at">, {{ when(t.approved_at) }}</template>
						</div>
						<div class="text-xs text-gray-600">
							Impressão digital <span class="font-mono">{{ t.fingerprint }}</span>
							<template v-if="t.base_url"> · {{ t.base_url }}</template>
							· Visto por último <template v-if="t.last_seen_at">{{ when(t.last_seen_at) }}<template v-if="t.last_seen_ip"> de {{ t.last_seen_ip }}</template></template><span v-else class="text-gray-400">nunca</span>
						</div>

						<div v-if="editing[t.id]" class="space-y-2">
							<label v-for="p in data.permissions" :key="p.key" class="flex items-start gap-2">
								<input type="checkbox" class="mt-1 rounded border-gray-300" :checked="editing[t.id].includes(p.key)" @change="toggle(editing[t.id], p.key)" />
								<span>{{ p.label }} <span class="ml-1 text-xs rounded px-1.5 py-0.5" :class="riskClass[p.risk]">{{ riskLabels[p.risk] || p.risk }}</span></span>
							</label>
							<div class="flex items-center gap-4">
									<PrimaryButton :disabled="busy" @click="saveGrants(t)">Salvar permissões</PrimaryButton>
									<button class="text-sm underline text-gray-600" @click="delete editing[t.id]">Cancelar</button>
							</div>
						</div>
						<div v-else class="flex items-center gap-2 flex-wrap">
							<span class="text-xs text-gray-500">Pode:</span>
							<span v-for="k in t.inbound" :key="k" class="text-xs rounded px-1.5 py-0.5" :class="riskClass[describe(k)?.risk ?? 'low']">{{ describe(k)?.label ?? k }}</span>
							<span v-if="!t.inbound.length" class="text-xs text-gray-400">nada</span>
							<button v-if="t.status === 'approved'" class="text-xs underline text-gray-600" @click="startEdit(t)">Editar</button>
						</div>
						<div v-if="t.kind === 'instance'" class="flex items-center gap-2 flex-wrap">
							<span class="text-xs text-gray-500">Podemos fazer:</span>
							<span v-for="k in t.outbound" :key="k" class="text-xs rounded px-1.5 py-0.5" :class="riskClass[describe(k)?.risk ?? 'low']">{{ describe(k)?.label ?? k }}</span>
							<span v-if="!t.outbound.length" class="text-xs text-gray-400">nada conhecido</span>
							<template v-if="t.status === 'approved'">
								<button class="text-xs underline text-gray-600" :disabled="busy" @click="refreshGrants(t)">Atualizar</button>
								<button class="text-xs underline text-gray-600" :disabled="busy" @click="verifyDomain(t)">Verificar domínio</button>
							</template>
						</div>
					</div>
					<p class="text-xs text-gray-500">As alterações de permissões e revogações entram em vigor na próxima solicitação da entidade parceira.</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-2">
					<h2 class="text-lg font-semibold">Eventos recentes de confiança</h2>
					<p v-if="!data.audit.length" class="text-gray-400 text-sm">nenhum ainda</p>
					<ul class="text-xs text-gray-600 space-y-1">
						<li v-for="a in data.audit" :key="a.id"><span class="font-mono">{{ when(a.created_at) }}</span> — {{ a.event.replace('_', ' ') }}</li>
					</ul>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
