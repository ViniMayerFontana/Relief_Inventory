<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import Banner from '@/Components/Banner.vue';
import Dropdown from '@/Components/Dropdown.vue';
import DropdownLink from '@/Components/DropdownLink.vue';
import FeedbackReportModal from '@/Components/FeedbackReportModal.vue';
import NavLink from '@/Components/NavLink.vue';
import PrintToast from '@/Components/PrintToast.vue';
import ResponsiveNavLink from '@/Components/ResponsiveNavLink.vue';
import { Link, usePage } from '@inertiajs/vue3';
import { t } from '@/i18n';

const showingNavigationDropdown = ref(false);
const showingFeedbackModal = ref(false);

const page = usePage();
const unreadCount = ref(page.props.notifications.unreadCount);
const notificationRecords = ref([]);
const notificationsLoaded = ref(false);

function timeAgo(value) {
    const seconds = Math.max(0, Math.round((Date.now() - new Date(value)) / 1000));
    if (seconds < 60) return t('Commons.text.just_now');
    const minutes = Math.round(seconds / 60);
    if (minutes < 60) return t('Commons.text.p0_m_ago', { p0: minutes });
    const hours = Math.round(minutes / 60);
    if (hours < 24) return t('Commons.text.p0_h_ago', { p0: hours });
    return t('Commons.text.p0_d_ago', { p0: Math.round(hours / 24) });
}

async function loadNotifications() {
    const response = await axios.get('/json/notifications');
    notificationRecords.value = response.data.records;
    unreadCount.value = response.data.unread_count;
    notificationsLoaded.value = true;
}

async function markAllNotificationsRead() {
    await axios.post('/json/notifications/read-all');
    notificationRecords.value = notificationRecords.value.map((n) => ({ ...n, read_at: n.read_at || new Date().toISOString() }));
    unreadCount.value = 0;
}
</script>

