<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- InstanceAdmin.vue

	Instance Admin (/setup/instance) — what belongs to the whole instance rather than one warehouse. Instance
	administrators only (route middleware `instance-admin`; the JSON half is /json/instance/*, which reuses
	SystemController's actions). Tabs:

	  Updates & Mode           Software version / update (Docker: through the host-side updater, see InstanceUpdate;
	                           systemd: the DEPRECATED in-app updater) and Offline mode.
	  Full Instance Backups    One zip of every warehouse plus the control and accounts schemas: the schedule (off until turned
	                           on), the list, Back up now and download (InstanceBackupController). The provisioner container
	                           makes them, since it alone holds the database administrator's password; this page only writes
	                           fixed requests for it. Each zip holds the warehouse keys sealed to the instance's recovery key
	                           (the panel at the top of the tab makes it and shows the private half once; see dev/notes/BACKUPS.md).
	  Warehouses               The warehouse:* commands as buttons (InstanceWarehouseController): list, create, edit, suspend /
	                           maintenance / activate / resume, archive, remove, setup codes, hostnames. Every change asks for
	                           the person's password again. Removal waits 30 days after archiving here (the artisan command
	                           removes at once).

	`runtime` ('systemd' | 'docker') comes from config('system.runtime'). During an update the site enters
	maintenance mode, so status polls start failing with 503 — expected, and shown as progress rather than an error.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import axios from 'axios';
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue';

const props = defineProps({
	breadcrumb: { type: Array },
	runtime: { type: String, default: 'systemd' },
});

const docker = computed(() => props.runtime === 'docker');

// ?tab=backups opens that tab directly (the recovery-key banner links there).
const tab = ref(['updates', 'warehouses', 'backups'].includes(new URLSearchParams(location.search).get('tab')) ? new URLSearchParams(location.search).get('tab') : 'updates');
const status = ref(null);
const error = ref('');
const notice = ref('');
const checking = ref(false);
const updating = ref(false);
const confirmingUpdate = ref(false);
const inMaintenance = ref(false);
const savingOfflineMode = ref(false);

// Docker: the self-update flag the host-side updater works from (status.docker_update).
const dockerUpdate = computed(() => status.value?.docker_update ?? null);
const dockerBusy = computed(() => ['requested', 'checking', 'pulling', 'restarting'].includes(dockerUpdate.value?.state));
const requestingDocker = ref(false);
const confirmingDockerUpdate = ref(false);
const dockerStateText = {
	requested: 'Aguardando o serviço de atualização…',
	checking: 'Procurando uma nova versão…',
	pulling: 'Baixando a nova versão…',
	restarting: 'Instalando. O site ficará indisponível por alguns minutos e esta página voltará automaticamente.',
};
let dockerTimer = null;

let pollTimer = null;

async function fetchStatus() {
	const response = await axios.get('/json/instance/status');
	status.value = response.data;
	// An update left running (or just finished) when the page loaded
	if (response.data.update_status?.state === 'running' && !updating.value) {
		updating.value = true;
		startPolling();
	} else if (response.data.update_status?.state === 'stalled') {
		error.value = `Atualização interrompida: ${response.data.update_status.message}`;
	}
	if (response.data.docker_update) {
		if (dockerBusy.value) startDockerPolling();
		else stopDockerPolling();
	}
	return response.data;
}

async function requestDockerUpdate(action) {
	if (action === 'update' && !confirmingDockerUpdate.value) {
		confirmingDockerUpdate.value = true;
		return;
	}
	confirmingDockerUpdate.value = false;
	requestingDocker.value = true;
	error.value = '';
	notice.value = '';
	try {
		const response = await axios.post(action === 'update' ? '/json/instance/update' : '/json/instance/check-updates');
		status.value.docker_update = response.data.docker_update;
		startDockerPolling();
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível enviar a solicitação.';
	} finally {
		requestingDocker.value = false;
	}
}

// Poll while a request is open. The app is down while it restarts, so a failed poll is expected, not an error.
function startDockerPolling() {
	if (dockerTimer) return;
	let wasBusy = true;
	dockerTimer = setInterval(async () => {
		try {
			const data = await fetchStatus();
			const du = data.docker_update;
			if (du && !dockerBusy.value && wasBusy) {
				wasBusy = false;
				if (du.state === 'failed') error.value = `Falha na atualização: ${du.message}`;
				else if (du.state === 'stalled') error.value = du.message;
				else notice.value = du.message || 'Concluído.';
			}
		} catch (e) {
			// offline while restarting — keep polling
		}
	}, 4000);
}

function stopDockerPolling() {
	if (dockerTimer) {
		clearInterval(dockerTimer);
		dockerTimer = null;
	}
}

async function checkForUpdates() {
	checking.value = true;
	error.value = '';
	notice.value = '';
	try {
		const response = await axios.post('/json/instance/check-updates');
		status.value.version = response.data.version;
		notice.value = response.data.version.behind === 0
			? 'Você está usando a versão mais recente.'
			: `Atualização disponível: ${response.data.version.behind} novo(s) commit(s).`;
	} catch (e) {
		error.value = e.response?.data?.message || 'Falha ao verificar atualizações.';
	} finally {
		checking.value = false;
	}
}

async function startUpdate() {
	if (!confirmingUpdate.value) {
		confirmingUpdate.value = true;
		return;
	}
	confirmingUpdate.value = false;
	updating.value = true;
	error.value = '';
	notice.value = '';
	try {
		await axios.post('/json/instance/update');
		startPolling();
	} catch (e) {
		updating.value = false;
		error.value = e.response?.data?.message || 'Não foi possível iniciar a atualização.';
	}
}

function startPolling() {
	stopPolling();
	pollTimer = setInterval(async () => {
		try {
			const data = await fetchStatus();
			inMaintenance.value = false;
			const state = data.update_status?.state;
			if (state === 'success' || state === 'failed' || state === 'stalled') {
				stopPolling();
				updating.value = false;
				if (state === 'success') {
					notice.value = 'Atualização concluída com sucesso.';
				} else if (state === 'stalled') {
					error.value = `A atualização parou: ${data.update_status.message}`;
				} else {
					error.value = `Falha na atualização: ${data.update_status.message} O site pode estar em modo de manutenção — verifique o servidor.`;
				}
			}
		} catch (e) {
			// 503 = maintenance mode = update in progress; keep polling
			inMaintenance.value = true;
		}
	}, 4000);
}

function stopPolling() {
	if (pollTimer) {
		clearInterval(pollTimer);
		pollTimer = null;
	}
}

async function toggleOfflineMode() {
	const desired = status.value.offline_mode;
	savingOfflineMode.value = true;
	error.value = '';
	notice.value = '';
	try {
		const response = await axios.put('/json/instance/offline-mode', { enabled: desired });
		status.value.offline_mode = response.data.offline_mode;
		notice.value = response.data.offline_mode ? 'Modo off-line ativado.' : 'Modo off-line desativado.';
	} catch (e) {
		status.value.offline_mode = !desired; // revert the checkbox — save failed
		error.value = e.response?.data?.message || 'Não foi possível salvar o modo off-line.';
	} finally {
		savingOfflineMode.value = false;
	}
}


// ---- Warehouses ----
// Every change goes through one dialog that asks for your password again (the server checks it on each request).
const warehouses = ref(null);
const removalWaitDays = ref(30);
const dialog = ref(null); // { title, text, danger, button, fields: [{ key, label, type, value, help }], run(values, password) }
const dialogPassword = ref('');
const dialogError = ref('');
const dialogBusy = ref(false);
const result = ref(null); // a setup code to show once
const statusNames = {
	provisioning: 'Em criação', awaiting_setup: 'Aguardando configuração', active: 'Ativo', maintenance: 'Em manutenção', restoring: 'Em restauração',
	upgrading: 'Em atualização', held: 'Retido', suspended: 'Suspenso', archived: 'Arquivado',
};
const statusClass = (st) => ({
	active: 'bg-green-100 text-green-800',
	awaiting_setup: 'bg-blue-100 text-blue-800',
	archived: 'bg-gray-200 text-gray-700',
	suspended: 'bg-amber-100 text-amber-800',
	maintenance: 'bg-amber-100 text-amber-800',
}[st] || 'bg-red-100 text-red-800');
const shortDate = (iso) => (iso ? new Date(iso).toLocaleDateString('pt-BR') : '');

async function loadWarehouses() {
	try {
		const { data } = await axios.get('/json/instance/warehouses');
		warehouses.value = data.warehouses;
		removalWaitDays.value = data.removal_wait_days;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar os armazéns.';
	}
}

function openDialog(d) {
	dialog.value = { fields: [], ...d, values: Object.fromEntries((d.fields || []).map((f) => [f.key, f.value ?? (f.type === 'checkbox' ? false : '')])) };
	dialogPassword.value = '';
	dialogError.value = '';
	error.value = '';
	notice.value = '';
	result.value = null;
}

function closeDialog() {
	if (dialogBusy.value) return;
	dialog.value = null;
	dialogPassword.value = '';
}

async function submitDialog() {
	dialogBusy.value = true;
	dialogError.value = '';
	try {
		const { data } = await dialog.value.run(dialog.value.values, dialogPassword.value);
		notice.value = data.message || 'Concluído.';
		if (data.private_key) recoveryShown.value = data;   // the one time it exists outside the person's hands: shown in the dialog below
		else if (data.code && data.address) pairCode.value = data;
		else if (data.setup_code) result.value = { code: data.setup_code, url: data.setup_url, note: data.message };
		else if (data.backup !== undefined) result.value = { removed: data };
		else if (data.note) notice.value += ` ${data.note}`;
		dialog.value = null;
		await loadWarehouses();
		if (tab.value === 'backups') await loadInstanceBackups();
	} catch (e) {
		dialogError.value = e.response?.data?.errors
			? Object.values(e.response.data.errors).flat().join(' ')
			: e.response?.data?.message || 'Não foi possível concluir a operação.';
	} finally {
		dialogBusy.value = false;
		dialogPassword.value = '';
	}
}

const post = (id, action, body) => (password) => axios.post(`/json/instance/warehouses/${id}/${action}`, { ...body, password });

function newWarehouse() {
	openDialog({
		title: 'Novo armazém', button: 'Criar armazém',
		text: 'Cria um armazém vazio, com banco de dados e arquivos próprios, e um código de configuração de uso único. Quem tiver o código poderá se tornar administrador do armazém. Isso pode levar um minuto.',
		fields: [
			{ key: 'name', label: 'Nome', type: 'text' },
			{ key: 'email', label: 'E-mail de contato (opcional)', type: 'email' },
			{ key: 'training', label: 'Armazém de treinamento (ferramentas de aula; descartável)', type: 'checkbox' },
		],
		run: (v, password) => axios.post('/json/instance/warehouses', { name: v.name, email: v.email || null, training: v.training, password }),
	});
}

function editWarehouse(w) {
	openDialog({
		title: `Editar ${w.name}`, button: 'Salvar',
		fields: [
			{ key: 'name', label: 'Nome (exibido na página de login e na seleção de armazéns)', type: 'text', value: w.name },
			{ key: 'email', label: 'E-mail de contato', type: 'email', value: w.admin_email || '' },
			{ key: 'listed', label: 'Exibir na seleção de armazéns do endereço compartilhado', type: 'checkbox', value: w.listed },
			{ key: 'notes', label: 'Observações (visíveis apenas para administradores da instância)', type: 'textarea', value: w.notes || '' },
		],
		run: (v, password) => axios.put(`/json/instance/warehouses/${w.id}`, { name: v.name, email: v.email || null, listed: v.listed, notes: v.notes || null, password }),
	});
}

function suspendWarehouse(w, maintenance) {
	openDialog({
		title: `${maintenance ? 'Colocar em manutenção' : 'Suspender'} ${w.name}`, button: maintenance ? 'Iniciar manutenção' : 'Suspender',
		text: `${w.name} deixará de responder a todos (logins, URLs de máquina e clientes de impressão) até ser ativado novamente. Nada será excluído.`
			+ (w.is_default ? ' Este é o armazém padrão: as URLs de máquina sem prefixo também deixarão de funcionar.' : ''),
		danger: true,
		fields: [{ key: 'reason', label: 'Motivo (registrado no log de auditoria)', type: 'text' }],
		run: (v, password) => post(w.id, 'suspend', { maintenance, reason: v.reason || null })(password),
	});
}

const simple = (w, action, title, text, button = title, danger = false) => openDialog({ title: `${title}: ${w.name}`, text, button, danger, run: (v, password) => post(w.id, action, {})(password) });
const activateWarehouse = (w) => simple(w, 'activate', 'Ativar', `${w.name} voltará a funcionar.`);
const resumeWarehouse = (w) => simple(w, 'resume', 'Retomar', `Encerra uma restauração que deixou ${w.name} fora de serviço. Confira primeiro o log da restauração.`);

function archiveWarehouse(w, undo = false) {
	openDialog({
		title: `${undo ? 'Restaurar' : 'Arquivar'} ${w.name}`, button: undo ? 'Restaurar' : 'Arquivar', danger: !undo,
		text: undo
			? `${w.name} voltará ao estado em que estava antes de ser arquivado.`
			: `${w.name} deixará de atender a todos, mas nada será excluído. Depois de ${removalWaitDays.value} dias, poderá ser removido definitivamente por aqui. Você pode restaurá-lo a qualquer momento antes disso.`,
		run: (v, password) => post(w.id, 'archive', { undo })(password),
	});
}

function removeWarehouse(w) {
	openDialog({
		title: `Remover ${w.name} definitivamente`, button: 'Remover definitivamente', danger: true,
		text: 'Primeiro, será feito um backup final, armazenado na pasta de armazéns removidos do diretório de backups. Em seguida, o banco de dados, os arquivos e os logins exclusivos desse armazém serão excluídos. Esta ação não pode ser desfeita e pode levar alguns minutos.',
		fields: [{ key: 'confirm', label: `Digite o nome do armazém (${w.name}) para confirmar`, type: 'text' }],
		run: (v, password) => axios.delete(`/json/instance/warehouses/${w.id}`, { data: { confirm: v.confirm, password } }),
	});
}

function newSetupCode(w) {
	simple(w, 'setup-code', 'Novo código de configuração', 'Gera um novo código de uso único para quem vai configurar este armazém. Os códigos anteriores deixam de funcionar. O código será exibido uma única vez.', 'Gerar código');
}

function revokeSetupCode(w) {
	openDialog({ title: `Revogar código de configuração: ${w.name}`, button: 'Revogar', danger: true, text: 'O código pendente deixará de funcionar.', run: (v, password) => post(w.id, 'setup-code', { revoke: true })(password) });
}

function addHostname(w) {
	openDialog({
		title: `Adicionar nome de host a ${w.name}`, button: 'Adicionar nome de host',
		text: 'Um nome de host associado a um armazém acessa somente esse armazém e nunca exibe a seleção. Você precisa configurar o DNS e o TLS para apontar para este servidor.',
		fields: [
			{ key: 'hostname', label: 'Nome de host (por exemplo, armazem2.example.org)', type: 'text' },
			{ key: 'primary', label: 'Definir como endereço principal (usado em e-mails e links)', type: 'checkbox' },
		],
		run: (v, password) => post(w.id, 'domains', { hostname: v.hostname, primary: v.primary })(password),
	});
}

function removeHostname(w, hostname) {
	openDialog({
		title: `Remover ${hostname}`, button: 'Remover nome de host', danger: true,
		text: `${hostname} não dará mais acesso a ${w.name}.`,
		run: (v, password) => axios.delete(`/json/instance/warehouses/${w.id}/domains`, { data: { hostname, password } }),
	});
}

const copied = ref(false);
async function copyCode() {
	try {
		await navigator.clipboard.writeText(result.value.code);
		copied.value = true;
	} catch {
		copied.value = false;
	}
}

// ---- Full Instance Backups (Docker) ----
const instBackups = ref(null);   // the server's payload: { available, schedule, backups, activity, working }
const instForm = ref(null);
const weekdays = ['Domingo', 'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado'];
let instTimer = null;

const instFormOf = (sc) => ({
	enabled: !!sc.enabled, daily_hour: sc.daily_hour, daily_keep: sc.daily_keep, daily_with_files: !!sc.daily_with_files,
	weekly_enabled: !!sc.weekly_enabled, weekly_dow: sc.weekly_dow, weekly_keep: sc.weekly_keep, weekly_with_files: !!sc.weekly_with_files,
});

async function loadInstanceBackups() {
	try {
		const { data } = await axios.get('/json/instance/backups');
		instBackups.value = data;
		// Filled once (and after a save): the poll must not overwrite what is being typed.
		if (data.available && !instForm.value) instForm.value = instFormOf(data.schedule);
	} catch (e) {
		/* a poll that fails (an update is restarting the site) is not worth showing */
		if (!instBackups.value) error.value = e.response?.data?.message || 'Não foi possível carregar os backups da instância.';
	}
}

