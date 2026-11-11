<script setup>
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Link, useForm, usePage } from '@inertiajs/vue3';

defineProps({
    mustVerifyEmail: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});

const user = usePage().props.auth.user;

const form = useForm({
	first_name: user.first_name,
	last_name: user.last_name,
	organization: user.organization,
	address: user.address,
	city: user.city,
	state: user.state,
	zip: user.zip,
	county_id: user.county_id,
	phone: user.phone,
    email: user.email,
});
</script>

<template>
    <section>
        <header>
            <h2 class="text-lg font-medium text-gray-900">
                {{ $t('Commons.heading.profile_information', {}) }}
            </h2>

            <p class="mt-1 text-sm text-gray-600">
                {{ $t('Pages.Profile.Partials.text.update_your_account_s', {}) }}
            </p>
        </header>

        <form
            @submit.prevent="form.patch(route('profile.update'))"
            class="mt-6 space-y-6"
        >
		<div>
		    <InputLabel for="first_name" value="First Name" />

		    <TextInput
		        id="first_name"
		        type="text"
		        class="mt-1 block w-full"
		        v-model="form.first_name"
		        required
		        autofocus
		        autocomplete="first_name"
		    />

		    <InputError class="mt-2" :message="form.errors.first_name" />
		</div>
		<div>
		    <InputLabel for="last_name" value="Last Name" />

		    <TextInput
		        id="last_name"
		        type="text"
		        class="mt-1 block w-full"
		        v-model="form.last_name"
		        required
		        autocomplete="last_name"
		    />

		    <InputError class="mt-2" :message="form.errors.last_name" />
		</div>

            <div>
                <InputLabel for="email" value="Email" />

                <TextInput
                    id="email"
                    type="email"
                    class="mt-1 block w-full"
                    v-model="form.email"
                    required
                    autocomplete="username"
                />

                <InputError class="mt-2" :message="form.errors.email" />
            </div>

            <div v-if="mustVerifyEmail && user.email_verified_at === null">
                <p class="mt-2 text-sm text-gray-800">
                    {{ $t('Pages.Profile.Partials.text.your_email_address_is', {}) }}
                    <Link
                        :href="route('verification.send')"
                        method="post"
                        as="button"
                        class="rounded-md text-sm text-gray-600 underline hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                    >
                        Click here to re-send the verification email.
                    </Link>
                </p>

                <div
                    v-show="status === 'verification-link-sent'"
                    class="mt-2 text-sm font-medium text-green-600"
                >
                    {{ $t('Pages.Profile.Partials.text.a_new_verification_link', {}) }}
                </div>
            </div>

			<!-- Organization -->
			<div>
			    <InputLabel for="organization" value="Organization" />
			    <TextInput
			        id="organization"
			        type="text"
			        class="mt-1 block w-full"
			        v-model="form.organization"
			        required
			        autocomplete="organization"
			    />
			    <InputError class="mt-2" :message="form.errors.organization" />
			</div>
			
			    <!-- Address -->
			    <div>
			        <InputLabel for="address" value="Address" />
			        <TextInput
			            id="address"
			            type="text"
			            class="mt-1 block w-full"
			            v-model="form.address"
			            required
			            autocomplete="address"
			        />
			        <InputError class="mt-2" :message="form.errors.address" />
			    </div>

			    <!-- City -->
			    <div>
			        <InputLabel for="city" value="City" />
			        <TextInput
			            id="city"
			            type="text"
			            class="mt-1 block w-full"
			            v-model="form.city"
			            required
			            autocomplete="address-level2"
			        />
			        <InputError class="mt-2" :message="form.errors.city" />
			    </div>

			    <!-- State -->
			    <div>
			        <InputLabel for="state" value="State" />
			        <TextInput
			            id="state"
			            type="text"
			            class="mt-1 block w-full"
			            v-model="form.state"
			            required
			            autocomplete="address-level1"
			        />
			        <InputError class="mt-2" :message="form.errors.state" />
			    </div>

			    <!-- Zip Code -->
			    <div>
			        <InputLabel for="zip" value="Zip Code" />
			        <TextInput
			            id="zip"
			            type="text"
			            class="mt-1 block w-full"
			            v-model="form.zip"
			            required
			            autocomplete="postal-code"
			        />
			        <InputError class="mt-2" :message="form.errors.zip" />
			    </div>

			    <!-- County -->
			    <div>
			        <InputLabel for="county_id" value="County" />
			        <!-- <TextInput
			            id="county_id"
			            type="text"
			            class="mt-1 block w-full"
			            v-model="form.county_id"
			            required
			        />--> <i>{{ $t('Pages.Profile.Partials.text.coming_soon', {}) }}</i>
			        <InputError class="mt-2" :message="form.errors.county_id" />
			    </div> 

			    <!-- Phone -->
			    <div>
			        <InputLabel for="phone" value="Phone" />
			        <TextInput
			            id="phone"
			            type="tel"
			            class="mt-1 block w-full"
			            v-model="form.phone"
			            required
			            autocomplete="tel"
			        />
			        <InputError class="mt-2" :message="form.errors.phone" />
			    </div>
			
			
            <div class="flex items-center gap-4">
                <PrimaryButton :disabled="form.processing">{{ $t('Commons.button.save', {}) }}</PrimaryButton>

                <Transition
                    enter-active-class="transition ease-in-out"
                    enter-from-class="opacity-0"
                    leave-active-class="transition ease-in-out"
                    leave-to-class="opacity-0"
                >
                    <p
                        v-if="form.recentlySuccessful"
                        class="text-sm text-gray-600"
                    >
                        {{ $t('Pages.Profile.Partials.text.saved', {}) }}
                    </p>
                </Transition>
            </div>
        </form>
    </section>
</template>
