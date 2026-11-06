<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details

	Where GuardWarehouseTab sends a tab that tried to act on a warehouse the browser no longer uses (another tab
	switched warehouses). Nothing was changed; the visitor continues in the warehouse the browser is on now.
-->

<script setup>
import GuestLayout from '@/Layouts/GuestLayout.vue';
import { Head, Link, usePage } from '@inertiajs/vue3';

const warehouse = usePage().props.warehouse;
</script>

<template>
	<Head title="Armazém alterado" />
	<GuestLayout>
		<div class="space-y-4">
			<h1 class="text-lg font-bold">Este navegador mudou de armazém</h1>
			<p class="text-gray-700">
				A página que você estava usando pertencia a outro armazém, diferente do que este navegador está usando agora,
				provavelmente porque outra aba mudou de armazém. Nenhuma alteração foi feita.
			</p>
			<p class="text-gray-700">
				Este navegador está usando <strong>{{ warehouse?.name }}</strong>. Armazéns no mesmo endereço compartilham
				uma única sessão por vez. Use um armazém por navegador (ou uma janela privativa para o outro).
			</p>
			<Link href="/dashboard" class="inline-block px-4 py-2 bg-gray-800 text-white rounded">
				Continuar em {{ warehouse?.name }}
			</Link>
		</div>
	</GuestLayout>
</template>
