<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- EmailSettings.vue

	Outgoing email settings (permission: admin-system): which mail service to
	use, the From address/name, the Resend API key or SMTP server, and who is
	emailed about new feedback reports — plus a test-email button. A blank
	field falls back to the server's .env value, shown as the placeholder.
	Secrets are write-only: the server only says whether one is saved.
	Panel-style page per the admin-page-style skill.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, reactive, ref } from 'vue';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

const MAILER_LABELS = { resend: 'Resend', smtp: 'Servidor SMTP', log: 'Apenas registrar (nenhum e-mail é enviado)' };

const error = ref('');
const notice = ref('');
const loaded = ref(false);
const saving = ref(false);
const savedAt = ref('');
const testing = ref(false);
const testTo = ref('');

const status = ref(null); // last server response: settings, defaults, mailers
const form = reactive({});
const clean = ref('');

function fill(data) {
	status.value = data;
	const s = data.settings;
	Object.assign(form, {
		mailer: s.mailer ?? '',
		from_address: s.from_address ?? '',
		from_name: s.from_name ?? '',
		resend_key: '',
		clear_resend_key: false,
		smtp_host: s.smtp_host ?? '',
		smtp_port: s.smtp_port ?? '',
		smtp_username: s.smtp_username ?? '',
		smtp_password: '',
		clear_smtp_password: false,
		feedback_notify_emails: s.feedback_notify_emails ?? '',
	});
	clean.value = JSON.stringify(form);
}

const dirty = computed(() => loaded.value && JSON.stringify(form) !== clean.value);
const defaults = computed(() => status.value?.defaults ?? {});
const activeMailer = computed(() => form.mailer || defaults.value.mailer);

function placeholder(key) {
	const value = defaults.value[key];
	return value ? `Padrão do servidor: ${value}` : 'Não configurado';
}

// Where the key/password in use comes from, for the status line under each secret field.
function secretSource(key) {
	const s = status.value?.settings ?? {};
	if (form['clear_' + key]) return defaults.value[key + '_set'] ? 'Será usado o valor do arquivo .env do servidor' : 'Será removido';
	if (form[key]) return 'Um novo valor será salvo';
	if (s[key + '_set']) return 'Salvo aqui';
	if (defaults.value[key + '_set']) return 'Usando o valor do arquivo .env do servidor';
	return 'Nenhum valor configurado';
}

async function load() {
	try {
		const response = await axios.get('/json/mail-settings');
		fill(response.data);
		testTo.value = response.data.test_to ?? '';
		loaded.value = true;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar as configurações de e-mail.';
	}
}

async function save() {
	error.value = '';
	notice.value = '';
	saving.value = true;
	try {
		const payload = { ...form, smtp_port: form.smtp_port === '' ? null : Number(form.smtp_port) };
		const response = await axios.put('/json/mail-settings', payload);
		fill(response.data);
		savedAt.value = 'Salvo às ' + new Date().toLocaleTimeString(document.documentElement.lang || 'pt-BR');
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível salvar as configurações de e-mail.';
	} finally {
		saving.value = false;
	}
}

async function sendTest() {
	error.value = '';
	notice.value = '';
	testing.value = true;
	try {
		const response = await axios.post('/json/mail-settings/test', { to: testTo.value });
		notice.value = response.data.message;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível enviar o e-mail de teste.';
	} finally {
		testing.value = false;
	}
}

onMounted(load);
</script>