watch(tab, (t) => {
	clearInterval(instTimer);
	if (t === 'backups') {
		loadInstanceBackups();
		instTimer = setInterval(loadInstanceBackups, 4000);
	}
}, { immediate: true });   // ?tab=backups starts on this tab, so the value never "changes"

function saveInstanceSchedule() {
	openDialog({
		title: 'Salvar o agendamento de backup da instância', button: 'Salvar agendamento',
		text: instForm.value.enabled
			? 'O provisionador fará backups completos da instância conforme este agendamento e manterá os mais recentes.'
			: 'Os backups completos automáticos da instância serão desativados. Os backups já feitos não serão excluídos.',
		run: (v, password) => axios.put('/json/instance/backups/schedule', { ...instForm.value, password }).then((r) => {
			instForm.value = instFormOf(r.data.schedule);
			return r;
		}),
	});
}

function backUpInstanceNow(files) {
	openDialog({
		title: files ? 'Fazer backup de toda a instância, incluindo os arquivos de todos os armazéns' : 'Fazer backup de toda a instância (somente bancos de dados)', button: 'Fazer backup agora',
		text: 'O provisionador fará um backup consistente de todos os armazéns e dos bancos de dados compartilhados. Isso pode levar algum tempo, e a criação de armazéns aguardará até a conclusão. O backup não incluirá as chaves dos armazéns.',
		run: (v, password) => axios.post('/json/instance/backups', { files, password }),
	});
}

