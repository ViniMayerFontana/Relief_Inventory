<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<script setup>
import { Head, Link } from '@inertiajs/vue3';
import { t } from '@/i18n';

defineProps({
    canLogin: {
        type: Boolean,
    },
    canRegister: {
        type: Boolean,
    },
    hostedBy: {
        type: String,
    },
    hostedLink: {
        type: String,
    },
    laravelVersion: {
        type: String,
        required: true,
    },
    phpVersion: {
        type: String,
        required: true,
    },
});

function handleImageError() {
    document.getElementById('screenshot-container')?.classList.add('!hidden');
    document.getElementById('docs-card')?.classList.add('!row-span-1');
    document.getElementById('docs-card-content')?.classList.add('!flex-row');
    document.getElementById(t('Commons.text.background'))?.classList.add('!hidden');
}
</script>

<template>
  <div class="planck-theme min-h-screen bg-planck-base flex flex-col">
    <!-- Header -->
    <header class="bg-planck-surface shadow-md">
      <div class="container mx-auto px-4 py-4 flex justify-between items-center">
        <h1 class="text-xl sm:text-2xl font-bold text-planck-brand whitespace-nowrap">{{ $t('Commons.heading.relief_inventory', {}) }}</h1>
        <nav class="whitespace-nowrap">
          <a href="/login" class="text-planck-text-secondary hover:text-planck-brand">{{ $t('Commons.button.login', {}) }}</a>
        </nav>
      </div>
    </header>

    <!-- Hero Section -->
    <section class="flex-1 bg-planck-secondary">
      <div class="container mx-auto px-4 py-16 text-center md:text-left md:flex md:items-center">
        <div class="md:w-1/2">
          <h2 class="text-4xl md:text-5xl font-bold text-planck-text-primary mb-6">
            {{ $t('Pages.heading.welcome_to_relief_inventory', {}) }}
          </h2>
          <p class="text-planck-text-secondary text-lg mb-8">
            {{ $t('Pages.text.manage_and_track_donations', {}) }}
          </p>
          <div class="space-x-4">
	    <a href="/login">
	      <button class="bg-planck-brand text-white px-6 py-3 rounded-lg shadow hover:bg-planck-brand-hover">
                {{ $t('Commons.button.login', {}) }}
              </button>
	    </a>
	    <a href="/register">
              <button class="bg-white/5 text-planck-text-primary px-6 py-3 rounded-lg shadow ring-1 ring-planck-line hover:bg-planck-surface-hover">
                {{ $t('Commons.button.register', {}) }}
              </button>
	    </a>
          </div>
        </div>
        <div class="mt-8 md:mt-0 md:w-1/2 flex flex-col items-center">
          <img src="/img/warehouse.webp" :alt="$t('Commons.alt.welcome_illustration')" class="w-3/4 md:w-full max-w-md">
          <a href="/driver-portal" class="welcome_driverportal mt-6">
            <img src="/img/truck-box-icon.webp" alt="" class="welcome_driverportal_icon">
            <span class="welcome_driverportal_label">{{ $t('Commons.heading.driver_portal', {}) }}</span>
          </a>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="bg-planck-surface border-t border-planck-line">
      <div class="container mx-auto px-4 py-6 text-center text-planck-text-secondary">
	      &copy;  {{ new Date().getFullYear() }} {{ $t('Pages.text.inventory_relief_project') }} 
	      <a href="https://www.gnu.org/licenses/gpl-3.0.en.html">{{ $t('Pages.link.licensed_under_the_gnu', {}) }}</a>
	      {{ $t('Commons.text.hosted_by', {}) }} <a :href="hostedLink" target="_blank">{{ hostedBy }}</a>
      </div>
    </footer>
  </div>
</template>

<script>import { t } from '@/i18n';


export default {
  name: t('Commons.text.welcome'),
};
</script>

<style>
/* Add custom styles if necessary */

/* Matches TileSelect.vue's icon+label tile styling (see Receiving's Truck
   Size picker) — a plain, no-frills button so it reads as a distinct,
   equally-weighted action next to the hero image rather than competing
   with the Login/Register CTAs. */
.welcome_driverportal {
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 0.35em;
	padding: 0.6em 1.2em;
	border-radius: 10px;
	text-decoration: none;
}
.welcome_driverportal:hover {
	background: rgba(255, 255, 255, 0.08);
}
.welcome_driverportal_icon {
	width: 64px;
	height: 64px;
	object-fit: contain;
	border-radius: 12px;
}
.welcome_driverportal_label {
	font-size: 0.9rem;
	font-weight: bold;
	color: var(--text-primary);
}
</style>

