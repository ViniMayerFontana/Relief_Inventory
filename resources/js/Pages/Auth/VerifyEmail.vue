<script setup>
import { computed } from 'vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const props = defineProps({
    status: {
        type: String,
    },
    email_error: {
        type: String,
    },
});

const form = useForm({});

const submit = () => {
    form.post(route('verification.send'));
};

const verificationLinkSent = computed(
    () => props.status === 'verification-link-sent',
);
</script>

<template>
    <GuestLayout>
        <Head :title="$t('Commons.title.email_verification')" />

        <div class="mb-4 text-sm text-gray-600">
            {{ $t('Pages.Auth.text.thanks_for_signing_up', {}) }}
        </div>

        <div
            class="mb-4 text-sm font-medium text-green-600"
            v-if="verificationLinkSent"
        >
            {{ $t('Pages.Auth.text.a_new_verification_link', {}) }}
        </div>

        <div
            class="mb-4 rounded-md border border-red-300 bg-red-50 p-3 text-sm text-red-700"
            v-if="email_error"
        >
            <p class="font-medium">
                {{ $t('Pages.Auth.text.we_couldn_t_send', {}) }}
            </p>
            <p class="mt-1">{{ email_error }}</p>
            <p class="mt-1">
                {{ $t('Pages.Auth.text.please_try_again_in', {}) }}
            </p>
        </div>

        <form @submit.prevent="submit">
            <div class="mt-4 flex items-center justify-between">
                <PrimaryButton
                    :class="{ 'opacity-25': form.processing }"
                    :disabled="form.processing"
                >
                    {{ $t('Pages.Auth.button.resend_verification_email', {}) }}
                </PrimaryButton>

                <Link
                    :href="route('logout')"
                    method="post"
                    as="button"
                    class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                    >{{ $t('Commons.link.log_out', {}) }}</Link
                >
            </div>
        </form>
    </GuestLayout>
</template>
