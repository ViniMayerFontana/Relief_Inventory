<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Setup/Training.vue

	Setup > Training Warehouse (TrainingAdminController, manage-training, a key only a training warehouse has). Approved devices offer a tap-your-name login for the
	trainees listed here, capped to station work (App\Services\TrainingMode). Prepare Training loads
	starter work for every station and the setup packet tells trainers how to stage the floor.
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import { Head, Link } from '@inertiajs/vue3';
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { t } from '@/i18n';

defineProps({
	breadcrumb: { type: Array },
});

const status = ref(null);
const error = ref(null);
const notice = ref(null);
const busy = ref(false);
const confirmingPrepare = ref(false);
const preparing = ref(false);
const newTrainee = ref({ first_name: '', last_name: '', team: null });
const showInactive = ref(false);
const event = ref({ event_title: '', event_location: '', trainer1_name: '', trainer2_name: '' });
const uploadingSlot = ref(null);
const confirmingReset = ref(false);
const resetText = ref('');
const resetting = ref(false);
const savingEvent = ref(false);

const trainees = computed(() => (status.value?.trainees || []).filter((t) => showInactive.value || t.active));

async function load() {
	try {
		status.value = (await axios.get('/json/training/status')).data;
		event.value = {
			event_title: status.value.event_title || '',
			event_location: status.value.event_location || '',
			trainer1_name: status.value.trainers[0].name || '',
			trainer2_name: status.value.trainers[1].name || '',
		};
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_load_the_3');
	}
}

async function saveEvent() {
	error.value = notice.value = null;
	savingEvent.value = true;
	try {
		status.value = (await axios.put('/json/training/event', event.value)).data;
		notice.value = t('Pages.Setup.text.certificate_details_saved');
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_save_the');
	} finally {
		savingEvent.value = false;
	}
}

async function startReset() {
	error.value = notice.value = null;
	resetting.value = true;
	try {
		await axios.post('/json/training/reset', { confirm: resetText.value });
		confirmingReset.value = false;
		watchReset();
	} catch (e) {
		resetting.value = false;
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_start_the');
	}
}

// The reset runs in the background: this warehouse answers 503 while it is rebuilt and, rebuilt, has none of today's
// sessions (401/419), so keep asking until the answer says how it ended.
function watchReset() {
	const timer = setInterval(async () => {
		try {
			const data = (await axios.get('/json/training/status')).data;
			if (data.reset_status?.state === 'running') return;
			clearInterval(timer);
			resetting.value = false;
			status.value = data;
			if (data.reset_status?.state === 'failed') error.value = t('Pages.Setup.text.the_reset_failed_placeholder', { placeholder: data.reset_status.error });
			else notice.value = t('Pages.Setup.text.the_reset_is_done');
		} catch (e) {
			const code = e.response?.status;
			if (code === 401 || code === 419) {
				clearInterval(timer);
				window.location.href = '/login';
			} // 503 (being rebuilt) or a dropped connection: still going
		}
	}, 3000);
}

function archiveTime(stamp) {
	const [d, t] = stamp.split('_');
	return new Date(d + 'T' + t.slice(0, 2) + ':' + t.slice(2, 4) + ':' + t.slice(4, 6)).toLocaleString();
}

async function prepare() {
	if (!confirmingPrepare.value) {
		confirmingPrepare.value = true;
		return;
	}
	error.value = notice.value = null;
	confirmingPrepare.value = false;
	preparing.value = true;
	try {
		const { data } = await axios.post('/json/training/prepare');
		notice.value = t('Pages.Setup.text.training_data_prepared_print')
			+ (data.warnings?.length ? ' ' + data.warnings.join(' ') : '');
		await load();
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_prepare_training');
	} finally {
		preparing.value = false;
	}
}

async function addTrainee() {
	error.value = notice.value = null;
	try {
		status.value = (await axios.post('/json/training/trainees', newTrainee.value)).data;
		notice.value = newTrainee.value.first_name + t('Pages.Setup.text.placeholder_added', { placeholder: newTrainee.value.last_name });
		newTrainee.value = { first_name: '', last_name: '', team: newTrainee.value.team };
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_add_that_2');
	}
}

async function updateTrainee(trainee, changes) {
	error.value = notice.value = null;
	try {
		status.value = (await axios.patch('/json/training/trainees/' + trainee.id, changes)).data;
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_update_that');
	}
}