const sizeOf = (bytes) => (bytes > 1073741824 ? `${(bytes / 1073741824).toFixed(2)} GB` : bytes > 1048576 ? `${(bytes / 1048576).toFixed(1)} MB` : `${Math.ceil(bytes / 1024)} KB`);
const labelNames = { 'scheduled-daily': 'Agendado (diário)', 'scheduled-weekly': 'Agendado (semanal)', manual: 'Manual', premigrate: 'Antes de uma atualização' };
const instWhen = (iso) => (iso ? new Date(iso).toLocaleString('pt-BR') : '');

// ---- Recovery key ----
// The server keeps only the public half. The private half arrives once, here, in the response to "Make a recovery key", and is gone from the
// server the moment it is sent. The person must print or save it before closing; if the page is closed first the key is lost and a new one is made.
const recoveryShown = ref(null);   // { private_key, fingerprint, instance, address, made_at } while the dialog is open
const recoveryStored = ref(false);
const recoveryCopied = ref(false);
const recoveryBusy = ref(false);
const recoveryState = computed(() => instBackups.value?.recovery_key ?? { state: 'none' });

function makeRecoveryKey(replace = false) {
	recoveryShown.value = null;
	openDialog({
		title: replace ? 'Criar uma NOVA chave de recuperação' : 'Criar chave de recuperação', button: replace ? 'Substituir chave' : 'Criar chave', danger: replace,
		text: replace
			? 'Os próximos backups serão protegidos com a nova chave e precisarão dela para serem restaurados. Os backups anteriores ainda exigem a chave ANTIGA, então guarde a impressão até que eles não sejam mais necessários. A nova chave será exibida uma única vez.'
			: 'Cria a chave que protege as chaves de criptografia de todos os armazéns nos backups da instância. Ela será exibida uma única vez na próxima tela: tenha uma impressora ou um local seguro preparado.',
		run: (v, password) => axios.post('/json/instance/backups/recovery-key', { replace, password }),
	});
}

function recoveryText() {
	const k = recoveryShown.value;
	return [
		`RELIEF INVENTORY — CHAVE DE RECUPERAÇÃO (${k.instance})`,
		'',
		`Instância:     ${k.address}`,
		`Criada:        ${new Date(k.made_at).toLocaleString('pt-BR')}`,
		`Impressão digital: ${k.fingerprint}`,
		'',
		'Chave de recuperação:',
		`  ${k.private_key}`,
		'',
		'O QUE É',
		'Cada backup completo deste servidor (inclusive os automáticos) contém a chave de criptografia de cada armazém, protegida para que somente esta chave',
		'possa desbloqueá-la. Após um desastre, restaure com:  restore:instance <backup.zip> --recovery-key-file <a file containing the line above>',
		'e todas as configurações criptografadas dos armazéns (senhas de e-mail e chave de federação) serão recuperadas.',
		'',
		'MANTENHA-A EM SEGURANÇA',
		'Guarde-a longe deste servidor e dos seus backups (em um cofre, envelope lacrado ou gerenciador de senhas). Qualquer pessoa com esta chave',
		'e um backup poderá ler essas configurações. O servidor NÃO guarda esta chave e não poderá exibi-la novamente: se ela for perdida, crie outra em',
		'Administração da instância > Backups completos da instância (os backups anteriores ainda precisam desta chave).',
		'',
	].join('\n');
}

