<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Setup/Training.vue

	Setup > Training Warehouse (TrainingAdminController, manage-training, a key only a training warehouse has). Approved devices offer a tap-your-name login for the
	trainees listed here, capped to station work (App\Services\TrainingMode). Prepare Training loads
	starter work for every station and the setup packet tells trainers how to stage the floor.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import { Head, Link } from '@inertiajs/vue3';
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

defineProps({
	breadcrumb: { type: Array },
});

const status = ref(null);
const error = ref(null);
const notice = ref(null);
const busy = ref(false);
const confirmingPrepare = ref(false);
const preparing = ref(false);
const newTrainee = ref({ first_name: '', last_name: '', team: null });
const showInactive = ref(false);
const event = ref({ event_title: '', event_location: '', trainer1_name: '', trainer2_name: '' });
const uploadingSlot = ref(null);
const confirmingReset = ref(false);
const resetText = ref('');
const resetting = ref(false);
const savingEvent = ref(false);

const trainees = computed(() => (status.value?.trainees || []).filter((t) => showInactive.value || t.active));

async function load() {
	try {
		status.value = (await axios.get('/json/training/status')).data;
		event.value = {
			event_title: status.value.event_title || '',
			event_location: status.value.event_location || '',
			trainer1_name: status.value.trainers[0].name || '',
			trainer2_name: status.value.trainers[1].name || '',
		};
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível carregar as configurações do armazém de treinamento.';
	}
}

async function saveEvent() {
	error.value = notice.value = null;
	savingEvent.value = true;
	try {
		status.value = (await axios.put('/json/training/event', event.value)).data;
		notice.value = 'Detalhes do certificado salvos.';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível salvar os detalhes do certificado.';
	} finally {
		savingEvent.value = false;
	}
}

async function startReset() {
	error.value = notice.value = null;
	resetting.value = true;
	try {
		await axios.post('/json/training/reset', { confirm: resetText.value });
		confirmingReset.value = false;
		watchReset();
	} catch (e) {
		resetting.value = false;
		error.value = e.response?.data?.message || 'Não foi possível iniciar a redefinição.';
	}
}

// The reset runs in the background: this warehouse answers 503 while it is rebuilt and, rebuilt, has none of today's
// sessions (401/419), so keep asking until the answer says how it ended.
function watchReset() {
	const timer = setInterval(async () => {
		try {
			const data = (await axios.get('/json/training/status')).data;
			if (data.reset_status?.state === 'running') return;
			clearInterval(timer);
			resetting.value = false;
			status.value = data;
			if (data.reset_status?.state === 'failed') error.value = 'A redefinição falhou: ' + data.reset_status.error;
			else notice.value = 'Redefinição concluída.';
		} catch (e) {
			const code = e.response?.status;
			if (code === 401 || code === 419) {
				clearInterval(timer);
				window.location.href = '/login';
			} // 503 (being rebuilt) or a dropped connection: still going
		}
	}, 3000);
}

function archiveTime(stamp) {
	const [d, t] = stamp.split('_');
	return new Date(d + 'T' + t.slice(0, 2) + ':' + t.slice(2, 4) + ':' + t.slice(4, 6)).toLocaleString();
}

async function prepare() {
	if (!confirmingPrepare.value) {
		confirmingPrepare.value = true;
		return;
	}
	error.value = notice.value = null;
	confirmingPrepare.value = false;
	preparing.value = true;
	try {
		const { data } = await axios.post('/json/training/prepare');
		notice.value = 'Dados de treinamento preparados. Imprima o pacote de configuração inicial e as etiquetas abaixo.'
			+ (data.warnings?.length ? ' ' + data.warnings.join(' ') : '');
		await load();
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível preparar os dados de treinamento.';
	} finally {
		preparing.value = false;
	}
}

async function addTrainee() {
	error.value = notice.value = null;
	try {
		status.value = (await axios.post('/json/training/trainees', newTrainee.value)).data;
		notice.value = newTrainee.value.first_name + ' ' + newTrainee.value.last_name + ' added.';
		newTrainee.value = { first_name: '', last_name: '', team: newTrainee.value.team };
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível adicionar essa pessoa em treinamento.';
	}
}

async function updateTrainee(trainee, changes) {
	error.value = notice.value = null;
	try {
		status.value = (await axios.patch('/json/training/trainees/' + trainee.id, changes)).data;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível atualizar essa pessoa em treinamento.';
	}
}

