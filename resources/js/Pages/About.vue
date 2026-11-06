<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- About.vue

	Public "About This Project" page, linked from Welcome.vue's HOSTED_BY
	credit line (config('app.hosted_link'), typically pointed at this page
	via a relative /about URL rather than an external domain — see
	routes/web/public.php). No auth required, matching Welcome's own guest access.
-->

<script setup>
import { Head } from '@inertiajs/vue3';
</script>

<template>
	<Head title="Sobre este projeto" />
	<div class="min-h-screen bg-gray-50 flex flex-col">
		<header class="bg-white shadow-md">
			<div class="container mx-auto px-4 py-4 flex justify-between items-center">
				<a href="/" class="text-2xl font-bold text-blue-600">Relief Inventory</a>
				<nav class="space-x-4">
					<a href="/" class="text-gray-700 hover:text-blue-600">Início</a>
					<a href="/login" class="text-gray-700 hover:text-blue-600">Entrar</a>
				</nav>
			</div>
		</header>

		<section class="flex-1">
			<div class="container mx-auto px-4 py-16 max-w-3xl">
				<h1 class="text-4xl font-bold text-gray-800 mb-6">Sobre este projeto</h1>

				<div class="prose prose-lg text-gray-700 space-y-6">
					<p>
						O Relief Inventory surgiu durante a resposta ao furacão Helene, no oeste da Carolina
						do Norte. Um armazém de ajuda humanitária precisava de uma forma precisa e ágil de
						acompanhar as doações recebidas, encaminhar decisões de aprovação e gerenciar os
						envios — mas nenhuma solução disponível atendia às necessidades específicas de um
						armazém de doações. Para dar conta do trabalho, improvisaram um sistema no Google
						Planilhas, que foi sendo reformulado conforme a situação evoluía. Logo suas limitações
						ficaram evidentes, e começou o trabalho em algo melhor — não a partir de uma
						especificação, mas de uma conversa entre as pessoas que realmente operavam o armazém.
						Dessa colaboração começou a surgir uma estrutura para acompanhar uma doação desde a
						oferta inicial até a entrega a um ponto de distribuição, registrando também as horas
						de voluntariado.
					</p>
					<p>
						Essa colaboração continua desde então, junto com a Adventist Community Services e as
						pessoas voluntárias e funcionárias que usam o sistema no dia a dia. O software foi
						moldado menos por uma especificação prévia e mais pelas operações reais — começou a
						ser usado enquanto ainda estava em desenvolvimento, e a maioria dos recursos atuais —
						desde o salvamento automático de cada linha durante a triagem, para que uma queda de
						conexão não faça perder uma leitura, até o fluxo de separação, envio e entrega de um
						pedido — surgiu de uma necessidade concreta durante o trabalho, não de uma ideia que
						parecia boa no papel.
					</p>

					<h2 class="text-2xl font-semibold text-gray-800 pt-4">Próximos passos</h2>
					<p>
						O ponto de partida deste projeto foi o estoque: o que entrou, o que está disponível e
						o que saiu. Isso é necessário, mas, por si só, é apenas um banco de dados — e um banco
						de dados não ajuda uma pessoa voluntária nova a saber o que fazer em seguida, não
						registra por que uma doação precisa ser revisada e não se adapta quando dois armazéns
						organizam suas operações de maneiras diferentes por bons motivos.
					</p>
					<p>
						O projeto está caminhando para um software que <strong>orienta o trabalho</strong>,
						em vez de apenas registrá-lo — um sistema que conduz as pessoas pela próxima etapa,
						em vez de apresentar um formulário vazio e várias listas de opções, e que integra o
						treinamento às telas usadas no dia a dia, em vez de depender de um manual separado que
						ninguém tem tempo de ler durante uma operação de resposta.
					</p>
					<p>
						Tão importante quanto isso: cada armazém e cada incidente são diferentes. Um local
						pequeno, operado por pessoas voluntárias, não funciona da mesma forma que um grande
						ponto de distribuição com várias organizações. Uma ferramenta que força ambos a seguir
						um único fluxo rígido acaba atrapalhando quem a utiliza. O objetivo é oferecer
						flexibilidade desde o início — com configurações que permitam ao processo real do
						armazém orientar o funcionamento do software, e não o contrário.
					</p>
					<p>
						Este projeto continua em desenvolvimento, é construído de forma aberta e é aprimorado
						continuamente com base no que acontece na prática.
					</p>
				</div>
			</div>
		</section>

		<footer class="bg-white border-t">
			<div class="container mx-auto px-4 py-6 text-center text-gray-600">
				&copy; {{ new Date().getFullYear() }} Relief Inventory Project,
				<a href="https://www.gnu.org/licenses/gpl-3.0.en.html">Licenciado sob a GNU General Public License v. 3</a>
			</div>
		</footer>
	</div>
</template>