function printRecoveryKey() {
	const k = recoveryShown.value;
	const w = window.open('', '_blank', 'width=720,height=900');
	if (!w) { error.value = 'Seu navegador bloqueou a janela de impressão. Use a opção Baixar.'; return; }
	const esc = (t) => String(t).replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]));
	w.document.write(`<!doctype html><title>Chave de recuperação</title><style>body{font-family:sans-serif;margin:2rem;color:#000}h1{font-size:1.3rem}
		.key{font:700 1.25rem/1.6 monospace;letter-spacing:.05em;border:2px solid #000;padding:1rem;margin:1rem 0;word-break:break-all}
		pre{white-space:pre-wrap;font:0.85rem/1.5 sans-serif}</style>
		<h1>Relief Inventory &mdash; chave de recuperação (${esc(k.instance)})</h1>
		<div>Instância: ${esc(k.address)}<br>Criada: ${esc(new Date(k.made_at).toLocaleString('pt-BR'))}<br>Impressão digital: <b>${esc(k.fingerprint)}</b></div>
		<div class="key">${esc(k.private_key)}</div>
		<pre>${esc(recoveryText().split('O QUE É')[1] ? 'O QUE É' + recoveryText().split('O QUE É')[1] : '')}</pre>`);
	w.document.close();
	w.focus();
	w.print();
}

function downloadRecoveryKey() {
	const k = recoveryShown.value;
	const url = URL.createObjectURL(new Blob([recoveryText()], { type: 'text/plain' }));
	const a = document.createElement('a');
	a.href = url;
	a.download = `recovery-key-${k.fingerprint}.txt`;
	a.click();
	URL.revokeObjectURL(url);
}

async function copyRecoveryKey() {
	try {
		await navigator.clipboard.writeText(recoveryShown.value.private_key);
		recoveryCopied.value = true;
	} catch {
		recoveryCopied.value = false;
	}
}

async function finishRecoveryKey() {
	recoveryBusy.value = true;
	try {
		await axios.post('/json/instance/backups/recovery-key/confirm');
		recoveryShown.value = null;
		recoveryStored.value = false;
		recoveryCopied.value = false;
		notice.value = 'Chave de recuperação confirmada. A partir de agora, todos os backups da instância incluirão as chaves dos armazéns protegidas por ela.';
		await loadInstanceBackups();
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível confirmar a chave de recuperação.';
	} finally {
		recoveryBusy.value = false;
	}
}

// Computers (the RI Launcher) paired to the instance so they can take whole-instance backups. A new code is shown once.
const pairCode = ref(null);   // { code, expires_at, address }

function newBackupClient() {
	pairCode.value = null;
	openDialog({
		title: 'Vincular computador para backups da instância', button: 'Gerar código',
		text: 'Gera um código de uso único, válido por 15 minutos. No RI Launcher, escolha Backups remotos e vincule como backup de instância usando este endereço e o código. Esse computador poderá criar e baixar backups da instância INTEIRA (todos os armazéns e as informações de todas as pessoas) até que você revogue o acesso por aqui.',
		fields: [{ key: 'name', label: 'Identificação (opcional)', type: 'text' }],
		run: (v, password) => axios.post('/json/instance/backups/clients/code', { name_hint: v.name || null, password }),
	});
}

function revokeBackupClient(c) {
	openDialog({
		title: `Desconectar ${c.name}`, button: 'Revogar', danger: true,
		text: `${c.name} não poderá mais criar nem baixar backups da instância. As cópias que já possui permanecerão nesse computador. Ele poderá ser vinculado novamente com um novo código.`,
		run: (v, password) => axios.delete(`/json/instance/backups/clients/${c.id}`, { data: { password } }),
	});
}

onMounted(() => {
	loadWarehouses();
	fetchStatus().catch(() => { error.value = 'Não foi possível carregar o status do sistema.'; });
});
onUnmounted(() => {
	stopPolling();
	stopDockerPolling();
	clearInterval(instTimer);
});
</script>