<template>
	<Head title="Configurações de e-mail" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Configurações de e-mail</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<p v-if="!loaded && !error" class="text-gray-500">Carregando configurações de e-mail…</p>

			<template v-if="loaded">
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Envio de e-mails</h2>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<label class="block">
							<span class="text-gray-700">Enviar e-mails usando</span>
							<select v-model="form.mailer" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option value="">Padrão do servidor ({{ MAILER_LABELS[defaults.mailer] ?? defaults.mailer }})</option>
								<option v-for="m in status.mailers" :key="m" :value="m">{{ MAILER_LABELS[m] ?? m }}</option>
							</select>
						</label>
						<div class="hidden sm:block"></div>
						<label class="block">
							<span class="text-gray-700">Endereço do remetente</span>
							<input v-model="form.from_address" type="email" :placeholder="placeholder('from_address')"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Nome do remetente</span>
							<input v-model="form.from_name" type="text" :placeholder="placeholder('from_name')"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>

						<label v-if="activeMailer === 'resend'" class="block sm:col-span-2">
							<span class="text-gray-700">Resend API key</span>
							<input v-model="form.resend_key" type="password" autocomplete="new-password"
								placeholder="Deixe em branco para manter a chave atual" :disabled="form.clear_resend_key"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm font-mono" />
							<span class="mt-1 flex flex-wrap items-center gap-x-4 text-xs text-gray-600">
								<span>{{ secretSource('resend_key') }}</span>
								<label v-if="status.settings.resend_key_set" class="inline-flex items-center gap-1">
									<input v-model="form.clear_resend_key" type="checkbox" class="rounded border-gray-300" />
									Remover a chave salva
								</label>
							</span>
						</label>

						<template v-if="activeMailer === 'smtp'">
							<label class="block">
								<span class="text-gray-700">SMTP server</span>
								<input v-model="form.smtp_host" type="text" :placeholder="placeholder('smtp_host')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">Porta</span>
								<input v-model="form.smtp_port" type="number" min="1" max="65535" :placeholder="placeholder('smtp_port')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">Usuário</span>
								<input v-model="form.smtp_username" type="text" autocomplete="off" :placeholder="placeholder('smtp_username')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<label class="block">
								<span class="text-gray-700">Password</span>
								<input v-model="form.smtp_password" type="password" autocomplete="new-password"
									placeholder="Deixe em branco para manter a senha atual" :disabled="form.clear_smtp_password"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
								<span class="mt-1 flex flex-wrap items-center gap-x-4 text-xs text-gray-600">
									<span>{{ secretSource('smtp_password') }}</span>
									<label v-if="status.settings.smtp_password_set" class="inline-flex items-center gap-1">
										<input v-model="form.clear_smtp_password" type="checkbox" class="rounded border-gray-300" />
										Remover a senha salva
									</label>
								</span>
							</label>
						</template>
					</div>
					<p class="text-xs text-gray-500">
						Um campo em branco usa o valor do arquivo <span class="font-mono">.env</span> do servidor, exibido em cinza.
						<template v-if="activeMailer === 'resend'">
							O endereço do remetente deve pertencer a um domínio verificado na conta do Resend associada à chave.
						</template>
						<template v-if="activeMailer === 'smtp'">
							A porta 465 usa SSL; nas demais portas, a conexão usa TLS quando oferecido pelo servidor.
						</template>
						As chaves e senhas são armazenadas criptografadas e não são exibidas novamente após serem salvas.
						Se um backup for restaurado em outro servidor, elas não serão incluídas e precisarão ser informadas novamente.
					</p>
				</section>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Destinatários dos relatos</h2>
					<label class="block text-sm">
						<span class="text-gray-700">Enviar uma notificação para estes endereços quando alguém relatar um erro ou sugerir uma melhoria</span>
						<input v-model="form.feedback_notify_emails" type="text" :placeholder="placeholder('feedback_notify_emails')"
							class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
					</label>
					<p class="text-xs text-gray-500">Separe os endereços com vírgulas. Se nenhum for informado, os relatos continuarão sendo salvos, mas não serão enviados por e-mail.</p>
				</section>

				<div class="flex items-center gap-4">
					<PrimaryButton :disabled="saving || !dirty" @click="save">{{ saving ? 'Salvando…' : 'Salvar' }}</PrimaryButton>
					<span v-if="savedAt && !dirty" class="text-sm text-gray-600">{{ savedAt }}</span>
					<span v-if="dirty" class="text-sm text-amber-700">Alterações não salvas</span>
				</div>

				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Enviar e-mail de teste</h2>
					<div class="flex flex-wrap items-end gap-4 text-sm">
						<label class="block grow">
							<span class="text-gray-700">Enviar para</span>
							<input v-model="testTo" type="email" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<PrimaryButton :disabled="testing || dirty || !testTo" @click="sendTest">
							{{ testing ? 'Enviando…' : 'Enviar teste' }}
						</PrimaryButton>
					</div>
					<p class="text-xs text-gray-500">
						Usa as configurações salvas{{ dirty ? ' — salve suas alterações primeiro' : '' }}. Se o serviço de e-mail
						recusar a mensagem, o erro correspondente será exibido acima.
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
