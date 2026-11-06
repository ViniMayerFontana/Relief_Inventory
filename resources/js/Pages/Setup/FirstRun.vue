<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!--
	FirstRun.vue — the first-run setup wizard at /install (SetupController).

	Only reachable while the instance has no administrator and the setup latch is
	unset (FirstRunService::needsSetup); RedirectToSetup sends every other page
	here until it's done. Two client-side steps, one POST at the end — unlike the
	long-running scan/entry screens this is a single short write, so there is no
	per-step autosave: nothing exists server-side until "Finish setup".
-->

<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import RestoreBackup from './RestoreBackup.vue';
import { Head, useForm } from '@inertiajs/vue3';
import { computed, onBeforeUnmount, ref } from 'vue';

const props = defineProps({
	codeRequired: { type: Boolean, default: false },
});

// 'new' (the two-step wizard) or 'restore' (upload a backup instead)
const mode = ref('new');
const step = ref(1);
const form = useForm({
	first_name: '',
	last_name: '',
	email: '',
	password: '',
	password_confirmation: '',
	setup_code: '',
	// 'empty' | 'example' | 'simulation'
	starting_data: 'empty',
});

// Client-side check only to keep people from advancing with an obviously
// incomplete step; the server validates everything again on submit.
const localErrors = ref({});
const accountFields = ['first_name', 'last_name', 'email', 'password', 'password_confirmation', 'setup_code'];

function validateAccount() {
	const e = {};
	if (!form.first_name.trim()) e.first_name = 'Informe seu nome.';
	if (!form.last_name.trim()) e.last_name = 'Informe seu sobrenome.';
	if (!/^\S+@\S+\.\S+$/.test(form.email)) e.email = 'Informe um endereço de e-mail válido.';
	if (form.password.length < 8) e.password = 'Use pelo menos 8 caracteres.';
	if (form.password !== form.password_confirmation) e.password_confirmation = 'As senhas não coincidem.';
	if (props.codeRequired && !form.setup_code.trim()) e.setup_code = 'Informe o código de configuração definido no servidor.';
	localErrors.value = e;
	return Object.keys(e).length === 0;
}

// "Next" and "Finish setup" sit in the same spot, so a double-click on Next would
// land on Finish and provision the instance before a starting-data choice is made.
// Finish stays locked briefly after arriving on step 2.
const finishLocked = ref(false);
let finishTimer = null;

function next() {
	form.clearErrors();
	if (!validateAccount()) return;
	step.value = 2;
	finishLocked.value = true;
	clearTimeout(finishTimer);
	finishTimer = setTimeout(() => (finishLocked.value = false), 2000);
}

onBeforeUnmount(() => clearTimeout(finishTimer));

const err = (field) => localErrors.value[field] || form.errors[field];

const submit = () => {
	// Enter in a step 1 field must advance, not submit the whole wizard.
	if (step.value === 1) return next();
	if (finishLocked.value) return;
	form.post(route('setup.store'), {
		onError: (errors) => {
			// Server-side complaints about step 1 fields send you back to fix them.
			if (accountFields.some((f) => errors[f])) step.value = 1;
		},
		onFinish: () => form.reset('password', 'password_confirmation'),
	});
};

const stepTitle = computed(() => (step.value === 1 ? 'Criar conta de administrador' : 'Dados iniciais'));
</script>