<template>
	<Head title="Administração da instância" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Administração da instância</h1>
			<p class="text-sm text-gray-600">
				Estas configurações se aplicam a toda a instalação, não a um único armazém. Os backups de um armazém ficam em
				<a href="/setup/system" class="underline">Backups do armazém</a>.
			</p>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>

			<div class="flex gap-1 border-b border-gray-300">
				<button v-for="t in [['updates', 'Atualizações e modo'], ['warehouses', 'Armazéns'], ['backups', 'Backups completos da instância']]" :key="t[0]"
					class="px-4 py-2 text-sm font-medium -mb-px border-b-2"
					:class="tab === t[0] ? 'border-indigo-600 text-indigo-700' : 'border-transparent text-gray-600 hover:text-gray-900'"
					@click="tab = t[0]">{{ t[1] }}</button>
			</div>

			<div v-if="tab === 'updates'" class="space-y-6">
				<div v-if="!status" class="text-gray-500">Carregando o status do sistema…</div>
					<!-- Software update -->
					<section v-if="status" class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">{{ docker ? 'Versão do software' : 'Atualização do software' }}</h2>
						<div class="text-sm text-gray-700">
							<p>
								Versão atual:
								<span v-if="status.version.release" class="font-semibold">{{ status.version.release }}</span>
								<span v-else class="text-gray-500">sem versão</span>
								(commit <span class="font-mono">{{ status.version.current || 'desconhecido' }}</span>)
								<span v-if="status.version.current_date"> — {{ new Date(status.version.current_date).toLocaleString('pt-BR') }}</span>
							</p>
							<p v-if="status.version.current_subject" class="text-gray-500">“{{ status.version.current_subject }}”</p>
						</div>

						<!-- Docker / R Station: the host-side updater does the work; this page only asks it -->
						<template v-if="docker">
							<p v-if="!dockerUpdate?.enabled" class="text-sm text-gray-600">
								A atualização por esta página não está configurada. Para ativá-la, defina <span class="font-mono">RI_UPDATE_SECRET</span> em
								compose.yaml e instale o atualizador no servidor (“Atualizações automáticas” no guia do Docker). Até lá, atualize baixando
								a nova imagem e reiniciando-a; o banco de dados será copiado automaticamente antes, caso a atualização tenha alterações a aplicar.
							</p>
							<template v-else>
								<p v-if="dockerUpdate.available_version" class="text-sm font-medium text-amber-700">
									A versão {{ dockerUpdate.available_version }} está disponível (verificada em {{ new Date(dockerUpdate.last_checked_at).toLocaleString('pt-BR') }}).
								</p>
								<p v-else-if="dockerUpdate.last_checked_at" class="text-sm text-gray-600">
									Última verificação em {{ new Date(dockerUpdate.last_checked_at).toLocaleString('pt-BR') }}: nenhuma versão mais recente.
								</p>

								<div v-if="dockerBusy" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
									<p class="font-medium">{{ dockerStateText[dockerUpdate.state] }}</p>
									<p v-if="dockerUpdate.message">{{ dockerUpdate.message }}</p>
								</div>
								<div v-else-if="dockerUpdate.state === 'stalled'" class="rounded bg-amber-50 border border-amber-300 text-amber-800 px-4 py-3 text-sm">
									{{ dockerUpdate.message }}
								</div>

								<div v-if="dockerUpdate.can_request && !dockerBusy" class="flex gap-3 items-center">
									<PrimaryButton :disabled="requestingDocker" @click="requestDockerUpdate('check')">Verificar atualizações</PrimaryButton>
									<button
										v-if="dockerUpdate.available_version || confirmingDockerUpdate"
										class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
										:class="confirmingDockerUpdate ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'"
										:disabled="requestingDocker"
										@click="requestDockerUpdate('update')"
									>
										{{ confirmingDockerUpdate ? 'Confirmar — todos os armazéns ficarão indisponíveis por alguns instantes' : 'Instalar atualização' }}
									</button>
									<button v-if="confirmingDockerUpdate" class="text-sm text-gray-500 underline" @click="confirmingDockerUpdate = false">Cancelar</button>
								</div>
								<p v-else-if="!dockerUpdate.can_request" class="text-xs text-gray-500">
									Somente um administrador da instância pode verificar ou instalar atualizações: isso reinicia todos os armazéns deste sistema.
								</p>
								<p class="text-xs text-gray-500">
									O atualizador do servidor baixa a nova versão e reinicia o sistema. O banco de dados é copiado antes se a versão tiver alterações a aplicar.
								</p>
							</template>
						</template>

						<template v-else>
							<div v-if="status.updater_deprecated" class="rounded bg-amber-50 border border-amber-300 text-amber-900 px-4 py-3 text-sm">
								<p class="font-medium">Obsoleto: a atualização por esta página será removida.</p>
								<p>
									O código é baixado do GitHub, depois a migração do banco de dados é executada e os recursos da web são recompilados dentro de uma solicitação web,
									o que pode deixar o sistema parcialmente atualizado se algo der errado. Ainda funciona por enquanto. Prefira uma instalação Docker ou
									execute <span class="font-mono">scripts/update.sh</span> em um terminal no servidor, onde você poderá acompanhar o processo.
								</p>
							</div>
							<div v-if="status.version.behind > 0" class="text-sm">
								<p class="font-medium text-amber-700">{{ status.version.behind }} atualização(ões) disponível(is):</p>
								<ul class="font-mono text-xs text-gray-600 mt-1 space-y-0.5">
									<li v-for="commit in status.version.pending_commits" :key="commit">{{ commit }}</li>
								</ul>
							</div>

							<div v-if="updating" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
								<p class="font-medium">Atualização em andamento…</p>
								<p v-if="inMaintenance">O site está em modo de manutenção durante a atualização. Esta página voltará automaticamente.</p>
								<p v-else-if="status.update_status?.message">{{ status.update_status.message }}</p>
							</div>

							<div class="flex gap-3 items-center" v-if="!updating">
								<PrimaryButton :disabled="checking" @click="checkForUpdates">
									{{ checking ? 'Verificando…' : 'Verificar atualizações' }}
								</PrimaryButton>
								<button
									v-if="status.version.behind > 0 || confirmingUpdate"
									class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white"
									:class="confirmingUpdate ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'"
									@click="startUpdate"
								>
									{{ confirmingUpdate ? 'Confirmar — o site ficará indisponível por alguns instantes' : 'Instalar atualização' }}
								</button>
								<button v-if="confirmingUpdate" class="text-sm text-gray-500 underline" @click="confirmingUpdate = false">Cancelar</button>
							</div>
							<p class="text-xs text-gray-500">
								A instalação de uma atualização faz um backup primeiro, coloca o site em modo de manutenção, aplica a atualização
								e verifica se está tudo funcionando antes de voltar ao ar.
							</p>
						</template>
					</section>

					<!-- Offline Mode -->
					<section v-if="status" class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">Modo offline</h2>
						<p class="text-sm text-gray-600">
							Ative esta opção quando este armazém não tiver uma conexão confiável com a internet. Ela
							desativa automaticamente o Cloudflare Turnstile (proteção contra bots no login, cadastro e redefinição de senha) e
							as consultas de endereço do geocod.io (preenchimento automático de condado, cidade e estado em Pedidos e Pessoas) — nenhum dos dois
							é necessário para o funcionamento normal; sem uma conexão real, apenas demoram a falhar.
							Nada mais muda: o cadastro de endereços, pedidos e estoque funciona exatamente da mesma forma.
						</p>
						<label class="flex items-center gap-3">
							<input type="checkbox" v-model="status.offline_mode" :disabled="savingOfflineMode"
								@change="toggleOfflineMode" class="h-5 w-5 rounded border-gray-300" />
							<span class="text-sm font-medium text-gray-700">
								{{ status.offline_mode ? 'Modo offline ativado' : 'Modo offline desativado' }}
							</span>
						</label>
					</section>

			</div>

			<div v-if="tab === 'warehouses'" class="space-y-6">
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<div class="flex items-center justify-between gap-3 flex-wrap">
						<h2 class="text-lg font-semibold">Armazéns</h2>
						<PrimaryButton @click="newWarehouse">Novo armazém</PrimaryButton>
					</div>
					<p class="text-sm text-gray-600">
						Cada armazém tem seu próprio banco de dados, arquivos e pessoas. Cada alteração aqui solicita sua senha novamente.
						Arquivar tira um armazém de serviço sem excluir nada; um armazém arquivado pode ser removido definitivamente por aqui
						após {{ removalWaitDays }} dias. <span class="text-gray-500">(O comando
						<span class="font-mono">php artisan warehouse:remove &lt;id&gt;</span> remove um armazém arquivado imediatamente, sem período de espera.)</span>
					</p>

					<div v-if="result?.code" class="rounded border-2 border-amber-400 bg-amber-50 p-4 text-sm space-y-2">
						<p class="font-semibold">{{ result.note }}</p>
						<p>Código de configuração: <span class="font-mono text-lg font-bold">{{ result.code }}</span>
							<button class="ml-3 text-xs underline" @click="copyCode">{{ copied ? 'Copiado' : 'Copiar' }}</button></p>
						<p>Endereço: <span class="font-mono break-all">{{ result.url }}</span></p>
					</div>
					<div v-if="result?.removed" class="rounded border border-gray-300 bg-gray-50 p-4 text-sm space-y-1">
						<p>Backup final: <span class="font-mono break-all">{{ result.removed.backup || 'nenhum' }}</span></p>
						<p>Logins removidos com ele: {{ result.removed.accounts_removed.length ? result.removed.accounts_removed.join(', ') : 'nenhum' }}; mantidos (pertencem a outros armazéns): {{ result.removed.accounts_kept }}</p>
						<p v-for="n in result.removed.notes" :key="n" class="text-amber-800">{{ n }}</p>
					</div>

					<div v-if="!warehouses" class="text-gray-500">Carregando…</div>
					<div v-for="w in warehouses" :key="w.id" class="border rounded-lg p-4 space-y-2" :class="w.status === 'archived' ? 'bg-gray-50' : ''">
						<div class="flex items-center gap-2 flex-wrap">
							<h3 class="font-semibold">{{ w.name }}</h3>
							<span class="text-xs rounded px-2 py-0.5" :class="statusClass(w.status)">{{ statusNames[w.status] || w.status }}</span>
							<span v-if="w.is_default" class="text-xs rounded px-2 py-0.5 bg-indigo-100 text-indigo-800">Padrão</span>
							<span v-if="w.is_training" class="text-xs rounded px-2 py-0.5 bg-yellow-100 text-yellow-800">Treinamento</span>
							<span v-if="!w.listed" class="text-xs text-gray-500">não aparece na seleção</span>
							<span class="ml-auto font-mono text-xs text-gray-500">{{ w.id }}</span>
						</div>
						<p v-if="w.admin_email" class="text-xs text-gray-600">Contato: {{ w.admin_email }}</p>
						<p v-if="w.notes" class="text-xs text-gray-600 whitespace-pre-line">{{ w.notes }}</p>
						<p v-if="w.status === 'archived'" class="text-xs text-gray-600">
							Arquivado em {{ shortDate(w.archived_at) }}.
							<template v-if="w.is_default">O armazém padrão não pode ser removido.</template>
							<template v-else-if="w.can_remove_now">Já pode ser removido definitivamente.</template>
							<template v-else>Poderá ser removido por aqui a partir de {{ shortDate(w.removable_on) }}.</template>
						</p>
						<p v-if="w.status === 'awaiting_setup'" class="text-xs text-gray-600">
							Endereço de configuração <span class="font-mono break-all">{{ w.setup_url }}</span> —
							{{ w.setup_code_until ? `há um código pendente, válido até ${shortDate(w.setup_code_until)}` : 'não há código de configuração pendente' }}.
						</p>

						<div class="flex gap-2 flex-wrap items-center text-xs">
							<span class="text-gray-500">Nomes de host:</span>
							<span v-if="!w.domains.length" class="text-gray-400">nenhum (acessado pelo endereço compartilhado)</span>
							<span v-for="d in w.domains" :key="d.hostname" class="inline-flex items-center gap-1 rounded bg-gray-100 px-2 py-0.5 font-mono">
								{{ d.hostname }}<span v-if="d.primary" class="text-gray-500 font-sans">(principal)</span>
								<button class="text-red-600 font-sans" :title="`Remover ${d.hostname}`" @click="removeHostname(w, d.hostname)">×</button>
							</span>
							<button class="underline text-indigo-700" @click="addHostname(w)">Adicionar nome de host</button>
						</div>

						<div class="flex gap-3 flex-wrap text-sm pt-1">
							<button class="underline text-indigo-700" @click="editWarehouse(w)">Editar</button>
							<template v-if="w.status === 'active'">
								<button class="underline text-amber-700" @click="suspendWarehouse(w, false)">Suspender</button>
								<button class="underline text-amber-700" @click="suspendWarehouse(w, true)">Manutenção</button>
							</template>
							<button v-if="w.status === 'suspended' || w.status === 'maintenance'" class="underline text-green-700" @click="activateWarehouse(w)">Ativar</button>
							<button v-if="w.status === 'restoring'" class="underline text-green-700" @click="resumeWarehouse(w)">Retomar</button>
							<template v-if="w.status === 'awaiting_setup'">
								<button class="underline text-indigo-700" @click="newSetupCode(w)">Novo código de configuração</button>
								<button class="underline text-amber-700" @click="revokeSetupCode(w)">Revogar código</button>
							</template>
							<button v-if="w.status === 'archived'" class="underline text-indigo-700" @click="archiveWarehouse(w, true)">Restaurar</button>
							<button v-else-if="!w.is_default && ['active', 'suspended', 'maintenance', 'awaiting_setup'].includes(w.status)" class="underline text-red-700" @click="archiveWarehouse(w)">Arquivar</button>
							<button v-if="w.status === 'archived' && !w.is_default" class="underline" :class="w.can_remove_now ? 'text-red-700 font-semibold' : 'text-gray-400 cursor-not-allowed'"
								:disabled="!w.can_remove_now" :title="w.can_remove_now ? '' : `Disponível a partir de ${shortDate(w.removable_on)}`" @click="removeWarehouse(w)">Remover definitivamente</button>
						</div>
					</div>
				</section>
			</div>

			<!-- The password dialog every change goes through -->
			<div v-if="dialog" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="closeDialog">
				<form class="bg-white rounded-lg shadow-xl w-full max-w-md p-6 space-y-4 max-h-full overflow-y-auto" @submit.prevent="submitDialog">
					<h2 class="text-lg font-semibold" :class="dialog.danger ? 'text-red-800' : ''">{{ dialog.title }}</h2>
					<p v-if="dialog.text" class="text-sm text-gray-700">{{ dialog.text }}</p>
					<div v-for="f in dialog.fields" :key="f.key">
						<label v-if="f.type === 'checkbox'" class="flex items-center gap-2 text-sm">
							<input type="checkbox" v-model="dialog.values[f.key]" class="h-4 w-4 rounded border-gray-300" /> {{ f.label }}
						</label>
						<label v-else class="block text-sm">
							<span class="text-gray-700">{{ f.label }}</span>
							<textarea v-if="f.type === 'textarea'" v-model="dialog.values[f.key]" rows="3" class="mt-1 block w-full rounded border-gray-300 text-sm"></textarea>
							<input v-else :type="f.type" v-model="dialog.values[f.key]" class="mt-1 block w-full rounded border-gray-300 text-sm" autocomplete="off" />
						</label>
					</div>
					<label class="block text-sm">
						<span class="text-gray-700 font-medium">Sua senha, para confirmar</span>
						<input type="password" v-model="dialogPassword" required autocomplete="current-password" class="mt-1 block w-full rounded border-gray-300 text-sm" />
					</label>
					<p v-if="dialogError" class="rounded bg-red-100 border border-red-400 text-red-800 px-3 py-2 text-sm">{{ dialogError }}</p>
					<div class="flex gap-3 justify-end items-center">
						<button type="button" class="text-sm text-gray-600 underline" :disabled="dialogBusy" @click="closeDialog">Cancelar</button>
						<PrimaryButton :disabled="dialogBusy || !dialogPassword" :class="dialog.danger ? 'bg-red-600 hover:bg-red-500' : ''">
							{{ dialogBusy ? 'Processando…' : dialog.button }}
						</PrimaryButton>
					</div>
				</form>
			</div>

			<div v-if="tab === 'backups'" class="space-y-6">
				<section class="bg-white shadow rounded-lg p-6 space-y-3">
					<h2 class="text-lg font-semibold">Backups completos da instância</h2>
					<p class="text-sm text-gray-700">
						Um backup completo da instância é um único arquivo zip com os bancos de dados de controle e de contas e o banco de dados de <strong>todos</strong> os armazéns,
						opcionalmente incluindo os arquivos de cada armazém. É também o backup automático feito antes de uma atualização. Destina-se a quem administra o
						servidor, para mover ou recuperar toda a instalação. Para fazer backup ou restaurar um único armazém, use
						<a href="/setup/system" class="underline">Backups do armazém</a>. Cada zip contém a chave de criptografia de todos os armazéns <strong>protegida pela sua chave de recuperação</strong> (abaixo),
						para que seja possível restaurar até mesmo os backups automáticos, incluindo as chaves.
					</p>
					<p v-if="instBackups && !instBackups.available" class="rounded bg-amber-100 border border-amber-400 text-amber-900 px-3 py-2 text-sm">
						É necessária uma instalação Docker: o backup é feito pelo contêiner <span class="font-mono">provisioner</span>. Em uma instalação padrão no servidor, use
						Backups do armazém.
					</p>
					<p v-else-if="!instBackups" class="text-gray-500 text-sm">Carregando…</p>
				</section>

				<template v-if="instBackups?.available && instForm">
					<!-- The recovery key: public half on the server, private half on paper -->
					<section class="rounded-lg border-2 p-6 space-y-3"
						:class="recoveryState.state === 'ok' ? 'bg-white border-green-400' : 'bg-red-50 border-red-400'">
						<h2 class="text-lg font-semibold">Chave de recuperação</h2>
						<template v-if="recoveryState.state === 'none'">
							<p class="text-sm text-red-900">
								<strong>Esta instância não tem uma chave de recuperação.</strong> Os backups contêm tudo, exceto as chaves de criptografia dos armazéns. Assim, após um desastre,
								não será possível ler as senhas de e-mail nem a chave de federação, que precisarão ser inseridas novamente; todas as instâncias e clientes vinculados também terão de aprovar esta instância outra vez.
							</p>
						</template>
						<template v-else-if="recoveryState.state === 'unconfirmed'">
							<p class="text-sm text-red-900">
								<strong>Ninguém confirmou que a chave de recuperação {{ recoveryState.fingerprint }} foi guardada.</strong> A parte privada foi exibida uma única vez e o servidor não
								a guarda. Se você não a imprimiu nem salvou, crie uma nova chave.
							</p>
						</template>
						<template v-else>
							<p class="text-sm text-gray-700">
								Todos os backups da instância contêm cópias criptografadas das chaves dos armazéns. Essas chaves são protegidas pela chave de recuperação <span class="font-mono font-semibold">{{ recoveryState.fingerprint }}</span>
								<span class="text-gray-500">(criada por {{ recoveryState.created_by }}{{ recoveryState.source === 'generated' ? '' : `, ${recoveryState.source}` }})</span>.
								Guarde a impressão longe deste servidor e dos seus backups.
							</p>
						</template>
						<p class="text-xs text-gray-600">
							Como funciona: cada backup protege as chaves dos armazéns com uma chave <em>pública</em> mantida aqui. Assim, o backup automático pode fazer isso, mas nada neste servidor pode desbloqueá-las.
							Somente a chave <em>privada</em>, que você imprime uma vez, pode fazê-lo. Para restaurar após um desastre:
							<span class="font-mono">restore:instance &lt;zip&gt; --recovery-key-file &lt;file&gt;</span>. Check a printout at any time with
							<span class="font-mono">instance:recovery-key verify</span>.
						</p>
						<div class="flex flex-wrap gap-3">
							<PrimaryButton v-if="recoveryState.state === 'none'" type="button" @click="makeRecoveryKey(false)">Criar chave de recuperação…</PrimaryButton>
							<PrimaryButton v-else type="button" @click="makeRecoveryKey(true)" :class="recoveryState.state === 'ok' ? 'bg-gray-600 hover:bg-gray-500' : ''">
								Criar nova chave de recuperação…
							</PrimaryButton>
						</div>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">Fazer backup agora</h2>
						<div class="flex flex-wrap items-center gap-3">
							<PrimaryButton :disabled="instBackups.working" @click="backUpInstanceNow(false)">{{ instBackups.working ? 'Backup em andamento…' : 'Fazer backup (bancos de dados)' }}</PrimaryButton>
							<PrimaryButton :disabled="instBackups.working" @click="backUpInstanceNow(true)">Fazer backup (bancos de dados + arquivos de todos os armazéns)</PrimaryButton>
						</div>
						<p v-if="instBackups.working" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-3 py-2 text-sm">Processando… esta página é atualizada automaticamente.</p>
						<p v-else-if="instBackups.activity" class="text-sm" :class="instBackups.activity.status === 'failed' ? 'text-red-700' : 'text-gray-600'">
							Última solicitação: {{ instBackups.activity.status === 'failed' ? 'FALHOU — ' : 'concluída — ' }}{{ instBackups.activity.message }}
							<span v-if="instBackups.activity.finished_at" class="text-xs text-gray-500">({{ instWhen(instBackups.activity.finished_at) }})</span>
						</p>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-4">
						<h2 class="text-lg font-semibold">Agendamento</h2>
						<form @submit.prevent="saveInstanceSchedule" class="space-y-3 text-sm">
							<label class="flex items-center gap-2 font-medium"><input type="checkbox" v-model="instForm.enabled" class="rounded border-gray-300" /> Fazer backup completo da instância automaticamente</label>
							<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2" :class="instForm.enabled ? '' : 'opacity-60'">
								<span class="w-28 font-medium">Diário</span>
								<label class="flex items-center gap-2">Após <select v-model.number="instForm.daily_hour" class="rounded-md border-gray-300 text-sm"><option v-for="h in 24" :key="h" :value="h - 1">{{ String(h - 1).padStart(2, '0') }}:00</option></select> (horário do servidor)</label>
								<label class="flex items-center gap-2">Manter os <input type="number" min="1" max="90" v-model.number="instForm.daily_keep" class="w-20 rounded-md border-gray-300 text-sm" /> mais recentes</label>
								<label class="flex items-center gap-2"><input type="checkbox" v-model="instForm.daily_with_files" class="rounded border-gray-300" /> incluir os arquivos de todos os armazéns</label>
							</div>
							<div class="border rounded p-3 flex flex-wrap items-center gap-x-6 gap-y-2" :class="instForm.enabled ? '' : 'opacity-60'">
								<label class="flex items-center gap-2 w-28 font-medium"><input type="checkbox" v-model="instForm.weekly_enabled" class="rounded border-gray-300" /> Semanal</label>
								<label class="flex items-center gap-2">Às <select v-model.number="instForm.weekly_dow" class="rounded-md border-gray-300 text-sm"><option v-for="(d, i) in weekdays" :key="d" :value="i">{{ d }}</option></select></label>
								<label class="flex items-center gap-2">Manter os <input type="number" min="1" max="52" v-model.number="instForm.weekly_keep" class="w-20 rounded-md border-gray-300 text-sm" /> mais recentes</label>
								<label class="flex items-center gap-2"><input type="checkbox" v-model="instForm.weekly_with_files" class="rounded border-gray-300" /> incluir os arquivos de todos os armazéns</label>
							</div>
							<div class="flex flex-wrap items-center gap-4">
								<PrimaryButton type="submit">Salvar agendamento…</PrimaryButton>
								<span v-if="instBackups.schedule.last_run_at" class="text-xs" :class="instBackups.schedule.last_status === 'failed' ? 'text-red-700' : 'text-gray-500'">
									Último backup agendado: {{ instWhen(instBackups.schedule.last_run_at) }} — {{ instBackups.schedule.last_status === 'failed' ? `FALHOU: ${instBackups.schedule.last_message}` : 'feito' }}
								</span>
							</div>
						</form>
						<p class="text-xs text-gray-500">
							Um backup semanal também conta como o backup diário daquele dia. Os backups manuais e os feitos antes de uma atualização não são excluídos por este agendamento
							(os de atualização são removidos após o número habitual de dias). Eles ficam nesta máquina: copie-os também para outro local (o RI Launcher pode fazer isso).
							O provisionador processa uma solicitação por vez, então a criação de um armazém aguarda enquanto um backup grande é feito.
						</p>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-3">
						<h2 class="text-lg font-semibold">Computadores autorizados a fazer backups da instância</h2>
						<p class="text-sm text-gray-700">
							O RI Launcher em um computador vinculado aqui pode criar e baixar estes backups automaticamente, conforme um agendamento, para manter cópias em outro local. Isto é
							separado do Console de confiança de cada armazém: cobre a <strong>instância inteira</strong>, então vincule somente computadores confiáveis com as informações de todos.
						</p>
						<div v-if="pairCode" class="rounded border-2 border-green-500 bg-green-50 p-4 text-sm space-y-1">
							<div>Endereço do servidor: <span class="font-mono font-semibold">{{ pairCode.address }}</span></div>
							<div>Código: <span class="font-mono text-xl font-bold tracking-widest">{{ pairCode.code }}</span></div>
							<div class="text-xs text-gray-600">Exibido uma única vez. Expira em {{ instWhen(pairCode.expires_at) }}. No Launcher: Backups remotos → Vincular → “Backup da instância”.</div>
						</div>
						<div v-for="c in instBackups.clients" :key="c.id" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-3">
							<div>
								<span class="font-medium">{{ c.name }}</span>
								<span class="ml-2 rounded px-2 py-0.5 text-xs" :class="c.status === 'approved' ? 'bg-green-100 text-green-800' : 'bg-gray-200 text-gray-700'">{{ c.status === 'approved' ? 'Vinculado' : 'Revogado' }}</span>
								<div class="text-xs text-gray-500">
									Vinculado em {{ instWhen(c.approved_at) }}<span v-if="c.last_seen_at"> · visto por último em {{ instWhen(c.last_seen_at) }}<span v-if="c.last_seen_ip"> de {{ c.last_seen_ip }}</span></span><span v-else> · nunca conectado</span>
								</div>
							</div>
							<button v-if="c.status === 'approved'" @click="revokeBackupClient(c)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500">Revogar…</button>
						</div>
						<p v-if="!instBackups.clients.length" class="text-gray-400 text-sm">Nenhum computador vinculado ainda.</p>
						<PrimaryButton type="button" @click="newBackupClient">Vincular computador…</PrimaryButton>
					</section>

					<section class="bg-white shadow rounded-lg p-6 space-y-3">
						<h2 class="text-lg font-semibold">Backups da instância</h2>
						<p v-if="!instBackups.backups.length" class="text-gray-400 text-sm">nenhum ainda</p>
						<div v-for="z in instBackups.backups" :key="z.name" class="border rounded p-3 text-sm flex flex-wrap items-center justify-between gap-3">
							<div class="space-y-1">
								<div class="font-mono text-xs text-gray-600">{{ z.name }}</div>
								<div>
									{{ instWhen(z.made_at) }} — {{ sizeOf(z.size) }}, {{ z.scope === 'full' ? 'bancos de dados + arquivos' : 'somente bancos de dados' }}
									<span v-if="z.label" class="ml-1 rounded bg-gray-100 px-2 py-0.5 text-xs text-gray-700">{{ labelNames[z.label] || z.label }}</span>
								</div>
							</div>
							<a v-if="z.downloadable" :href="$withWarehouse(`/json/instance/backups/${z.name}/download`)"
								class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-gray-800 hover:bg-gray-700">Baixar</a>
							<span v-else class="text-xs text-gray-500">Não pode ser lido aqui: copie-o da pasta de backups do servidor (<span class="font-mono">instance/</span>)</span>
						</div>
						<p class="text-xs text-gray-500">
							Para restaurá-lo em uma nova máquina (com os outros contêineres parados):
							<span class="font-mono">docker compose exec provisioner php artisan restore:instance &lt;zip&gt;</span>. A exclusão deve ser feita no servidor.
						</p>
					</section>
				</template>
			</div>
		</div>

		<!-- The recovery key, shown once. No way to dismiss it until the person says it is stored. -->
		<div v-if="recoveryShown" class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4" role="dialog" aria-modal="true" aria-labelledby="recovery-title">
			<div class="max-h-full w-full max-w-2xl overflow-y-auto rounded-lg bg-white p-6 shadow-xl space-y-4">
				<h2 id="recovery-title" class="text-xl font-bold text-red-800">Imprima esta chave e guarde-a em um local seguro</h2>
				<p class="text-sm text-gray-800">
					Esta é a <strong>chave de recuperação</strong> da sua instância. Ela é exibida <strong>somente agora</strong>: o servidor não a guarda e não poderá exibi-la novamente.
					É ela que permite restaurar as configurações criptografadas de todos os armazéns a partir de um backup automático após um desastre.
				</p>
				<div class="rounded border-2 border-gray-800 bg-gray-50 p-4">
					<div class="text-xs text-gray-500">Impressão digital {{ recoveryShown.fingerprint }}</div>
					<div class="mt-1 break-all font-mono text-lg font-bold leading-relaxed tracking-wide" data-testid="recovery-key">{{ recoveryShown.private_key }}</div>
				</div>
				<div class="flex flex-wrap gap-3">
					<button type="button" class="rounded-md bg-gray-800 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white hover:bg-gray-700" @click="printRecoveryKey">Imprimir</button>
					<button type="button" class="rounded-md bg-gray-800 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-white hover:bg-gray-700" @click="downloadRecoveryKey">Baixar como arquivo</button>
					<button type="button" class="rounded-md bg-gray-200 px-4 py-2 text-xs font-semibold uppercase tracking-widest text-gray-800 hover:bg-gray-300" @click="copyRecoveryKey">{{ recoveryCopied ? 'Copiado' : 'Copiar' }}</button>
				</div>
				<ul class="list-disc space-y-1 pl-5 text-sm text-gray-700">
					<li>Mantenha-a <strong>longe deste servidor e dos seus backups</strong>: em um cofre, envelope lacrado ou gerenciador de senhas. Qualquer pessoa com esta chave e um backup pode ler as configurações criptografadas dos armazéns.</li>
					<li>Confira uma impressão depois com <span class="font-mono">instance:recovery-key verify</span>. A chave tem caracteres de verificação para detectar erros de digitação.</li>
					<li>Se ela for perdida, crie outra por aqui. Os backups anteriores ainda precisarão desta chave.</li>
				</ul>
				<label class="flex items-start gap-2 text-sm font-medium text-gray-900">
					<input type="checkbox" v-model="recoveryStored" class="mt-1 rounded border-gray-400" />
					<span>Imprimi ou salvei esta chave em um local seguro, longe deste servidor e dos meus backups.</span>
				</label>
				<div class="flex justify-end">
					<PrimaryButton type="button" :disabled="!recoveryStored || recoveryBusy" @click="finishRecoveryKey">{{ recoveryBusy ? 'Salvando…' : 'Concluir' }}</PrimaryButton>
				</div>
			</div>
		</div>
	</AuthenticatedLayout>
</template>
