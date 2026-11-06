<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<!-- Receiving.vue

	Dock-side donation/equipment/supplies intake, built on RIForm like the
	rest of the CRUD-style admin pages. Donation-category intakes get
	pallets created for them (one label per container) via an action button
	in the detail view once a record has been saved; those pallets then
	show up on the Sorting page ready to work. The donation's own status
	rolls from Received -> Sorting -> Complete automatically as those
	pallets get sorted and emptied. Close-out is likewise an action in the
	detail view, shown only when the record is a close-out candidate
	(is_close_out_candidate, computed server-side).
-->

<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head, Link } from '@inertiajs/vue3';
import TextInput from '@/Components/TextInput.vue';
import TextArea from '@/Components/TextArea.vue';
import SearchSelect from '@/Components/SearchSelect.vue';
import ChipSelect from '@/Components/ChipSelect.vue';
import TileSelect from '@/Components/TileSelect.vue';
import RIForm from '@/Components/RIForm.vue';
import Modal from '@/Components/Modal.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import WebcamCapture from '@/Components/WebcamCapture.vue';

defineProps({
	breadcrumb: {
		type: Array,
	},
});

// Equipment and Supplies are both for the warehouse's own operational use
// (never distributed to partners/recipients, unlike Donation) — the
// distinction between the two is easy to miss, hence the hover tooltip.
const categoryOptions = [
	{ id: 'donation', name: 'Donation' },
	{
		id: 'equipment',
		name: 'Equipment',
		title: 'Durable items the warehouse itself uses long-term (shelving, pallet jacks, tools, computers) — not for distribution.',
	},
	{
		id: 'supplies',
		name: 'Supplies',
		title: 'Consumables the warehouse itself uses up (packing tape, gloves, cleaning supplies, printer paper) — not for distribution.',
	},
	{ id: 'other', name: 'Other' },
];

const yesNoOptions = [
	{ value: true, label: 'Yes' },
	{ value: false, label: 'No' },
];

// Pallets is a single, exclusive choice; Other reveals a multi-select
// checklist below it since a mixed load can be boxes AND bags AND totes
// AND/OR loose all at once.
const arrivalModeOptions = [
	{ value: 'pallet', label: 'Pallets' },
	{ value: 'other', label: 'Other' },
];

const otherContainerTypeOptions = [
	{ value: 'box', label: 'Boxes' },
	{ value: 'bag', label: 'Bags' },
	{ value: 'tote', label: 'Totes' },
	{ value: 'loose', label: 'Loose' },
];

// Icon paths point at public/img/ files in the same style as the
// Dashboard menu tile graphics (navy rounded-square badge, white
// line-art glyph) — drop matching .webp files there with these exact
// names. TileSelect falls back to plain text/emoji for any icon value
// that isn't a path, so this degrades gracefully if a file is missing.
const arrivalMethodOptions = [
	{ value: 'semi', label: 'Semi', icon: '/img/truck-semi-icon.webp' },
	{ value: 'box_truck', label: 'Box Truck', icon: '/img/truck-box-icon.webp' },
	{ value: 'personal_vehicle', label: 'Personal Vehicle', icon: '/img/truck-personal-icon.webp' },
	{ value: 'trailer', label: 'Trailer', icon: '/img/truck-trailer-icon.webp' },
	{ value: 'delivery_truck', label: 'Delivery Truck', icon: '/img/truck-delivery-icon.webp' },
	{ value: 'other', label: 'Other', icon: '/img/truck-other-icon.webp' },
];

const containerTypeOptions = [
	{ value: 'pallet', label: 'Pallet' },
	{ value: 'gaylord', label: 'Gaylord' },
	{ value: 'box', label: 'Box' },
	{ value: 'bag', label: 'Bag' },
	{ value: 'tote', label: 'Tote' },
];
</script>