<template>
	<GuestLayout>
		<Head title="Configuração inicial do Relief Inventory" />

		<h1 class="text-lg font-semibold text-gray-900">Bem-vindo ao Relief Inventory</h1>
		<template v-if="mode === 'restore'">
			<p class="mt-1 text-sm text-gray-600">Restaurar a partir de um backup</p>
			<RestoreBackup :code-required="codeRequired" @back="mode = 'new'" />
		</template>

		<template v-else>
		<p class="mt-1 text-sm text-gray-600">
			Esta é uma instalação nova. São apenas duas etapas rápidas.
			Vem de outro sistema?
			<button type="button" class="underline text-blue-700" @click="mode = 'restore'">Restaurar a partir de um backup</button>
		</p>

		<p class="mt-4 text-xs font-semibold uppercase tracking-wide text-gray-500">
			Step {{ step }} of 2 &middot; {{ stepTitle }}
		</p>

		<form @submit.prevent="submit">
			<!-- Step 1: administrator -->
			<div v-show="step === 1" class="mt-3">
				<p class="text-sm text-gray-600">
					Essa pessoa administrará o restante — os demais usuários, as permissões e as configurações
					serão adicionados pelo aplicativo depois.
				</p>

				<div class="mt-4 grid grid-cols-2 gap-3">
					<div>
						<InputLabel for="first_name" value="Nome" />
						<TextInput id="first_name" type="text" class="mt-1 block w-full" v-model="form.first_name" autofocus autocomplete="given-name" />
						<InputError class="mt-2" :message="err('first_name')" />
					</div>
					<div>
						<InputLabel for="last_name" value="Sobrenome" />
						<TextInput id="last_name" type="text" class="mt-1 block w-full" v-model="form.last_name" autocomplete="family-name" />
						<InputError class="mt-2" :message="err('last_name')" />
					</div>
				</div>

				<div class="mt-4">
					<InputLabel for="email" value="E-mail (usado para entrar)" />
					<TextInput id="email" type="email" class="mt-1 block w-full" v-model="form.email" autocomplete="username" />
					<InputError class="mt-2" :message="err('email')" />
				</div>

				<div class="mt-4">
					<InputLabel for="password" value="Senha" />
					<TextInput id="password" type="password" class="mt-1 block w-full" v-model="form.password" autocomplete="new-password" />
					<InputError class="mt-2" :message="err('password')" />
				</div>

				<div class="mt-4">
					<InputLabel for="password_confirmation" value="Confirme a senha" />
					<TextInput id="password_confirmation" type="password" class="mt-1 block w-full" v-model="form.password_confirmation" autocomplete="new-password" />
					<InputError class="mt-2" :message="err('password_confirmation')" />
				</div>

				<div v-if="codeRequired" class="mt-4">
					<InputLabel for="setup_code" value="Código de configuração" />
					<TextInput id="setup_code" type="password" class="mt-1 block w-full" v-model="form.setup_code" autocomplete="off" />
					<p class="mt-1 text-xs text-gray-500">Este servidor exige um código de configuração. No R Station, ele aparece no dispositivo em Configurações &gt; Servidor local; no Docker, é RI_SETUP_CODE no arquivo compose.</p>
					<InputError class="mt-2" :message="err('setup_code')" />
				</div>

				<div class="mt-6 flex justify-end">
					<PrimaryButton type="button" @click="next">Avançar</PrimaryButton>
				</div>
			</div>

			<!-- Step 2: starting data -->
			<div v-show="step === 2" class="mt-3">
				<p class="text-sm text-gray-600">
					As categorias, unidades e o catálogo de itens padrão já estão configurados. Escolha
					se deseja começar do zero ou usar dados de exemplo.
				</p>

				<label class="mt-4 flex cursor-pointer items-start gap-3 rounded border p-3" :class="form.starting_data === 'empty' ? 'border-blue-500 bg-blue-50' : 'border-gray-200'">
					<input type="radio" class="mt-1" value="empty" v-model="form.starting_data" />
					<span>
						<span class="block text-sm font-medium text-gray-900">Começar vazio <span class="text-xs font-normal text-blue-700">(recomendado para uso real)</span></span>
						<span class="block text-xs text-gray-600">Somente o catálogo padrão. Você cadastra seus próprios doadores, entidades parceiras e estoque.</span>
					</span>
				</label>

				<label class="mt-3 flex cursor-pointer items-start gap-3 rounded border p-3" :class="form.starting_data === 'example' ? 'border-blue-500 bg-blue-50' : 'border-gray-200'">
					<input type="radio" class="mt-1" value="example" v-model="form.starting_data" />
					<span>
						<span class="block text-sm font-medium text-gray-900">Carregar dados de exemplo</span>
						<span class="block text-xs text-gray-600">
							Doadores e entidades parceiras fictícios, doações em todas as etapas, estoque disponível e
							pedidos em todos os status — ideal para experimentar ou treinar.
						</span>
					</span>
				</label>

				<label class="mt-3 flex cursor-pointer items-start gap-3 rounded border p-3" :class="form.starting_data === 'simulation' ? 'border-blue-500 bg-blue-50' : 'border-gray-200'">
					<input type="radio" class="mt-1" value="simulation" v-model="form.starting_data" />
					<span>
						<span class="block text-sm font-medium text-gray-900">Simular um ano de atividades <span class="text-xs font-normal text-gray-600">(para testes)</span></span>
						<span class="block text-xs text-gray-600">
							Gera cerca de um ano de doações fictícias, triagem, pedidos de entidades parceiras, expedições e movimentações de estoque
							— aproximadamente 1.000 pedidos e mais de 10.000 movimentações de estoque. Ideal para testar telas,
							relatórios e desempenho com um volume realista de dados. Leva um ou dois minutos.
						</span>
					</span>
				</label>

				<p v-if="form.starting_data !== 'empty'" class="mt-3 rounded border border-amber-300 bg-amber-50 p-2 text-xs text-amber-900">
					Os dados de exemplo e simulados não podem ser removidos pelo aplicativo. Se mais tarde quiser uma instalação limpa,
					será necessário começar novamente com um banco de dados vazio. Não use esta opção em uma operação real.
				</p>

				<InputError class="mt-2" :message="form.errors.starting_data" />

				<div class="mt-6 flex items-center justify-between">
					<SecondaryButton type="button" @click="step = 1" :disabled="form.processing">Voltar</SecondaryButton>
					<PrimaryButton :class="{ 'opacity-25': form.processing || finishLocked }" :disabled="form.processing || finishLocked">
						{{ form.processing ? (form.starting_data === 'example' ? 'Configurando (carregando exemplos…)' : 'Configurando…') : 'Concluir configuração inicial' }}
					</PrimaryButton>
				</div>
			</div>
		</form>
		</template>
	</GuestLayout>
</template>
