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
	<Head :title="$t('Pages.title.about_this_installation')" />
	<AuthenticatedLayout>
		<div class="max-w-3xl mx-auto p-6 space-y-6">
			<h1 class="text-2xl font-semibold">{{ $t('Pages.heading.about_relief_inventory', {}) }}</h1>

			<section class="bg-white shadow rounded-lg p-6 space-y-3 text-sm text-gray-700">
				<p>
					{{ $t('Pages.text.relief_inventory_is_a', {}) }}
				</p>
				<p>
					{{ $t('Pages.text.it_was_originally_built', {}) }}
					<a href="/about" class="text-blue-700 underline">{{ $t('Commons.link.project_history', {}) }}</a>
					{{ $t('Pages.text.tells_the_story_of', {}) }}
				</p>
			</section>

			<section class="bg-white shadow rounded-lg p-6 space-y-2 text-sm text-gray-700">
				<h2 class="text-lg font-semibold">{{ $t('Commons.heading.this_installation', {}) }}</h2>
				<p>
					{{ $t('Commons.text.version_2', {}) }}
					<span v-if="version" class="font-semibold">{{ version }}</span>
					<span v-else class="text-gray-500">unversioned (installed from source)</span>
				</p>
				<p v-if="commit">{{ $t('Commons.text.commit_2', {}) }} <span class="font-mono">{{ commit }}</span></p>
				<p>{{ $t('Commons.text.running_in') }} {{ docker ? $t('Pages.text.a_docker_container') : $t('Pages.text.a_standard_non_docker') }}</p>
			</section>

			<section class="bg-white shadow rounded-lg p-6 space-y-3 text-sm text-gray-700">
				<h2 class="text-lg font-semibold">{{ $t('Commons.heading.free_software', {}) }}</h2>
				<p>
					{{ $t('Pages.text.relief_inventory_is_free', {}) }}
					<a href="https://www.gnu.org/licenses/gpl-3.0.html" target="_blank" rel="noopener"
						class="text-blue-700 underline">{{ $t('Pages.link.gnu_general_public_license', {}) }}</a>.
					You can run your own copy for free, for any purpose, and you can study and modify
					the source code. If you share a modified version, the same license terms apply to it.
				</p>
				<p>
					{{ $t('Pages.text.the_program_comes_with', {}) }}
				</p>
				<p>
					{{ $t('Pages.text.source_code_downloads_and', {}) }}
					<a href="https://github.com/fiforms/reliefinventory" target="_blank" rel="noopener"
						class="text-blue-700 underline">github.com/fiforms/reliefinventory</a>
				</p>
				<p>
					{{ $t('Commons.text.project_website', {}) }}
					<a href="https://reliefinventory.app" target="_blank" rel="noopener"
						class="text-blue-700 underline">reliefinventory.app</a>
				</p>
			</section>
		</div>
	</AuthenticatedLayout>
</template>