<template>
	<Head title="Recebimento" />
	<AuthenticatedLayout :breadcrumb="breadcrumb">
		<RIForm
			ref="riform"
			title="Recebimento"
			datasource="/json/receiving"
			newrecordcaption="Registrar um recebimento"
			:filter="receivingFilter"
			@select="onOpenRecord"
			@new="onOpenRecord"
		>
			<template #titleactions>
				<button type="button" class="ri_defaultbutton" @click="preprintOpen = true">Imprimir etiquetas antecipadamente</button>
				<Link href="/receiving/offers" class="ri_defaultbutton">Ofertas de doação</Link>

				<Modal :show="preprintOpen" @close="preprintOpen = false" max-width="sm">
					<div class="p-6 space-y-4">
						<h2 class="text-lg font-semibold">Imprimir etiquetas antecipadamente</h2>
						<p class="text-sm text-gray-600">
							Imprima uma série de etiquetas R em branco antes de registrar qualquer doação. Coloque-as nos
							paletes à medida que os itens chegarem e informe os números das etiquetas ao registrar o recebimento.
						</p>
						<div>
							<InputLabel value="Quantas?" />
							<TextInput v-model.number="preprintCount" type="number" min="1" max="300" class="mt-1 block w-full" autofocus />
						</div>
						<div>
							<InputLabel value="Tipo de recipiente" />
							<ChipSelect v-model="preprintContainerType" :options="containerTypeOptions" />
						</div>
						<p v-if="preprintError" class="text-sm text-red-700">{{ preprintError }}</p>
						<div class="flex justify-end gap-3">
							<SecondaryButton :disabled="preprintSaving" @click="preprintOpen = false">Cancelar</SecondaryButton>
							<PrintMenu
								document-key="preprint-pallet-labels" :media="$page.props.printing.palletLabelMedia" label="Imprimir etiquetas" placement="up"
								:prepare="preparePreprint" :disabled="preprintSaving"
								@sent="onPreprintDone" @downloaded="onPreprintDone"
							/>
						</div>
					</div>
				</Modal>
			</template>

			<template #listactions>
				<input
					type="text"
					v-model="donorSearch"
					class="ri_forminput recv_search"
					placeholder="Buscar por nome do doador ou organização..."
				/>
				<label class="recv_checkbox">
					<input type="checkbox" v-model="flaggedOnly" />
					Sinalizados apenas para identificação do doador
				</label>
				<HelpLink guide="receiving">Guia de recebimento</HelpLink>
			</template>

			<template #thead>
				<th>Doador</th>
				<th>Categoria</th>
				<th>Status</th>
				<th>Estimativa de recipientes</th>
				<th>Paletes</th>
			</template>

			<template #tbody="{ record, index }">
				<td>
					{{ donorName(record) }}
					<span v-if="record.donor_identification_pending" class="recv_badge recv_badge_id">identificação do doador pendente</span>
				</td>
				<td>{{ record.category === 'other' && record.category_other ? record.category_other : record.category }}</td>
				<td>
					{{ record.status ? record.status.name : '' }}
					<span v-if="record.is_close_out_candidate" class="recv_badge">pronto para concluir</span>
				</td>
				<td>{{ record.container_count }}</td>
				<td>{{ (record.pallets || []).length }}</td>
			</template>

			<template #default="{ record, editing, templates }">
				<template v-if="wizardStep === 'details'">
					<div class="recv_helplink_form"><HelpLink guide="receiving">Guia de recebimento</HelpLink></div>
					<div class="ri_formtable">
						<div class="ri_fieldset" v-if="!record.id">
							<div class="ri_fieldlabel">Esta doação corresponde a uma oferta recebida por telefone?</div>
							<div v-if="pendingOffers.length" class="recv_offerlist">
								<div
									v-for="offer in pendingOffers"
									:key="offer.id"
									class="recv_offercard"
									:class="{ recv_offercard_selected: matchedOfferId === offer.id }"
									@click="editing && toggleOfferMatch(record, offer)"
								>
									<div class="recv_offerdonor">{{ offer.person?.full_name || 'Doador desconhecido' }}</div>
									<div v-if="offer.description" class="recv_offerdesc">{{ offer.description }}</div>
									<div v-if="offer.eta_start" class="recv_offereta">ETA {{ formatEtaRange(offer.eta_start, offer.eta_end) }}</div>
								</div>
							</div>
							<div v-else class="ri_hint">Não há ofertas pendentes — a chegada não foi informada com antecedência ou não corresponde a nenhuma oferta atual.</div>
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Data:</div>
							<div class="ri_formcontrol">
								<input
								type="date"
								v-model="record.order_date"
								class="ri_forminput"
								:disabled="!editing"
								@change="$event.target.blur()"
							/>
							</div>
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Categoria:</div>
							<ChipSelect
								v-model="record.category"
								:options="categoryOptions.map((o) => ({ value: o.id, label: o.name, title: o.title }))"
								:enabled="editing"
							/>
						</div>
						<div class="ri_fieldset" v-if="record.category === 'other'">
							<div class="ri_fieldlabel">Descrição:</div>
							<TextInput v-model="record.category_other" placeholder="O que é?" :enabled="editing" />
						</div>
						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Tamanho do caminhão:</div>
							<TileSelect v-model="record.arrival_method" :options="arrivalMethodOptions" :enabled="editing" />
						</div>

						<div class="ri_fieldset" v-if="record.arrival_method === 'other'">
							<div class="ri_fieldlabel">Descrição:</div>
							<TextInput v-model="record.arrival_method_other" placeholder="Como chegou?" :enabled="editing" />
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Motorista:</div>
							<SearchSelect
								ref="driverSelect"
								v-model="record.driver_id"
								optionsource="/json/drivers"
								display="name"
								secondary="carrier"
								:searchfields="['name', 'phone', 'carrier']"
								placeholder="Buscar motoristas..."
								:allowcreate="true"
								:enabled="editing"
								@selected="(d) => onDriverSelected(record, d)"
								@create="(name) => startNewDriver(record, name)"
							/>
						</div>
						<Modal :show="creatingDriver" @close="creatingDriver = false" max-width="sm">
							<div class="p-6 space-y-4">
								<h2 class="text-lg font-semibold">Novo motorista</h2>
								<div>
									<InputLabel value="Nome" />
									<TextInput v-model="newDriver.name" class="mt-1 block w-full" autofocus />
								</div>
								<div>
									<InputLabel value="Telefone" />
									<TextInput v-model="newDriver.phone" class="mt-1 block w-full" />
								</div>
								<div>
									<InputLabel value="Transportadora (se for empresa de transporte, não veículo pessoal)" />
									<TextInput v-model="newDriver.carrier" class="mt-1 block w-full" />
								</div>
								<p v-if="driverError" class="text-sm text-red-700">{{ driverError }}</p>
								<div class="flex justify-end gap-3">
									<SecondaryButton :disabled="driverSaving" @click="creatingDriver = false">Cancelar</SecondaryButton>
									<PrimaryButton :disabled="driverSaving" @click="saveNewDriver(record)">Salvar motorista</PrimaryButton>
								</div>
							</div>
						</Modal>
						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Transportadora:</div>
							<TextInput v-model="record.carrier" placeholder="Transportadora (ex.: empresa de frete, UPS, FedEx, Amazon etc.)" :enabled="editing" />
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Como a doação chegou?</div>
							<ChipSelect
								:modelValue="arrivalMode"
								:options="arrivalModeOptions"
								:enabled="editing"
								@update:modelValue="(m) => setArrivalMode(record, m)"
							/>
						</div>

						<div class="ri_fieldset" v-if="arrivalMode === 'other'">
							<div class="ri_fieldlabel">Quais tipos?</div>
							<ChipSelect
								v-model="record.container_types"
								:options="otherContainerTypeOptions"
								:multiple="true"
								:enabled="editing"
							/>
						</div>

						<div class="ri_fieldset" v-if="arrivalMode === 'pallet'">
							<div class="ri_fieldlabel">Número de paletes:</div>
							<TextInput v-model="record.container_type_counts.pallet" type="number" :enabled="editing" />
						</div>
						<div
							class="ri_fieldset"
							v-for="type in otherContainerTypeOptions.filter((o) => o.value !== 'loose' && (record.container_types || []).includes(o.value))"
							:key="type.value"
						>
							<div class="ri_fieldlabel">Número de {{ type.label }}:</div>
							<TextInput v-model="record.container_type_counts[type.value]" type="number" :enabled="editing" />
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Doador / origem:</div>
							<SearchSelect
								ref="donorSelect"
								v-model="record.person_id"
								optionsource="/json/people"
								display="search_label"
								:searchfields="['organization', 'first_name', 'last_name']"
								placeholder="Buscar doadores..."
								:allowcreate="true"
								:enabled="editing"
								@selected="(p) => { creatingDonor = false; record.person = p; record.contact_person_id = null; }"
								@create="startNewDonor"
							/>
							<!-- A warning only: standing never blocks receiving (set from the Donor Report). -->
							<p v-if="['watch', 'decline'].includes(record.person?.donor_standing)"
								:class="['recv_standing', 'recv_standing_' + record.person.donor_standing]">
								<strong>{{ record.person.donor_standing === 'decline' ? 'Lista de recusa' : 'Em observação' }}:</strong>
								As doações anteriores deste doador tiveram uma proporção elevada de itens inutilizáveis.
								<span v-if="record.person.donor_standing_note">{{ record.person.donor_standing_note }}</span>
							</p>
						</div>
						<Modal :show="creatingDonor" @close="creatingDonor = false" max-width="sm">
							<div class="p-6 space-y-4">
								<h2 class="text-lg font-semibold">Novo doador</h2>
								<div>
									<InputLabel value="Nome" />
									<TextInput v-model="newDonor.first_name" class="mt-1 block w-full" autofocus />
								</div>
								<div>
									<InputLabel value="Sobrenome" />
									<TextInput v-model="newDonor.last_name" class="mt-1 block w-full" />
								</div>
								<div>
									<InputLabel value="Organização" />
									<TextInput v-model="newDonor.organization" class="mt-1 block w-full" />
								</div>
								<p v-if="donorError" class="text-sm text-red-700">{{ donorError }}</p>
								<div class="flex justify-end gap-3">
									<SecondaryButton :disabled="donorSaving" @click="creatingDonor = false">Cancelar</SecondaryButton>
									<PrimaryButton :disabled="donorSaving" @click="saveNewDonor(record)">Salvar doador</PrimaryButton>
								</div>
							</div>
						</Modal>
						<button
							v-if="selectedDriver"
							type="button"
							@click="useDriverAsDonor(record)"
							:disabled="donorSaving"
							class="ri_linkbutton"
						>
							Este motorista também é o doador
						</button>

						<template v-if="record.person_id && record.person?.is_organization">
							<div class="ri_fieldset">
								<div class="ri_fieldlabel">Pessoa de contato para esta entrega:</div>
								<SearchSelect
									ref="contactSelect"
									v-model="record.contact_person_id"
									:optionsource="`/json/people?parent_person_id=${record.person_id}`"
									display="full_name"
									:searchfields="['first_name', 'last_name']"
									placeholder="Buscar contatos desta organização..."
									:allowcreate="true"
									:enabled="editing"
									@create="startNewContact"
								/>
							</div>
							<Modal :show="creatingContact" @close="creatingContact = false" max-width="sm">
								<div class="p-6 space-y-4">
									<h2 class="text-lg font-semibold">Novo contato</h2>
									<div>
										<InputLabel value="Nome" />
										<TextInput v-model="newContact.first_name" class="mt-1 block w-full" autofocus />
									</div>
									<div>
										<InputLabel value="Sobrenome" />
										<TextInput v-model="newContact.last_name" class="mt-1 block w-full" />
									</div>
									<div>
										<InputLabel value="Telefone" />
										<TextInput v-model="newContact.phone" class="mt-1 block w-full" />
									</div>
									<p v-if="contactError" class="text-sm text-red-700">{{ contactError }}</p>
									<div class="flex justify-end gap-3">
										<SecondaryButton :disabled="contactSaving" @click="creatingContact = false">Cancelar</SecondaryButton>
										<PrimaryButton :disabled="contactSaving" @click="saveNewContact(record)">Salvar contato</PrimaryButton>
									</div>
								</div>
							</Modal>
						</template>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel"></div>
							<div class="ri_formcontrol">
								<label class="recv_checkbox">
									<input type="checkbox" v-model="record.donor_identification_pending" :disabled="!editing" />
									Doador desconhecido
								</label>
							</div>
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Endereço de retirada desta doação:</div>
							<TextInput v-model="record.source_address" placeholder="Endereço" :enabled="editing" />
						</div>
						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Cidade / estado / CEP:</div>
							<div class="ri_formcontrol recv_addressline">
								<TextInput v-model="record.source_city" placeholder="Cidade" :enabled="editing" />
								<TextInput v-model="record.source_state" placeholder="Estado" :enabled="editing" />
								<TextInput v-model="record.source_zip" placeholder="CEP" :enabled="editing" />
							</div>
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Resumo dos itens:</div>
							<TextArea v-model="record.manifest" :enabled="editing" />
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Candidato à triagem rápida?</div>
							<ChipSelect v-model="record.quick_sort_candidate" :options="yesNoOptions" :enabled="editing" />
						</div>

						<div class="ri_fieldset">
							<div class="ri_fieldlabel">Observações:</div>
							<TextArea v-model="record.comments" :enabled="editing" />
						</div>
					</div>

					<template v-if="record.id && (record.pallets || []).length">
						<h3 class="recv_subhead">Etiquetas do recebimento</h3>
						<div class="recv_tablewrap">
							<table class="ri_datatable" border="1">
								<thead>
									<tr><th>Etiqueta</th><th>Tipo</th><th>Status</th><th></th></tr>
								</thead>
								<tbody>
									<tr v-for="pallet in record.pallets" :key="pallet.id">
										<td class="recv_mono">{{ pallet.tag }}</td>
										<td>{{ pallet.container_type }}</td>
										<td>{{ pallet.status }}</td>
										<td><PrintMenu document-key="pallet-label" :media="$page.props.printing.palletLabelMedia" variant="link" label="Reimprimir"
											:params="{ id: pallet.id }" :download-href="'/report/pallet/' + pallet.id" /></td>
									</tr>
								</tbody>
							</table>
						</div>
						<PrintMenu document-key="donation-pallet-labels" :media="$page.props.printing.palletLabelMedia" variant="form"
							:label="'Reimprimir todas as etiquetas (' + (record.pallets || []).length + ')'"
							:params="{ id: record.id }" :download-href="'/report/pallets/donation/' + record.id" />
					</template>

					<template v-if="record.id && record.photo_path">
						<h3 class="recv_subhead">Foto da carga</h3>
						<a :href="$withWarehouse(photoUrl(record))" target="_blank">
							<img :src="photoUrl(record)" alt="Foto da carga" class="recv_photo" />
						</a>
					</template>

					<template v-if="record.id && record.is_close_out_candidate">
						<h3 class="recv_subhead">Conclusão do dia</h3>
						<button @click="closeOut(record)" class="ri_defaultbutton">Concluir</button>
						<p v-if="closeOutError" class="ri_error">{{ closeOutError }}</p>
					</template>
				</template>

				<template v-else-if="wizardStep === 'photo'">
					<h3 class="recv_subhead">Foto da carga</h3>
					<div class="recv_photobuttons">
						<input
							ref="cameraInput"
							type="file"
							accept="image/*"
							capture="environment"
							class="recv_hidden_input"
							@change="onPhotoSelected($event, record)"
						/>
						<input
							ref="fileInput"
							type="file"
							accept="image/*"
							class="recv_hidden_input"
							@change="onPhotoSelected($event, record)"
						/>
						<button type="button" class="ri_formbutton" v-if="canTakePhoto" @click="takePhoto">📷 Take Photo</button>
						<button type="button" class="ri_formbutton" @click="$refs.fileInput.click()">Escolher arquivo</button>
					</div>
					<WebcamCapture
						v-if="webcamOpen"
						@captured="(file) => onPhotoCaptured(file, record)"
						@close="webcamOpen = false"
					/>
					<a v-if="record.photo_path" :href="$withWarehouse(photoUrl(record))" target="_blank">
						<img :src="photoUrl(record)" alt="Foto da carga" class="recv_photo" />
					</a>
					<p v-if="photoError" class="ri_error">{{ photoError }}</p>
				</template>

				<template v-else>
					<h3 class="recv_subhead">Imprimir etiquetas</h3>
					<p class="recv_hint">
						{{ record.container_count ? `${(record.pallets || []).length} of ${record.container_count} labeled.` : `${(record.pallets || []).length} labeled so far.` }}
					</p>
					<div class="recv_palletline">
						<input
							v-model.number="palletCount"
							type="number"
							min="1"
							placeholder="Qtd."
							class="recv_pallet_count"
						/>
						<ChipSelect v-model="palletContainerType" :options="containerTypeOptions" />
						<button @click="createPallets(record)" :disabled="palletSaving" class="ri_formbutton">
							Adicionar etiqueta(s)
						</button>
					</div>
					<p v-if="palletError" class="ri_error">{{ palletError }}</p>

					<p class="recv_hint">Os recipientes já têm etiquetas impressas? Informe ou leia os números usados:</p>
					<div class="recv_palletline">
						<TextInput
							v-model="attachTagsInput"
							placeholder="R00000042 R00000043 ..."
							class="ri_forminput"
							@keyup.enter="attachPreprintedPallets(record)"
						/>
						<button @click="attachPreprintedPallets(record)" :disabled="attachSaving" class="ri_formbutton">
							Vincular etiqueta(s)
						</button>
					</div>
					<p v-if="attachError" class="ri_error">{{ attachError }}</p>
					<p v-for="f in attachFailed" :key="f.tag" class="ri_error">{{ f.tag }}: {{ f.reason }}</p>

					<template v-if="(record.pallets || []).length">
						<div class="recv_tablewrap">
							<table class="ri_datatable" border="1">
								<thead>
									<tr><th>Etiqueta</th><th>Tipo</th><th>Status</th><th></th></tr>
								</thead>
								<tbody>
									<tr v-for="pallet in record.pallets" :key="pallet.id">
										<td class="recv_mono">{{ pallet.tag }}</td>
										<td>{{ pallet.container_type }}</td>
										<td>{{ pallet.status }}</td>
										<td><PrintMenu document-key="pallet-label" :media="$page.props.printing.palletLabelMedia" variant="link" label="Etiqueta"
											:params="{ id: pallet.id }" :download-href="'/report/pallet/' + pallet.id" /></td>
									</tr>
								</tbody>
							</table>
						</div>
						<PrintMenu document-key="donation-pallet-labels" :media="$page.props.printing.palletLabelMedia" variant="form"
							:label="'Imprimir todas as etiquetas (' + (record.pallets || []).length + ')'"
							:params="{ id: record.id }" :download-href="'/report/pallets/donation/' + record.id" />
					</template>
					<p v-else>Nenhuma etiqueta criada para este recebimento ainda.</p>
				</template>
			</template>

			<template #actions="{ editing, record, confirmingDelete, save, cancel, delete: doDelete, keepRecord }">
				<div class="ri_formactions" v-if="!editing">
					<button @click="cancel()" class="ri_defaultbutton">Voltar à lista</button>
				</div>
				<template v-else-if="wizardStep === 'details'">
					<div class="ri_formactions recv_actionsrow">
						<div class="recv_cancelgroup">
							<button
								@click="handleCancelClick(cancel)"
								class="ri_formbutton"
								:class="{ recv_cancel_confirming: confirmingCancel }"
							>
								{{ confirmingCancel ? 'Confirmar cancelamento — as alterações serão perdidas' : 'Cancelar' }}
							</button>
							<button v-if="confirmingCancel" @click="confirmingCancel = false" class="ri_linkbutton">
								Continuar editando
							</button>
						</div>
						<button @click="goToPhoto(record, save)" class="ri_defaultbutton">Continuar</button>
					</div>
					<div class="ri_formactions recv_dangerrow" v-if="record.id">
						<a
							href="#"
							@click.prevent="doDelete()"
							class="ri_deletebutton"
							:class="{ ri_confirming: confirmingDelete }"
						>
							{{ confirmingDelete ? 'Confirmar exclusão do recebimento — não pode ser desfeita' : 'Excluir recebimento' }}
						</a>
						<button v-if="confirmingDelete" @click="keepRecord()" class="ri_linkbutton">Manter registro</button>
					</div>
				</template>
				<div class="ri_formactions recv_actionsrow" v-else-if="wizardStep === 'photo'">
					<button @click="wizardStep = 'details'" class="ri_formbutton">Voltar aos detalhes</button>
					<button @click="finishPhotoStep(record, cancel)" class="ri_defaultbutton">
						{{ photoStepContinueLabel(record) }}
					</button>
				</div>
				<div class="ri_formactions recv_actionsrow" v-else>
					<button @click="wizardStep = 'details'" class="ri_formbutton">Voltar aos detalhes</button>
					<button @click="finishWizard(cancel)" class="ri_defaultbutton">Concluir</button>
				</div>
			</template>
		</RIForm>
	</AuthenticatedLayout>
