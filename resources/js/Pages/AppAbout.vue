<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- AppAbout.vue

	Reached from "About" in the profile menu (AuthenticatedLayout.vue); route /about-this-install in routes/web/account.php.
	The version is the release tag (GitVersionService::release()) — null means an unversioned source install.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';

defineProps({
	version: { type: String, default: null },
	commit: { type: String, default: null },
	docker: { type: Boolean, default: false },
});
</script>

<template>
	<Head title="Sobre esta instalação" />
	<AuthenticatedLayout>
		<div class="max-w-3xl mx-auto p-6 space-y-6">
			<h1 class="text-2xl font-semibold">Sobre o Relief Inventory</h1>

			<section class="bg-white shadow rounded-lg p-6 space-y-3 text-sm text-gray-700">
				<p>
					O Relief Inventory é um sistema de gerenciamento de armazéns para ajuda humanitária.
					Ele acompanha os itens doados desde a chegada, passando pela triagem e organização em
					prateleiras e paletes, até os pedidos das entidades parceiras e os envios que os atendem.
				</p>
				<p>
					O sistema foi desenvolvido originalmente com a Adventist Community Services.
					<a href="/about" class="text-blue-700 underline">História do projeto</a>
					conta como ele começou e quais são seus próximos passos.
				</p>
			</section>

			<section class="bg-white shadow rounded-lg p-6 space-y-2 text-sm text-gray-700">
				<h2 class="text-lg font-semibold">Esta instalação</h2>
				<p>
					Versão:
					<span v-if="version" class="font-semibold">{{ version }}</span>
					<span v-else class="text-gray-500">sem versão (instalada a partir do código-fonte)</span>
				</p>
				<p v-if="commit">Commit: <span class="font-mono">{{ commit }}</span></p>
				<p>Executando em: {{ docker ? 'um contêiner Docker' : 'uma instalação padrão (sem Docker)' }}</p>
			</section>

			<section class="bg-white shadow rounded-lg p-6 space-y-3 text-sm text-gray-700">
				<h2 class="text-lg font-semibold">Software livre</h2>
				<p>
					O Relief Inventory é um software livre, licenciado sob a
					<a href="https://www.gnu.org/licenses/gpl-3.0.html" target="_blank" rel="noopener"
						class="text-blue-700 underline">GNU General Public License, versão 3</a>.
					Você pode executar sua própria cópia gratuitamente, para qualquer finalidade, além de
					estudar e modificar o código-fonte. Se compartilhar uma versão modificada, os mesmos
					termos de licença também se aplicam a ela.
				</p>
				<p>
					O programa é fornecido sem garantia, na medida permitida por lei. O texto completo da
					licença está no arquivo LICENSE.md do código-fonte.
				</p>
				<p>
					Código-fonte, downloads e instruções de instalação:
					<a href="https://github.com/fiforms/reliefinventory" target="_blank" rel="noopener"
						class="text-blue-700 underline">github.com/fiforms/reliefinventory</a>
				</p>
				<p>
					Site do projeto:
					<a href="https://reliefinventory.app" target="_blank" rel="noopener"
						class="text-blue-700 underline">reliefinventory.app</a>
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
