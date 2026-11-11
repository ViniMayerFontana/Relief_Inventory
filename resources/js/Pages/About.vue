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
	<Head :title="$t('Pages.title.about_this_project')" />
	<div class="min-h-screen bg-gray-50 flex flex-col">
		<header class="bg-white shadow-md">
			<div class="container mx-auto px-4 py-4 flex justify-between items-center">
				<a href="/" class="text-2xl font-bold text-blue-600">{{ $t('Commons.heading.relief_inventory', {}) }}</a>
				<nav class="space-x-4">
					<a href="/" class="text-gray-700 hover:text-blue-600">{{ $t('Commons.link.home', {}) }}</a>
					<a href="/login" class="text-gray-700 hover:text-blue-600">{{ $t('Commons.button.login', {}) }}</a>
				</nav>
			</div>
		</header>

		<section class="flex-1">
			<div class="container mx-auto px-4 py-16 max-w-3xl">
				<h1 class="text-4xl font-bold text-gray-800 mb-6">{{ $t('Pages.heading.about_this_project', {}) }}</h1>

				<div class="prose prose-lg text-gray-700 space-y-6">
					<p>
						{{ $t('Pages.text.relief_inventory_began_during', {}) }}
					</p>
					<p>
						{{ $t('Pages.text.that_collaboration_has_continued', {}) }}
					</p>

					<h2 class="text-2xl font-semibold text-gray-800 pt-4">{{ $t('Pages.heading.where_this_is_headed', {}) }}</h2>
					<p>
						{{ $t('Pages.text.the_starting_point_for', {}) }}
					</p>
					<p>
						{{ $t('Pages.text.the_direction_this_project', {}) }} <strong>{{ $t('Pages.text.guides_the_work', {}) }}</strong>{{ $t('Pages.text.not_just_records_it', {}) }}
					</p>
					<p>
						{{ $t('Pages.text.just_as_important_every', {}) }}
					</p>
					<p>
						{{ $t('Pages.text.this_is_a_work', {}) }}
					</p>
				</div>
			</div>
		</section>

		<footer class="bg-white border-t">
			<div class="container mx-auto px-4 py-6 text-center text-gray-600">
				&copy; {{ new Date().getFullYear() }} {{ $t('Pages.text.relief_inventory_project') }}
				<a href="https://www.gnu.org/licenses/gpl-3.0.en.html">{{ $t('Pages.link.licensed_under_the_gnu', {}) }}</a>
			</div>
		</footer>
	</div>
</template>