<template>
    <div>
        <div class="min-h-screen bg-gray-100">
            <Banner @open-feedback="showingFeedbackModal = true" />
            <!-- A training warehouse (MULTI_WAREHOUSE.md §12): practice data, never real stock -->
            <div v-if="$page.props.warehouse?.training" class="bg-amber-100 text-amber-900 text-sm px-4 py-1">
                {{ $t('Layouts.text.training_warehouse_everything_here', {}) }}
            </div>
            <!-- Instance administrators, until the instance has a recovery key and they have confirmed storing it (HandleInertiaRequests::recoveryKeyProps) -->
            <div v-if="$page.props.recoveryKey" class="bg-red-100 text-red-900 text-sm px-4 py-2 border-b border-red-300">
                <template v-if="$page.props.recoveryKey.state === 'none'">
                    <strong>{{ $t('Layouts.text.set_up_your_recovery', {}) }}</strong>
                    {{ $t('Layouts.text.without_it_an_automatic', {}) }}
                </template>
                <template v-else>
                    <strong>{{ $t('Layouts.text.confirm_your_recovery_key', {}) }}</strong>
                    {{ $t('Layouts.text.it_was_made_but', {}) }}
                </template>
                <a href="/setup/instance?tab=backups" class="underline font-semibold ml-1">{{ $t('Layouts.link.open_instance_admin', {}) }}</a>
            </div>
            <PrintToast />

            <nav
                class="border-b border-gray-100 bg-white"
            >
                <!-- Primary Navigation Menu -->
                <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                    <div class="flex h-16 justify-between">
                        <div class="flex">
							<div class="space-x-8 sm:-my-px sm:ms-10 sm:flex" style="padding-top: 12px; font-size: 26px;">
							<a href="/dashboard">🚚</a>
							</div>
                            <!-- Navigation Links -->
                            <div
                                class="hidden space-x-8 sm:-my-px sm:ms-10 sm:flex" style="margin-left: 10px;"
                            >
                                <NavLink
                                    :href="route('dashboard')"
                                    :active="fullroute == '/dashboard' || fullroute == '/dashboard#main'"
                                >
                                    {{ $t('Layouts.text.relief_inventory_dashboard', {}) }}
                                </NavLink>
								<NavLink
								    v-for="crumb in breadcrumb"
								    :href="crumb.href"
									:active="fullroute == crumb.href"
								>
								    → {{ crumb.title }}
								</NavLink>
                            </div>
                        </div>

                        <div class="hidden sm:ms-6 sm:flex sm:items-center">
                            <!-- Notification Bell -->
                            <div class="relative ms-3">
                                <Dropdown align="right" width="96">
                                    <template #trigger>
                                        <button
                                            type="button"
                                            class="relative inline-flex items-center rounded-md border border-transparent bg-white px-3 py-2 text-sm font-medium leading-4 text-gray-500 transition duration-150 ease-in-out hover:text-gray-700 focus:outline-none"
                                            @click="loadNotifications"
                                        >
                                            🔔
                                            <span
                                                v-if="unreadCount > 0"
                                                class="absolute -top-1 -right-1 inline-flex items-center justify-center rounded-full bg-red-600 px-1.5 py-0.5 text-xs font-bold leading-none text-white"
                                            >{{ unreadCount }}</span>
                                        </button>
                                    </template>

                                    <template #content>
                                        <div class="flex items-center justify-between px-4 py-2 text-sm font-semibold text-gray-700">
                                            <span>{{ $t('Commons.text.notifications', {}) }}</span>
                                            <button
                                                v-if="unreadCount > 0"
                                                type="button"
                                                class="text-xs font-normal text-indigo-600 hover:underline"
                                                @click.stop="markAllNotificationsRead"
                                            >{{ $t('Layouts.button.mark_all_read', {}) }}</button>
                                        </div>
                                        <div class="max-h-96 overflow-y-auto">
                                            <p v-if="!notificationsLoaded" class="px-4 py-3 text-sm text-gray-500">{{ $t('Commons.button.loading', {}) }}</p>
                                            <p v-else-if="notificationRecords.length === 0" class="px-4 py-3 text-sm text-gray-500">
                                                {{ $t('Layouts.text.no_notifications_yet', {}) }}
                                            </p>
                                            <div
                                                v-for="notification in notificationRecords"
                                                :key="notification.id"
                                                class="border-t border-gray-100 px-4 py-2 text-sm"
                                                :class="notification.read_at ? 'text-gray-500' : 'font-medium text-gray-900'"
                                            >
                                                <div>
                                                    {{ notification.data.category_label }} — {{ notification.data.name }}
                                                </div>
                                                <div class="text-xs text-gray-400">{{ timeAgo(notification.created_at) }}</div>
                                            </div>
                                        </div>
                                    </template>
                                </Dropdown>
                            </div>

                            <!-- Settings Dropdown -->
                            <div class="relative ms-3">
                                <Dropdown align="right" width="48">
                                    <template #trigger>
                                        <span class="inline-flex rounded-md">
                                            <button
                                                type="button"
                                                class="inline-flex items-center rounded-md border border-transparent bg-white px-3 py-2 text-sm font-medium leading-4 text-gray-500 transition duration-150 ease-in-out hover:text-gray-700 focus:outline-none"
                                            >
											<a :title="$page.props.auth.user.email">
											{{ $page.props.auth.user.first_name }}
											{{ $page.props.auth.user.last_name }}
											</a>
                                                <svg
                                                    class="-me-0.5 ms-2 h-4 w-4"
                                                    xmlns="http://www.w3.org/2000/svg"
                                                    viewBox="0 0 20 20"
                                                    fill="currentColor"
                                                >
                                                    <path
                                                        fill-rule="evenodd"
                                                        d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                                                        clip-rule="evenodd"
                                                    />
                                                </svg>
                                            </button>
                                        </span>
                                    </template>

                                    <template #content>
                                        <div v-if="$page.props.warehouse?.name" class="border-b border-gray-200 px-4 py-2">
                                            <div class="text-xs text-gray-500">{{ $t('Commons.text.warehouse', {}) }}</div>
                                            <div class="break-words text-sm font-medium text-gray-800">{{ $page.props.warehouse.name }}</div>
                                        </div>
                                        <DropdownLink
                                            :href="route('profile.edit')"
                                        >
                                            {{ $t('Commons.heading.profile', {}) }}
                                        </DropdownLink>
                                        <button
                                            type="button"
                                            class="block w-full px-4 py-2 text-start text-sm leading-5 text-gray-700 transition duration-150 ease-in-out hover:bg-gray-100 focus:bg-gray-100 focus:outline-none"
                                            @click="showingFeedbackModal = true"
                                        >
                                            {{ $t('Layouts.button.report_an_issue', {}) }}
                                        </button>
                                        <DropdownLink
                                            v-if="$page.props.buildingSafety.canView"
                                            href="/building-safety"
                                        >
                                            {{ $t('Layouts.text.who_s_in_the', {}) }}
                                        </DropdownLink>
                                        <DropdownLink
                                            v-if="$page.props.pinLogin.switchUserAvailable"
                                            :href="route('switch-user')"
                                            method="post"
                                            as="button"
                                        >
                                            {{ $t('Commons.text.switch_user', {}) }}
                                        </DropdownLink>
                                        <DropdownLink v-if="$page.props.pendingInvitations > 0" :href="route('account.invitations')">
                                            {{ $t('Commons.text.invitations') }}{{ $page.props.pendingInvitations }})
                                        </DropdownLink>
                                        <DropdownLink href="/this-device">
                                            {{ $t('Layouts.text.pin_login_on_this', {}) }}
                                        </DropdownLink>
                                        <DropdownLink href="/about-this-install">
                                            {{ $t('Commons.text.about', {}) }}
                                        </DropdownLink>
                                        <DropdownLink
                                            :href="route('logout')"
                                            method="post"
                                            as="button"
                                        >
                                            {{ $t('Commons.link.log_out', {}) }}
                                        </DropdownLink>
                                    </template>
                                </Dropdown>
                            </div>
                        </div>

                        <!-- Hamburger -->
                        <div class="-me-2 flex items-center sm:hidden">
                            <button
                                @click="
                                    showingNavigationDropdown =
                                        !showingNavigationDropdown
                                "
                                class="inline-flex items-center justify-center rounded-md p-2 text-gray-400 transition duration-150 ease-in-out hover:bg-gray-100 hover:text-gray-500 focus:bg-gray-100 focus:text-gray-500 focus:outline-none"
                            >
                                <svg
                                    class="h-6 w-6"
                                    stroke="currentColor"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                >
                                    <path
                                        :class="{
                                            hidden: showingNavigationDropdown,
                                            'inline-flex':
                                                !showingNavigationDropdown,
                                        }"
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M4 6h16M4 12h16M4 18h16"
                                    />
                                    <path
                                        :class="{
                                            hidden: !showingNavigationDropdown,
                                            'inline-flex':
                                                showingNavigationDropdown,
                                        }"
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M6 18L18 6M6 6l12 12"
                                    />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Responsive Navigation Menu -->
                <div
                    :class="{
                        block: showingNavigationDropdown,
                        hidden: !showingNavigationDropdown,
                    }"
                    class="sm:hidden"
                >
                    <div class="space-y-1 pb-3 pt-2">
                        <ResponsiveNavLink
                            :href="route('dashboard')"
                            :active="route().current('dashboard')"
                        >
                            {{ $t('Commons.text.dashboard', {}) }}
                        </ResponsiveNavLink>
                    </div>

                    <!-- Responsive Settings Options -->
                    <div
                        class="border-t border-gray-200 pb-1 pt-4"
                    >
                        <div class="px-4">
                            <div
                                class="text-base font-medium text-gray-800"
                            >
                                {{ $page.props.auth.user.name }}
                            </div>
                            <div class="text-sm font-medium text-gray-500">
                                {{ $page.props.auth.user.email }}
                            </div>
                            <div v-if="$page.props.warehouse?.name" class="mt-1 text-sm text-gray-500">
                                {{ $t('Commons.text.warehouse_2') }} {{ $page.props.warehouse.name }}
                            </div>
                        </div>

                        <div class="mt-3 space-y-1">
                            <ResponsiveNavLink :href="route('profile.edit')">
                                {{ $t('Commons.heading.profile', {}) }}
                            </ResponsiveNavLink>
                            <button
                                type="button"
                                class="block w-full ps-3 pe-4 py-2 text-start text-base font-medium text-gray-600 hover:bg-gray-50 hover:text-gray-800 focus:outline-none"
                                @click="showingFeedbackModal = true"
                            >
                                {{ $t('Layouts.button.report_an_issue', {}) }}
                            </button>
                            <ResponsiveNavLink
                                v-if="$page.props.buildingSafety.canView"
                                href="/building-safety"
                            >
                                {{ $t('Layouts.text.who_s_in_the', {}) }}
                            </ResponsiveNavLink>
                            <ResponsiveNavLink v-if="$page.props.pendingInvitations > 0" :href="route('account.invitations')">
                                {{ $t('Commons.text.invitations') }}{{ $page.props.pendingInvitations }})
                            </ResponsiveNavLink>
                            <ResponsiveNavLink href="/this-device">
                                {{ $t('Layouts.text.pin_login_on_this', {}) }}
                            </ResponsiveNavLink>
                            <ResponsiveNavLink
                                v-if="$page.props.pinLogin.switchUserAvailable"
                                :href="route('switch-user')"
                                method="post"
                                as="button"
                            >
                                {{ $t('Commons.text.switch_user', {}) }}
                            </ResponsiveNavLink>
                            <ResponsiveNavLink href="/about-this-install">
                                {{ $t('Commons.text.about', {}) }}
                            </ResponsiveNavLink>
                            <ResponsiveNavLink
                                :href="route('logout')"
                                method="post"
                                as="button"
                            >
                                {{ $t('Commons.link.log_out', {}) }}
                            </ResponsiveNavLink>
                        </div>
                    </div>
                </div>
            </nav>

            <FeedbackReportModal :show="showingFeedbackModal" @close="showingFeedbackModal = false" />

            <!-- Page Heading -->
            <header
                class="bg-white shadow"
                v-if="$slots.header"
            >
                <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                    <slot name="header" />
                </div>
            </header>

            <!-- Page Content -->
            <main>
                <slot />
            </main>
        </div>
    </div>
</template>

<script>import { t } from '@/i18n';


export default {
	props: {
		breadcrumb: {
			type: Array,
			required: false,
			default: [],
		},
	},
	data() {
	  return {
	      fullroute: "",
	  };
	},
	created() {
		this.fullroute = window.location.href.substring(window.location.origin.length);
		console.log(t('Layouts.text.fullroute_is_placeholder', { placeholder: this.fullroute }))
		window.addEventListener(
		  "hashchange",
		  () => {
			    this.fullroute = window.location.href.substring(window.location.origin.length);
		   },
		  false,
		);
	},
}
</script>