async function uploadSignature(slot, input) {
	const file = input.files[0];
	if (!file) return;
	error.value = notice.value = null;
	uploadingSlot.value = slot;
	try {
		const form = new FormData();
		form.append('signature', file);
		status.value = (await axios.post('/json/training/signatures/' + slot, form)).data;
		notice.value = t('Pages.Setup.text.signature_uploaded');
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_upload_that');
	} finally {
		uploadingSlot.value = null;
		input.value = '';
	}
}

async function removeSignature(slot) {
	error.value = notice.value = null;
	try {
		status.value = (await axios.delete('/json/training/signatures/' + slot)).data;
	} catch (e) {
		error.value = e.response?.data?.message || t('Pages.Setup.text.could_not_remove_that_2');
	}
}

function formatTime(value) {
	return value ? new Date(value).toLocaleString() : '';
}

onMounted(async () => {
	await load();
	if (status.value?.reset_status?.state === 'running') {
		resetting.value = true;
		watchReset();
	}
});
</script>

<template>
	<Head :title="$t('Commons.title.training_warehouse')" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<div class="max-w-4xl mx-auto p-4 space-y-6">
			<h1 class="text-2xl font-bold">{{ $t('Commons.heading.training_warehouse', {}) }}</h1>

			<div v-if="error" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3">{{ error }}</div>
			<div v-if="notice" class="rounded bg-green-100 border border-green-400 text-green-800 px-4 py-3">{{ notice }}</div>
			<p v-if="!status && !error" class="text-gray-500">{{ $t('Commons.button.loading', {}) }}</p>

			<template v-if="status">
				<!-- ======================= THIS WAREHOUSE ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Pages.Setup.heading.this_is_a_training', {}) }}</h2>
					<p class="text-sm text-gray-700">
						{{ $t('Pages.Setup.text.everything_entered_here_is', {}) }}
						<strong>tap-your-name</strong> login for trainees &mdash; no password &mdash; and a trainee can do what the Trainee
						role grants (station work and reports; nothing in Setup). To close this warehouse after the class, ask the person who runs the
						instance to turn it off (<span class="font-mono">{{ $t('Pages.Setup.text.php_artisan_warehouse_training', {}) }}</span>); its data is kept until it is reset.
					</p>
					<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
						<div class="border rounded p-3">
							<div class="text-gray-500">{{ $t('Commons.text.approved_devices', {}) }}</div>
							<div class="text-lg font-semibold">{{ status.approved_devices }}</div>
						</div>
						<div class="border rounded p-3">
							<div class="text-gray-500">{{ $t('Pages.Setup.text.trainees_on_the_list', {}) }}</div>
							<div class="text-lg font-semibold">{{ status.trainees.filter((t) => t.active).length }}</div>
						</div>
					</div>
					<div v-if="resetting" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">
						{{ $t('Pages.Setup.text.resetting_this_warehouse_it', {}) }}
					</div>
					<div v-else class="space-y-3">
						<button v-if="!confirmingReset" type="button"
							class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500"
							@click="confirmingReset = true; resetText = ''">{{ $t('Pages.Setup.button.reset_this_warehouse', {}) }}</button>
						<div v-if="confirmingReset" class="border border-red-300 bg-red-50 rounded p-4 space-y-2 text-sm">
							<p class="font-semibold text-red-800">{{ $t('Pages.Setup.text.this_erases_everything_entered', {}) }}</p>
							<p>
								{{ $t('Pages.Setup.text.practice_donations_orders_pallets', {}) }} <strong>{{ $t('Commons.text.kept', {}) }}</strong> {{ $t('Pages.Setup.text.the_people_who_log', {}) }}
							</p>
							<p>
								{{ $t('Commons.text.first_a', {}) }} <strong>class archive</strong> {{ $t('Pages.Setup.text.is_saved_the_sign', {}) }}
							</p>
							<label class="block">{{ $t('Commons.label.type', {}) }} <strong>{{ $t('Commons.text.reset', {}) }}</strong> {{ $t('Commons.label.to_confirm', {}) }}
								<input v-model="resetText" class="ml-2 border-gray-300 rounded-md shadow-sm text-sm py-1 w-32" autocomplete="off" />
							</label>
							<div class="flex gap-3">
								<button type="button" :disabled="resetText.trim() !== 'RESET'" @click="startReset"
									class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white bg-red-600 hover:bg-red-500 disabled:opacity-50">
									{{ $t('Commons.button.reset_now', {}) }}</button>
								<button type="button" class="text-sm underline" @click="confirmingReset = false">{{ $t('Commons.button.cancel', {}) }}</button>
							</div>
						</div>
					</div>
					<div v-if="status.reset_status?.state === 'failed' && !resetting" class="rounded bg-red-100 border border-red-400 text-red-800 px-4 py-3 text-sm">
						{{ $t('Pages.Setup.text.the_last_reset_failed') }} {{ status.reset_status.error }}
					</div>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.Setup.text.to_approve_a_tablet', {}) }} <strong>{{ $t('Pages.Setup.text.pin_login_on_this', {}) }}</strong> from the
						profile menu (the same approval PIN unlock uses; requests from others wait on
						<Link href="/setup/pin-login" class="underline">{{ $t('Commons.heading.pin_login', {}) }}</Link>). Staff can still log in on a training device with their
						PIN or email from the links under the name tiles.
					</p>
				</section>

				<!-- ======================= SELF SIGN-UP ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.sign_up_page', {}) }}</h2>
					<p class="text-sm text-gray-700">
						{{ $t('Pages.Setup.text.people_sign_themselves_up', {}) }}
					</p>
					<div class="flex flex-wrap items-center gap-6">
						<div class="w-40 h-40 shrink-0 [&>svg]:w-full [&>svg]:h-full" v-html="status.signup.qr_svg"></div>
						<div class="space-y-3 text-sm">
							<div><a :href="status.signup.url" target="_blank" class="font-mono text-blue-600 underline break-all">{{ status.signup.url }}</a></div>
							<div class="grid grid-cols-2 gap-4">
								<div class="border rounded p-3">
									<div class="text-gray-500">{{ $t('Pages.Setup.text.signed_up_today', {}) }}</div>
									<div class="text-lg font-semibold">{{ status.signup.today }}</div>
								</div>
								<div class="border rounded p-3">
									<div class="text-gray-500">{{ $t('Commons.text.all_time', {}) }}</div>
									<div class="text-lg font-semibold">{{ status.signup.total }}</div>
								</div>
							</div>
							<div class="flex flex-wrap gap-2">
								<PrintMenu document-key="training-signup-poster" media="report" variant="form" :label="$t('Commons.label.qr_poster')"
									download-href="/report/training/signup-poster.pdf" />
								<a :href="$withWarehouse('/report/training/signups.csv')" class="ri_formbutton">{{ $t('Pages.Setup.link.follow_up_list_csv', {}) }}</a>
								<button type="button" class="ri_formbutton" @click="load">{{ $t('Commons.button.refresh', {}) }}</button>
							</div>
						</div>
					</div>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.Setup.text.point_your_short_link', {}) }}
					</p>
				</section>

				<!-- ======================= PREPARE ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.button.prepare_training', {}) }}</h2>
					<p class="text-sm text-gray-700">
						{{ $t('Pages.Setup.text.receiving_and_sorting_use', {}) }}
					</p>
					<div class="flex flex-wrap items-center gap-4 border rounded p-3 text-sm">
						<div><span class="text-lg font-semibold">{{ status.products.units }}</span> of {{ status.products.plan.target }} {{ $t('Commons.text.items_scanned') }}</div>
						<div><span class="text-lg font-semibold">{{ status.products.distinct }}</span> of {{ status.products.plan.min_products }} {{ $t('Commons.text.different_products') }}</div>
						<Link href="/setup/training/products" class="ri_defaultbutton">{{ $t('Pages.Setup.heading.scan_training_products', {}) }}</Link>
					</div>
					<div v-if="preparing" class="rounded bg-blue-50 border border-blue-300 text-blue-800 px-4 py-3 text-sm">{{ $t('Pages.Setup.text.preparing_training_data', {}) }}</div>
					<div class="flex flex-wrap items-center gap-3">
						<button type="button" :disabled="preparing || status.products.units < status.products.plan.target" @click="prepare"
							class="inline-flex items-center px-4 py-2 rounded-md font-semibold text-xs uppercase tracking-widest text-white disabled:opacity-50"
							:class="confirmingPrepare ? 'bg-red-600 hover:bg-red-500' : 'bg-amber-600 hover:bg-amber-500'">
							{{ confirmingPrepare ? $t('Pages.Setup.button.confirm_adds_a_full') : $t('Commons.button.prepare_training') }}
						</button>
						<button v-if="confirmingPrepare" type="button" class="text-sm underline" @click="confirmingPrepare = false">{{ $t('Commons.button.cancel', {}) }}</button>
						<template v-if="status.prepared">
							<PrintMenu document-key="training-setup-packet" media="report" variant="form" :label="$t('Commons.label.setup_packet')"
								download-href="/report/training/setup-packet.pdf" />
							<PrintMenu document-key="training-pallet-labels" :media="$page.props.printing.palletLabelMedia" variant="form"
								:label="$t('Commons.label.pallet_labels_2')" download-href="/report/training/pallet-labels.pdf" />
						</template>
						<PrintMenu document-key="training-spot-labels" :media="$page.props.printing.palletLabelMedia" variant="form"
							:label="$t('Pages.Setup.label.table_spot_labels')" download-href="/report/training/spot-labels.pdf" />
					</div>
					<p v-if="status.products.units < status.products.plan.target" class="text-sm text-gray-500">
						{{ $t('Pages.Setup.text.scan_at_least') }} {{ status.products.plan.target }} items first ({{ status.products.plan.target - status.products.units }} more).
					</p>
					<p class="text-xs text-gray-500">
						{{ $t('Commons.text.last_prepared', {}) }} <span class="font-mono">{{ status.prepared_at ? formatTime(status.prepared_at) : 'never' }}</span>.
						Running it again adds another full set from the same scanned goods (it never removes anything).
						How many items each station gets is set in <span class="font-mono">config/training.php</span>.
						The table spot labels (A-1 to C-4, with a barcode for Inventory Movement to scan) print on the
						pallet label stock.
					</p>
				</section>

				<!-- ======================= TEAM SHEETS & REPORT CARDS ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Pages.Setup.heading.team_sheets_and_report', {}) }}</h2>
					<div class="flex flex-wrap items-center gap-3">
						<PrintMenu document-key="training-all-teams" media="report" variant="form" :label="$t('Pages.Setup.label.all_team_sheets')"
							download-href="/report/training/team-sheets.pdf" />
						<Link href="/reports/training" class="ri_formbutton">{{ $t('Pages.Setup.link.report_cards_certificates', {}) }}</Link>
					</div>
					<h3 class="font-semibold">{{ $t('Commons.heading.certificates', {}) }}</h3>
					<form class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm" @submit.prevent="saveEvent">
						<label class="block">
							<span class="text-gray-700">{{ $t('Pages.Setup.text.training_event_title', {}) }}</span>
							<input v-model="event.event_title" maxlength="150" :placeholder="$t('Pages.Setup.placeholder.hands_on_warehouse_training')"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Pages.Setup.text.where_the_class_was', {}) }}</span>
							<input v-model="event.event_location" maxlength="150" :placeholder="$t('Pages.Setup.placeholder.e_g_statesville_warehouse')"
								class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<div v-for="trainer in status.trainers" :key="trainer.slot" class="border rounded p-3 space-y-2">
							<label class="block">
								<span class="text-gray-700">{{ trainer.slot === 1 ? $t('Commons.text.left') : $t('Commons.text.right') }} {{ $t('Pages.Setup.text.signature_trainer_s_name') }}</span>
								<input v-model="event['trainer' + trainer.slot + '_name']" maxlength="100" :placeholder="$t('Commons.placeholder.trainer')"
									class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
							</label>
							<div class="h-16 border border-dashed rounded flex items-center justify-center bg-gray-50">
								<img v-if="trainer.has_signature" :src="'/json/training/signatures/' + trainer.slot + '?v=' + trainer.signature_version"
									:alt="$t('Commons.alt.signature')" class="max-h-14 max-w-full" />
								<span v-else class="text-xs text-gray-400">{{ $t('Pages.Setup.text.no_signature_the_line', {}) }}</span>
							</div>
							<div class="flex flex-wrap items-center gap-3">
								<label class="ri_formbutton cursor-pointer">
									{{ uploadingSlot === trainer.slot ? $t('Commons.label.uploading') : (trainer.has_signature ? $t('Commons.label.replace_signature') : $t('Commons.label.upload_signature')) }}
									<input type="file" accept="image/png,image/jpeg" class="hidden" :disabled="uploadingSlot !== null"
										@change="uploadSignature(trainer.slot, $event.target)" />
								</label>
								<button v-if="trainer.has_signature" type="button" class="text-sm underline" @click="removeSignature(trainer.slot)">{{ $t('Commons.button.remove', {}) }}</button>
							</div>
						</div>
						<div class="sm:col-span-2"><PrimaryButton :disabled="savingEvent">{{ savingEvent ? $t('Commons.button.saving') : $t('Pages.Setup.button.save_certificate_details') }}</PrimaryButton></div>
					</form>
					<p class="text-xs text-gray-500">
						A certificate reads "has completed <em>title</em> {{ $t('Commons.text.held_at', {}) }} <em>location</em> on <em>date</em>", with the two
						trainers' signature lines at the bottom left and right. Left blank, the title is "Hands-on Warehouse
						Training", the location is left out and each line is labelled "Trainer". Signatures are PNG or JPEG
						(up to 2 MB) — a scan or photo of a signature on white paper cropped close works; a PNG with a
						transparent background looks best. Uploading a signature takes effect right away; names need Save.
					</p>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.Setup.text.each_team_s_sheet', {}) }} <Link href="/help" class="underline">{{ $t('Commons.link.help_2', {}) }}</Link> {{ $t('Pages.Setup.text.page_print_the_team', {}) }}
					</p>
				</section>

				<!-- ======================= CLASS ARCHIVES ======================= -->
				<section v-if="status.archives.length" class="bg-white shadow rounded-lg p-6 space-y-3">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.class_archives', {}) }}</h2>
					<p class="text-sm text-gray-700">{{ $t('Pages.Setup.text.saved_by_each_reset', {}) }}</p>
					<table class="ri_datatable w-full text-sm" border="1">
						<thead><tr><th>{{ $t('Commons.text.saved', {}) }}</th><th>{{ $t('Commons.text.files', {}) }}</th></tr></thead>
						<tbody>
							<tr v-for="a in status.archives" :key="a.stamp">
								<td>{{ archiveTime(a.stamp) }}</td>
								<td>
									<a v-for="f in a.files" :key="f.name" :href="$withWarehouse('/report/training/archives/' + a.stamp + '/' + f.name)"
										class="underline text-blue-700 mr-4">{{ f.label }}</a>
								</td>
							</tr>
						</tbody>
					</table>
				</section>

				<!-- ======================= TRAINEES ======================= -->
				<section class="bg-white shadow rounded-lg p-6 space-y-4">
					<h2 class="text-lg font-semibold">{{ $t('Commons.heading.trainees', {}) }}</h2>
					<form class="grid grid-cols-1 sm:grid-cols-4 gap-4 text-sm items-end" @submit.prevent="addTrainee">
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.placeholder.first_name', {}) }}</span>
							<input v-model="newTrainee.first_name" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.placeholder.last_name', {}) }}</span>
							<input v-model="newTrainee.last_name" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm" />
						</label>
						<label class="block">
							<span class="text-gray-700">{{ $t('Commons.text.team', {}) }}</span>
							<select v-model="newTrainee.team" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm">
								<option :value="null">{{ $t('Pages.Setup.text.choose_at_login', {}) }}</option>
								<option v-for="n in status.teams" :key="n" :value="n">{{ $t('Commons.text.team') }} {{ n }}</option>
							</select>
						</label>
						<div><PrimaryButton>{{ $t('Commons.button.add_trainee', {}) }}</PrimaryButton></div>
					</form>

					<label class="text-sm flex items-center gap-2">
						<input type="checkbox" v-model="showInactive" /> {{ $t('Pages.Setup.label.show_trainees_taken_off', {}) }}
					</label>

					<p v-if="!trainees.length" class="text-sm text-gray-400">{{ $t('Pages.Setup.text.none_yet_add_them', {}) }}</p>
					<table v-else class="ri_datatable w-full text-sm" border="1">
						<thead><tr><th>{{ $t('Commons.button.name', {}) }}</th><th>{{ $t('Commons.text.team', {}) }}</th><th>{{ $t('Commons.text.actions_today', {}) }}</th><th></th></tr></thead>
						<tbody>
							<tr v-for="t in trainees" :key="t.id" :class="{ 'text-gray-400': !t.active }">
								<td>{{ t.full_name }}</td>
								<td>
									<select :value="t.team" class="border-gray-300 rounded-md shadow-sm text-sm py-1"
										@change="updateTrainee(t, { team: $event.target.value ? Number($event.target.value) : null })">
										<option value="">—</option>
										<option v-for="n in status.teams" :key="n" :value="n">{{ $t('Commons.text.team') }} {{ n }}</option>
									</select>
								</td>
								<td>{{ t.actions_today }}</td>
								<td>
									<button type="button" class="text-sm underline" @click="updateTrainee(t, { active: !t.active })">
										{{ t.active ? $t('Pages.Setup.button.take_off_the_list') : $t('Pages.Setup.button.put_back_on_the') }}
									</button>
								</td>
							</tr>
						</tbody>
					</table>
					<p class="text-xs text-gray-500">
						{{ $t('Pages.Setup.text.taking_a_trainee_off', {}) }}
					</p>
				</section>
			</template>
		</div>
	</AuthenticatedLayout>
</template>
