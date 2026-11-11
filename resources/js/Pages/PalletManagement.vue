<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import HelpLink from '@/Components/HelpLink.vue';
import { Head } from '@inertiajs/vue3';
import TextInput from '@/Components/TextInput.vue';
import ComboBox from '@/Components/ComboBox.vue';
import RIForm from '@/Components/RIForm.vue';
import RISubform from '@/Components/RISubform.vue';
import PrintMenu from '@/Components/PrintMenu.vue';
import { t } from '@/i18n';

defineProps({
    breadcrumb: {
        type: Array,
    },
});

const kindOptions = [
	{ id: 'R', name: 'Receiving' },
	{ id: 'W', name: 'Warehouse' },
	{ id: 'S', name: 'Shipping' },
	{ id: 'H', name: 'Hold' },
	{ id: 'Q', name: 'Quarantine' },
];

// Mirrors App\Support\PalletKind::LIFECYCLES (+ 'missing'); the server still validates.
const statusesByKind = {
	R: ['received', t('Commons.text.sorting'), 'empty'],
	W: ['sealed', t('Commons.text.open'), 'empty'],
	S: ['building', t('Commons.text.ready'), 'shipped'],
	H: ['filling', t('Commons.text.ready'), 'collected'],
	Q: ['held', 'released', 'condemned'],
};
const statusOptions = (kind) =>
	[...(statusesByKind[kind] || []), 'missing'].map((s) => ({ id: s, name: s.charAt(0).toUpperCase() + s.slice(1) }));

const containerTypeOptions = [
	{ id: 'pallet', name: 'Pallet' },
	{ id: 'gaylord', name: t('Commons.text.gaylord') },
	{ id: 'box', name: t('Commons.text.box') },
	{ id: 'bag', name: 'Bag' },
	{ id: 'tote', name: t('Commons.text.tote') },
];
</script>

<template>
  <Head title="Pallet Management" />
  <AuthenticatedLayout :breadcrumb="breadcrumb">
    <RIForm
      title="Pallet Management"
      datasource="/json/pallets"
	  :precreate="false"
	  >
      <template #listactions>
        <HelpLink guide="inventory-movement">{{ $t('Pages.text.inventory_movement_guide', {}) }}</HelpLink>
      </template>

      <template #thead>
		<th>{{ $t('Commons.text.tag', {}) }}</th>
        <th>{{ $t('Commons.text.kind', {}) }}</th>
        <th>{{ $t('Commons.text.packed_date', {}) }}</th>
        <th>{{ $t('Commons.text.location', {}) }}</th>
        <th>{{ $t('Commons.button.status', {}) }}</th>
      </template>

      <template #tbody="{ record, index }">
		<td><span style="font-weight: bold; font-size: 14pt;"> {{ record.kind }}{{ record.id.toString().padStart(8, "0") }}</span></td>
        <td>{{ record.kind }}</td>
        <td>{{ record.datepacked }}</td>
        <td v-if="record.location">{{ record.location.code }}</td>
        <td v-else>{{ $t('Commons.text.unknown', {}) }}</td>
        <td>{{ record.status }}</td>
      </template>

      <template #default="{ record, editing, templates }">

		<div class="ri_formtable">
		  <div class="ri_fieldset" v-if="record.id">
		    <div class="ri_fieldlabel"> {{ $t('Commons.text.pallet_tag', {}) }} </div>
		    <span style="font-weight: bold; font-size: 14pt;"> {{ record.kind }}{{ record.id.toString().padStart(8, "0") }}</span>
		  </div>
		</div>
		  <div class="ri_fieldset" v-if="record.id">
			<div class="ri_fieldlabel">  </div>
			<p>
			<PrintMenu document-key="pallet-label" :media="$page.props.printing.palletLabelMedia" :label="$t('Pages.label.print_pallet_label')"
				:params="{ id: record.id }" :download-href="'/report/pallet/' + record.id" />
			</p>
		  </div>
		  <div class="ri_formtable">
		    <div class="ri_fieldset">
		      <div class="ri_fieldlabel">{{ $t('Commons.text.kind_2', {}) }}</div>
			  <!-- Fixed forever once labeled (new-label-per-trip rule) -->
			  <ComboBox
			  	v-model:keyValue="record.kind"
			  	:options="kindOptions"
			  	:enabled="editing && !record.id"
			  />
		    </div>

		    <div class="ri_fieldset">
		      <div class="ri_fieldlabel">{{ $t('Commons.text.date_packed_2', {}) }}</div>
		      <TextInput
		        id="datepacked"
		        type="date"
		        v-model="record.datepacked"
		        required
		        autofocus
		        :enabled="editing"
		      />
		    </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.location_2', {}) }}</div>
            <ComboBox
              v-model:keyValue="record.location_id"
              v-model:updates="record.location"
              optionsource="/json/locations"
              :enabled="editing"
			  display="code"
            />
          </div>

          <div class="ri_fieldset">
            <div class="ri_fieldlabel">{{ $t('Commons.text.status_3', {}) }}</div>
            <ComboBox
              v-model:keyValue="record.status"
              :options="statusOptions(record.kind)"
              :enabled="editing"
            />
          </div>

		  <div class="ri_fieldset">
			<div class="ri_fieldlabel">{{ $t('Commons.text.container_type', {}) }}</div>
			<ComboBox
			  v-model:keyValue="record.container_type"
			  :options="containerTypeOptions"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.kind === 'R'">
			<div class="ri_fieldlabel">{{ $t('Commons.text.donor_2', {}) }}</div>
			<ComboBox
			  v-model:keyValue="record.donor_person_id"
			  v-model:updates="record.donor"
			  optionsource="/json/people"
			  display="last_name"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.kind === 'H'">
			<div class="ri_fieldlabel">{{ $t('Commons.text.destination', {}) }}</div>
			<ComboBox
			  v-model:keyValue="record.destination_person_id"
			  v-model:updates="record.destination"
			  optionsource="/json/people"
			  display="last_name"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.kind === 'W'">
			<div class="ri_fieldlabel">{{ $t('Commons.text.earliest_expiry', {}) }}</div>
			<TextInput
			  type="date"
			  v-model="record.earliest_expiry"
			  :enabled="editing"
			/>
		  </div>

		  <div class="ri_fieldset" v-if="record.condition">
			<div class="ri_fieldlabel">{{ $t('Commons.text.condition', {}) }}</div>
			<ComboBox
			  v-model:keyValue="record.condition"
			  :options="[{ id: $t('Commons.text.pending'), name: $t('Commons.text.pending_qc') }, { id: 'good', name: $t('Commons.text.good') }, { id: 'condemned', name: $t('Commons.text.condemned') }]"
			  :enabled="editing"
			/>
		  </div>
        </div>

        <RISubform
          :title="$t('Pages.title.pallet_status_history')"
          v-model:records="record.statuses"
          :template="[]"
          :enabled="false">

          <template #thead>
            <th>{{ $t('Commons.text.date', {}) }}</th>
            <th>{{ $t('Commons.text.location', {}) }}</th>
            <th>{{ $t('Commons.button.status', {}) }}</th>
			<th>{{ $t('Commons.text.notes', {}) }}</th>
          </template>

          <template #tbody="{ subrecord, index }">
            <td>{{ subrecord.created_at }}</td>
            <td>{{ subrecord.location ? subrecord.location.code : '' }}</td>
            <td>{{ subrecord.status }}</td>
			<td>{{ subrecord.notes }}</td>
          </template>

          <template #default="{ subrecord, index }">
            <td>
            </td>
          </template>
        </RISubform>
      </template>
    </RIForm>
  </AuthenticatedLayout>
</template>
