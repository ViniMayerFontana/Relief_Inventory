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
        <Head title="Verificação de e-mail" />

        <div class="mb-4 text-sm text-gray-600">
            Agradecemos por se cadastrar! Antes de começar, confirme seu
            endereço de e-mail clicando no link que acabamos de enviar. Se
            você não recebeu o e-mail, podemos enviar outro.
        </div>

        <div
            class="mb-4 text-sm font-medium text-green-600"
            v-if="verificationLinkSent"
        >
            Um novo link de confirmação foi enviado para o endereço de e-mail
            informado no cadastro.
        </div>

        <div
            class="mb-4 rounded-md border border-red-300 bg-red-50 p-3 text-sm text-red-700"
            v-if="email_error"
        >
            <p class="font-medium">
                Não foi possível enviar o e-mail de confirmação.
            </p>
            <p class="mt-1">{{ email_error }}</p>
            <p class="mt-1">
                Tente novamente em alguns minutos ou entre em contato com uma pessoa administradora,
                que poderá ativar sua conta sem a confirmação por e-mail.
            </p>
        </div>

        <form @submit.prevent="submit">
            <div class="mt-4 flex items-center justify-between">
                <PrimaryButton
                    :class="{ 'opacity-25': form.processing }"
                    :disabled="form.processing"
                >
                    Reenviar e-mail de confirmação
                </PrimaryButton>

                <Link
                    :href="route('logout')"
                    method="post"
                    as="button"
                    class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                    >Sair</Link
                >
            </div>
        </form>
    </GuestLayout>
</template>