</template>

<script>
import axios from 'axios';
import { invalidateOptions } from '@/Components/SearchSelect.vue';
import { webcamSupported } from '@/Components/WebcamCapture.vue';

export default {
	data() {
		return {
			wizardStep: 'details', // 'details' | 'photo' | 'labels' — see @select/@new on <RIForm> and goToPhoto()/finishPhotoStep()/finishWizard() below

			creatingDonor: false,
			newDonor: { first_name: '', last_name: '', organization: '' },
			donorSaving: false,
			donorError: null,

			selectedDriver: null,
			creatingDriver: false,
			newDriver: { name: '', phone: '', carrier: '' },
			driverSaving: false,
			driverError: null,

			creatingContact: false,
			newContact: { first_name: '', last_name: '', phone: '' },
			contactSaving: false,
			contactError: null,

			photoError: null,
			photoStamp: 0, // bumped on each upload so a retaken photo isn't served from the browser cache
			webcamOpen: false,

			confirmingCancel: false,
			arrivalMode: null, // 'pallet' | 'other' | null — derived from record.container_types on open, see onOpenRecord()

			palletCount: null,
			palletContainerType: 'pallet',
			palletSaving: false,
			palletError: null,

			preprintOpen: false,
			preprintCount: null,
			preprintContainerType: 'pallet',
			preprintSaving: false,
			preprintError: null,

			attachTagsInput: '',
			attachSaving: false,
			attachError: null,
			attachFailed: [],

			closeOutError: null,

			donorSearch: '',
			flaggedOnly: false,

			// Matching a phoned-in DonationOffer at intake — see
			// onOfferSelected()/onOpenRecord() and store()'s donation_offer_id.
			// pendingOffers is a glance-and-pick list (not a search box) —
			// dock staff usually don't know the offer's donor name well
			// enough to search for it, but can recognize it from a
			// short list of what's currently expected.
			matchedOfferId: null,
			pendingOffers: [],
		};
	},
	computed: {
		canTakePhoto() {
			return this.isTouchDevice() || webcamSupported();
		},
		receivingFilter() {
			const query = this.donorSearch.trim().toLowerCase();
			const flaggedOnly = this.flaggedOnly;
			const donorName = this.donorName;
			return (record) => {
				if (flaggedOnly && !record.donor_identification_pending) return false;
				if (query && !donorName(record).toLowerCase().includes(query)) return false;
				return true;
			};
		},
	},
	methods: {
		donorName(record) {
			return record.person?.full_name || '(no donor recorded)';
		},
		// Parses a "YYYY-MM-DD" string as a local calendar date, not UTC —
		// see the identical helper in DonationOffers.vue.
		formatLocalDate(value) {
			if (!value) return '';
			const [y, m, d] = value.split('-').map(Number);
			return new Date(y, m - 1, d).toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
		},
		formatEtaRange(start, end) {
			if (!start) return '';
			const startLabel = this.formatLocalDate(start);
			if (!end || end === start) return startLabel;
			return `${startLabel} – ${this.formatLocalDate(end)}`;
		},
		async loadPendingOffers() {
			try {
				const response = await axios.get('/json/donation-offers?status=pending');
				this.pendingOffers = response.data.records || [];
			} catch (error) {
				this.pendingOffers = [];
			}
		},
		// Clicking a card selects it (pre-filling donor/contact/manifest
		// fields); clicking the already-selected card clears the match
		// without undoing whatever it already pre-filled — matching the
		// wrong offer is rare enough that a full undo isn't worth the
		// complexity, and the pre-filled fields stay manually editable.
		toggleOfferMatch(record, offer) {
			if (this.matchedOfferId === offer.id) {
				this.matchedOfferId = null;
				record.donation_offer_id = null;
				return;
			}
			this.matchedOfferId = offer.id;
			this.onOfferSelected(record, offer);
		},

		// ---------- wizard navigation ----------
		onOpenRecord(record) {
			this.wizardStep = 'details';
			this.creatingDonor = false;
			this.creatingDriver = false;
			this.creatingContact = false;
			this.donorError = null;
			this.driverError = null;
			this.contactError = null;
			this.photoError = null;
			this.confirmingCancel = false;
			this.selectedDriver = record?.driver || null;
			if (record) record.container_type_counts = record.container_type_counts || {};
			const types = record?.container_types || [];
			this.arrivalMode = types.includes('pallet') ? 'pallet' : types.length ? 'other' : null;
			this.matchedOfferId = record?.donation_offer_id || null;
			if (!record?.id) this.loadPendingOffers();
		},
		// Selecting a pending offer pre-fills the donor/contact/manifest fields
		// it already has and stashes the offer id for store() to pick up —
		// matching at intake instead of requiring a separate trip to the
		// offers worklist afterward.
		onOfferSelected(record, offer) {
			if (!offer) return;
			record.donation_offer_id = offer.id;
			record.person_id = offer.person_id;
			record.person = offer.person;
			record.contact_person_id = offer.contact_person_id;
			if (offer.description) {
				record.comments = record.comments ? `${record.comments}\n\n${offer.description}` : offer.description;
			}
		},
		// Pallets is exclusive; switching to it replaces any box/bag/tote/loose
		// selection, and switching to Other clears a prior "pallet" choice
		// while keeping whatever box/bag/tote/loose was already picked.
		setArrivalMode(record, mode) {
			this.arrivalMode = mode;
			record.container_types = mode === 'pallet' ? ['pallet'] : (record.container_types || []).filter((t) => t !== 'pallet');
		},
		// container_count is the derived total the rest of the page reads
		// (list column, label progress) — computed from whichever
		// per-type counts are currently relevant, not entered directly.
		computeContainerCount(record) {
			const counts = record.container_type_counts || {};
			const types = this.arrivalMode === 'pallet' ? ['pallet'] : (record.container_types || []).filter((t) => t !== 'loose');
			return types.reduce((sum, t) => sum + (Number(counts[t]) || 0), 0);
		},
		// Two-step inline confirm (no window.confirm), matching the Delete
		// pattern — the first click just arms it.
		handleCancelClick(cancel) {
			if (!this.confirmingCancel) {
				this.confirmingCancel = true;
				return;
			}
			this.confirmingCancel = false;
			cancel();
		},
		remainingContainers(record) {
			const target = Number(record.container_count) || 0;
			const described = (record.pallets || []).length;
			return Math.max(target - described, 0);
		},
		async goToPhoto(record, save) {
			// Every category gets a chance to attach a photo; only a donation
			// goes on afterward to auto-generate pallet/container labels.
			record.container_count = this.computeContainerCount(record);
			const ok = await save(true);
			if (!ok) return;
			this.wizardStep = 'photo';
		},
		photoStepContinueLabel(record) {
			if (record.photo_path) return 'Continue';
			return record.category === 'donation' ? 'Proceed to Labels' : 'Skip';
		},
		async finishPhotoStep(record, cancel) {
			if (record.category === 'donation') {
				this.wizardStep = 'labels';
				await this.autoCreateLabels(record);
			} else {
				this.finishWizard(cancel);
			}
		},
		finishWizard(cancel) {
			cancel();
			this.$refs.riform?.fetchRecords();
		},
		// Quantities were already declared on the Details screen (Number of
		// Pallets/Boxes/Bags/Totes) — this creates exactly enough labels to
		// cover them in one shot instead of re-entering the same numbers by
		// hand. Idempotent: re-entering this step only tops up whatever's
		// still short, it never double-creates.
		async autoCreateLabels(record) {
			this.palletError = null;
			this.palletSaving = true;
			try {
				const declared = record.container_type_counts || {};
				const types = this.arrivalMode === 'pallet' ? ['pallet'] : (record.container_types || []).filter((t) => t !== 'loose');
				for (const type of types) {
					const wanted = Number(declared[type]) || 0;
					const already = (record.pallets || []).filter((p) => p.container_type === type).length;
					const remaining = wanted - already;
					if (remaining > 0) {
						const response = await axios.post('/json/receiving/' + record.id + '/pallets', {
							count: remaining,
							container_type: type,
						});
						record.pallets = [...(record.pallets || []), ...response.data.records];
					}
				}
				this.palletCount = this.remainingContainers(record) || null;
				this.$refs.riform?.fetchRecords();
			} catch (error) {
				this.palletError = error.response?.data?.message || 'Não foi possível criar as etiquetas.';
			} finally {
				this.palletSaving = false;
			}
		},

		// ---------- donor quick-add ----------
		startNewDonor(name) {
			this.creatingDonor = true;
			this.donorError = null;
			const parts = (name || '').trim().split(/\s+/);
			this.newDonor = {
				first_name: parts[0] || '',
				last_name: parts.slice(1).join(' '),
				organization: parts.length <= 1 ? (name || '') : '',
			};
		},
		async saveNewDonor(record) {
			this.donorError = null;
			const hasName = this.newDonor.first_name.trim() && this.newDonor.last_name.trim();
			const hasOrg = (this.newDonor.organization || '').trim();
			if (!hasName && !hasOrg) {
				// A donation often arrives with less than a full contact — an
				// organization alone (no known contact person) is fine.
				this.donorError = 'Informe o nome e o sobrenome ou uma organização.';
				return;
			}
			this.donorSaving = true;
			try {
				const response = await axios.post('/json/people', this.newDonor);
				invalidateOptions('/json/people');
				await this.$refs.donorSelect?.refresh(response.data.record.id);
				record.person_id = response.data.record.id;
				record.person = response.data.record;
				this.creatingDonor = false;
			} catch (error) {
				this.donorError = error.response?.data?.message || 'Não foi possível salvar o doador.';
			} finally {
				this.donorSaving = false;
			}
		},

		// ---------- driver quick-add / lookup ----------
		// A driver's carrier auto-fills the shipment's Carrier field (and
		// vice versa when quick-adding a driver) so it's never typed twice.
		onDriverSelected(record, driver) {
			this.selectedDriver = driver;
			if (driver?.carrier) record.carrier = driver.carrier;
		},
		startNewDriver(record, name) {
			this.creatingDriver = true;
			this.driverError = null;
			this.newDriver = { name: name || '', phone: '', carrier: record.carrier || '' };
		},
		async saveNewDriver(record) {
			this.driverError = null;
			if (!this.newDriver.name.trim()) {
				this.driverError = 'Informe o nome do motorista.';
				return;
			}
			this.driverSaving = true;
			try {
				const response = await axios.post('/json/drivers', this.newDriver);
				invalidateOptions('/json/drivers');
				await this.$refs.driverSelect?.refresh(response.data.record.id);
				record.driver_id = response.data.record.id;
				this.selectedDriver = response.data.record;
				if (response.data.record.carrier) record.carrier = response.data.record.carrier;
				this.creatingDriver = false;
			} catch (error) {
				this.driverError = error.response?.data?.message || 'Não foi possível salvar o motorista.';
			} finally {
				this.driverSaving = false;
			}
		},
		// Some people bring their own donations — link the driver's Person
		// record (creating one, quick-add style, if this driver has never
		// been linked before) and select them as the donor.
		async useDriverAsDonor(record) {
			if (!this.selectedDriver) return;
			this.donorError = null;
			this.donorSaving = true;
			try {
				let personId = this.selectedDriver.person_id;
				if (!personId) {
					const parts = this.selectedDriver.name.trim().split(/\s+/);
					const response = await axios.post('/json/people', {
						first_name: parts[0] || '',
						last_name: parts.slice(1).join(' '),
						phone: this.selectedDriver.phone || '',
					});
					personId = response.data.record.id;
					invalidateOptions('/json/people');
					await axios.put('/json/drivers/' + this.selectedDriver.id, { ...this.selectedDriver, person_id: personId });
					this.selectedDriver.person_id = personId;
					invalidateOptions('/json/drivers');
				}
				await this.$refs.donorSelect?.refresh(personId);
				record.person_id = personId;
			} catch (error) {
				this.donorError = error.response?.data?.message || 'Não foi possível vincular o motorista como doador.';
			} finally {
				this.donorSaving = false;
			}
		},

		// ---------- shipment contact quick-add ----------
		startNewContact(name) {
			this.creatingContact = true;
			this.contactError = null;
			const parts = (name || '').trim().split(/\s+/);
			this.newContact = { first_name: parts[0] || '', last_name: parts.slice(1).join(' '), phone: '' };
		},
		async saveNewContact(record) {
			this.contactError = null;
			if (!this.newContact.first_name.trim() && !this.newContact.last_name.trim()) {
				this.contactError = 'Informe o nome do contato.';
				return;
			}
			this.contactSaving = true;
			try {
				const response = await axios.post('/json/people', { ...this.newContact, parent_person_id: record.person_id });
				invalidateOptions(`/json/people?parent_person_id=${record.person_id}`);
				await this.$refs.contactSelect?.refresh(response.data.record.id);
				record.contact_person_id = response.data.record.id;
				this.creatingContact = false;
			} catch (error) {
				this.contactError = error.response?.data?.message || 'Não foi possível salvar o contato.';
			} finally {
				this.contactSaving = false;
			}
		},

		// ---------- photo of the shipment ----------
		// Phones/tablets (coarse pointer) get the native camera via <input capture>;
		// desktops get the in-app webcam preview, or no Take Photo button at all
		// when there's no camera API (plain HTTP, old browser).
		isTouchDevice() {
			return window.matchMedia?.('(pointer: coarse)').matches ?? false;
		},
		takePhoto() {
			if (this.isTouchDevice()) this.$refs.cameraInput.click();
			else this.webcamOpen = true;
		},
		async onPhotoCaptured(file, record) {
			this.webcamOpen = false;
			await this.uploadPhoto(file, record);
		},
		async onPhotoSelected(event, record) {
			const file = event.target.files?.[0];
			// Reset so picking the same file again (or retaking a photo) still
			// fires 'change' next time.
			event.target.value = '';
			if (!file) return;
			await this.uploadPhoto(file, record);
		},
		photoUrl(record) {
			return `/json/receiving/${record.id}/photo?v=${this.photoStamp}`;
		},
		async uploadPhoto(file, record) {
			this.photoError = null;
			const formData = new FormData();
			formData.append('photo', file);
			try {
				const response = await axios.post('/json/receiving/' + record.id + '/photo', formData);
				record.photo_path = response.data.record.photo_path;
				this.photoStamp++;
			} catch (error) {
				this.photoError = error.response?.data?.message || 'Não foi possível enviar a foto.';
			}
		},

		// ---------- pallets for a donation ----------
		async createPallets(record) {
			if (!this.palletCount || this.palletCount < 1) {
				this.palletError = 'Informe quantos paletes deseja adicionar.';
				return;
			}
			this.palletSaving = true;
			this.palletError = null;
			try {
				const response = await axios.post('/json/receiving/' + record.id + '/pallets', {
					count: this.palletCount,
					container_type: this.palletContainerType,
				});
				record.pallets = [...(record.pallets || []), ...response.data.records];
				const remaining = this.remainingContainers(record);
				this.palletCount = remaining || null;
				this.$refs.riform?.fetchRecords();
			} catch (error) {
				this.palletError = error.response?.data?.message || 'Não foi possível criar os paletes.';
			} finally {
				this.palletSaving = false;
			}
		},
		// ---------- pre-printed labels (not yet tied to a donation) ----------
		// Run by PrintMenu on any choice (download or a printer): creates the
		// batch of blank R pallets, then hands back their ids to render.
		async preparePreprint() {
			if (!this.preprintCount || this.preprintCount < 1) {
				this.preprintError = 'Informe quantas etiquetas deseja imprimir.';
				return null;
			}
			this.preprintSaving = true;
			this.preprintError = null;
			try {
				const response = await axios.post('/json/receiving/preprint-labels', {
					count: this.preprintCount,
					container_type: this.preprintContainerType,
				});
				const ids = response.data.records.map((p) => p.id);
				return { params: { ids }, downloadHref: '/report/pallets/preprint?ids=' + ids.join(',') };
			} catch (error) {
				this.preprintError = error.response?.data?.message || 'Não foi possível criar as etiquetas.';
				return null;
			} finally {
				this.preprintSaving = false;
			}
		},
		onPreprintDone() {
			this.preprintOpen = false;
			this.preprintCount = null;
		},
		// Splits on commas/whitespace/newlines so typed or scanned entry
		// (one per Enter, via a keyboard-wedge scanner) both work.
		async attachPreprintedPallets(record) {
			const tags = this.attachTagsInput.split(/[\s,]+/).map((t) => t.trim()).filter(Boolean);
			if (!tags.length) {
				this.attachError = 'Informe ou leia pelo menos o número de uma etiqueta.';
				return;
			}
			this.attachSaving = true;
			this.attachError = null;
			this.attachFailed = [];
			try {
				const response = await axios.post('/json/receiving/' + record.id + '/attach-pallets', { tags });
				record.pallets = [...(record.pallets || []), ...response.data.records];
				this.attachFailed = response.data.failed || [];
				this.attachTagsInput = '';
				const remaining = this.remainingContainers(record);
				this.palletCount = remaining || null;
				this.$refs.riform?.fetchRecords();
			} catch (error) {
				this.attachError = error.response?.data?.message || 'Não foi possível vincular as etiquetas.';
			} finally {
				this.attachSaving = false;
			}
		},

		// ---------- daily close-out ----------
		async closeOut(record) {
			this.closeOutError = null;
			try {
				const response = await axios.post('/json/receiving/' + record.id + '/close-out');
				Object.assign(record, response.data.record);
				this.$refs.riform?.fetchRecords();
			} catch (error) {
				this.closeOutError = error.response?.data?.message || 'Não foi possível concluir o recebimento dessa doação.';
			}
		},

		// ---------- matching a phoned-in offer, hand-off from DonationOffers.vue ----------
		waitForTemplates() {
			return new Promise((resolve) => {
				const check = () => {
					if (this.$refs.riform?.templates?._default) resolve();
					else setTimeout(check, 50);
				};
				check();
			});
		},
	},
	async mounted() {
		const offerId = new URLSearchParams(window.location.search).get('match_offer_id');
		if (!offerId) return;
		try {
			const response = await axios.get('/json/donation-offers?status=pending');
			const offer = (response.data.records || []).find((o) => String(o.id) === String(offerId));
			if (!offer) return;
			await this.waitForTemplates();
			this.$refs.riform.newRecord();
			this.onOfferSelected(this.$refs.riform.record, offer);
			this.matchedOfferId = offer.id;
		} catch (error) {
			// Offer no longer available/pending — just leave a fresh blank form.
		}
	},
};
</script>