async function uploadSignature(slot, input) {
	const file = input.files[0];
	if (!file) return;
	error.value = notice.value = null;
	uploadingSlot.value = slot;
	try {
		const form = new FormData();
		form.append('signature', file);
		status.value = (await axios.post('/json/training/signatures/' + slot, form)).data;
		notice.value = 'Assinatura enviada.';
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível enviar essa assinatura.';
	} finally {
		uploadingSlot.value = null;
		input.value = '';
	}
}

async function removeSignature(slot) {
	error.value = notice.value = null;
	try {
		status.value = (await axios.delete('/json/training/signatures/' + slot)).data;
	} catch (e) {
		error.value = e.response?.data?.message || 'Não foi possível remover essa assinatura.';
	}
}

function formatTime(value) {
	return value ? new Date(value).toLocaleString() : '';
}

onMounted(async () => {
	await load();
	if (status.value?.reset_status?.state === 'running') {
		resetting.value = true;
		watchReset();
	}
});
</script>

<template>
	<Head title="Armazém de treinamento" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">Armazém de treinamento</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>
			<p v-if="!status && !error" class="text-gray-500">Carregando…</p>

			<template v-if="status">
				<!-- ======================= THIS WAREHOUSE ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Este é um armazém de treinamento</h2>
					<p class="text-sm text-gray-700">
						Tudo o que for registrado aqui são dados de prática e nunca se mistura com um armazém real. Um dispositivo aprovado mostra
						um acesso em que a pessoa em treinamento toca no próprio nome — sem senha — e pode fazer o que a função Pessoa em treinamento
						permite (atividades nas estações e relatórios; nada na configuração inicial). Para fechar este armazém depois da aula, peça à pessoa responsável pela
						instância que o desative (<span class="font-mono">php artisan warehouse:training disable</span>); os dados serão mantidos até a redefinição.
					</p>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<div class="border rounded p-3">
							<div class="text-gray-500">Dispositivos aprovados</div>
							<div class="text-lg font-semibold">{{ status.approved_devices }}</div>
						</div>
						<div class="border rounded p-3">
							<div class="text-gray-500">Pessoas na lista de treinamento</div>
							<div class="text-lg font-semibold">{{ status.trainees.filter((t) => t.active).length }}</div>
						</div>
					</div>
					<div v-if="resetting" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
						Redefinindo este armazém… Ele ficará indisponível por um ou dois minutos e todos sairão do sistema ao final.
						Esta página abrirá a tela de acesso automaticamente.
					</div>
					<div v-else class="space-y-3">
						<button v-if="!confirmingReset" type="button"
							class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500"
							@click="confirmingReset = true; resetText = ''">Redefinir este armazém…</button>
						<div v-if="confirmingReset" class="border border-red-300 bg-red-50 rounded p-4 space-y-2 text-sm">
							<p class="font-semibold text-red-800">Esta ação apaga tudo o que foi registrado neste armazém e o recria a partir dos dados iniciais.</p>
							<p>
								Doações, pedidos, paletes e estoque de prática, pessoas em treinamento e inscrições, fichas de avaliação, itens adicionados à
								lista principal de itens, fotos enviadas e dispositivos aprovados serão apagados. <strong>Serão mantidos:</strong> as pessoas que entram aqui (com suas
								funções), os detalhes e as assinaturas dos certificados e os arquivos da turma. Nada fora deste armazém será alterado.
							</p>
							<p>
								Antes, será salvo um <strong>arquivo da turma</strong>: a lista de acompanhamento das inscrições, as fichas de avaliação (PDF e CSV) e
								os certificados. Depois, baixe-o abaixo.
							</p>
							<label class="block">Digite <strong>RESET</strong> para confirmar:
								<input v-model="resetText" class="ml-2 border-gray-300 rounded-md shadow-sm text-sm py-1 w-32" autocomplete="off" />
							</label>
							<div class="flex gap-3">
								<button type="button" :disabled="resetText.trim() !== 'RESET'" @click="startReset"
									class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500 disabled:opacity-50">
									Redefinir agora</button>
								<button type="button" class="text-sm underline" @click="confirmingReset = false">Cancelar</button>
							</div>
						</div>
					</div>
					<div v-if="status.reset_status?.state === 'failed' && !resetting" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
						A última redefinição falhou: {{ status.reset_status.error }}
					</div>
					<p class="text-xs text-gray-500">
						Para aprovar um tablet, entre nele e selecione <strong>Acesso por PIN neste dispositivo</strong> no
						menu do perfil (o mesmo PIN de aprovação usado no desbloqueio; solicitações de outras pessoas ficam aguardando em
						<Link href="/setup/pin-login" class="underline">Acesso por PIN</Link>). A equipe ainda pode entrar em um dispositivo de treinamento com seu
						PIN ou e-mail pelos links abaixo dos nomes.
					</p>
				</section>

				<!-- ======================= SELF SIGN-UP ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Página de inscrição</h2>
					<p class="text-sm text-gray-700">
						As pessoas se inscrevem pelo próprio celular: informam o nome e, opcionalmente, e-mail, telefone, se
						gostariam de receber novidades do projeto, como gostariam de ajudar e alguém que recomendariam. Cada
						inscrição é adicionada diretamente à lista de pessoas em treinamento. A página só aceita inscrições enquanto o
						Modo de treinamento está ativado e não inicia sessão de ninguém.
					</p>
					<div class="flex flex-wrap items-center gap-6">
						<div class="w-40 h-40 shrink-0 [&>svg]:w-full [&>svg]:h-full" v-html="status.signup.qr_svg"></div>
						<div class="space-y-3 text-sm">
							<div><a :href="status.signup.url" target="_blank" class="font-mono text-blue-600 underline break-all">{{ status.signup.url }}</a></div>
							<div class="grid grid-cols-2 gap-4">
								<div class="border rounded p-3">
									<div class="text-gray-500">Inscrições de hoje</div>
									<div class="text-lg font-semibold">{{ status.signup.today }}</div>
								</div>
								<div class="border rounded p-3">
									<div class="text-gray-500">Total</div>
									<div class="text-lg font-semibold">{{ status.signup.total }}</div>
								</div>
							</div>
							<div class="flex flex-wrap gap-2">
								<PrintMenu document-key="training-signup-poster" media="report" variant="form" label="Cartaz com QR code"
									download-href="/report/training/signup-poster.pdf" />
								<a :href="$withWarehouse('/report/training/signups.csv')" class="ri_formbutton">Lista de acompanhamento (CSV)</a>
								<button type="button" class="ri_formbutton" @click="load">Atualizar</button>
							</div>
						</div>
					</div>
					<p class="text-xs text-gray-500">
						Configure seu link curto para apontar para o endereço acima. A lista de acompanhamento contém as respostas de todos
						(dados de contato, novidades, formas de ajudar e recomendações).
					</p>
				</section>

				<!-- ======================= PREPARE ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Preparar treinamento</h2>
					<p class="text-sm text-gray-700">
						As estações de Recebimento e Triagem usam seus próprios produtos, que não são escaneados: disponha as caixas para recebimento, e as equipes
						fazem a triagem do que receberem. A preparação do treinamento adiciona ofertas correspondentes a essas entregas. Os produtos
						que já estarão no armazém — na mesa da área de triagem, em bandejas fechadas nos espaços de mesa com pedidos para separar e em pedidos separados aguardando expedição (estações 3 a 5) — são os que você deve escanear primeiro, para que o
						sistema saiba exatamente o que há no local. Cada equipe também terá uma pessoa motorista. Depois da primeira estação, cada equipe
						trabalha com os produtos que manipulou uma estação antes. O pacote de configuração inicial informa quais produtos escaneados
						devem ser colocados em cada espaço ou carga, com uma lista de conteúdo para cada um e uma placa para cada estação.
					</p>
					<div class="flex flex-wrap items-center gap-4 border rounded p-3 text-sm">
						<div><span class="text-lg font-semibold">{{ status.products.units }}</span> de {{ status.products.plan.target }} itens escaneados</div>
						<div><span class="text-lg font-semibold">{{ status.products.distinct }}</span> de {{ status.products.plan.min_products }} produtos diferentes</div>
						<Link href="/setup/training/products" class="ri_defaultbutton">Escanear produtos para treinamento</Link>
					</div>
					<div v-if="preparing" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">Preparando dados de treinamento…</div>
					<div class="flex flex-wrap items-center gap-3">
						<button type="button" :disabled="preparing || status.products.units < status.products.plan.target" @click="prepare"
							class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white disabled:opacity-50"
							:class="confirmingPrepare ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'">
							{{ confirmingPrepare ? 'Confirmar — adiciona um conjunto completo de registros de treinamento' : 'Preparar treinamento' }}
						</button>
						<button v-if="confirmingPrepare" type="button" class="text-sm underline" @click="confirmingPrepare = false">Cancelar</button>
						<template v-if="status.prepared">
							<PrintMenu document-key="training-setup-packet" media="report" variant="form" label="Pacote de configuração inicial"
								download-href="/report/training/setup-packet.pdf" />
							<PrintMenu document-key="training-pallet-labels" :media="$page.props.printing.palletLabelMedia" variant="form"
								label="Etiquetas de palete" download-href="/report/training/pallet-labels.pdf" />
						</template>
						<PrintMenu document-key="training-spot-labels" :media="$page.props.printing.palletLabelMedia" variant="form"
							label="Etiquetas dos espaços de mesa" download-href="/report/training/spot-labels.pdf" />
					</div>
					<p v-if="status.products.units < status.products.plan.target" class="text-sm text-gray-500">
						Escaneie pelo menos {{ status.products.plan.target }} itens primeiro (faltam {{ status.products.plan.target - status.products.units }}).
					</p>
					<p class="text-xs text-gray-500">
						Última preparação: <span class="font-mono">{{ status.prepared_at ? formatTime(status.prepared_at) : 'nunca' }}</span>.
						Executar novamente adiciona outro conjunto completo com os mesmos produtos escaneados (nada é removido).
						A quantidade de itens de cada estação é definida em <span class="font-mono">config/training.php</span>.
						As etiquetas dos espaços de mesa (A-1 a C-4, com um código de barras para escanear na Movimentação de estoque) são impressas em
						etiquetas para paletes.
					</p>
				</section>

				<!-- ======================= TEAM SHEETS & REPORT CARDS ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Folhas das equipes e fichas de avaliação</h2>
					<div class="flex flex-wrap items-center gap-3">
						<PrintMenu document-key="training-all-teams" media="report" variant="form" label="Folhas de todas as equipes"
							download-href="/report/training/team-sheets.pdf" />
						<Link href="/reports/training" class="ri_formbutton">Fichas de avaliação e certificados</Link>
					</div>
					<h3 class="font-semibold">Certificados</h3>
					<form class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm" @submit.prevent="saveEvent">
						<label class="block">
							<span class="text-gray-700">Nome do evento de treinamento</span>
							<input v-model="event.event_title" maxlength="150" placeholder="Treinamento prático em armazém"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Local da aula</span>
							<input v-model="event.event_location" maxlength="150" placeholder="Ex.: Armazém de Statesville, Statesville, NC"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<div v-for="trainer in status.trainers" :key="trainer.slot" class="border rounded p-3 space-y-2">
							<label class="block">
								<span class="text-gray-700">Assinatura {{ trainer.slot === 1 ? 'esquerda' : 'direita' }} — nome da pessoa instrutora</span>
								<input v-model="event['trainer' + trainer.slot + '_name']" maxlength="100" placeholder="Pessoa instrutora"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<div class="h-16 border border-dashed rounded flex items-center justify-center bg-gray-50">
								<img v-if="trainer.has_signature" :src="'/json/training/signatures/' + trainer.slot + '?v=' + trainer.signature_version"
									alt="Assinatura" class="max-h-14 max-w-full" />
								<span v-else class="text-xs text-gray-400">Sem assinatura — a linha será impressa em branco para assinatura manual</span>
							</div>
							<div class="flex flex-wrap items-center gap-3">
								<label class="ri_formbutton cursor-pointer">
									{{ uploadingSlot === trainer.slot ? 'Enviando…' : (trainer.has_signature ? 'Substituir assinatura' : 'Enviar assinatura') }}
									<input type="file" accept="image/png,image/jpeg" class="hidden" :disabled="uploadingSlot !== null"
										@change="uploadSignature(trainer.slot, $event.target)" />
								</label>
								<button v-if="trainer.has_signature" type="button" class="text-sm underline" @click="removeSignature(trainer.slot)">Remover</button>
							</div>
						</div>
						<div class="sm:col-span-2"><PrimaryButton :disabled="savingEvent">{{ savingEvent ? 'Salvando…' : 'Salvar detalhes do certificado' }}</PrimaryButton></div>
					</form>
					<p class="text-xs text-gray-500">
						O certificado informa que a pessoa concluiu o treinamento <em>título</em>, realizado em <em>local</em> na <em>data</em>, com as linhas de assinatura das duas
						pessoas instrutoras nos cantos inferiores esquerdo e direito. Se o título ficar em branco, será usado “Treinamento
						prático em armazém”; o local será omitido e cada linha será identificada como “Pessoa instrutora”. As assinaturas devem estar em PNG ou JPEG
						(até 2 MB) — funciona bem uma digitalização ou foto de uma assinatura em papel branco, cortada rente; um PNG com
						fundo transparente fica melhor. O envio da assinatura tem efeito imediato; os nomes precisam ser salvos.
					</p>
					<p class="text-xs text-gray-500">
						A folha de cada equipe também pode ser impressa na página <Link href="/help" class="underline">Ajuda</Link>.
						Imprima as folhas depois de preparar o treinamento para incluir os dados de acesso da pessoa motorista de cada equipe.
					</p>
				</section>

				<!-- ======================= CLASS ARCHIVES ======================= -->
				<section v-if="status.archives.length" class="bg-white shadow rounded-lg p-6 space-y-3">
					<h2 class="text-lg font-semibold">Arquivos das turmas</h2>
					<p class="text-sm text-gray-700">Salvos antes de cada redefinição para o estado anterior ao treinamento e da restauração do banco de dados.</p>
					<table class="ri_datatable w-full text-sm" border="1">
						<thead><tr><th>Salvo em</th><th>Arquivos</th></tr></thead>
						<tbody>
							<tr v-for="a in status.archives" :key="a.stamp">
								<td>{{ archiveTime(a.stamp) }}</td>
								<td>
									<a v-for="f in a.files" :key="f.name" :href="$withWarehouse('/report/training/archives/' + a.stamp + '/' + f.name)"
										class="underline text-blue-700 mr-4">{{ f.label }}</a>
								</td>
							</tr>
						</tbody>
					</table>
				</section>

				<!-- ======================= TRAINEES ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">Pessoas em treinamento</h2>
					<form class="grid grid-cols-1 sm:grid-cols-4 gap-4 text-sm items-end" @submit.prevent="addTrainee">
						<label class="block">
							<span class="text-gray-700">Nome</span>
							<input v-model="newTrainee.first_name" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Sobrenome</span>
							<input v-model="newTrainee.last_name" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">Equipe</span>
							<select v-model="newTrainee.team" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option :value="null">Escolher ao entrar</option>
								<option v-for="n in status.teams" :key="n" :value="n">Equipe {{ n }}</option>
							</select>
						</label>
						<div><PrimaryButton>Adicionar pessoa</PrimaryButton></div>
					</form>

					<label class="text-sm flex items-center gap-2">
						<input type="checkbox" v-model="showInactive" /> Mostrar pessoas removidas da lista
					</label>

					<p v-if="!trainees.length" class="text-sm text-gray-400">Nenhuma pessoa ainda — adicione aqui ou use “Adicionar novo” em um dispositivo de treinamento.</p>
					<table v-else class="ri_datatable w-full text-sm" border="1">
						<thead><tr><th>Nome</th><th>Equipe</th><th>Ações de hoje</th><th></th></tr></thead>
						<tbody>
							<tr v-for="t in trainees" :key="t.id" :class="{ 'text-gray-400': !t.active }">
								<td>{{ t.full_name }}</td>
								<td>
									<select :value="t.team" class="border-gray-300 rounded-md shadow-sm text-sm py-1"
										@change="updateTrainee(t, { team: $event.target.value ? Number($event.target.value) : null })">
										<option value="">—</option>
										<option v-for="n in status.teams" :key="n" :value="n">Equipe {{ n }}</option>
									</select>
								</td>
								<td>{{ t.actions_today }}</td>
								<td>
									<button type="button" class="text-sm underline" @click="updateTrainee(t, { active: !t.active })">
										{{ t.active ? 'Remover da lista' : 'Adicionar novamente à lista' }}
									</button>
								</td>
							</tr>
						</tbody>
					</table>
					<p class="text-xs text-gray-500">
						Remover uma pessoa da lista tira seu nome da tela de acesso e impede que ela entre; sua
						atividade e ficha de avaliação são mantidas.
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