<style scoped>
.recv_subhead {
	margin-top: 1.5em;
}
.recv_hint {
	color: #666;
	font-size: 0.9em;
}
.recv_pallet_count {
	width: 5em;
}
.recv_palletline {
	display: flex;
	align-items: center;
	gap: 0.5em;
	flex-wrap: wrap;
	margin: 0.5em 0;
}
.recv_addressline {
	display: flex;
	gap: 0.5em;
	flex-wrap: wrap;
	margin: 0 0 0.75em;
}
.recv_addressline > * {
	flex: 1;
	min-width: 6em;
}
.recv_photo {
	display: block;
	max-width: 100%;
	max-height: 24rem;
	margin-top: 0.75em;
	border-radius: 4px;
}

.recv_photobuttons {
	display: flex;
	gap: 0.5em;
	flex-wrap: wrap;
	margin: 0.5em 0;
}
.recv_hidden_input {
	display: none;
}
.recv_tablewrap {
	overflow-x: auto;
	margin: 0.5em 0;
}
.recv_mono {
	font-family: monospace;
}
.recv_badge {
	display: inline-block;
	margin-left: 0.5em;
	padding: 0.1em 0.5em;
	font-size: 0.8em;
	background: #fef3c7;
	color: #92400e;
	border-radius: 3px;
}
.recv_badge_id {
	background: #fee2e2;
	color: #991b1b;
}
.recv_standing {
	margin: 6px 0 0 0;
	padding: 6px 10px;
	border-radius: 4px;
	font-size: 0.9rem;
}
.recv_standing_watch {
	background: #fef3c7;
	color: #92400e;
}
.recv_standing_decline {
	background: #fee2e2;
	color: #991b1b;
}
.recv_checkbox {
	display: flex;
	align-items: center;
	gap: 0.4em;
	font-weight: normal;
}
.recv_offerlist {
	display: flex;
	flex-direction: column;
	gap: 0.4em;
	max-width: 32em;
}
.recv_offercard {
	border: 1px solid #e5e7eb;
	border-radius: 4px;
	padding: 0.5em 0.75em;
	cursor: pointer;
	background: #fff;
}
.recv_offercard:hover {
	border-color: #9ca3af;
}
.recv_offercard_selected {
	border-color: #2563eb;
	background: #eff6ff;
}
.recv_offerdonor {
	font-weight: 600;
}
.recv_offerdesc {
	font-size: 0.9em;
	color: #444;
}
.recv_offereta {
	font-size: 0.85em;
	color: #666;
}
.recv_search {
	min-width: 220px;
}
.recv_helplink_form {
	text-align: right;
	margin-bottom: 0.75rem;
}

/* Cancel (left) and Next (right), pushed to opposite ends and given real
   room between them so a mis-tap on a tablet doesn't hit the wrong one.
   Delete lives in its own row below, further separating the two "lose your
   work" actions from each other. */
.recv_actionsrow {
	justify-content: space-between;
}
.recv_cancelgroup {
	display: flex;
	align-items: center;
	gap: 0.75rem;
}
.recv_cancel_confirming {
	background-color: #b45309;
}
.recv_dangerrow {
	justify-content: flex-end;
}
</style>
